# Try to find the ICONV library
#
# If successful, the following variables will be defined:
# ICONV_INCLUDE_DIR
# ICONV_LIBRARIES
# ICONV_FOUND
#
# Additionally, one of the following import targets will be defined:
# z

find_package(PkgConfig QUIET)
pkg_check_modules(PC_ICONV QUIET ICONV)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(ICONV_INCLUDE_DIRS NAMES iconv.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(ICONV_LIBRARIES NAMES libiconv.a libcharset.a
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
if(ICONV_INCLUDE_DIRS AND EXISTS "${ICONV_INCLUDE_DIRS}/iconv.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${ICONV_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${ICONV_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${ICONV_LIBRARIES})
  check_include_file(iconv.h HAVE_ICONV_H)
  cmake_pop_check_state()
  if (HAVE_ICONV_H)
    set(ICONV_VERSION_STRING "1.17")
  else()
    set(ICONV_INCLUDE_DIRS "")
    set(ICONV_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ICONV
                                  FOUND_VAR
                                    ICONV_FOUND
                                  REQUIRED_VARS
                                    ICONV_INCLUDE_DIRS
                                    ICONV_LIBRARIES
                                  VERSION_VAR
                                    ICONV_VERSION_STRING)
mark_as_advanced(ICONV_INCLUDE_DIRS ICONV_LIBRARIES)

message(STATUS "ICONV: found :        ${ICONV_FOUND}")
message(STATUS "ICONV: include_dirs : ${ICONV_INCLUDE_DIRS}")
message(STATUS "ICONV: lib :          ${ICONV_LIBRARIES}")
message(STATUS "ICONV: version :      ${ICONV_VERSION_STRING}")

if (ICONV_FOUND AND NOT TARGET LLVM_STATIC_ICONV)
  add_library(LLVM_STATIC_ICONV UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_ICONV PROPERTIES
                        IMPORTED_LOCATION ${ICONV_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${ICONV_INCLUDE_DIRS})
  set(ICONV_TARGET LLVM_STATIC_ICONV)
endif()
