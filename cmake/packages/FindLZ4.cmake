# Try to find the LZ4 library
#
# If successful, the following variables will be defined:
# LZ4_INCLUDE_DIR
# LZ4_LIBRARIES
# LZ4_FOUND
#
# Additionally, one of the following import targets will be defined:
# z

find_package(PkgConfig QUIET)
pkg_check_modules(PC_LZ4 QUIET LZ4)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(LZ4_INCLUDE_DIRS NAMES lz4.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(LZ4_LIBRARIES NAMES liblz4.a
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
if(LZ4_INCLUDE_DIRS AND EXISTS "${LZ4_INCLUDE_DIRS}/lz4.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${LZ4_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${LZ4_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${LZ4_LIBRARIES})
  check_include_file(lz4.h HAVE_LZ4_H)
  cmake_pop_check_state()
  if (HAVE_LZ4_H)
    file(STRINGS "${LZ4_INCLUDE_DIRS}/lz4.h" _lz4_version_lines REGEX "#define[ \t]+LZ4_VERSION_(MAJOR|MINOR|RELEASE)")
    string(REGEX REPLACE ".*LZ4_VERSION_MAJOR *\([0-9]*\).*" "\\1" _lz4_version_major "${_lz4_version_lines}")
    string(REGEX REPLACE ".*LZ4_VERSION_MINOR *\([0-9]*\).*" "\\1" _lz4_version_minor "${_lz4_version_lines}")
    string(REGEX REPLACE ".*LZ4_VERSION_RELEASE *\([0-9]*\).*" "\\1" _lz4_version_release "${_lz4_version_lines}")
    set(LZ4_VERSION_STRING "${_lz4_version_major}.${_lz4_version_minor}.${_lz4_version_release}")
  else()
    set(LZ4_INCLUDE_DIRS "")
    set(LZ4_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LZ4
                                  FOUND_VAR
                                    LZ4_FOUND
                                  REQUIRED_VARS
                                    LZ4_INCLUDE_DIRS
                                    LZ4_LIBRARIES
                                  VERSION_VAR
                                    LZ4_VERSION_STRING)
mark_as_advanced(LZ4_INCLUDE_DIRS LZ4_LIBRARIES)

message(STATUS "LZ4: found :        ${LZ4_FOUND}")
message(STATUS "LZ4: include_dirs : ${LZ4_INCLUDE_DIRS}")
message(STATUS "LZ4: lib :          ${LZ4_LIBRARIES}")
message(STATUS "LZ4: version :      ${LZ4_VERSION_STRING}")

if (LZ4_FOUND AND NOT TARGET LLVM_STATIC_LZ4)
  add_library(LLVM_STATIC_LZ4 UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_LZ4 PROPERTIES
                        IMPORTED_LOCATION ${LZ4_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${LZ4_INCLUDE_DIRS})
  set(LZ4_TARGET LLVM_STATIC_LZ4)
endif()
