# Try to find the wcwidth library
#
# If successful, the following variables will be defined:
# WCWIDTH_INCLUDE_DIR
# WCWIDTH_LIBRARIES
# WCWIDTH_FOUND
#

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(WCWIDTH_INCLUDE_DIRS NAMES wcwidth.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(WCWIDTH_LIBRARIES NAMES libwcwidth.a
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
if(WCWIDTH_INCLUDE_DIRS AND EXISTS "${WCWIDTH_INCLUDE_DIRS}/wcwidth.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${WCWIDTH_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${WCWIDTH_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${WCWIDTH_LIBRARIES})
  check_include_file(wcwidth.h HAVE_WCWIDTH_H)
  cmake_pop_check_state()
  if (HAVE_WCWIDTH_H)
    set(WCWIDTH_VERSION_STRING "1.0")
  else()
    set(WCWIDTH_INCLUDE_DIRS "")
    set(WCWIDTH_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(wcwidth
                                  FOUND_VAR
                                    WCWIDTH_FOUND
                                  REQUIRED_VARS
                                    WCWIDTH_INCLUDE_DIRS
                                    WCWIDTH_LIBRARIES
                                  VERSION_VAR
                                    WCWIDTH_VERSION_STRING)
mark_as_advanced(WCWIDTH_INCLUDE_DIRS WCWIDTH_LIBRARIES)

if (WCWIDTH_FOUND AND NOT TARGET LLVM_STATIC_WCWIDTH)
  add_library(LLVM_STATIC_WCWIDTH UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_WCWIDTH PROPERTIES
                        IMPORTED_LOCATION ${WCWIDTH_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${WCWIDTH_INCLUDE_DIRS})
  set(WCWIDTH_TARGET LLVM_STATIC_WCWIDTH)
endif()
