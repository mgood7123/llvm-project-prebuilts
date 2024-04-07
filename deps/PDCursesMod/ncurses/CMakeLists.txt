cmake_minimum_required(VERSION 3.11)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "MinSizeRel" CACHE STRING "Choose the type of build, options are: Debug, Release, or MinSizeRel." FORCE)
    message(STATUS "CMAKE_BUILD_TYPE not set, defaulting to MinSizeRel.")
endif()

if(APPLE)
    # look for brew version first
    set(CMAKE_LIBRARY_PATH /usr/local/opt/ncurses/lib)
endif()

set(CURSES_NEED_WIDE PDC_WIDE)
include(FindCurses)

if(CURSES_FOUND)
    # this project is dependent on libncurses5-dev, and libncursesw5-dev.
    # Apple builds without ncursesw
    
    PROJECT(ncurses VERSION "${PROJECT_VERSION}" LANGUAGES C)
    message(STATUS "**** ${PROJECT_NAME} ****")

    if(APPLE)
        if ("/usr/lib/libcurses.dylib" IN_LIST CURSES_LIBRARIES)
            #MESSAGE(WARNING "Building with old ncurses lib -> Manually defining A_ITALIC to 64-bit...")
            MESSAGE(WARNING "    Use `brew install ncurses` to resolve this warning")
            add_definitions("-DA_ITALIC=((chtype)0x008 << 21)") #default to 64 bit for now...
        endif()
        MESSAGE(STATUS "Linking with ${CURSES_LIBRARIES}")
    endif()
    set(PDCURSES_DIST ${CMAKE_INSTALL_PREFIX}/${CMAKE_BUILD_TYPE})

endif()