cmake_minimum_required(VERSION 3.1.0)

if(WIN32)
    if(MSVC)
        set(BUILD_ARCH "win64" CACHE STRING "CPU architecture win32/win64")
        set(SDK_PATH "e:/build/msvc2017-root" CACHE STRING "Path to SDK")
    else()
        set(BUILD_ARCH "i386" CACHE STRING "CPU architecture i386/x86_64")
        set(SDK_PATH "e:/build/psisdk" CACHE STRING "Path to SDK")
    endif()
    #autodetect 64bit architecture
    if(CMAKE_SIZEOF_VOID_P MATCHES "8")
        if(MSVC)
            set(BUILD_ARCH "win64")
        else()
            set(BUILD_ARCH "x86_64")
        endif()
        if(DEV_MODE)
            set(GST_SDK $ENV{GSTREAMER_1_0_ROOT_x86_64})
        endif()
    else()
        if(MSVC)
            set(BUILD_ARCH "win32")
        else()
            set(BUILD_ARCH "i386")
        endif()
        if(DEV_MODE)
            set(GST_SDK $ENV{GSTREAMER_1_0_ROOT_x86})
        endif()
    endif()

    message(STATUS "Detecting build architecture: ${BUILD_ARCH} detected")
    if(EXISTS "${SDK_PATH}")
        if(MSVC)
            set(QCA_DIR "${SDK_PATH}/" CACHE STRING "Path to QCA")
            set(IDN_ROOT "${SDK_PATH}/" CACHE STRING "Path to IDN library")
            set(HUNSPELL_ROOT "${SDK_PATH}/" CACHE STRING "Path to hunspell library")
            if(ENABLE_PLUGINS)
                set(LIBGCRYPT_ROOT "${SDK_PATH}/" CACHE STRING "Path to libgcrypt library")
                set(LIBGPGERROR_ROOT "${SDK_PATH}/" CACHE STRING "Path to libgpg-error library")
                set(LIBOTR_ROOT "${SDK_PATH}/" CACHE STRING "Path to libotr library")
                set(LIBTIDY_ROOT "${SDK_PATH}/" CACHE STRING "Path to libtidy library")
                set(SIGNAL_PROTOCOL_C_ROOT "${SDK_PATH}/" CACHE STRING "Path to libsignal-protocol-c library")
            endif()
            set(ZLIB_ROOT "${SDK_PATH}/" CACHE STRING "Path to zlib")
            set(OPENSSL_ROOT_DIR "${SDK_PATH}/" CACHE STRING "Path to openssl library")
            set(Qt5Keychain_DIR "${SDK_PATH}/lib/cmake/Qt5Keychain" CACHE STRING "Path to Qt5Keychain cmake files")
        else()
            set(QCA_DIR "${SDK_PATH}/qca/" CACHE STRING "Path to QCA")
            set(IDN_ROOT "${SDK_PATH}/libidn/" CACHE STRING "Path to IDN library")
            set(HUNSPELL_ROOT "${SDK_PATH}/hunspell/" CACHE STRING "Path to hunspell library")
            if(ENABLE_PLUGINS)
                set(LIBGCRYPT_ROOT "${SDK_PATH}/libgcrypt/" CACHE STRING "Path to libgcrypt library")
                set(LIBGPGERROR_ROOT "${SDK_PATH}/libgpg-error/" CACHE STRING "Path to libgpg-error library")
                set(LIBOTR_ROOT "${SDK_PATH}/libotr/" CACHE STRING "Path to libotr library")
                set(LIBTIDY_ROOT "${SDK_PATH}/libtidy/" CACHE STRING "Path to libtidy library")
                set(SIGNAL_PROTOCOL_C_ROOT "${SDK_PATH}/signal-protocol-c" CACHE STRING "Path to libsignal-protocol-c library")
            endif()
            set(ZLIB_ROOT "${SDK_PATH}/zlib/" CACHE STRING "Path to zlib")
            set(OPENSSL_ROOT_DIR "${SDK_PATH}/openssl" CACHE STRING "Path to openssl library")
            set(Qt5Keychain_DIR "${SDK_PATH}/qt5keychain/lib/cmake/Qt5Keychain" CACHE STRING "Path to Qt5Keychain cmake files")
            if(DEV_MODE)
                if(NOT GST_SDK)
                    set(GST_SDK "${SDK_PATH}/gstbundle/" CACHE STRING "Path to gstreamer SDK")
                endif()
                set(PSIMEDIA_DIR "${SDK_PATH}/psimedia/" CACHE STRING "Path to psimedia plugin")
            endif()
        endif()
    else()
        if(NOT USE_MXE)
            message(WARNING "Psi SDK not found at ${SDK_PATH}. Please set SDK_PATH variable or add Psi dependencies to PATH system environmet variable")
        endif()
    endif()
    set(PLUGINS_PATH "/plugins" CACHE STRING "Install suffix for plugins")

    function(set_deb_flags FLAG_VALUES FLAG_ITEM)
        foreach(FLAG ${FLAG_VALUES})
            if(NOT ("${${FLAG_ITEM}}" MATCHES "${FLAG}"))
                set(${FLAG_ITEM} "${${FLAG_ITEM}} ${FLAG}" PARENT_SCOPE)
            endif()
        endforeach()
    endfunction()
    if(NOT MSVC)
        if(ISDEBUG)
            #Force build without optimizations
            set(CompilerFlags
                CMAKE_CXX_FLAGS_DEBUG
                CMAKE_C_FLAGS_DEBUG
                CMAKE_C_FLAGS_RELWITHDEBINFO
                CMAKE_CXX_FLAGS_RELWITHDEBINFO
                )
            foreach(CompilerFlag ${CompilerFlags})
              string(REPLACE "-O3" "-O0" ${CompilerFlag} "${${CompilerFlag}}")
              string(REPLACE "-O2" "-O0" ${CompilerFlag} "${${CompilerFlag}}")
              string(REPLACE "-DNDEBUG" "" ${CompilerFlag} "${${CompilerFlag}}")
            endforeach()
        endif()
        set(FLAGS_DEBUG "-O0")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -Wall -Wextra")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra")
        set_deb_flags(${FLAGS_DEBUG} CMAKE_CXX_FLAGS_DEBUG)
        set_deb_flags(${FLAGS_DEBUG} CMAKE_C_FLAGS_DEBUG)
        set_deb_flags(${FLAGS_DEBUG} CMAKE_C_FLAGS_RELWITHDEBINFO)
        set_deb_flags(${FLAGS_DEBUG} CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    else()
        set_deb_flags("/MP" CMAKE_CXX_FLAGS)
        set(DEFAULT_DEBUG_FLAG "/ENTRY:mainCRTStartup /DEBUG /INCREMENTAL /SAFESEH:NO /MANIFEST:NO")
        set(DEFAULT_LINKER_FLAG "/ENTRY:mainCRTStartup /INCREMENTAL:NO /LTCG")
        set(CMAKE_EXE_LINKER_FLAGS_DEBUG        "${DEFAULT_DEBUG_FLAG}" CACHE STRING "" FORCE)
        set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL        "${DEFAULT_LINKER_FLAG}" CACHE STRING "" FORCE)
        set(CMAKE_EXE_LINKER_FLAGS_RELEASE        "${DEFAULT_LINKER_FLAG}" CACHE STRING "" FORCE)
        set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO    "${DEFAULT_DEBUG_FLAG}" CACHE STRING "" FORCE)
        set(CMAKE_MODULE_LINKER_FLAGS_DEBUG        "/DEBUG /INCREMENTAL /SAFESEH:NO /MANIFEST:NO" CACHE STRING "" FORCE)
        set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL    "/INCREMENTAL:NO /LTCG" CACHE STRING "" FORCE)
        set(CMAKE_MODULE_LINKER_FLAGS_RELEASE        "/INCREMENTAL:NO /LTCG" CACHE STRING "" FORCE)
        set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO    "/DEBUG /INCREMENTAL:NO /MANIFEST:NO" CACHE STRING "" FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_DEBUG        "${DEFAULT_DEBUG_FLAG}" CACHE STRING "" FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL    "${DEFAULT_LINKER_FLAG}" CACHE STRING "" FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_RELEASE        "${DEFAULT_LINKER_FLAG}" CACHE STRING "" FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO    "${DEFAULT_DEBUG_FLAG}" CACHE STRING "" FORCE)
        if(ISDEBUG)
            #Force use debug flags instead of release flags for debug
            set(CompilerFlags
                CMAKE_CXX_FLAGS_DEBUG
                CMAKE_C_FLAGS_DEBUG
                CMAKE_C_FLAGS_RELWITHDEBINFO
                CMAKE_CXX_FLAGS_RELWITHDEBINFO
                )
            foreach(CompilerFlag ${CompilerFlags})
              string(REPLACE "/MD " "/MDd " ${CompilerFlag} "${${CompilerFlag}}")
              string(REPLACE "/Ob1" "/Ob0" ${CompilerFlag} "${${CompilerFlag}}")
              string(REPLACE "/O2" "/Od" ${CompilerFlag} "${${CompilerFlag}}")
              string(REPLACE "/DNDEBUG" "" ${CompilerFlag} "${${CompilerFlag}}")
            endforeach()
        endif()
        set(DEBUG_FLAGS "/Zi" "/Ob0" "/Od" "/RTC1")
        set_deb_flags("${DEBUG_FLAGS}" CMAKE_CXX_FLAGS_DEBUG)
        set_deb_flags("${DEBUG_FLAGS}" CMAKE_C_FLAGS_DEBUG)
        set_deb_flags("${DEBUG_FLAGS}" CMAKE_C_FLAGS_RELWITHDEBINFO)
        set_deb_flags("${DEBUG_FLAGS}" CMAKE_CXX_FLAGS_RELWITHDEBINFO)
        add_definitions(-DNOMINMAX)
        add_definitions(-D_CRT_SECURE_NO_WARNINGS)
        add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
        add_definitions(-D_CRT_NON_CONFORMING_SWPRINTFS)
        add_definitions(-D_SCL_SECURE_NO_WARNINGS)
        add_definitions(-D_WINSOCK_DEPRECATED_NO_WARNINGS)
    endif()
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(D "d")
        add_definitions(-DALLOW_QT_PLUGINS_DIR)
    endif()
    add_definitions(
        -DUNICODE
        -D_UNICODE
    )
endif()
