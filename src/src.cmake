add_definitions(
    -DFILETRANSFER
    -DGROUPCHAT
    -DWHITEBOARDING
    -DNEWCONTACTLIST
    -DHAVE_PGPUTIL
    -DPSI_PLUGINS
    -DUSE_PEP
    -DQT_STATICPLUGIN
    )

if(UNIX AND NOT APPLE)
    add_definitions(
        -DUSE_DBUS
        )
endif()

#if(APPLE)
#    add_definitions(-DHAVE_GROWL)
#endif()

include_directories(.)

list(APPEND FORMS
    about.ui
    accountadd.ui
    accountmanage.ui
    accountmodify.ui
    accountreg.ui
    accountremove.ui
    activity.ui
    addurl.ui
    adduser.ui
    ahcformdlg.ui
    ahcommanddlg.ui
    bookmarkmanage.ui
    captchadlg.ui
    changepw.ui
    chatdlg.ui
    disco.ui
    filetrans.ui
    geolocation.ui
    groupchatdlg.ui
    groupchattopicdlg.ui
    groupchattopicaddlang.ui
    history.ui
    homedirmigration.ui
    infodlg.ui
    info.ui
    mood.ui
    mucconfig.ui
    mucjoin.ui
    mucreasonseditor.ui
    optioneditor.ui
    passphrase.ui
    pgpkey.ui
    profilemanage.ui
    profilenew.ui
    profileopen.ui
    proxy.ui
    rosteravatarframe.ui
    search.ui
    tip.ui
    voicecall.ui
    xmlconsole.ui
    )

list(APPEND HEADERS
    aboutdlg.h
    abstracttreemodel.h
    accountadddlg.h
    accountlabel.h
    accountmanagedlg.h
    accountmodifydlg.h
    accountregdlg.h
    accountscombobox.h
    accountstatusmenu.h
    actionlist.h
    activecontactsmenu.h
    activeprofiles.h
    activitydlg.h
    adduserdlg.h
    ahcformdlg.h
    ahcommanddlg.h
    alertable.h
    alerticon.h
    alertmanager.h
    avatars.h
    bobfilecache.h
    bookmarkmanagedlg.h
    bookmarkmanager.h
    bosskey.h
    bytearrayreply.h
    captchadlg.h
    changepwdlg.h
    chatdlg.h
    chateditproxy.h
    chatsplitter.h
    coloropt.h
    contactlistaccountmenu.h
    contactlistdragmodel.h
    contactlistdragview.h
    contactlistgroupmenu.h
    contactlistgroupmenu_p.h
    contactlistitemmenu.h
    contactlistmodel.h
    contactlistmodel_p.h
    contactlistmodelselection.h
    contactlistproxymodel.h
    contactlistview.h
    contactlistviewdelegate.h
    contactlistviewdelegate_p.h
    contactupdatesmanager.h
    discodlg.h
    edbflatfile.h
    eventdb.h
    eventdlg.h
    filecache.h
    filetransdlg.h
    fileutil.h
    gcuserview.h
    geolocationdlg.h
    globaleventqueue.h
    globalstatusmenu.h
    groupchatdlg.h
    groupchattopicdlg.h
    groupmenu.h
    historycontactlistmodel.h
    historydlg.h
    homedirmigration.h
    hoverabletreeview.h
    htmltextcontroller.h
    httpauthmanager.h
    infodlg.h
    invitetogroupchatmenu.h
    main.h
    mainwin.h
    mainwin_p.h
    mcmdmanager.h
    miniclient.h
    mooddlg.h
    msgmle.h
    mucaffiliationsmodel.h
    mucaffiliationsproxymodel.h
    mucaffiliationsview.h
    mucconfigdlg.h
    mucjoindlg.h
    mucmanager.h
    mucreasonseditor.h
    networkaccessmanager.h
    passdialog.h
    passphrasedlg.h
    pepmanager.h
    pgpkeydlg.h
    pgptransaction.h
    pgputil.h
    pluginhost.h
    pluginmanager.h
    profiledlg.h
    proxy.h
    psiaccount.h
    psiapplication.h
    psicapsregsitry.h
    psichatdlg.h
    psicli.h
    psicon.h
    psicontact.h
    psicontactlist.h
    psicontactlistview.h
    psicontactmenu.h
    psicontactmenu_p.h
    psievent.h
    psifilteredcontactlistview.h
    psiiconset.h
    psioptions.h
    psioptionseditor.h
    psipopup.h
    psirosterwidget.h
    psithememanager.h
    psithememodel.h
    psithemeprovider.h
    psitoolbar.h
    psitrayicon.h
    registrationdlg.h
    resourcemenu.h
    rosteravatarframe.h
    rosteritemexchangetask.h
    searchdlg.h
    serverinfomanager.h
    serverlistquerier.h
    showtextdlg.h
    statuscombobox.h
    statusdlg.h
    statusmenu.h
    tabcompletion.h
    tasklist.h
    tipdlg.h
    translationmanager.h
    vcardfactory.h
    vcardphotodlg.h
    voicecalldlg.h
    voicecaller.h
    xdata_widget.h
    xmlconsole.h
    )

# Source files
list(APPEND SOURCES
    accountmanagedlg.cpp
    actionlist.cpp
    activecontactsmenu.cpp
    ahcommanddlg.cpp
    ahcservermanager.cpp
    alerticon.cpp
    avatars.cpp
    contactlistaccountmenu.cpp
    discodlg.cpp
    eventdlg.cpp
    filetransdlg.cpp
    gcuserview.cpp
    groupchatdlg.cpp
    htmltextcontroller.cpp
    httpauthmanager.cpp
    mainwin_p.cpp
    msgmle.cpp
    proxy.cpp
    psiaccount.cpp
    psiactionlist.cpp
    psichatdlg.cpp
    psicon.cpp
    psicontactlistview.cpp
    psievent.cpp
    psioptionseditor.cpp
    psipopup.cpp
    psirosterwidget.cpp
    registrationdlg.cpp
    searchdlg.cpp
    xdata_widget.cpp
    )

if(UNIX AND NOT APPLE)
    list(APPEND SOURCES
        dbus.cpp
        )

    list(APPEND PLAIN_SOURCES
        activeprofiles_dbus.cpp
        psidbusnotifier.cpp
        )

    list(APPEND HEADERS
        psidbusnotifier.h
        )

    list(APPEND PLAIN_HEADERS
        dbus.h
        )
    list(APPEND PLAIN_SOURCES
        x11windowsystem.cpp
        )
    list(APPEND PLAIN_HEADERS
        x11windowsystem.h
        )
elseif(APPLE)
    list(APPEND PLAIN_SOURCES
        activeprofiles_stub.cpp
        )
#    list(APPEND SOURCES
#        psigrowlnotifier.cpp
#        )
#
#    list(APPEND HEADERS
#        psigrowlnotifier.h
#        )
elseif(WIN32)
    list(APPEND PLAIN_SOURCES
        activeprofiles_win.cpp
        )
endif()

list(APPEND PLAIN_HEADERS
    abstracttreeitem.h
    activity.h
    activitycatalog.h
    ahcexecutetask.h
    ahcommand.h
    ahcommandserver.h
    ahcservermanager.h
    applicationinfo.h
    chatview.h
    chatviewcommon.h
    common.h
    conferencebookmark.h
    contactlistitem.h
    debug.h
    desktoputil.h
    dummystream.h
    geolocation.h
    jidutil.h
    lastactivitytask.h
    mcmdcompletion.h
    messageview.h
    minicmd.h
    mood.h
    moodcatalog.h
    pixmaputil.h
    popupmanager.h
    profiles.h
    psiactionlist.h
    psiactions.h
    psihttpauthrequest.h
    psipopupinterface.h
    psiselfcontact.h
    pubsubsubscription.h
    rc.h
    rtparse.h
    shortcutmanager.h
    statuspreset.h
    systeminfo.h
    textutil.h
    theme.h
    theme_p.h
    urlbookmark.h
    userlist.h
    varlist.h
    )

list(APPEND PLAIN_SOURCES
    aboutdlg.cpp
    abstracttreeitem.cpp
    abstracttreemodel.cpp
    accountadddlg.cpp
    accountlabel.cpp
    accountmodifydlg.cpp
    accountregdlg.cpp
    accountscombobox.cpp
    accountstatusmenu.cpp
    activeprofiles.cpp
    activity.cpp
    activitycatalog.cpp
    activitydlg.cpp
    adduserdlg.cpp
    ahcexecutetask.cpp
    ahcformdlg.cpp
    ahcommand.cpp
    ahcommandserver.cpp
    alertable.cpp
    alertmanager.cpp
    applicationinfo.cpp
    bobfilecache.cpp
    bookmarkmanagedlg.cpp
    bookmarkmanager.cpp
    bosskey.cpp
    bytearrayreply.cpp
    captchadlg.cpp
    changepwdlg.cpp
    chatdlg.cpp
    chateditproxy.cpp
    chatsplitter.cpp
    chatviewcommon.cpp
    coloropt.cpp
    common.cpp
    conferencebookmark.cpp
    contactlistdragmodel.cpp
    contactlistdragview.cpp
    contactlistgroupmenu.cpp
    contactlistitem.cpp
    contactlistitemmenu.cpp
    contactlistmodel.cpp
    contactlistmodelselection.cpp
    contactlistproxymodel.cpp
    contactlistview.cpp
    contactlistviewdelegate.cpp
    contactupdatesmanager.cpp
    debug.cpp
    desktoputil.cpp
    dummystream.cpp
    edbflatfile.cpp
    eventdb.cpp
    filecache.cpp
    fileutil.cpp
    fileutil.cpp
    geolocation.cpp
    geolocationdlg.cpp
    globaleventqueue.cpp
    globalstatusmenu.cpp
    groupchattopicdlg.cpp
    groupmenu.cpp
    historycontactlistmodel.cpp
    historydlg.cpp
    homedirmigration.cpp
    hoverabletreeview.cpp
    infodlg.cpp
    infodlg.cpp
    invitetogroupchatmenu.cpp
    jidutil.cpp
    lastactivitytask.cpp
    main.cpp
    mainwin.cpp
    mcmdcompletion.cpp
    mcmdmanager.cpp
    mcmdsimplesite.cpp
    messageview.cpp
    miniclient.cpp
    mood.cpp
    moodcatalog.cpp
    mooddlg.cpp
    mucaffiliationsmodel.cpp
    mucaffiliationsproxymodel.cpp
    mucaffiliationsview.cpp
    mucconfigdlg.cpp
    mucjoindlg.cpp
    mucmanager.cpp
    mucreasonseditor.cpp
    networkaccessmanager.cpp
    passdialog.cpp
    passphrasedlg.cpp
    pepmanager.cpp
    pgpkeydlg.cpp
    pgptransaction.cpp
    pgputil.cpp
    pixmaputil.cpp
    pluginhost.cpp
    pluginmanager.cpp
    popupmanager.cpp
    profiledlg.cpp
    psicapsregsitry.cpp
    psicontactmenu.cpp
    psi_profiles.cpp
    psiapplication.cpp
    psicontact.cpp
    psicontactlist.cpp
    psifilteredcontactlistview.cpp
    psiiconset.cpp
    psioptions.cpp
    psipopupinterface.cpp
    psithememanager.cpp
    psithememodel.cpp
    psithemeprovider.cpp
    psitoolbar.cpp
    psitrayicon.cpp
    pubsubsubscription.cpp
    rc.cpp
    resourcemenu.cpp
    rosteravatarframe.cpp
    rosteritemexchangetask.cpp
    rtparse.cpp
    serverinfomanager.cpp
    serverlistquerier.cpp
    shortcutmanager.cpp
    showtextdlg.cpp
    statuscombobox.cpp
    statusdlg.cpp
    statusmenu.cpp
    statuspreset.cpp
    systeminfo.cpp
    tabcompletion.cpp
    textutil.cpp
    theme.cpp
    theme_p.cpp
    tipdlg.cpp
    translationmanager.cpp
    urlbookmark.cpp
    userlist.cpp
    varlist.cpp
    vcardfactory.cpp
    vcardphotodlg.cpp
    voicecalldlg.cpp
    xmlconsole.cpp
    )

if(ENABLE_WEBKIT)
    if(USE_WEBENGINE)
        list(APPEND PLAIN_SOURCES
            themeserver.cpp
        )
        list(APPEND HEADERS
            themeserver.h
        )
    endif()
    list(APPEND HEADERS
        chatview_webkit.h
        webview.h
        chatviewtheme.h
        chatviewtheme_p.h
        chatviewthemeprovider.h
        chatviewthemeprovider_priv.h
        )
    list(APPEND PLAIN_HEADERS
        jsutil.h
        )
    list(APPEND SOURCES
        chatview_webkit.cpp
        )
    list(APPEND PLAIN_SOURCES
        webview.cpp
        jsutil.cpp
        chatviewtheme.cpp
        chatviewthemeprovider.cpp
        chatviewthemeprovider_priv.cpp
        )
else()
    list(APPEND HEADERS
        chatview_te.h
        )
    list(APPEND SOURCES
        chatview_te.cpp
        )
endif()

if(ENABLE_SQL)
    list(APPEND HEADERS
        edbsqlite.h
        historyimp.h
        )
    list(APPEND PLAIN_SOURCES
        edbsqlite.cpp
        historyimp.cpp
        )
endif()

if(IS_PSIPLUS)
    list(APPEND FORMS
        sendbuttontemplateseditor.ui
    )
    list(APPEND HEADERS
        sendbuttonmenu.h
    )
    list(APPEND PLAIN_SOURCES
        sendbuttonmenu.cpp
    )
endif()
