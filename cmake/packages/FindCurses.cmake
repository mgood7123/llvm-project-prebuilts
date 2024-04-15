unset(CMAKE_FIND_DEBUG_MODE)
unset(CMAKE_FIND_DEBUG_MODE CACHE)
set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(CURSES_INCLUDE_DIRS ncurses/curses.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

find_library(NCURSES_LIBRARIES NAMES libncurses.a
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/lib
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

unset(CURSES_LIBRARIES)
unset(CURSES_LIBRARIES CACHE)
set(CURSES_LIBRARIES ${NCURSES_LIBRARIES})

find_library(PANEL_LIBRARIES NAMES libpanel.a
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/lib
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

find_library(FORM_LIBRARIES NAMES libform.a
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/lib
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

find_library(MENU_LIBRARIES NAMES libmenu.a
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/lib
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

unset(CMAKE_FIND_DEBUG_MODE)
unset(CMAKE_FIND_DEBUG_MODE CACHE)
set(CMAKE_FIND_DEBUG_MODE FALSE)

include(CheckIncludeFile)

macro(CHECK_LIBRARY_EXISTS LIBRARY FUNCTION LOCATION VARIABLE)
  if(NOT DEFINED "${VARIABLE}")
    set(MACRO_CHECK_LIBRARY_EXISTS_DEFINITION
      "-DCHECK_FUNCTION_EXISTS=${FUNCTION} ${CMAKE_REQUIRED_FLAGS}")
    if(NOT CMAKE_REQUIRED_QUIET)
      message(CHECK_START "Looking for ${FUNCTION} in ${LIBRARY}")
    endif()
    set(CHECK_LIBRARY_EXISTS_LINK_OPTIONS)
    if(CMAKE_REQUIRED_LINK_OPTIONS)
      set(CHECK_LIBRARY_EXISTS_LINK_OPTIONS
        LINK_OPTIONS ${CMAKE_REQUIRED_LINK_OPTIONS})
    endif()
    set(CHECK_LIBRARY_EXISTS_LIBRARIES ${LIBRARY})
    if(CMAKE_REQUIRED_LIBRARIES)
      set(CHECK_LIBRARY_EXISTS_LIBRARIES
        ${CHECK_LIBRARY_EXISTS_LIBRARIES} ${CMAKE_REQUIRED_LIBRARIES})
    endif()

    if(CMAKE_C_COMPILER_LOADED)
      set(_cle_source ${CMAKE_ROOT}/Modules/CheckFunctionExists.c)
    elseif(CMAKE_CXX_COMPILER_LOADED)
      set(_cle_source ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CheckLibraryExists/CheckFunctionExists.cxx)
      configure_file(${CMAKE_ROOT}/Modules/CheckFunctionExists.c "${_cle_source}" COPYONLY)
    else()
      message(FATAL_ERROR "CHECK_FUNCTION_EXISTS needs either C or CXX language enabled")
    endif()

    try_compile(${VARIABLE}
      ${CMAKE_BINARY_DIR}
      ${_cle_source}
      COMPILE_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS}
      ${CHECK_LIBRARY_EXISTS_LINK_OPTIONS}
      LINK_LIBRARIES ${CHECK_LIBRARY_EXISTS_LIBRARIES}
      CMAKE_FLAGS
      -DCOMPILE_DEFINITIONS:STRING=${MACRO_CHECK_LIBRARY_EXISTS_DEFINITION}
      -DLINK_DIRECTORIES:STRING=${LOCATION}
      OUTPUT_VARIABLE OUTPUT)
    unset(_cle_source)

    if(${VARIABLE})
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_PASS "found")
      endif()
      set(${VARIABLE} 1 CACHE INTERNAL "Have library ${LIBRARY}")
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining if the function ${FUNCTION} exists in the ${LIBRARY} "
        "passed with the following output:\n"
        "${OUTPUT}\n\n")
    else()
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_FAIL "not found")
      endif()
      set(${VARIABLE} "" CACHE INTERNAL "Have library ${LIBRARY}")
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "Determining if the function ${FUNCTION} exists in the ${LIBRARY} "
        "failed with the following output:\n"
        "${OUTPUT}\n\n")
    endif()
  endif()
endmacro()

if(CURSES_INCLUDE_DIRS AND EXISTS "${CURSES_INCLUDE_DIRS}/ncurses/termcap.h")
    set(HAVE_TERMCAP_H TRUE)
endif()

if(CURSES_INCLUDE_DIRS AND EXISTS "${CURSES_INCLUDE_DIRS}/ncurses/curses.h")
  set(HAVE_CURSES_H TRUE)
  if (HAVE_CURSES_H)
    set(CURSES_VERSION_STRING "6.4")

    include(CMakePushCheckState)
    cmake_push_check_state()
    if (WIN32)
      find_program(CYGPATH_EXE NAMES cygpath.exe)
      if (CYGPATH_EXE)
        execute_process(COMMAND "${CYGPATH_EXE}" "-m" "/" OUTPUT_VARIABLE CYGDIR)
        string(STRIP ${CYGDIR} CYGDIR)
      endif()
      if (EXISTS "${CYGDIR}/usr/bin/cygpath.exe")
        if (EXISTS "${CYGDIR}/usr/lib/libmsys-2.0.a")
          # clang64 provides nanosleep in /clang64/lib/libpthread.a
          CHECK_LIBRARY_EXISTS("${CYGDIR}clang64/lib/libpthread.a" nanosleep "" HAVE_NANOSLEEP_FUNC)
          # msys2
          set(CMAKE_REQUIRED_LIBRARIES "${CYGDIR}clang64/lib/libpthread.a")
        else()
          # cygwin provides nanosleep, we assume it is implicit
        endif()
      endif()
    else()
      # linux provides nanosleep, we assume it is implicit
    endif()
    CHECK_LIBRARY_EXISTS(${CURSES_LIBRARIES} cbreak "" CURSES_NCURSES_HAS_CBREAK)
    CHECK_LIBRARY_EXISTS(${CURSES_LIBRARIES} nodelay "" CURSES_NCURSES_HAS_NODELAY)
    cmake_pop_check_state()
  else()
    set(CURSES_INCLUDE_DIRS "")
    set(CURSES_LIBRARIES "")
    set(NCURSES_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Curses
                                  FOUND_VAR
                                    CURSES_FOUND
                                  REQUIRED_VARS
                                    CURSES_INCLUDE_DIRS
                                    CURSES_LIBRARIES
                                    PANEL_LIBRARIES
                                    FORM_LIBRARIES
                                    MENU_LIBRARIES
                                    CURSES_NCURSES_HAS_CBREAK
                                    CURSES_NCURSES_HAS_NODELAY
                                  VERSION_VAR
                                    CURSES_VERSION_STRING)
mark_as_advanced(CURSES_INCLUDE_DIRS CURSES_LIBRARIES PANEL_LIBRARIES)

message(STATUS "CURSES: found :         ${CURSES_FOUND}")
message(STATUS "CURSES: include_dirs :  ${CURSES_INCLUDE_DIRS}")
message(STATUS "CURSES: lib :           ${CURSES_LIBRARIES}")
message(STATUS "PANEL:  lib :           ${PANEL_LIBRARIES}")
message(STATUS "FORM:   lib :           ${FORM_LIBRARIES}")
message(STATUS "MENU:   lib :           ${MENU_LIBRARIES}")
message(STATUS "CURSES: version :       ${CURSES_VERSION_STRING}")
message(STATUS "CURSES: has cbreak :    ${CURSES_NCURSES_HAS_CBREAK}")
message(STATUS "CURSES: has nodelay :   ${CURSES_NCURSES_HAS_NODELAY}")

if (CURSES_FOUND AND NOT TARGET LLVM_STATIC_CURSES)
  add_library(LLVM_STATIC_CURSES UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_CURSES PROPERTIES IMPORTED_LOCATION ${CURSES_LIBRARIES})
  set_target_properties(LLVM_STATIC_CURSES PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${CURSES_INCLUDE_DIRS};${CURSES_INCLUDE_DIRS}/ncurses")
  set_target_properties(LLVM_STATIC_CURSES PROPERTIES INTERFACE_COMPILE_DEFINITIONS NCURSES_STATIC)
  if (WIN32)
    find_program(CYGPATH_EXE NAMES cygpath.exe)
    if (CYGPATH_EXE)
      execute_process(COMMAND "${CYGPATH_EXE}" "-m" "/" OUTPUT_VARIABLE CYGDIR)
      string(STRIP ${CYGDIR} CYGDIR)
    endif()
    if (EXISTS "${CYGDIR}usr/bin/cygpath.exe")
      if (EXISTS "${CYGDIR}usr/lib/libmsys-2.0.a")
        # clang64 provides nanosleep in /clang64/lib/libpthread.a
        CHECK_LIBRARY_EXISTS("${CYGDIR}clang64/lib/libpthread.a" nanosleep "" HAVE_NANOSLEEP_FUNC)
        # msys2
        add_library(LLVM_STATIC_CURSES_P UNKNOWN IMPORTED)
        set_target_properties(LLVM_STATIC_CURSES_P PROPERTIES IMPORTED_LOCATION "${CYGDIR}clang64/lib/libpthread.a")
        set_target_properties(LLVM_STATIC_CURSES PROPERTIES INTERFACE_LINK_LIBRARIES LLVM_STATIC_CURSES_P)
      else()
        # cygwin provides nanosleep, we assume it is implicit
      endif()
    endif()
  else()
    # linux provides nanosleep, we assume it is implicit
  endif()
  set(CURSES_TARGET LLVM_STATIC_CURSES)
endif()

if (CURSES_FOUND AND NOT TARGET LLVM_STATIC_PANEL)
  add_library(LLVM_STATIC_PANEL UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_PANEL PROPERTIES IMPORTED_LOCATION ${PANEL_LIBRARIES})
  set(PANEL_TARGET LLVM_STATIC_PANEL)
endif()

if (CURSES_FOUND AND NOT TARGET LLVM_STATIC_FORM)
  add_library(LLVM_STATIC_FORM UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_FORM PROPERTIES IMPORTED_LOCATION ${FORM_LIBRARIES})
  set(FORM_TARGET LLVM_STATIC_FORM)
endif()

if (CURSES_FOUND AND NOT TARGET LLVM_STATIC_MENU)
  add_library(LLVM_STATIC_MENU UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_MENU PROPERTIES IMPORTED_LOCATION ${MENU_LIBRARIES})
  set(MENU_TARGET LLVM_STATIC_MENU)
endif()
