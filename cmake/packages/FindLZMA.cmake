# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindLibLZMA
-----------

Find LZMA compression algorithm headers and library.

Result variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``LIBLZMA_FOUND``
  True if liblzma headers and library were found.
``LIBLZMA_INCLUDE_DIRS``
  Directory where liblzma headers are located.
``LIBLZMA_LIBRARIES``
  Lzma libraries to link against.
``LIBLZMA_HAS_AUTO_DECODER``
  True if lzma_auto_decoder() is found (required).
``LIBLZMA_HAS_EASY_ENCODER``
  True if lzma_easy_encoder() is found (required).
``LIBLZMA_HAS_LZMA_PRESET``
  True if lzma_lzma_preset() is found (required).
``LIBLZMA_VERSION_MAJOR``
  The major version of lzma
``LIBLZMA_VERSION_MINOR``
  The minor version of lzma
``LIBLZMA_VERSION_PATCH``
  The patch version of lzma
``LIBLZMA_VERSION_STRING``
  version number as a string (ex: "5.0.3")
#]=======================================================================]

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(LIBLZMA_INCLUDE_DIRS lzma.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

find_library(LIBLZMA_LIBRARIES NAMES liblzma.a
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

if(LIBLZMA_INCLUDE_DIRS AND EXISTS "${LIBLZMA_INCLUDE_DIRS}/lzma.h")
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_INCLUDES ${LIBLZMA_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${LIBLZMA_LIBRARIES})
  check_include_file(lzma.h HAVE_LZMA_H)
  cmake_pop_check_state()
  if (HAVE_LZMA_H)
    file(STRINGS "${LIBLZMA_INCLUDE_DIRS}/lzma/version.h" _lzma_version_lines REGEX "#define[ \t]+LZMA_VERSION_(MAJOR|MINOR|PATCH)")
    string(REGEX REPLACE ".*LZMA_VERSION_MAJOR *\([0-9]*\).*" "\\1" _lzma_version_major "${_lzma_version_lines}")
    string(REGEX REPLACE ".*LZMA_VERSION_MINOR *\([0-9]*\).*" "\\1" _lzma_version_minor "${_lzma_version_lines}")
    string(REGEX REPLACE ".*LZMA_VERSION_PATCH *\([0-9]*\).*" "\\1" _lzma_version_patch "${_lzma_version_lines}")
    set(LIBLZMA_VERSION_STRING "${_lzma_version_major}.${_lzma_version_minor}.${_lzma_version_patch}")
    CHECK_LIBRARY_EXISTS(${LIBLZMA_LIBRARIES} lzma_auto_decoder "" LIBLZMA_HAS_AUTO_DECODER)
    CHECK_LIBRARY_EXISTS(${LIBLZMA_LIBRARIES} lzma_easy_encoder "" LIBLZMA_HAS_EASY_ENCODER)
    CHECK_LIBRARY_EXISTS(${LIBLZMA_LIBRARIES} lzma_lzma_preset "" LIBLZMA_HAS_LZMA_PRESET)
  else()
    set(LIBLZMA_INCLUDE_DIRS "")
    set(LIBLZMA_LIBRARIES "")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibLZMA
                                  FOUND_VAR
                                    LIBLZMA_FOUND
                                  REQUIRED_VARS
                                    LIBLZMA_INCLUDE_DIRS
                                    LIBLZMA_LIBRARIES
                                    LIBLZMA_HAS_AUTO_DECODER
                                    LIBLZMA_HAS_EASY_ENCODER
                                    LIBLZMA_HAS_LZMA_PRESET
                                  VERSION_VAR
                                    LIBLZMA_VERSION_STRING)
mark_as_advanced(LIBLZMA_INCLUDE_DIRS LIBLZMA_LIBRARIES)

message(STATUS "LIBLZMA: found :           ${LIBLZMA_FOUND}")
message(STATUS "LIBLZMA: include_dirs :    ${LIBLZMA_INCLUDE_DIRS}")
message(STATUS "LIBLZMA: lib :             ${LIBLZMA_LIBRARIES}")
message(STATUS "LIBLZMA: version :         ${LIBLZMA_VERSION_STRING}")
message(STATUS "LIBLZMA: has auto decode : ${LIBLZMA_HAS_AUTO_DECODER}")
message(STATUS "LIBLZMA: has easy decode : ${LIBLZMA_HAS_EASY_ENCODER}")
message(STATUS "LIBLZMA: has lzma preset : ${LIBLZMA_HAS_LZMA_PRESET}")

if (LIBLZMA_FOUND AND NOT TARGET LLVM_STATIC_LIBLZMA)
  add_library(LLVM_STATIC_LIBLZMA UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_LIBLZMA PROPERTIES IMPORTED_LOCATION ${LIBLZMA_LIBRARIES})
  set_target_properties(LLVM_STATIC_LIBLZMA PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${LIBLZMA_INCLUDE_DIRS})
  set_target_properties(LLVM_STATIC_LIBLZMA PROPERTIES INTERFACE_COMPILE_DEFINITIONS LZMA_API_STATIC )
  set(LIBLZMA_TARGET LLVM_STATIC_LIBLZMA)
endif()
