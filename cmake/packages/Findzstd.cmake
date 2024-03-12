# Try to find the zstd library
#
# If successful, the following variables will be defined:
# zstd_INCLUDE_DIR
# zstd_LIBRARY
# zstd_FOUND
#
# Additionally, one of the following import targets will be defined:
# zstd

find_package(PkgConfig QUIET)
pkg_check_modules(PC_zstd QUIET zstd)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(zstd_INCLUDE_DIRS NAMES zstd.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(zstd_LIBRARY NAMES libzstd.a
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
if(zstd_INCLUDE_DIRS AND EXISTS "${zstd_INCLUDE_DIRS}/zstd.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  list(APPEND CMAKE_REQUIRED_INCLUDES ${zstd_INCLUDE_DIRS})
  list(APPEND CMAKE_REQUIRED_LIBRARIES ${zstd_LIBRARY} ${zstd_STATIC_LIBRARY})
  check_include_file(zstd.h HAVE_ZSTD_H)
  cmake_pop_check_state()
  if (HAVE_ZSTD_H)
    file(STRINGS "${zstd_INCLUDE_DIRS}/zstd.h"
          zstd_major_version_str
          REGEX "^#define[ \t]+ZSTD_VERSION_MAJOR[ \t]+[0-9]+")
    string(REGEX REPLACE "^#define[ \t]+ZSTD_VERSION_MAJOR[ \t]+([0-9]+)" "\\1"
            zstd_major_version "${zstd_major_version_str}")

    file(STRINGS "${zstd_INCLUDE_DIRS}/zstd.h"
          zstd_minor_version_str
          REGEX "^#define[ \t]+ZSTD_VERSION_MINOR[ \t]+[0-9]+")
    string(REGEX REPLACE "^#define[ \t]+ZSTD_VERSION_MINOR[ \t]+([0-9]+)" "\\1"
            zstd_minor_version "${zstd_minor_version_str}")

    file(STRINGS "${zstd_INCLUDE_DIRS}/zstd.h"
          zstd_release_version_str
          REGEX "^#define[ \t]+ZSTD_VERSION_RELEASE[ \t]+[0-9]+")
    string(REGEX REPLACE "^#define[ \t]+ZSTD_VERSION_RELEASE[ \t]+([0-9]+)" "\\1"
            zstd_release_version "${zstd_release_version_str}")

    set(zstd_VERSION_STRING "${zstd_release_version}.${zstd_major_version}.${zstd_minor_version}")
  else()
    set(zstd_INCLUDE_DIRS "")
    set(zstd_LIBRARY "")
    set(zstd_STATIC_LIBRARY "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(zstd
                                  FOUND_VAR
                                    zstd_FOUND
                                  REQUIRED_VARS
                                    zstd_INCLUDE_DIRS
                                    zstd_LIBRARY
                                  VERSION_VAR
                                    zstd_VERSION_STRING)
mark_as_advanced(zstd_INCLUDE_DIRS zstd_LIBRARY)

message(STATUS "zstd: found :        ${zstd_FOUND}")
message(STATUS "zstd: include_dirs : ${zstd_INCLUDE_DIRS}")
message(STATUS "zstd: lib :          ${zstd_LIBRARY}")
message(STATUS "zstd: version :      ${zstd_VERSION_STRING}")

if (zstd_FOUND AND NOT TARGET LLVM_STATIC_zstd)
  add_library(LLVM_STATIC_zstd UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_zstd PROPERTIES
                        IMPORTED_LOCATION ${zstd_LIBRARY}
                        INTERFACE_INCLUDE_DIRECTORIES ${zstd_INCLUDE_DIRS})
  set(zstd_TARGET LLVM_STATIC_zstd)
endif()
