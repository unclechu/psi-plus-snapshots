#ifndef OPT_THEME_H
#define OPT_THEME_H

#include "optionstab.h"
#include <QPointer>

class QModelIndex;
class QWidget;
class PsiThemeModel;
class PsiThemeProvider;
class QDialog;

class OptionsTabAppearanceThemes : public MetaOptionsTab
{
	Q_OBJECT
public:
	OptionsTabAppearanceThemes(QObject *parent);
};

class OptionsTabAppearanceTheme : public OptionsTab
{
	Q_OBJECT
public:
	OptionsTabAppearanceTheme(QObject *parent, PsiThemeProvider *provider_);
	~OptionsTabAppearanceTheme();

	bool stretchable() const { return true; }
	QWidget *widget();
	void applyOptions();
	void restoreOptions();

protected slots:
	void modelRowsInserted(const QModelIndex &parent, int first, int last);
	void itemChanged(const QModelIndex &current, const QModelIndex &previous);
	void showThemeScreenshot();
	void radioToggled(bool toggled);

private:
	QString getThemeId(const QString &objName) const;
	void uncheckAll(const QString &name_);

private:
	QWidget *w;
	PsiThemeModel *themesModel;
	PsiThemeProvider *provider;
	QPointer<QDialog> screenshotDialog;
};

#endif
