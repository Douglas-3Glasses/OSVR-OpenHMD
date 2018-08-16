cmake_minimum_required(VERSION 2.8.12)
project(OpenHMDPlugin)

find_package(osvr REQUIRED)

# OpenHMD
set(OPENHMD_DIR "${CMAKE_CURRENT_LIST_DIR}/vendor/OpenHMD")
include_directories(${OPENHMD_DIR}/include)
set(OPENHMD_SOURCES
    ${OPENHMD_DIR}/src/openhmd.c
    ${OPENHMD_DIR}/src/platform-win32.c
    ${OPENHMD_DIR}/src/drv_dummy/dummy.c
    ${OPENHMD_DIR}/src/omath.c
    ${OPENHMD_DIR}/src/platform-posix.c
    ${OPENHMD_DIR}/src/fusion.c
    ${OPENHMD_DIR}/src/shaders.c
	)

OPTION(OPENHMD_DRIVER_OCULUS_RIFT "Oculus Rift DK1 and DK2" ON)
OPTION(OPENHMD_DRIVER_DEEPOON "Deepoon E2" ON)
OPTION(OPENHMD_DRIVER_WMR "Windows Mixed Reality" ON)
OPTION(OPENHMD_DRIVER_PSVR "Sony PSVR" ON)
OPTION(OPENHMD_DRIVER_HTC_VIVE "HTC Vive" ON)
OPTION(OPENHMD_DRIVER_NOLO "NOLO VR CV1" ON)
OPTION(OPENHMD_DRIVER_XGVR "3Glasses HMD" ON)
OPTION(OPENHMD_DRIVER_EXTERNAL "External sensor driver" OFF)
OPTION(OPENHMD_DRIVER_ANDROID "General Android driver" OFF)

if(OPENHMD_DRIVER_OCULUS_RIFT)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_oculus_rift/rift.c
    ${OPENHMD_DIR}/src/drv_oculus_rift/packet.c
    )
    add_definitions(-DDRIVER_OCULUS_RIFT)
endif(OPENHMD_DRIVER_OCULUS_RIFT)

if(OPENHMD_DRIVER_DEEPOON)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_deepoon/deepoon.c
    ${OPENHMD_DIR}/src/drv_deepoon/packet.c
    )
    add_definitions(-DDRIVER_DEEPOON)
endif(OPENHMD_DRIVER_DEEPOON)

if(OPENHMD_DRIVER_WMR)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_wmr/wmr.c
    ${OPENHMD_DIR}/src/drv_wmr/packet.c
    )
    add_definitions(-DDRIVER_WMR)
endif(OPENHMD_DRIVER_WMR)

if(OPENHMD_DRIVER_PSVR)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_psvr/psvr.c
    ${OPENHMD_DIR}/src/drv_psvr/packet.c
    )
    add_definitions(-DDRIVER_PSVR)
endif(OPENHMD_DRIVER_PSVR)

if(OPENHMD_DRIVER_HTC_VIVE)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_htc_vive/vive.c
    ${OPENHMD_DIR}/src/drv_htc_vive/packet.c
    #${OPENHMD_DIR}/src/ext_deps/miniz.c
    ${OPENHMD_DIR}/src/ext_deps/nxjson.c
    )
    add_definitions(-DDRIVER_HTC_VIVE)
endif(OPENHMD_DRIVER_HTC_VIVE)

if(OPENHMD_DRIVER_NOLO)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_nolo/nolo.c
    ${OPENHMD_DIR}/src/drv_nolo/packet.c
    )
    add_definitions(-DDRIVER_NOLO)
endif(OPENHMD_DRIVER_NOLO)

if(OPENHMD_DRIVER_XGVR)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_3glasses/xgvr.c
    ${OPENHMD_DIR}/src/drv_3glasses/packet.c
    )
    add_definitions(-DDRIVER_XGVR)
endif(OPENHMD_DRIVER_XGVR)

if (OPENHMD_DRIVER_EXTERNAL)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_external/external.c
    )
    add_definitions(-DDRIVER_EXTERNAL)
endif(OPENHMD_DRIVER_EXTERNAL)

if (OPENHMD_DRIVER_ANDROID)
    set(OPENHMD_SOURCES ${OPENHMD_SOURCES}
    ${OPENHMD_DIR}/src/drv_android/android.c
    )
    add_definitions(-DDRIVER_ANDROID)
endif(OPENHMD_DRIVER_ANDROID)

add_definitions(-DOHMD_STATIC)

if (WIN32)
   	execute_process(COMMAND powershell -Command "(gc ${OPENHMD_DIR}/src/platform-win32.c) -replace '__stdcall DWORD', 'DWORD __stdcall' | Out-File ${OPENHMD_DIR}/src/platform-win32.c")
endif(WIN32)

# HIDAPI
set(HIDAPI_DIR "${CMAKE_CURRENT_LIST_DIR}/vendor/hidapi")
include_directories(${HIDAPI_DIR}/hidapi)

IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
   	set (HIDAPI_SOURCES ${HIDAPI_DIR}/mac/hid.c)
   	set (LIBS ${LIBS} "-framework CoreFoundation -framework IOKit")
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

if (WIN32)
   	set (HIDAPI_SOURCES ${HIDAPI_DIR}/windows/hid.c)
   	set (LIBS ${LIBS} setupapi)
endif(WIN32)

IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
   	set (HIDAPI_SOURCES ${HIDAPI_DIR}/libusb/hid.c)
   	find_package(PkgConfig REQUIRED)
   	pkg_search_module(LIBUSB REQUIRED libusb-1.0)
   	set (LIBS ${LIBS} ${LIBUSB_LIBRARIES})
   	include_directories(${LIBUSB_INCLUDE_DIRS})
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

# OSVR Plugin
osvr_convert_json(je_nourish_openhmd_json
    je_nourish_openhmd.json
    "${CMAKE_CURRENT_BINARY_DIR}/je_nourish_openhmd_json.h")

include_directories("${CMAKE_CURRENT_BINARY_DIR}")

osvr_add_plugin(NAME je_nourish_openhmd
    CPP # indicates we'd like to use the C++ wrapper
    SOURCES
    je_nourish_openhmd.cpp
    "${CMAKE_CURRENT_BINARY_DIR}/je_nourish_openhmd_json.h"
	${HIDAPI_SOURCES}
	${OPENHMD_SOURCES})

target_link_libraries(je_nourish_openhmd ${LIBS})
