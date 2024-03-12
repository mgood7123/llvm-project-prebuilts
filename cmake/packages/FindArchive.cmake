# Try to find the ARCHIVE library
#
# If successful, the following variables will be defined:
# ARCHIVE_INCLUDE_DIRS
# ARCHIVE_LIBRARIES
# ARCHIVE_FOUND

find_package(PkgConfig QUIET)
pkg_check_modules(PC_ARCHIVE QUIET Archive)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(ARCHIVE_INCLUDE_DIRS NAMES archive.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(ARCHIVE_LIBRARIES NAMES libarchive.a
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
if(ARCHIVE_INCLUDE_DIRS AND EXISTS "${ARCHIVE_INCLUDE_DIRS}/archive.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${ARCHIVE_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${ARCHIVE_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${ARCHIVE_LIBRARIES})
  check_include_file(archive.h HAVE_ARCHIVE_H)
  cmake_pop_check_state()
  if (HAVE_ARCHIVE_H)
    # The version string appears in one of three known formats in the header:
    #  #define ARCHIVE_LIBRARY_VERSION "libarchive 2.4.12"
    #  #define ARCHIVE_VERSION_STRING "libarchive 2.8.4"
    #  #define ARCHIVE_VERSION_ONLY_STRING "3.2.0"
    # Match any format.
    set(_LibArchive_VERSION_REGEX "^#define[ \t]+ARCHIVE[_A-Z]+VERSION[_A-Z]*[ \t]+\"(libarchive +)?([0-9]+)\\.([0-9]+)\\.([0-9]+)[^\"]*\".*$")
    file(STRINGS "${ARCHIVE_INCLUDE_DIRS}/archive.h" _LibArchive_VERSION_STRING LIMIT_COUNT 1 REGEX "${_LibArchive_VERSION_REGEX}")
    if(_LibArchive_VERSION_STRING)
      string(REGEX REPLACE "${_LibArchive_VERSION_REGEX}" "\\2.\\3.\\4" ARCHIVE_VERSION_STRING "${_LibArchive_VERSION_STRING}")
    endif()
    unset(_LibArchive_VERSION_REGEX)
    unset(_LibArchive_VERSION_STRING)
  else()
    set(ARCHIVE_INCLUDE_DIRS "")
    set(ARCHIVE_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Archive
                                  FOUND_VAR
                                    ARCHIVE_FOUND
                                  REQUIRED_VARS
                                    ARCHIVE_INCLUDE_DIRS
                                    ARCHIVE_LIBRARIES
                                  VERSION_VAR
                                    ARCHIVE_VERSION_STRING)
mark_as_advanced(ARCHIVE_INCLUDE_DIRS ARCHIVE_LIBRARIES)

message(STATUS "ARCHIVE: found :        ${ARCHIVE_FOUND}")
message(STATUS "ARCHIVE: include_dirs : ${ARCHIVE_INCLUDE_DIRS}")
message(STATUS "ARCHIVE: lib :          ${ARCHIVE_LIBRARIES}")
message(STATUS "ARCHIVE: version :      ${ARCHIVE_VERSION_STRING}")

if (ARCHIVE_FOUND AND NOT TARGET LLVM_STATIC_archive)
  add_library(LLVM_STATIC_archive UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_archive PROPERTIES
                        IMPORTED_LOCATION ${ARCHIVE_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${ARCHIVE_INCLUDE_DIRS})
  set(ARCHIVE_TARGET LLVM_STATIC_archive)
endif()
