# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindLibLZMA
-----------

Find LZMA compression algorithm headers and library.

Result variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``LZMA_FOUND``
  True if liblzma headers and library were found.
``LZMA_INCLUDE_DIRS``
  Directory where liblzma headers are located.
``LZMA_LIBRARIES``
  Lzma libraries to link against.
``LZMA_HAS_AUTO_DECODER``
  True if lzma_auto_decoder() is found (required).
``LZMA_HAS_EASY_ENCODER``
  True if lzma_easy_encoder() is found (required).
``LZMA_HAS_LZMA_PRESET``
  True if lzma_lzma_preset() is found (required).
``LZMA_VERSION_MAJOR``
  The major version of lzma
``LZMA_VERSION_MINOR``
  The minor version of lzma
``LZMA_VERSION_PATCH``
  The patch version of lzma
``LZMA_VERSION_STRING``
  version number as a string (ex: "5.0.3")
#]=======================================================================]

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(LZMA_INCLUDE_DIRS lzma.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

find_library(LZMA_LIBRARIES NAMES liblzma.a
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

macro(CHECK_LIBRARY_EXISTS LIBRARY FUNCTION LOCATION VARIABLE)
  if(NOT DEFINED "${VARIABLE}")
    set(MACRO_CHECK_LIBRARY_EXISTS_DEFINITION
      "-DCHECK_FUNCTION_EXISTS=${FUNCTION} ${CMAKE_REQUIRED_FLAGS}")
    if(NOT CMAKE_REQUIRED_QUIET)
      message(CHECK_START "Looking for ${FUNCTION} in ${LIBRARY}")
    endif()
    set(CHECK_LIBRARY_EXISTS_LINK_OPTIONS)
    if(CMAKE_REQUIRED_LINK_OPTIONS)
      set(CHECK_LIBRARY_EXISTS_LINK_OPTIONS
        LINK_OPTIONS ${CMAKE_REQUIRED_LINK_OPTIONS})
    endif()
    set(CHECK_LIBRARY_EXISTS_LIBRARIES ${LIBRARY})
    if(CMAKE_REQUIRED_LIBRARIES)
      set(CHECK_LIBRARY_EXISTS_LIBRARIES
        ${CHECK_LIBRARY_EXISTS_LIBRARIES} ${CMAKE_REQUIRED_LIBRARIES})
    endif()

    if(CMAKE_C_COMPILER_LOADED)
      set(_cle_source ${CMAKE_ROOT}/Modules/CheckFunctionExists.c)
    elseif(CMAKE_CXX_COMPILER_LOADED)
      set(_cle_source ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CheckLibraryExists/CheckFunctionExists.cxx)
      configure_file(${CMAKE_ROOT}/Modules/CheckFunctionExists.c "${_cle_source}" COPYONLY)
    else()
      message(FATAL_ERROR "CHECK_FUNCTION_EXISTS needs either C or CXX language enabled")
    endif()

    try_compile(${VARIABLE}
      ${CMAKE_BINARY_DIR}
      ${_cle_source}
      COMPILE_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS}
      ${CHECK_LIBRARY_EXISTS_LINK_OPTIONS}
      LINK_LIBRARIES ${CHECK_LIBRARY_EXISTS_LIBRARIES}
      CMAKE_FLAGS
      -DCOMPILE_DEFINITIONS:STRING=${MACRO_CHECK_LIBRARY_EXISTS_DEFINITION}
      -DLINK_DIRECTORIES:STRING=${LOCATION}
      OUTPUT_VARIABLE OUTPUT)
    unset(_cle_source)

    if(${VARIABLE})
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_PASS "found")
      endif()
      set(${VARIABLE} 1 CACHE INTERNAL "Have library ${LIBRARY}")
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining if the function ${FUNCTION} exists in the ${LIBRARY} "
        "passed with the following output:\n"
        "${OUTPUT}\n\n")
    else()
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_FAIL "not found")
      endif()
      set(${VARIABLE} "" CACHE INTERNAL "Have library ${LIBRARY}")
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "Determining if the function ${FUNCTION} exists in the ${LIBRARY} "
        "failed with the following output:\n"
        "${OUTPUT}\n\n")
    endif()
  endif()
endmacro()

if(LZMA_INCLUDE_DIRS AND EXISTS "${LZMA_INCLUDE_DIRS}/lzma.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_INCLUDES ${LZMA_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${LZMA_LIBRARIES})
  check_include_file(lzma.h HAVE_LZMA_H)
  cmake_pop_check_state()
  if (HAVE_LZMA_H)
    file(STRINGS "${LZMA_INCLUDE_DIRS}/lzma/version.h" _lzma_version_lines REGEX "#define[ \t]+LZMA_VERSION_(MAJOR|MINOR|PATCH)")
    string(REGEX REPLACE ".*LZMA_VERSION_MAJOR *\([0-9]*\).*" "\\1" _lzma_version_major "${_lzma_version_lines}")
    string(REGEX REPLACE ".*LZMA_VERSION_MINOR *\([0-9]*\).*" "\\1" _lzma_version_minor "${_lzma_version_lines}")
    string(REGEX REPLACE ".*LZMA_VERSION_PATCH *\([0-9]*\).*" "\\1" _lzma_version_patch "${_lzma_version_lines}")
    set(LZMA_VERSION_STRING "${_lzma_version_major}.${_lzma_version_minor}.${_lzma_version_patch}")
    CHECK_LIBRARY_EXISTS(${LZMA_LIBRARIES} lzma_auto_decoder "" LZMA_HAS_AUTO_DECODER)
    CHECK_LIBRARY_EXISTS(${LZMA_LIBRARIES} lzma_easy_encoder "" LZMA_HAS_EASY_ENCODER)
    CHECK_LIBRARY_EXISTS(${LZMA_LIBRARIES} lzma_lzma_preset "" LZMA_HAS_LZMA_PRESET)
  else()
    set(LZMA_INCLUDE_DIRS "")
    set(LZMA_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LZMA
                                  FOUND_VAR
                                    LZMA_FOUND
                                  REQUIRED_VARS
                                    LZMA_INCLUDE_DIRS
                                    LZMA_LIBRARIES
                                    LZMA_HAS_AUTO_DECODER
                                    LZMA_HAS_EASY_ENCODER
                                    LZMA_HAS_LZMA_PRESET
                                  VERSION_VAR
                                    LZMA_VERSION_STRING)
mark_as_advanced(LZMA_INCLUDE_DIRS LZMA_LIBRARIES)

message(STATUS "LZMA: found :           ${LZMA_FOUND}")
message(STATUS "LZMA: include_dirs :    ${LZMA_INCLUDE_DIRS}")
message(STATUS "LZMA: lib :             ${LZMA_LIBRARIES}")
message(STATUS "LZMA: version :         ${LZMA_VERSION_STRING}")
message(STATUS "LZMA: has auto decode : ${LZMA_HAS_AUTO_DECODER}")
message(STATUS "LZMA: has easy decode : ${LZMA_HAS_EASY_ENCODER}")
message(STATUS "LZMA: has lzma preset : ${LZMA_HAS_LZMA_PRESET}")

if (LZMA_FOUND AND NOT TARGET LLVM_STATIC_LZMA)
  add_library(LLVM_STATIC_LZMA UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_LZMA PROPERTIES IMPORTED_LOCATION ${LZMA_LIBRARIES})
  set_target_properties(LLVM_STATIC_LZMA PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${LZMA_INCLUDE_DIRS})
  set_target_properties(LLVM_STATIC_LZMA PROPERTIES INTERFACE_COMPILE_DEFINITIONS LZMA_API_STATIC )
  set(LZMA_TARGET LLVM_STATIC_LZMA)
endif()
