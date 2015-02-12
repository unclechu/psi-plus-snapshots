#include "opt_plugins.h"
#include "common.h"
#include "iconwidget.h"
#include "pluginmanager.h"
#include "psioptions.h"
#include "psiiconset.h"

#include <QWhatsThis>
#include <QToolButton>

#include "ui_opt_plugins.h"

class OptPluginsUI : public QWidget, public Ui::OptPlugins
{
public:
	OptPluginsUI() : QWidget() { setupUi(this); }
};

//----------------------------------------------------------------------------
// OptionsTabPlugins
//----------------------------------------------------------------------------

OptionsTabPlugins::OptionsTabPlugins(QObject *parent)
	: OptionsTab(parent, "plugins", "", tr("Plugins"), tr("Options for Psi plugins"), "psi/plugins")
	, w(0)
{
}

OptionsTabPlugins::~OptionsTabPlugins()
{
	if(infoDialog)
		delete(infoDialog);
	if(settingsDialog)
		delete(settingsDialog);
}

QWidget *OptionsTabPlugins::widget()
{
	if ( w )
		return 0;

	w = new OptPluginsUI();
	OptPluginsUI *d = (OptPluginsUI *)w;

	listPlugins();
	connect(d->tw_Plugins, SIGNAL(itemChanged(QTreeWidgetItem*,int)), this, SLOT(itemChanged(QTreeWidgetItem*,int)));

	return w;
}

void OptionsTabPlugins::applyOptions()
{
}

void OptionsTabPlugins::restoreOptions()
{
}

bool OptionsTabPlugins::stretchable() const
{
	return true;
}


void OptionsTabPlugins::listPlugins()
{
	if ( !w )
		return;

	OptPluginsUI *d = (OptPluginsUI *)w;

	d->tw_Plugins->clear();

	PluginManager *pm=PluginManager::instance();

	QStringList plugins = pm->availablePlugins();
	plugins.sort();
	const QSize buttonSize = QSize(21,21);
	foreach (const QString& plugin, plugins){
		QIcon icon = pm->icon(plugin);
		bool enabled = pm->isEnabled(plugin);
		const QString path = pm->pathToPlugin(plugin);
		QString toolTip = tr("Plugin Path:\n%1").arg(path);
		Qt::CheckState state = enabled ? Qt::Checked : Qt::Unchecked;
		QTreeWidgetItem *item = new QTreeWidgetItem(d->tw_Plugins, QTreeWidgetItem::Type);
		item->setFlags(item->flags() | Qt::ItemIsUserCheckable);
		item->setText(C_NAME, plugin);
		item->setText(C_VERSION, pm->version(plugin));
		item->setTextAlignment(C_VERSION, Qt::AlignHCenter);
		item->setToolTip(C_NAME, toolTip);
		item->setCheckState(C_NAME, state);
		if (!enabled) {
			icon = QIcon(icon.pixmap(icon.availableSizes().at(0), QIcon::Disabled));
		}
		item->setIcon(C_NAME,icon);
		QString shortName = PluginManager::instance()->shortName(plugin);

		QToolButton *aboutbutton = new QToolButton(d->tw_Plugins);
		aboutbutton->setIcon(QIcon(IconsetFactory::iconPixmap("psi/info")));
		aboutbutton->resize(buttonSize);
		aboutbutton->setObjectName("ab_" + shortName);
		aboutbutton->setToolTip(tr("Show information about plugin"));
		connect(aboutbutton, SIGNAL(clicked()), this, SLOT(showPluginInfo()));
		d->tw_Plugins->setItemWidget(item, C_ABOUT, aboutbutton);

		QToolButton *settsbutton = new QToolButton(d->tw_Plugins);
		settsbutton->setIcon(QIcon(IconsetFactory::iconPixmap("psi/options")));
		settsbutton->resize(buttonSize);
		settsbutton->setObjectName("sb_" + shortName);
		settsbutton->setToolTip(tr("Open plugin settings dialog"));
		connect(settsbutton, SIGNAL(clicked()), this, SLOT(settingsClicked()));
		settsbutton->setEnabled(enabled);
		d->tw_Plugins->setItemWidget(item, C_SETTS, settsbutton);
	}
	if (d->tw_Plugins->topLevelItemCount() > 0) {
		d->tw_Plugins->header()->setResizeMode(C_NAME, QHeaderView::Stretch);
		d->tw_Plugins->resizeColumnToContents(C_VERSION);
		d->tw_Plugins->resizeColumnToContents(C_ABOUT);
		d->tw_Plugins->resizeColumnToContents(C_SETTS);
	}
}

void OptionsTabPlugins::itemChanged(QTreeWidgetItem *item, int column)
{
	Q_UNUSED(column);
	if ( !w )
		return;
	OptPluginsUI *d = (OptPluginsUI *)w;
	bool enabled = item->checkState(C_NAME) == Qt::Checked;
	d->tw_Plugins->setCurrentItem(item);

	PluginManager *pm = PluginManager::instance();
	QString name = item->text(C_NAME);
	QString option=QString("%1.%2")
		.arg(PluginManager::loadOptionPrefix)
		.arg(pm->shortName(name));
	PsiOptions::instance()->setOption(option, enabled);

	d->tw_Plugins->blockSignals(true); //Block signalls to change item elements
	d->tw_Plugins->itemWidget(item, C_SETTS)->setEnabled(enabled);
	QIcon icon = pm->icon(name);
	if (!enabled) {
		icon = QIcon(icon.pixmap(icon.availableSizes().at(0), QIcon::Disabled));
	}
	item->setIcon(C_NAME, icon);
	d->tw_Plugins->blockSignals(false); //Release signals blocking
}

void OptionsTabPlugins::showPluginInfo()
{
	if ( !w )
		return;
	OptPluginsUI *d = (OptPluginsUI *)w;
	QToolButton *btn = qobject_cast<QToolButton*>(sender());
	const QPoint coords = QPoint(btn->x(),btn->y());
	d->tw_Plugins->setCurrentItem(d->tw_Plugins->itemAt(coords));
	if ( d->tw_Plugins->selectedItems().size() > 0 ) {
		if(infoDialog)
			delete(infoDialog);

		infoDialog = new QDialog();
		ui_.setupUi(infoDialog);
		QString name = d->tw_Plugins->currentItem()->text(C_NAME);
		infoDialog->setWindowTitle(infoDialog->windowTitle() + " " + name);
		infoDialog->setWindowIcon(QIcon(IconsetFactory::iconPixmap("psi/logo_128")));
		ui_.te_info->setText(PluginManager::instance()->pluginInfo(name));
		infoDialog->setAttribute(Qt::WA_DeleteOnClose);
		infoDialog->show();
	}
}

void OptionsTabPlugins::settingsClicked()
{
	if ( !w )
		return;

	OptPluginsUI *d = (OptPluginsUI *)w;
	QToolButton *btn = qobject_cast<QToolButton*>(sender());
	const QPoint coords = QPoint(btn->x(),btn->y());
	d->tw_Plugins->setCurrentItem(d->tw_Plugins->itemAt(coords));
	if ( d->tw_Plugins->selectedItems().size() > 0 ) {
		QString pluginName = d->tw_Plugins->currentItem()->text(C_NAME);
		QWidget* pluginOptions = PluginManager::instance()->optionsWidget( pluginName );
		PluginManager::instance()->restoreOptions( pluginName );
		pluginOptions->setParent(d);

		if(settingsDialog)
			delete(settingsDialog);

		settingsDialog = new QDialog();
		settsUi_.setupUi(settingsDialog);
		settingsDialog->setWindowIcon(QIcon(IconsetFactory::iconPixmap("psi/logo_128")));
		settingsDialog->setWindowTitle(tr("Settings of %1").arg(pluginName));
		settsUi_.verticalLayout->insertWidget(0, pluginOptions);
		settsUi_.buttonBox->addButton(QDialogButtonBox::Ok);
		settsUi_.buttonBox->addButton(QDialogButtonBox::Apply);
		settsUi_.buttonBox->addButton(QDialogButtonBox::Cancel);
		connect(settsUi_.buttonBox, SIGNAL(accepted()), this, SLOT(onSettingsOk()));
		connect(settsUi_.buttonBox, SIGNAL(clicked(QAbstractButton*)), this, SLOT(onSettingsClicked(QAbstractButton*)));
		settingsDialog->adjustSize();
		settingsDialog->setAttribute(Qt::WA_DeleteOnClose);
		settingsDialog->show();
	}
}

void OptionsTabPlugins::onSettingsOk()
{
	if ( !w )
		return;
	OptPluginsUI *d = (OptPluginsUI *)w;
	if (d->tw_Plugins->currentItem()->isSelected()) {
		PluginManager::instance()->applyOptions( d->tw_Plugins->currentItem()->text(C_NAME) );
	}
}

void OptionsTabPlugins::onSettingsClicked(QAbstractButton *button)
{
	if (settsUi_.buttonBox->buttonRole(button) == QDialogButtonBox::ApplyRole) {
		onSettingsOk();
	}
}
