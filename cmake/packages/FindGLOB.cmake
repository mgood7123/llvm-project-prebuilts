# Try to find the GLOB library
#
# If successful, the following variables will be defined:
# GLOB_INCLUDE_DIR
# GLOB_LIBRARIES
# GLOB_FOUND
#
# Additionally, one of the following import targets will be defined:
# z

find_package(PkgConfig QUIET)
pkg_check_modules(PC_GLOB QUIET GLOB)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(GLOB_INCLUDE_DIRS NAMES glob.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(GLOB_LIBRARIES NAMES libglob.a
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
if(GLOB_INCLUDE_DIRS AND EXISTS "${GLOB_INCLUDE_DIRS}/glob.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${GLOB_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${GLOB_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${GLOB_LIBRARIES})
  check_include_file(glob.h HAVE_GLOB_H)
  cmake_pop_check_state()
  if (HAVE_GLOB_H)
    set(GLOB_VERSION_STRING "1.0")
  else()
    set(GLOB_INCLUDE_DIRS "")
    set(GLOB_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GLOB
                                  FOUND_VAR
                                    GLOB_FOUND
                                  REQUIRED_VARS
                                    GLOB_INCLUDE_DIRS
                                    GLOB_LIBRARIES
                                  VERSION_VAR
                                    GLOB_VERSION_STRING)
mark_as_advanced(GLOB_INCLUDE_DIRS GLOB_LIBRARIES)

if (GLOB_FOUND AND NOT TARGET LLVM_STATIC_GLOB)
  add_library(LLVM_STATIC_GLOB UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_GLOB PROPERTIES
                        IMPORTED_LOCATION ${GLOB_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${GLOB_INCLUDE_DIRS})
  set(GLOB_TARGET LLVM_STATIC_GLOB)
endif()
