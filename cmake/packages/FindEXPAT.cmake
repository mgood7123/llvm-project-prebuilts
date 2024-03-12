# Try to find the EXPAT library
#
# If successful, the following variables will be defined:
# EXPAT_INCLUDE_DIRS
# EXPAT_LIBRARIES
# EXPAT_FOUND

find_package(PkgConfig QUIET)
pkg_check_modules(PC_EXPAT QUIET EXPAT)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(EXPAT_INCLUDE_DIRS NAMES expat.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(EXPAT_LIBRARIES NAMES libexpat.a libexpatd.a
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
if(EXPAT_INCLUDE_DIRS AND EXISTS "${EXPAT_INCLUDE_DIRS}/expat.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${EXPAT_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${EXPAT_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${EXPAT_LIBRARIES})
  check_include_file(expat.h HAVE_EXPAT_H)
  cmake_pop_check_state()
  if (HAVE_EXPAT_H)
    file(STRINGS "${EXPAT_INCLUDE_DIRS}/expat.h" _XML_version_lines REGEX "#define[ \t]+XML_(MAJOR|MINOR|MICRO)_VERSION")
    string(REGEX REPLACE ".*XML_MAJOR_VERSION *\([0-9]*\).*" "\\1" _XML_version_major "${_XML_version_lines}")
    string(REGEX REPLACE ".*XML_MINOR_VERSION *\([0-9]*\).*" "\\1" _XML_version_minor "${_XML_version_lines}")
    string(REGEX REPLACE ".*XML_MICRO_VERSION *\([0-9]*\).*" "\\1" _XML_version_micro "${_XML_version_lines}")
    set(EXPAT_VERSION_STRING "${_XML_version_major}.${_XML_version_minor}.${_XML_version_micro}")
  else()
    set(EXPAT_INCLUDE_DIRS "")
    set(EXPAT_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(EXPAT
                                  FOUND_VAR
                                    EXPAT_FOUND
                                  REQUIRED_VARS
                                    EXPAT_INCLUDE_DIRS
                                    EXPAT_LIBRARIES
                                  VERSION_VAR
                                    EXPAT_VERSION_STRING)
mark_as_advanced(EXPAT_INCLUDE_DIRS EXPAT_LIBRARIES)

message(STATUS "EXPAT: found :        ${EXPAT_FOUND}")
message(STATUS "EXPAT: include_dirs : ${EXPAT_INCLUDE_DIRS}")
message(STATUS "EXPAT: lib :          ${EXPAT_LIBRARIES}")
message(STATUS "EXPAT: version :      ${EXPAT_VERSION_STRING}")

if (EXPAT_FOUND AND NOT TARGET LLVM_STATIC_EXPAT)
  add_library(LLVM_STATIC_EXPAT UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_EXPAT PROPERTIES
                        IMPORTED_LOCATION ${EXPAT_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${EXPAT_INCLUDE_DIRS})
  set(EXPAT_TARGET LLVM_STATIC_EXPAT)
endif()
