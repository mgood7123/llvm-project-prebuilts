# Try to find the ZLIB library
#
# If successful, the following variables will be defined:
# ZLIB_INCLUDE_DIRS
# ZLIB_LIBRARIES
# ZLIB_FOUND
#
# Additionally, one of the following import targets will be defined:
# z

find_package(PkgConfig QUIET)
pkg_check_modules(PC_ZLIB QUIET ZLIB)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(ZLIB_INCLUDE_DIRS NAMES zlib.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(ZLIB_LIBRARIES NAMES libz.a
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
if(ZLIB_INCLUDE_DIRS AND EXISTS "${ZLIB_INCLUDE_DIRS}/zlib.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${ZLIB_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${ZLIB_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${ZLIB_LIBRARIES})
  check_include_file(zlib.h HAVE_ZLIB_H)
  cmake_pop_check_state()
  if (HAVE_ZLIB_H)
    file(STRINGS "${ZLIB_INCLUDE_DIRS}/zlib.h" _zlib_version_lines REGEX "#define[ \t]+ZLIB_VER_(MAJOR|MINOR|REVISION|SUBREVISION)")
    string(REGEX REPLACE ".*ZLIB_VER_MAJOR *\([0-9]*\).*" "\\1" zlib_major_version "${_zlib_version_lines}")
    string(REGEX REPLACE ".*ZLIB_VER_MINOR *\([0-9]*\).*" "\\1" zlib_minor_version "${_zlib_version_lines}")
    string(REGEX REPLACE ".*ZLIB_VER_REVISION *\([0-9]*\).*" "\\1" zlib_revision_version "${_zlib_version_lines}")
    string(REGEX REPLACE ".*ZLIB_VER_SUBREVISION *\([0-9]*\).*" "\\1" zlib_subrevision_version "${_zlib_version_lines}")
    set(ZLIB_VERSION_STRING "${zlib_major_version}.${zlib_minor_version}.${zlib_revision_version}.${zlib_subrevision_version}")
  else()
    set(ZLIB_INCLUDE_DIRS "")
    set(ZLIB_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZLIB
                                  FOUND_VAR
                                    ZLIB_FOUND
                                  REQUIRED_VARS
                                    ZLIB_INCLUDE_DIRS
                                    ZLIB_LIBRARIES
                                  VERSION_VAR
                                    ZLIB_VERSION_STRING)
mark_as_advanced(ZLIB_INCLUDE_DIRS ZLIB_LIBRARIES)

message(STATUS "ZLIB: found :        ${ZLIB_FOUND}")
message(STATUS "ZLIB: include_dirs : ${ZLIB_INCLUDE_DIRS}")
message(STATUS "ZLIB: lib :          ${ZLIB_LIBRARIES}")
message(STATUS "ZLIB: version :      ${ZLIB_VERSION_STRING}")

if (ZLIB_FOUND AND NOT TARGET LLVM_STATIC_ZLIB)
  add_library(LLVM_STATIC_ZLIB UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_ZLIB PROPERTIES
                        IMPORTED_LOCATION ${ZLIB_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${ZLIB_INCLUDE_DIRS})
  set(ZLIB_TARGET LLVM_STATIC_ZLIB)
  add_library(ZLIB::ZLIB ALIAS ${ZLIB_TARGET})
endif()
