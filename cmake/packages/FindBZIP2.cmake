# Try to find the BZIP2 library
#
# If successful, the following variables will be defined:
# BZIP2_INCLUDE_DIR
# BZIP2_LIBRARIES
# BZIP2_FOUND
#
# ``BZIP2_NEED_PREFIX``
#  this is set if the functions are prefixed with ``BZ2_``
#
# Additionally, one of the following import targets will be defined:
# BZIP2

find_package(PkgConfig QUIET)
pkg_check_modules(PC_BZIP2 QUIET BZIP2)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(BZIP2_INCLUDE_DIRS NAMES bzlib.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(BZIP2_LIBRARIES NAMES libbz2_static.a
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
if(BZIP2_INCLUDE_DIRS AND EXISTS "${BZIP2_INCLUDE_DIRS}/bzlib.h")
  include(CheckSymbolExists)
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${BZIP2_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${BZIP2_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${BZIP2_LIBRARIES})
  check_include_file(bzlib.h HAVE_BZLIB_H)
  CHECK_SYMBOL_EXISTS(BZ2_bzCompressInit "bzlib.h" BZIP2_NEED_PREFIX)
  cmake_pop_check_state()
  if (HAVE_BZLIB_H)
    set(BZIP2_VERSION_STRING "1.1.0")
  else()
    set(BZIP2_INCLUDE_DIRS "")
    set(BZIP2_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BZIP2
                                  FOUND_VAR
                                    BZIP2_FOUND
                                  REQUIRED_VARS
                                    BZIP2_INCLUDE_DIRS
                                    BZIP2_LIBRARIES
                                  VERSION_VAR
                                    BZIP2_VERSION_STRING)
mark_as_advanced(BZIP2_INCLUDE_DIRS BZIP2_LIBRARIES)

message(STATUS "BZIP2: found :        ${BZIP2_FOUND}")
message(STATUS "BZIP2: include_dirs : ${BZIP2_INCLUDE_DIRS}")
message(STATUS "BZIP2: lib :          ${BZIP2_LIBRARIES}")
message(STATUS "BZIP2: version :      ${BZIP2_VERSION_STRING}")

if (BZIP2_FOUND AND NOT TARGET LLVM_STATIC_BZip2::BZip2)
  add_library(LLVM_STATIC_BZip2::BZip2 UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_BZip2::BZip2 PROPERTIES
                        IMPORTED_LOCATION ${BZIP2_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${BZIP2_INCLUDE_DIRS})
  set(BZIP2_TARGET LLVM_STATIC_BZip2::BZip2)
endif()
