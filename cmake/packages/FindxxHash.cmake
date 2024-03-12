# Try to find the xxHash library
#
# If successful, the following variables will be defined:
# xxHash_INCLUDE_DIR
# xxHash_LIBRARIES
# xxHash_FOUND
#
# Additionally, one of the following import targets will be defined:
# z

find_package(PkgConfig QUIET)
pkg_check_modules(PC_xxHash QUIET xxHash)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(xxHash_INCLUDE_DIRS NAMES xxhash.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(xxHash_LIBRARIES NAMES libxxhash.a
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
if(xxHash_INCLUDE_DIRS AND EXISTS "${xxHash_INCLUDE_DIRS}/xxhash.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${xxHash_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${xxHash_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${xxHash_LIBRARIES})
  check_include_file(xxhash.h HAVE_XXHASH_H)
  cmake_pop_check_state()
  if (HAVE_XXHASH_H)
    file(STRINGS "${xxHash_INCLUDE_DIRS}/xxhash.h" _lz4_version_lines REGEX "#define[ \t]+XXH_VERSION_(MAJOR|MINOR|RELEASE)")
    string(REGEX REPLACE ".*XXH_VERSION_MAJOR *\([0-9]*\).*" "\\1" _lz4_version_major "${_lz4_version_lines}")
    string(REGEX REPLACE ".*XXH_VERSION_MINOR *\([0-9]*\).*" "\\1" _lz4_version_minor "${_lz4_version_lines}")
    string(REGEX REPLACE ".*XXH_VERSION_RELEASE *\([0-9]*\).*" "\\1" _lz4_version_release "${_lz4_version_lines}")
    set(xxHash_VERSION_STRING "${_lz4_version_major}.${_lz4_version_minor}.${_lz4_version_release}")
  else()
    set(xxHash_INCLUDE_DIRS "")
    set(xxHash_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(xxHash
                                  FOUND_VAR
                                    xxHash_FOUND
                                  REQUIRED_VARS
                                    xxHash_INCLUDE_DIRS
                                    xxHash_LIBRARIES
                                  VERSION_VAR
                                    xxHash_VERSION_STRING)
mark_as_advanced(xxHash_INCLUDE_DIRS xxHash_LIBRARIES)

message(STATUS "xxHash: found :        ${xxHash_FOUND}")
message(STATUS "xxHash: include_dirs : ${xxHash_INCLUDE_DIRS}")
message(STATUS "xxHash: lib :          ${xxHash_LIBRARIES}")
message(STATUS "xxHash: version :      ${xxHash_VERSION_STRING}")

if (xxHash_FOUND AND NOT TARGET LLVM_STATIC_xxHash)
  add_library(LLVM_STATIC_xxHash UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_xxHash PROPERTIES
                        IMPORTED_LOCATION ${xxHash_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${xxHash_INCLUDE_DIRS})
  set(xxHash_TARGET LLVM_STATIC_xxHash)
endif()
