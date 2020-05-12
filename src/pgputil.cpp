#include "pgputil.h"

#include "gpgprocess.h"
#include "passphrasedlg.h"
#include "showtextdlg.h"

#include <QDialog>
#include <QMessageBox>
#include <QStringList>
#include <QtCore>

PGPUtil *PGPUtil::instance_ = nullptr;

PGPUtil::PGPUtil() :
    qcaEventHandler_(nullptr), qcaKeyStoreManager_(new QCA::KeyStoreManager), passphraseDlg_(nullptr),
    cache_no_pgp_(false)
{
    qcaEventHandler_ = new QCA::EventHandler(this);

    connect(qcaEventHandler_, SIGNAL(eventReady(int, const QCA::Event &)), SLOT(handleEvent(int, const QCA::Event &)));
    qcaEventHandler_->start();

    reloadKeyStores();
    connect(qcaKeyStoreManager_, &QCA::KeyStoreManager::keyStoreAvailable, this, &PGPUtil::keyStoreAvailable);

    connect(QCoreApplication::instance(), SIGNAL(aboutToQuit()), SLOT(deleteLater()));
}

PGPUtil::~PGPUtil()
{
    clearKeyStores();

    if (qcaKeyStoreManager_) {
        qcaKeyStoreManager_->disconnect();
        delete qcaKeyStoreManager_;
        qcaKeyStoreManager_ = nullptr;
    }
}

void PGPUtil::clearKeyStores()
{
    for (QCA::KeyStore *ks : keystores_) {
        delete ks;
    }
    keystores_.clear();
}

PGPUtil &PGPUtil::instance()
{
    if (!instance_) {
        instance_ = new PGPUtil();
    }
    return *instance_;
}

void PGPUtil::reloadKeyStores()
{
    clearKeyStores();
    for (const QString &k : qcaKeyStoreManager_->keyStores()) {
        keyStoreAvailable(k);
    }
}

void PGPUtil::handleEvent(int id, const QCA::Event &event)
{
    if (event.type() == QCA::Event::Password) {
        QCA::KeyStoreEntry entry = event.keyStoreEntry();
        if (!entry.isNull() && passphrases_.contains(entry.id())) {
            qcaEventHandler_->submitPassword(id, QCA::SecureArray(passphrases_[entry.id()].toUtf8()));
        } else if (passphraseDlg_) {
            EventItem i;
            i.id    = id;
            i.event = event;
            pendingEvents_.push_back(i);
        } else {
            promptPassphrase(id, event);
        }
    }
}

void PGPUtil::promptPassphrase(int id, const QCA::Event &event)
{
    QString name;
    currentEventId_ = id;

    QCA::KeyStoreEntry entry = event.keyStoreEntry();
    if (!entry.isNull()) {
        name            = entry.name();
        currentEntryId_ = entry.id();
    } else {
        name            = event.keyStoreInfo().name();
        currentEntryId_ = QString();
    }

    if (!passphraseDlg_) {
        passphraseDlg_ = new PassphraseDlg();
        connect(passphraseDlg_, SIGNAL(finished(int)), SLOT(passphraseDone(int)));
    }
    passphraseDlg_->promptPassphrase(name);
    passphraseDlg_->show();
}

void PGPUtil::passphraseDone(int result)
{
    // Process the result
    if (result == QDialog::Accepted) {
        QString passphrase = passphraseDlg_->getPassphrase();
        if (!currentEntryId_.isEmpty()) {
            passphrases_[currentEntryId_] = passphrase;
            if (passphraseDlg_->rememberPassPhrase()) {
                emit newPassPhase(currentEntryId_, passphrase);
            }
        }
        qcaEventHandler_->submitPassword(currentEventId_, passphrase.toUtf8());
    } else if (result == QDialog::Rejected) {
        qcaEventHandler_->reject(currentEventId_);
    } else {
        qWarning() << "PGPUtil: Unexpected passphrase dialog result";
    }

    // Process the queue
    if (!pendingEvents_.isEmpty()) {
        EventItem eventItem;
        bool      handlePendingEvent = false;
        while (!pendingEvents_.isEmpty() && !handlePendingEvent) {
            eventItem                = pendingEvents_.takeFirst();
            QCA::KeyStoreEntry entry = eventItem.event.keyStoreEntry();
            if (!entry.isNull() && passphrases_.contains(entry.id())) {
                qcaEventHandler_->submitPassword(eventItem.id, QCA::SecureArray(passphrases_[entry.id()].toUtf8()));
            } else {
                handlePendingEvent = true;
            }
        }
        if (handlePendingEvent) {
            promptPassphrase(eventItem.id, eventItem.event);
            return;
        }
    }
    passphraseDlg_->deleteLater();
    passphraseDlg_ = nullptr;
}

bool PGPUtil::pgpAvailable()
{
    bool have_openpgp = false;
    if (!cache_no_pgp_) {
        have_openpgp = QCA::isSupported("openpgp");
        if (!have_openpgp)
            cache_no_pgp_ = true;
    }
    return (have_openpgp && keystores_.count() > 0);
}

void PGPUtil::clearPGPAvailableCache() { cache_no_pgp_ = false; }

QString PGPUtil::stripHeaderFooter(const QString &str)
{
    QString s;
    if (str.isEmpty()) {
        qWarning("pgputil.cpp: Empty PGP message");
        return "";
    }
    if (str.at(0) != '-')
        return str;
    QStringList                lines = str.split('\n');
    QStringList::ConstIterator it    = lines.begin();
    // skip the first line
    ++it;
    if (it == lines.end())
        return str;

    // skip the header
    for (; it != lines.end(); ++it) {
        if ((*it).isEmpty())
            break;
    }
    if (it == lines.end())
        return str;
    ++it;
    if (it == lines.end())
        return str;

    bool first = true;
    for (; it != lines.end(); ++it) {
        if ((*it).at(0) == '-')
            break;
        if (!first)
            s += '\n';
        s += (*it);
        first = false;
    }

    return s;
}

QString PGPUtil::addHeaderFooter(const QString &str, int type)
{
    QString stype;
    if (type == 0)
        stype = "MESSAGE";
    else
        stype = "SIGNATURE";

    QString s;
    s += QString("-----BEGIN PGP %1-----\n").arg(stype);
    s += "Version: PGP\n";
    s += '\n';
    s += str + '\n';
    s += QString("-----END PGP %1-----\n").arg(stype);
    return s;
}

QCA::KeyStoreEntry PGPUtil::getSecretKeyStoreEntry(const QString &keyID)
{
    for (QCA::KeyStore *ks : keystores_) {
        if (ks->type() == QCA::KeyStore::PGPKeyring && ks->holdsIdentities()) {
            for (QCA::KeyStoreEntry ke : ks->entryList()) {
                if (ke.type() == QCA::KeyStoreEntry::TypePGPSecretKey && ke.pgpSecretKey().keyId() == keyID) {
                    return ke;
                }
            }
        }
    }
    return QCA::KeyStoreEntry();
}

QCA::KeyStoreEntry PGPUtil::getPublicKeyStoreEntry(const QString &keyID)
{
    for (QCA::KeyStore *ks : keystores_) {
        if (ks->type() == QCA::KeyStore::PGPKeyring && ks->holdsIdentities()) {
            for (QCA::KeyStoreEntry ke : ks->entryList()) {
                if ((ke.type() == QCA::KeyStoreEntry::TypePGPSecretKey
                     || ke.type() == QCA::KeyStoreEntry::TypePGPPublicKey)
                    && ke.pgpPublicKey().keyId() == keyID) {
                    return ke;
                }
            }
        }
    }
    return QCA::KeyStoreEntry();
}

QString PGPUtil::messageErrorString(QCA::SecureMessage::Error e)
{
    QString msg;
    switch (e) {
    case QCA::SecureMessage::ErrorPassphrase:
        msg = QObject::tr("Invalid passphrase");
        break;
    case QCA::SecureMessage::ErrorFormat:
        msg = QObject::tr("Invalid input format");
        break;
    case QCA::SecureMessage::ErrorSignerExpired:
        msg = QObject::tr("Signing key expired");
        break;
    case QCA::SecureMessage::ErrorSignerInvalid:
        msg = QObject::tr("Invalid key");
        break;
    case QCA::SecureMessage::ErrorEncryptExpired:
        msg = QObject::tr("Encrypting key expired");
        break;
    case QCA::SecureMessage::ErrorEncryptUntrusted:
        msg = QObject::tr("Encrypting key is untrusted");
        break;
    case QCA::SecureMessage::ErrorEncryptInvalid:
        msg = QObject::tr("Encrypting key is invalid");
        break;
    case QCA::SecureMessage::ErrorNeedCard:
        msg = QObject::tr("PGP card is missing");
        break;
    default:
        msg = QObject::tr("Unknown error");
    }
    return msg;
}

bool PGPUtil::equals(QCA::PGPKey k1, QCA::PGPKey k2)
{
    if (k1.isNull()) {
        return k2.isNull();
    } else if (k2.isNull()) {
        return false;
    } else {
        return k1.keyId() == k2.keyId();
    }
}

void PGPUtil::removePassphrase(const QString &id) { passphrases_.remove(id); }

void PGPUtil::addPassphrase(const QString &id, const QString &pass) { passphrases_.insert(id, pass); }

QString PGPUtil::getKeyOwnerName(const QString &key)
{
    if (key.isEmpty())
        return QString();

    const QStringList &&arguments = { "--list-public-keys", "--with-colons", "--fixed-list-mode", "0x" + key };

    GpgProcess gpg;
    gpg.start(arguments);
    gpg.waitForFinished();

    if (!gpg.success())
        return QString();

    const QString &&rawData = QString::fromUtf8(gpg.readAllStandardOutput());
    if (rawData.isEmpty())
        return QString();

    QString name;
    const QStringList &&stringsList = rawData.split("\n");
    for (const QString &line : stringsList) {
        const QString &&type = line.section(':', 0, 0);
        if (type == "uid") {
            name = line.section(':', 9, 9); // Name
            break;
        }
    }
    return name;
}

QString PGPUtil::getPublicKeyData(const QString &key)
{
    if (key.isEmpty())
        return QString();

    const QStringList &&arguments = { "--armor", "--export", "0x" + key };

    GpgProcess gpg;
    gpg.start(arguments);
    gpg.waitForFinished();

    if (!gpg.success())
        return QString();

#ifdef Q_OS_WIN
    QString keyData = QString::fromUtf8(gpg.readAllStandardOutput());
    keyData.replace("\r","");
#else
    const QString &&keyData = QString::fromUtf8(gpg.readAllStandardOutput());
#endif
    return keyData;
}

QString PGPUtil::getFingerprint(const QString &key)
{
    const QStringList &&arguments = { "--with-colons", "--fingerprint", "0x" + key };

    GpgProcess gpg;
    gpg.start(arguments);
    gpg.waitForFinished();

    QString             fingerprint;
    const QString &&    out   = QString::fromUtf8(gpg.readAllStandardOutput());
    const QStringList &&lines = out.split("\n");
    for (const QString &line : lines) {
        const QString &&type = line.section(':', 0, 0);
        if (type == "fpr") {
            fingerprint = line.section(':', 9, 9);
            break;
        }
    }

    if (fingerprint.size() == 40) {
        for (int k = fingerprint.size() - 4; k >= 3; k -= 4) {
            fingerprint.insert(k, ' ');
        }
        fingerprint.insert(24, ' ');
        return fingerprint;
    }

    return QString();
}

QString PGPUtil::chooseKey(PGPKeyDlg::Type type, const QString &key, const QString &title)
{
    PGPKeyDlg d(PGPKeyDlg::Public, key, nullptr);
    d.setWindowTitle(title);
    if (d.exec() == QDialog::Accepted) {
        return d.keyId();
    }
    return QString();
}

void PGPUtil::keyStoreAvailable(const QString &k)
{
    if (!qcaKeyStoreManager_)
        return;
    QCA::KeyStore *ks = new QCA::KeyStore(k, qcaKeyStoreManager_);
    connect(ks, SIGNAL(updated()), SIGNAL(pgpKeysUpdated()));
    keystores_ += ks;
}

void PGPUtil::showDiagnosticText(const QString &event, const QString &diagnostic)
{
    while (1) {
        QMessageBox  msgbox(QMessageBox::Critical, tr("Error"), event, QMessageBox::Ok, nullptr);
        QPushButton *diag = msgbox.addButton(tr("Diagnostics"), QMessageBox::HelpRole);
        msgbox.exec();
        if (msgbox.clickedButton() == diag) {
            ShowTextDlg *w = new ShowTextDlg(diagnostic, true, false, nullptr);
            w->setWindowTitle(tr("OpenPGP Diagnostic Text"));
            w->resize(560, 240);
            w->exec();

            continue;
        } else {
            break;
        }
    }
}

void PGPUtil::showDiagnosticText(QCA::SecureMessage::Error error, const QString &diagnostic)
{
    showDiagnosticText(tr("There was an error trying to send the message encrypted.\nReason: %1.")
                           .arg(PGPUtil::instance().messageErrorString(error)),
                       diagnostic);
}
