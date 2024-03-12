#.rst:
# FindLibEdit
# -----------
#
# Find libedit library and headers
#
# The module defines the following variables:
#
# ::
#
#   LibEdit_FOUND          - true if libedit was found
#   LibEdit_INCLUDE_DIRS   - include search path
#   LibEdit_LIBRARIES      - libraries to link
#   LibEdit_VERSION_STRING - version number

find_package(PkgConfig QUIET)
pkg_check_modules(PC_LIBEDIT QUIET libedit)


set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(LibEdit_INCLUDE_DIRS NAMES histedit.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(LibEdit_LIBRARIES NAMES libedit_static.a libedit.a
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/lib
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

set(CMAKE_FIND_DEBUG_MODE FALSE)

include(CheckIncludeFile)
if(LibEdit_INCLUDE_DIRS AND EXISTS "${LibEdit_INCLUDE_DIRS}/histedit.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  list(APPEND CMAKE_REQUIRED_INCLUDES ${LibEdit_INCLUDE_DIRS})
  list(APPEND CMAKE_REQUIRED_LIBRARIES ${LibEdit_LIBRARIES})
  check_include_file(histedit.h HAVE_HISTEDIT_H)
  cmake_pop_check_state()
  if (HAVE_HISTEDIT_H)
    file(STRINGS "${LibEdit_INCLUDE_DIRS}/histedit.h"
          libedit_major_version_str
          REGEX "^#define[ \t]+LIBEDIT_MAJOR[ \t]+[0-9]+")
    string(REGEX REPLACE "^#define[ \t]+LIBEDIT_MAJOR[ \t]+([0-9]+)" "\\1"
            libedit_major_version "${libedit_major_version_str}")

    file(STRINGS "${LibEdit_INCLUDE_DIRS}/histedit.h"
          libedit_minor_version_str
          REGEX "^#define[ \t]+LIBEDIT_MINOR[ \t]+[0-9]+")
    string(REGEX REPLACE "^#define[ \t]+LIBEDIT_MINOR[ \t]+([0-9]+)" "\\1"
            libedit_minor_version "${libedit_minor_version_str}")

    set(LibEdit_VERSION_STRING "${libedit_major_version}.${libedit_minor_version}")
  else()
    set(LibEdit_INCLUDE_DIRS "")
    set(LibEdit_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibEdit
                                  FOUND_VAR
                                    LibEdit_FOUND
                                  REQUIRED_VARS
                                    LibEdit_INCLUDE_DIRS
                                    LibEdit_LIBRARIES
                                  VERSION_VAR
                                    LibEdit_VERSION_STRING)
mark_as_advanced(LibEdit_INCLUDE_DIRS LibEdit_LIBRARIES)

message(STATUS "LibEdit: found :        ${LibEdit_FOUND}")
message(STATUS "LibEdit: include_dirs : ${LibEdit_INCLUDE_DIRS}")
message(STATUS "LibEdit: lib :          ${LibEdit_LIBRARIES}")
message(STATUS "LibEdit: version :      ${LibEdit_VERSION_STRING}")

if (LibEdit_FOUND AND NOT TARGET LLVM_STATIC_LibEdit::LibEdit)
  add_library(LLVM_STATIC_LibEdit::LibEdit UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_LibEdit::LibEdit PROPERTIES
                        IMPORTED_LOCATION ${LibEdit_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${LibEdit_INCLUDE_DIRS})
  set(LibEdit_TARGET LLVM_STATIC_LibEdit::LibEdit)
endif()
