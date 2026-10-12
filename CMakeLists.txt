cmake_minimum_required(VERSION 3.16)
project(plasma-applet-netspeed-widget)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

set(QT_MAJOR_VERSION 6)

include(KDEInstallDirs)

find_package(Plasma REQUIRED)

plasma_install_package(package org.kde.netspeedWidget)
