# NOTE:
#  there is little value to use caching past stage1
#   the runtime build and stage2+ will be built from a fresh from source compiler and it will always result in cache miss.

cmake_minimum_required(VERSION 3.12)

project(llvm_project_prebuilt_deps C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_POLICY_DEFAULT_CMP0074 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0075 NEW)

if (APPLE)
  message("PLATFORM APPLE")
elseif (UNIX AND NOT ANDROID)
  message("PLATFORM LINUX")
elseif (UNIX AND ANDROID)
  message("PLATFORM LINUX ANDROID")
elseif (WIN32 AND NOT CYGWIN)
  message("PLATFORM WINDOWS")
elseif (WIN32 AND CYGWIN)
  message("PLATFORM WINDOWS CYGWIN")
else()
  message(FATAL_ERROR "UNKNOWN PLATFORM")
endif()

include(./build_root.cmake)

build_root_init(${CMAKE_CURRENT_SOURCE_DIR}/cmake/packages ${CMAKE_CURRENT_BINARY_DIR}/BUILD_ROOT)

if (WIN32)
    set(ENV{PTHREAD_LIBS} /usr/lib/libpthread.a)
endif()

# rcu does not depend on any libs
build_root_add_makefile_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/userspace-rcu . rcu
    "" # no extra c flags
    "" # no extra cxx flags
    "
        --enable-static=yes
        --enable-shared=no
    "
)

if (ANDROID)
    # android does not have glob/globfree, build it early
    #
    # glob does not depend on any libs
    build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/libglob . glob
        "" # no extra c flags
        "" # no extra cxx flags
        "
            -D BUILD_SHARED_LIBS=OFF
        " # extra configure arguments
    )
endif()

# 7z does not depend on any libs
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/lzma2301 . 7z
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

# iconv does not depend on any libs
build_root_add_makefile_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/libiconv . iconv
    "" # no extra c flags
    "" # no extra cxx flags
    "
        --enable-static=yes
        --enable-shared=no
    " # extra configure arguments
)

# zlib does not depend on any libs
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/zlib . zlib
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

if (WIN32)
    build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/wineditline . LibEdit
        "" # no extra c flags
        "" # no extra cxx flags
        "
          -D BUILD_SHARED_LIBS=OFF
        "
    )
else()
    if (ANDROID)
        # https://android.googlesource.com/platform/bionic/+/master/docs/status.md
        # android does not have ncurses so we must build it
        build_root_add_makefile_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/ncurses . ncurses
            "" # no extra c flags
            "" # no extra cxx flags
            "
                --disable-stripping
            " # extra configure arguments
        )
    endif()
    build_root_add_makefile_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/libedit-20230828-3.1 . LibEdit
        # wchar_t must store ISO 10646 characters
        "-I${LLVM_BUILD_ROOT__ROOTFS}/include/ncurses -D__STDC_ISO_10646__ -DNBBY=${BUILD_ROOT_____________NBBY}" # extra c flags
        "-I${LLVM_BUILD_ROOT__ROOTFS}/include/ncurses -D__STDC_ISO_10646__ -DNBBY=${BUILD_ROOT_____________NBBY}" # extra cxx flags
        "
            --enable-static=yes
            --enable-shared=no
        " # extra configure arguments
    )
endif()

# lz4 does not depend on any libs
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/ZPack/externals/lz4 build/cmake lz4
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

# xz does not depend on any libs

if(CMAKE_C_FLAGS MATCHES "-fsanitize=")
    # Of our three sandbox methods, only Landlock is incompatible
    # with -fsanitize. FreeBSD 13.2 with Capsicum was tested with
    # -fsanitize=address,undefined and had no issues. OpenBSD (as
    # of version 7.4) has minimal support for process instrumentation.
    # OpenBSD does not distribute the additional libraries needed
    # (libasan, libubsan, etc.) with GCC or Clang needed for runtime
    # sanitization support and instead only support
    # -fsanitize-minimal-runtime for minimal undefined behavior
    # sanitization. This minimal support is compatible with our use
    # of the Pledge sandbox. So only Landlock will result in a
    # build that cannot compress or decompress a single file to
    # standard out.
    build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/xz . xz
        "" # no extra c flags
        "" # no extra cxx flags
        "
          -D BUILD_SHARED_LIBS=OFF
          -D ENABLE_SANDBOX=OFF
          -D USE_ATTR_IFUNC=OFF
          -D ALLOW_ATTR_IFUNC=OFF
        "
    )
else()
    build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/xz . xz
        "" # no extra c flags
        "" # no extra cxx flags
        "
          -D BUILD_SHARED_LIBS=OFF
        "
    )
endif()

# zstd does not depend on any libs
# zstd programs depend on zlib, lzma, lz4
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/zstd build/cmake zstd
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

# xxHash does not depend on any libs
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/ZPack/externals/xxHash cmake_unofficial xxHash
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

# bzip2 does not depend on any libs
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/bzip2 . bzip2
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

# libxml2 depends on xz (lzma) and zlib and iconv (and glob (android only))
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/libxml2 . xml2
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
      -D LIBXML2_WITH_PYTHON=OFF
    "
)

# openssl does not depend on any libs
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/openssl-cmake . openssl
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

# expat does not depend on any libs
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/libexpat expat expat
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

# lzo2 does not depend on any libs
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/lzo-2.10 . lzo2
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
    "
)

# libarchive depends on zlib, bzip2, xz (lzma), lzo2, lz4, openssl, libzml2, and expat
build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/deps/libarchive . archive
    "" # no extra c flags
    "" # no extra cxx flags
    "
      -D BUILD_SHARED_LIBS=OFF
      -D ENABLE_LZO=ON
    "
)

find_package(LibEdit REQUIRED)
find_package(ZLIB REQUIRED)
find_package(LZ4 REQUIRED)
find_package(LZMA REQUIRED)
find_package(7z REQUIRED)
find_package(zstd REQUIRED)
find_package(xxHash REQUIRED)
find_package(BZIP2 REQUIRED)
find_package(ICONV REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(EXPAT REQUIRED)
find_package(LZO2 REQUIRED)
find_package(Archive REQUIRED)

message("LIBEDIT LIBS: ${LibEdit_LIBRARIES}")
message("ZLIB LIBS: ${ZLIB_LIBRARIES}")
message("LZ4 LIBS: ${LZ4_LIBRARIES}")
message("LZMA LIBS: ${LZMA_LIBRARIES}")
message("7Z LIBS: ${7Z_LIBRARIES}")
message("ZSTD LIB: ${zstd_LIBRARY}")
message("XXHASH LIBS: ${xxHash_LIBRARIES}")
message("BZip2 LIBS: ${BZIP2_LIBRARIES}")
message("ICONV LIBS: ${ICONV_LIBRARIES}")
message("Xml2 LIBS: ${LIBXML2_LIBRARIES}")
message("OpenSSL LIBS: ${OPENSSL_LIBRARIES}")
message("OpenSSL Crypto LIBS: ${OPENSSL_CRYPTO_LIBRARIES}")
message("Expat LIBS: ${EXPAT_LIBRARIES}")
message("Lzo2 LIBS: ${LZO2_LIBRARIES}")
message("Archive LIBS: ${ARCHIVE_LIBRARIES}")
message("LIBEDIT INCLUDE_DIRECTORIES: ${LibEdit_INCLUDE_DIRS}")
message("ZLIB INCLUDE_DIRECTORIES: ${ZLIB_INCLUDE_DIRS}")
message("LZ4 INCLUDE_DIRECTORIES: ${LZ4_INCLUDE_DIRS}")
message("LZMA INCLUDE_DIRECTORIES: ${LZMA_INCLUDE_DIRS}")
message("7Z INCLUDE_DIRECTORIES: ${7Z_INCLUDE_DIRS}")
message("ZSTD INCLUDE_DIRECTORIES: ${zstd_INCLUDE_DIRS}")
message("XXHASH INCLUDE_DIRECTORIES: ${xxHash_INCLUDE_DIRS}")
message("ICONV INCLUDE_DIRECTORIES: ${ICONV_INCLUDE_DIRS}")
message("Xml2 INCLUDE_DIRECTORIES: ${LIBXML2_INCLUDE_DIRS}")
message("OpenSSL INCLUDE_DIRECTORIES: ${OPENSSL_INCLUDE_DIRS}")
message("Expat INCLUDE_DIRECTORIES: ${EXPAT_INCLUDE_DIRS}")
message("Lzo2 INCLUDE_DIRECTORIES: ${LZO2_INCLUDE_DIRS}")
message("Archive INCLUDE_DIRECTORIES: ${ARCHIVE_INCLUDE_DIRS}")
message("ZLIB_TARGET = ${ZLIB_TARGET}")
message("LZ4_TARGET = ${LZ4_TARGET}")
message("LZMA_TARGET = ${LZMA_TARGET}")
message("7Z_TARGET = ${7Z_TARGET}")
message("zstd_TARGET = ${zstd_TARGET}")
message("xxHash_TARGET = ${xxHash_TARGET}")
message("BZIP2_TARGET = ${BZIP2_TARGET}")
message("ICONV_TARGET = ${ICONV_TARGET}")
message("LIBXML2_TARGET = ${LIBXML2_TARGET}")
message("OPENSSL_TARGET = ${OPENSSL_TARGET}")
message("OPENSSL_CRYPTO_TARGET = ${OPENSSL_CRYPTO_TARGET}")
message("EXPAT_TARGET = ${EXPAT_TARGET}")
message("LZO2_TARGET = ${LZO2_TARGET}")
message("ARCHIVE_TARGET = ${ARCHIVE_TARGET}")

# set(ZPACK_USE_SYSTEM_LZ4 ON CACHE BOOL "" FORCE)
# set(ZPACK_USE_SYSTEM_ZSTD ON CACHE BOOL "" FORCE)
# set(ZPACK_USE_SYSTEM_XXHASH ON CACHE BOOL "" FORCE)

# if(NOT COMMAND testBuilder_build)
#     add_subdirectory(testBuilder)
#     testBuilder_set_current_working_directory_to_default_binary_directory()
# endif()

# unset(LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION)
# unset(LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION CACHE)

# unset(LIBRARY_LLVM_18_STATIC)
# unset(LIBRARY_LLVM_18_STATIC CACHE)

# unset(LIBRARY_LLVM_18_STATIC_PATH)
# unset(LIBRARY_LLVM_18_STATIC_PATH CACHE)
# #set(LIBRARY_LLVM_18_STATIC_PATH ${CMAKE_BINARY_DIR})
# set(LIBRARY_LLVM_18_STATIC_PATH ${CMAKE_CURRENT_SOURCE_DIR}/release_BUILD)


# find_library(
#   LIBRARY_LLVM_18_STATIC
#   NAMES LLVM_18_STATIC
#   PATHS ${LIBRARY_LLVM_18_STATIC_PATH}
#   NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH
#   NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH
#   NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH
#   NO_CMAKE_FIND_ROOT_PATH
# )
# if ("${LIBRARY_LLVM_18_STATIC}" STREQUAL "LIBRARY_LLVM_18_STATIC-NOTFOUND")
#   message("LLVM_18_STATIC NOT FOUND, generating\n")
#   set(LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION TRUE)
# else()
#   unset(LIBRARY_CLANG_18_STATIC)
#   unset(LIBRARY_CLANG_18_STATIC CACHE)
#   find_library(
#     LIBRARY_CLANG_18_STATIC
#     NAMES CLANG_18_STATIC
#     PATHS ${LIBRARY_LLVM_18_STATIC_PATH}
#     NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH
#     NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH
#     NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH
#     NO_CMAKE_FIND_ROOT_PATH
#   )
#   if ("${LIBRARY_CLANG_18_STATIC}" STREQUAL "LIBRARY_CLANG_18_STATIC-NOTFOUND")
#     message("CLANG_18_STATIC NOT FOUND, generating\n")
#     set(LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION TRUE)
#   else()
#     unset(LIBRARY_LLDB_18_STATIC)
#     unset(LIBRARY_LLDB_18_STATIC CACHE)
#     find_library(
#       LIBRARY_LLDB_18_STATIC
#       NAMES LLDB_18_STATIC
#       PATHS ${LIBRARY_LLVM_18_STATIC_PATH}
#       NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH
#       NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH
#       NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH
#       NO_CMAKE_FIND_ROOT_PATH
#     )
#     if ("${LIBRARY_LLDB_18_STATIC}" STREQUAL "LIBRARY_LLDB_18_STATIC-NOTFOUND")
#       message("LLDB_18_STATIC NOT FOUND, generating\n")
#       set(LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION TRUE)
#     else()
#       if (NOT EXISTS ${LIBRARY_LLVM_18_STATIC_PATH}/LLVM_18_STATIC.target_link_libraries)
#         message(WARNING "LLVM_18_STATIC.target_link_libraries (list of required system libs) NOT FOUND, generating\n")
#         set(LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION TRUE)
#       else()
#         if (NOT EXISTS ${LIBRARY_LLVM_18_STATIC_PATH}/LLVM_18_STATIC.lldb_server_path)
#           message(WARNING "LLVM_18_STATIC.lldb_server_path (path to built lldb-server executable) NOT FOUND, generating\n")
#           set(LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION TRUE)
#         else()
#           set(LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION FALSE)
#         endif()
#       endif()
#     endif()
#   endif()
# endif()

# # clang and gcc don't default-print colored diagnostics when invoked from Ninja.
# if (UNIX AND
#     CMAKE_GENERATOR MATCHES "Ninja" AND
#     (CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR
#     (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND
#       NOT (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9))))
#   append("-fdiagnostics-color" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
# endif()

# # lld doesn't print colored diagnostics when invoked from Ninja
# if (UNIX AND CMAKE_GENERATOR MATCHES "Ninja")
#   include(LLVMCheckLinkerFlag)
#   llvm_check_linker_flag(CXX "-Wl,--color-diagnostics" LINKER_SUPPORTS_COLOR_DIAGNOSTICS)
#   append_if(LINKER_SUPPORTS_COLOR_DIAGNOSTICS "-Wl,--color-diagnostics"
#     CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS)
# endif()

# macro (exec)
#     unset(command_list)
#     unset(command_list CACHE)

#     string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" command_list "${ARGN}")

#     unset(command_str)
#     unset(command_str CACHE)

#     foreach(ARG IN ITEMS ${command_list})
#         if (command_str)
#           string(APPEND command_str " ")
#         endif()

#         string(APPEND command_str "'${ARG}'")
#     endforeach()

#     execute_process(
#         COMMAND ${command_list}
#         COMMAND_ECHO STDOUT
#         RESULT_VARIABLE EXEC_FAILED
#     )
#     if (EXEC_FAILED)
#         message(FATAL_ERROR "failed to execute command: '${command_str}'")
#     endif()

# endmacro()

# macro(exit)
#   message(FATAL_ERROR "exiting")
# endmacro()

# if (NOT NIX_SHELL)
#   message("bootstrapping build environment")

#   # locate nix
#   macro(find_nix)
#     function(find_nix_program PROGRAM_VAR program)
#       # we need which
#       find_program(WHICH_COMMAND NAMES which REQUIRED)
#       if (NOT WHICH_COMMAND)
#           message(FATAL_ERROR "could not locate 'which' command")
#       endif()
#       execute_process(
#           COMMAND ${WHICH_COMMAND} ${program}
#           OUTPUT_VARIABLE PROGRAM
#           RESULT_VARIABLE EXEC_FAILED
#       )
#       if (EXEC_FAILED)
#           message(FATAL_ERROR "failed to find program: '${program}'")
#       endif()
#       set(${PROGRAM_VAR} ${PROGRAM} PARENT_SCOPE)
#     endfunction()

#     find_nix_program(NIX_COMMAND nix)
#     find_nix_program(NIX_SHELL_COMMAND nix-shell)
#     find_nix_program(NIX_BUILD_COMMAND nix-build)
#   endmacro()

#   find_nix()

#   macro (exec_build)

#       unset(command_list)
#       unset(command_list CACHE)

#       string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" command_list "${ARGN}")

#       unset(command_str)
#       unset(command_str CACHE)

#       foreach(ARG IN ITEMS ${command_list})
#           if (command_str)
#             string(APPEND command_str " ")
#           endif()

#           string(APPEND command_str "'${ARG}'")
#       endforeach()

#       execute_process(
#           COMMAND ${command_list}
#           COMMAND_ECHO STDOUT
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/BOOTSTRAP_NIX_BUILD_DIR
#           RESULT_VARIABLE EXEC_FAILED
#       )
#       if (EXEC_FAILED)
#           message(FATAL_ERROR "failed to execute command: '${command_str}'")
#       endif()

#   endmacro()

#   #if (NOT EXISTS ${CMAKE_BINARY_DIR}/BOOTSTRAP_NIX_BUILD_DIR)
#   #    execute_process(
#   #        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/BOOTSTRAP_NIX_BUILD_DIR"
#   #        RESULT_VARIABLE BOOTSTRAP_NIX_BUILD_DIR__COMMAND_FAILED
#   #    )
#   #    if (BOOTSTRAP_NIX_BUILD_DIR__COMMAND_FAILED)
#   #        message(FATAL_ERROR "failed to create directory '${CMAKE_BINARY_DIR}/BOOTSTRAP_NIX_BUILD_DIR'")
#   #    endif()
#   #endif()

#   exec(${NIX_SHELL_COMMAND} --version)

#   unset(HAS_CMAKE_COLOR)
#   unset(HAS_CMAKE_COLOR CACHE)

#   if (CMAKE_COLOR_MAKEFILE OR CMAKE_COLOR_DIAGNOSTICS)
#     set(HAS_CMAKE_COLOR ON)
#   endif()

#   #exec_build(${NIX_BUILD_COMMAND} --no-out-link ${CMAKE_CURRENT_SOURCE_DIR}/build.nix)

#   exec(
#     ${NIX_SHELL_COMMAND}
#       --pure
#       ${CMAKE_CURRENT_SOURCE_DIR}/nix/linux.nix
#       --run
#         "pwd \; CLICOLOR_FORCE=${HAS_CMAKE_COLOR} cmake -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -D CMAKE_COLOR_MAKEFILE=${CMAKE_COLOR_MAKEFILE} -D CMAKE_COLOR_DIAGNOSTICS=${CMAKE_COLOR_DIAGNOSTICS} -D NIX_SHELL=1 -D NIX_SHELL_OS_LINUX=1 -B NIX_SHELL_BOOTSTRAP_BUILD__LINUX ${CMAKE_CURRENT_SOURCE_DIR}\; true"
#   )

#   exec(
#     ${NIX_SHELL_COMMAND}
#       --pure
#       ${CMAKE_CURRENT_SOURCE_DIR}/nix/mingw-ncurses.nix
#       --run "true"
#   )

#   exec(
#     ${NIX_SHELL_COMMAND}
#       --pure
#       ${CMAKE_CURRENT_SOURCE_DIR}/nix/mingw.nix
#       --run
#         "pwd \; CLICOLOR_FORCE=${HAS_CMAKE_COLOR} cmake -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -D CMAKE_COLOR_MAKEFILE=${CMAKE_COLOR_MAKEFILE} -D CMAKE_COLOR_DIAGNOSTICS=${CMAKE_COLOR_DIAGNOSTICS} -D NIX_SHELL=1 -D NIX_SHELL_OS_WINDOWS=1 -B NIX_SHELL_BOOTSTRAP_BUILD__WINDOWS ${CMAKE_CURRENT_SOURCE_DIR}\; true"
#   )

#   exit()
# endif()

# message(WARNING "we are inside a bootstrap build environment")

# include(build_root/build_root.cmake)

# build_root_init(${CMAKE_CURRENT_SOURCE_DIR}/cmake/packages ${CMAKE_CURRENT_BINARY_DIR}/BUILD_ROOT)

# message("CMAKE_SYSTEM_NAME = ${CMAKE_SYSTEM_NAME}")
# message("CMAKE_C_COMPILER = ${CMAKE_C_COMPILER}")


# if (NIX_SHELL_OS_WINDOWS)
#   build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/wineditline . libedit
#   "" # no extra c flags
#   "" # no extra cxx flags
#   "
#     -D BUILD_SHARED_LIBS=OFF
#   ")
# endif()

# build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/lzma2301 . 7z
# "" # no extra c flags
# "" # no extra cxx flags
# "
#   -D BUILD_SHARED_LIBS=OFF
# ")

# if (LIBRARY_LLVM_18_STATIC_NEEDS_GENERATION)

#   # - static
#   #
#   # -  :$<TARGET_OBJECTS:objLib>
#   #
#   # du -shc ./release_BUILD/llvm/lib/* | grep -e "LLVM.*\.a" | sed -e "s/.*libLLVM/list\(APPEND LLVM_MC_JIT_LINK_LIBS LLVM/g" -e "s/\.a/\)/g" > llvm_libs.cmake
#   # du -shc ./release_BUILD/llvm/lib/* | grep -e "clang.*\.a" | sed -e "s/.*libclang/list\(APPEND LLVM_MC_JIT_LINK_LIBS clang/g" -e "s/\.a/\)/g" > clang_libs.cmake

#   list(APPEND LLVM_MC_JIT_LINK_LIBS LLVMSupportBlake3)

#   include(./llvm_libs.cmake)
#   include(./clang_libs.cmake)
#   include(./lldb_libs.cmake)

#   if(UNIX)

#     include(CheckIncludeFile)
#     check_include_file("opagent.h" HAVE_OPAGENT_H)

#     if (HAVE_OPAGENT_H)
#       set(LLVM_USE_OPROFILE ON CACHE BOOL "" FORCE)
#       list(APPEND LLVM_MC_JIT_LINK_LIBS LLVMOProfileJIT)
#     endif()

#     set(LLVM_USE_PERF ON CACHE BOOL "" FORCE)
#     list(APPEND LLVM_MC_JIT_LINK_LIBS LLVMPerfJITEvents)

#   endif()

#   if(WIN32 OR UNIX)
#     set(LLVM_USE_INTEL_JITEVENTS ON CACHE BOOL "" FORCE)
#     list(APPEND LLVM_MC_JIT_LINK_LIBS LLVMIntelJITEvents)
#   endif()


#   # shared llvm is supported but shared clang is not supported
#   # see https://github.com/llvm/llvm-project/issues/46461
#   set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
#   set(LLVM_INCLUDE_TESTS OFF CACHE BOOL "" FORCE)
#   set(LLVM_INCLUDE_RUNTIMES OFF CACHE BOOL "" FORCE)
#   set(LLVM_INCLUDE_EXAMPLES OFF CACHE BOOL "" FORCE)
#   set(LLVM_INCLUDE_BENCHMARKS OFF CACHE BOOL "" FORCE)
#   set(LLVM_INCLUDE_DOCS OFF CACHE BOOL "" FORCE)
#   # LLVM_BUILD_TOOLS is required for to build clang
#   set(LLVM_BUILD_TOOLS ON CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_UTILS OFF CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_RUNTIMES OFF CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_RUNTIME OFF CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_BENCHMARKS OFF CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_DOCS OFF CACHE BOOL "" FORCE)
#   set(LLVM_ENABLE_DOXYGEN OFF CACHE BOOL "" FORCE)
#   set(LLVM_ENABLE_SPHINX OFF CACHE BOOL "" FORCE)
#   set(LLVM_ENABLE_OCAMLDOC OFF CACHE BOOL "" FORCE)
#   set(LLVM_ENABLE_BINDINGS OFF CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_EXTERNAL_COMPILER_RT OFF CACHE BOOL "" FORCE)
#   set(LLVM_VERSION_PRINTER_SHOW_HOST_TARGET_INFO ON CACHE BOOL "" FORCE)
#   set(LLVM_BUILD_LLVM_C_DYLIB OFF CACHE BOOL "" FORCE)
#   set(LLVM_OPTIMIZED_TABLEGEN ON CACHE BOOL "" FORCE)
#   set(LLVM_ENABLE_EH ON CACHE BOOL "" FORCE)
#   set(LLVM_ENABLE_RTTI ON CACHE BOOL "" FORCE)
#   set(LLVM_ENABLE_PROJECTS "clang;lldb" CACHE STRING "" FORCE)

#   if(CMAKE_BUILD_TYPE STREQUAL "Debug")
#     set(LLVM_UNREACHABLE_OPTIMIZE OFF CACHE BOOL "" FORCE)
#   endif()

#   set(CLANG_ENABLE_ARCMT OFF CACHE BOOL "" FORCE)
#   set(CLANG_ENABLE_STATIC_ANALYZER OFF CACHE BOOL "" FORCE)
#   set(CLANG_ENABLE_PROTO_FUZZER OFF CACHE BOOL "" FORCE)
#   set(CLANG_ENABLE_HLSL OFF CACHE BOOL "" FORCE)
#   set(CLANG_INCLUDE_EXAMPLES OFF CACHE BOOL "" FORCE)
#   set(CLANG_INCLUDE_TOOLS OFF CACHE BOOL "" FORCE)
#   set(CLANG_INCLUDE_DOCS OFF CACHE BOOL "" FORCE)
#   set(CLANG_INCLUDE_TESTS OFF CACHE BOOL "" FORCE)
#   set(CLANG_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
#   set(CLANG_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
#   set(CLANG_BUILD_DOCS OFF CACHE BOOL "" FORCE)
#   set(CLANG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
#   set(CLANG_ENABLE_BOOTSTRAP OFF CACHE BOOL "" FORCE)

#   add_subdirectory(llvm)

#   foreach(lib IN ITEMS ${LLVM_MC_JIT_LINK_LIBS})
#     if (TARGET ${lib})
#       if (${lib} MATCHES "^LLVM")
#         list(APPEND LLVM_MC_JIT_LINK_LIBS_LLVM ${lib})
#         if (TARGET obj.${lib})
#           list(APPEND LLVM_18_OBJECT_FILES $<TARGET_OBJECTS:obj.${lib}>)
#         else()
#           list(APPEND LLVM_18_OBJECT_FILES $<TARGET_OBJECTS:${lib}>)
#         endif()
#         get_target_property(OUT ${lib} LLVM_SYSTEM_LIBS)
#         if (NOT OUT MATCHES "NOTFOUND$")
#           foreach(link_lib IN ITEMS ${OUT})
#             if (link_lib MATCHES "^clang")
#             elseif (link_lib MATCHES "^LLVM")
#             elseif (link_lib MATCHES "^@")
#             elseif (link_lib MATCHES "^:")
#             elseif (link_lib MATCHES ".*::.*")
#             else()
#               list(APPEND LLVM_18_L ${link_lib})
#             endif()
#           endforeach()
#         else()
#           get_target_property(OUT ${lib} LINK_LIBRARIES)
#           if (NOT OUT MATCHES "NOTFOUND$")
#             foreach(link_lib IN ITEMS ${OUT})
#               if (link_lib MATCHES "^clang")
#               elseif (link_lib MATCHES "^LLVM")
#               elseif (link_lib MATCHES "^@")
#               elseif (link_lib MATCHES "^:")
#               elseif (link_lib MATCHES ".*::.*")
#               else()
#                 list(APPEND LLVM_18_L ${link_lib})
#               endif()
#             endforeach()
#           endif()
#         endif()
#       elseif (${lib} MATCHES "^clang")
#         list(APPEND LLVM_MC_JIT_LINK_LIBS_CLANG ${lib})
#         if (TARGET obj.${lib})
#           list(APPEND CLANG_18_OBJECT_FILES $<TARGET_OBJECTS:obj.${lib}>)
#         else()
#           list(APPEND CLANG_18_OBJECT_FILES $<TARGET_OBJECTS:${lib}>)
#         endif()
#       else()

#         # lldbAPI is not a target but liblldbAPI is a target
#         #
#         if (${lib} MATCHES "^lldb" OR ${lib} MATCHES "^liblldb")
#           list(APPEND LLVM_MC_JIT_LINK_LIBS_LLDB ${lib})
#           if (TARGET obj.${lib})
#             list(APPEND LLDB_18_OBJECT_FILES $<TARGET_OBJECTS:obj.${lib}>)
#           else()
#             list(APPEND LLDB_18_OBJECT_FILES $<TARGET_OBJECTS:${lib}>)
#           endif()
#         endif()
#       endif()
#     else()
#       message(WARNING "${lib} is not a target")
#     endif()
#   endforeach()

#   list(REMOVE_DUPLICATES LLVM_18_L)
#   list(REMOVE_ITEM z LLVM_18_L)
#   list(REMOVE_ITEM zstd LLVM_18_L)
#   list(REMOVE_ITEM xml2 LLVM_18_L)

#   message("linking against these LLVM libraries : ${LLVM_MC_JIT_LINK_LIBS_LLVM}")
#   message("linking against these CLANG libraries : ${LLVM_MC_JIT_LINK_LIBS_CLANG}")
#   message("linking against these LLDB libraries : ${LLVM_MC_JIT_LINK_LIBS_LLDB}")
#   message("linking against these system libraries : ${LLVM_18_L}")

#   add_library(LLVM_18_STATIC STATIC empty.c ${LLVM_18_OBJECT_FILES})
#   target_include_directories(LLVM_18_STATIC SYSTEM PUBLIC ${LIBRARY_LLVM_18_STATIC_PATH}/llvm/include)
#   target_include_directories(LLVM_18_STATIC SYSTEM PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/llvm/include)
#   target_include_directories(LLVM_18_STATIC SYSTEM INTERFACE ${LibEdit_INCLUDE_DIRS})
#   target_link_libraries(LLVM_18_STATIC PUBLIC ${LLVM_18_L} ${LibEdit_TARGET})
#   file(WRITE ${LIBRARY_LLVM_18_STATIC_PATH}/LLVM_18_STATIC.target_link_libraries "${LLVM_18_L}")

#   add_library(CLANG_18_STATIC STATIC empty.c ${CLANG_18_OBJECT_FILES})
#   target_include_directories(CLANG_18_STATIC SYSTEM PUBLIC ${LIBRARY_LLVM_18_STATIC_PATH}/llvm/tools/clang/include)
#   target_include_directories(CLANG_18_STATIC SYSTEM PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/clang/include)
#   target_link_libraries(CLANG_18_STATIC PUBLIC LLVM_18_STATIC)

#   add_library(LLDB_18_STATIC STATIC empty.c ${LLDB_18_OBJECT_FILES})
#   target_include_directories(LLDB_18_STATIC SYSTEM PUBLIC ${LIBRARY_LLVM_18_STATIC_PATH}/llvm/tools/lldb/include)
#   target_include_directories(LLDB_18_STATIC SYSTEM PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/lldb/include)
#   target_link_libraries(LLDB_18_STATIC PUBLIC CLANG_18_STATIC)

#   file(GENERATE OUTPUT ${LIBRARY_LLVM_18_STATIC_PATH}/LLVM_18_STATIC.lldb_server_path CONTENT $<TARGET_FILE:lldb-server>)
  
#   set(LLDB_18_SERVER_PATH $<TARGET_FILE:lldb-server>)

#   add_dependencies(LLDB_18_STATIC lldb)
#   add_dependencies(LLDB_18_STATIC lldb-server)

# else()

#   message("reusing LLVM_18  - ${LIBRARY_LLVM_18_STATIC}")
#   message("reusing CLANG_18 - ${LIBRARY_CLANG_18_STATIC}")
#   message("reusing LLDB_18  - ${LIBRARY_LLDB_18_STATIC}")

#   add_library(LLVM_18_STATIC STATIC IMPORTED)
#   set_target_properties(LLVM_18_STATIC PROPERTIES IMPORTED_LOCATION ${LIBRARY_LLVM_18_STATIC})
#   target_include_directories(LLVM_18_STATIC SYSTEM INTERFACE ${LIBRARY_LLVM_18_STATIC_PATH}/llvm/include)
#   target_include_directories(LLVM_18_STATIC SYSTEM INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/llvm/include)
#   target_include_directories(LLVM_18_STATIC SYSTEM INTERFACE ${LibEdit_INCLUDE_DIRS})
#   file(READ ${LIBRARY_LLVM_18_STATIC_PATH}/LLVM_18_STATIC.target_link_libraries LLVM_18_L)
#   list(REMOVE_ITEM z LLVM_18_L)
#   list(REMOVE_ITEM zstd LLVM_18_L)
#   list(REMOVE_ITEM xml2 LLVM_18_L)
#   target_link_libraries(LLVM_18_STATIC INTERFACE ${LLVM_18_L} ${LibEdit_TARGET})

#   add_library(CLANG_18_STATIC STATIC IMPORTED)
#   set_target_properties(CLANG_18_STATIC PROPERTIES IMPORTED_LOCATION ${LIBRARY_CLANG_18_STATIC})
#   target_include_directories(CLANG_18_STATIC SYSTEM INTERFACE ${LIBRARY_LLVM_18_STATIC_PATH}/llvm/tools/clang/include)
#   target_include_directories(CLANG_18_STATIC SYSTEM INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/clang/include)
#   target_link_libraries(CLANG_18_STATIC INTERFACE LLVM_18_STATIC)

#   add_library(LLDB_18_STATIC STATIC IMPORTED)
#   set_target_properties(LLDB_18_STATIC PROPERTIES IMPORTED_LOCATION ${LIBRARY_LLDB_18_STATIC})
#   target_include_directories(LLDB_18_STATIC SYSTEM INTERFACE ${LIBRARY_LLVM_18_STATIC_PATH}/llvm/tools/lldb/include)
#   target_include_directories(LLDB_18_STATIC SYSTEM INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/lldb/include)
#   target_link_libraries(LLDB_18_STATIC INTERFACE CLANG_18_STATIC)
#   file(READ ${LIBRARY_LLVM_18_STATIC_PATH}/LLVM_18_STATIC.lldb_server_path LLDB_18_SERVER_PATH)

# endif()

# set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
# set(LIBZIP_DO_INSTALL OFF CACHE BOOL "" FORCE)
# add_subdirectory(libzip)
# add_subdirectory(ZPack)

# target_compile_definitions(zip PUBLIC ZIP_ALLOCATE_BUFFER)

# add_executable(llvm_orcjit_example_packager src/package.cpp)
# target_link_libraries(llvm_orcjit_example_packager zip zpack LLVM_18_STATIC
#     ${ZLIB_TARGET}
#     ${LZ4_TARGET}
#     ${7Z_TARGET}
#     ${zstd_TARGET}
#     ${xxHash_TARGET}
#     ${BZIP2_TARGET}
#     ${LIBXML2_TARGET}
#     ${OPENSSL_CRYPTO_TARGET}
#     ${OPENSSL_SSL_TARGET}
#     ${EXPAT_TARGET}
#     ${ARCHIVE_TARGET}
#     ${LZMA_TARGET}
# )

# target_compile_options(zip PRIVATE "-O3")
# target_compile_options(zip PRIVATE "-g0")

# target_compile_options(llvm_orcjit_example_packager PRIVATE "-O3")
# target_compile_options(llvm_orcjit_example_packager PRIVATE "-g0")

# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES)
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES CACHE)

# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE CACHE)
# get_target_property(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE zip INCLUDE_DIRECTORIES)
# if (LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
#   string(REPLACE ";" " " LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE "${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE}")
#   string(APPEND LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES ${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE})
# endif()
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE CACHE)

# get_target_property(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE zip INTERFACE_INCLUDE_DIRECTORIES)
# if (LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
#   string(REPLACE ";" " " LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE "${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE}")
#   string(APPEND LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES ${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE})
# endif()
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE CACHE)

# get_target_property(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE zpack INCLUDE_DIRECTORIES)
# if (LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
#   string(REPLACE ";" " " LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE "${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE}")
#   string(APPEND LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES ${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE})
# endif()
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE CACHE)

# get_target_property(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE zpack INTERFACE_INCLUDE_DIRECTORIES)
# if (LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
#   string(REPLACE ";" " " LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE "${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE}")
#   string(APPEND LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES ${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE})
# endif()
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE CACHE)

# get_target_property(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE LLVM_18_STATIC INCLUDE_DIRECTORIES)
# if (LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
#   string(REPLACE ";" " " LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE "${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE}")
#   string(APPEND LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES ${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE})
# endif()
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE CACHE)

# get_target_property(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE LLVM_18_STATIC INTERFACE_INCLUDE_DIRECTORIES)
# if (LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
#   string(REPLACE ";" " " LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE "${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE}")
#   string(APPEND LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES ${LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE})
# endif()
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE)
# unset(LLVM_18_STATIC_EMBEDDED_RESOURCES_TMP_INCLUDE CACHE)

# add_custom_command(
#   OUTPUT ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/CMakeLists.txt
#   COMMAND
#     ${CMAKE_COMMAND} -E rm -f -- ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/CMakeLists.txt
#   COMMAND
#     ${CMAKE_COMMAND} -E echo removing directory ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/GEN
#   COMMAND
#     ${CMAKE_COMMAND} -E rm -rf -- ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/GEN
#   COMMAND
#     ${CMAKE_COMMAND} -E echo removing directory ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/BUILD
#   COMMAND
#     ${CMAKE_COMMAND} -E rm -rf -- ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/BUILD
#   COMMAND
#     ${CMAKE_COMMAND} -E echo creating directory ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/GEN
#   COMMAND
#     ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/GEN
#   COMMAND
#     lldb $<TARGET_FILE:llvm_orcjit_example_packager>

#     OUTPUT_CMAKE ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/CMakeLists.txt

#     OUTPUT_FILE_DIRECTORY ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/GEN

#     OUTPUT_FILE_NAME llvm_orcjit_example_packaged_zip

#     OUTPUT_FILE_SUFFIX archive

#     OUTPUT_DATA_LABEL llvm_orcjit_example_packaged_zip_data

#     CMAKE_LINK_LIBS
#       ${ZLIB_LIBRARIES}
#       ${LZ4_LIBRARIES}
#       ${7Z_LIBRARIES}
#       ${zstd_LIBRARY}
#       ${xxHash_LIBRARIES}
#       ${BZIP2_LIBRARIES}
#       ${LIBXML2_LIBRARIES}
#       ${OPENSSL_CRYPTO_LIBRARY}
#       ${OPENSSL_SSL_LIBRARY}
#       ${EXPAT_LIBRARIES}
#       ${ARCHIVE_LIBRARIES}
#       ${LZMA_LIBRARIES}
#       $<TARGET_FILE:zip>
#       $<TARGET_FILE:zpack>
#       $<TARGET_FILE:LLVM_18_STATIC>
    
#     CMAKE_LINK_INCLUDES
#       ${ZLIB_INCLUDE_DIRS}
#       ${LZ4_INCLUDE_DIRS}
#       ${7Z_INCLUDE_DIRS}
#       ${zstd_INCLUDE_DIRS}
#       ${xxHash_INCLUDE_DIRS}
#       ${BZIP2_INCLUDE_DIRS}
#       ${LIBXML2_INCLUDE_DIRS}
#       ${OPENSSL_INCLUDE_DIR}
#       ${EXPAT_INCLUDE_DIRS}
#       ${ARCHIVE_INCLUDE_DIRS}
#       ${LZMA_INCLUDE_DIRS}
#       ${LLVM_18_STATIC_EMBEDDED_RESOURCES_REAL_INCLUDES}

#     EXECUTABLES
#       LLDB_SERVER ${LLDB_18_SERVER_PATH}

#     STATIC_LIBS
#       LLVM_18 $<TARGET_FILE:LLVM_18_STATIC>
#       CLANG_18 $<TARGET_FILE:CLANG_18_STATIC>
#       LLDB_18 $<TARGET_FILE:LLDB_18_STATIC>
#       CLANG_DRIVER $<TARGET_FILE:clang_driver>
#       LIBEDIT ${LibEdit_LIBRARIES}
#       ZIP $<TARGET_FILE:zip>
#       ZPACK $<TARGET_FILE:zpack>
#       ZLIB ${ZLIB_LIBRARIES}
#       LZ4 ${LZ4_LIBRARIES}
#       7Z ${7Z_LIBRARIES}
#       ZSTD ${zstd_LIBRARY}
#       XXHASH ${xxHash_LIBRARIES}
#       BZIP2 ${BZIP2_LIBRARIES}
#       LIBXML2 ${LIBXML2_LIBRARIES}
#       OPENSSL_CRYPTO ${OPENSSL_CRYPTO_LIBRARY}
#       OPENSSL_SSL ${OPENSSL_SSL_LIBRARY}
#       EXPAT ${EXPAT_LIBRARIES}
#       ARCHIVE ${ARCHIVE_LIBRARIES}
#       LZMA ${LZMA_LIBRARIES}

#     SYS_LIBS
#       ${LLVM_18_L}

#   DEPENDS llvm_orcjit_example_packager
# )

# add_custom_target(llvm_orcjit_example_packaged_zip_gen_cmake DEPENDS ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/CMakeLists.txt)

# add_custom_command(
#   OUTPUT ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/BUILD/llvm_orcjit_example_packaged_zip.archive
#   COMMAND
#     ${CMAKE_COMMAND}
#     -DCMAKE_BUILD_TYPE=Debug
#     -B ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/BUILD
#   COMMAND
#     ${CMAKE_COMMAND}
#     --build ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/BUILD
#   WORKING_DIRECTORY
#     ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES
#   DEPENDS
#     ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/CMakeLists.txt
#     llvm_orcjit_example_packaged_zip_gen_cmake
# )

# add_custom_target(llvm_orcjit_example_packaged_zip_gen_archive DEPENDS ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/BUILD/llvm_orcjit_example_packaged_zip.archive)

# add_library(llvm_orcjit_example_packaged_zip_imported_lib STATIC IMPORTED)
# set_target_properties(llvm_orcjit_example_packaged_zip_imported_lib PROPERTIES IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/BUILD/llvm_orcjit_example_packaged_zip.archive)
# add_dependencies(llvm_orcjit_example_packaged_zip_imported_lib llvm_orcjit_example_packaged_zip_gen_archive)

# add_library(llvm_orcjit_example_packaged_zip STATIC empty.c)
# target_link_libraries(llvm_orcjit_example_packaged_zip llvm_orcjit_example_packaged_zip_imported_lib zip zpack LLVM_18_STATIC
#     ${ZLIB_TARGET}
#     ${LZ4_TARGET}
#     ${7Z_TARGET}
#     ${zstd_TARGET}
#     ${xxHash_TARGET}
#     ${BZIP2_TARGET}
#     ${LIBXML2_TARGET}
#     ${OPENSSL_CRYPTO_TARGET}
#     ${OPENSSL_SSL_TARGET}
#     ${EXPAT_TARGET}
#     ${ARCHIVE_TARGET}
#     ${LZMA_TARGET}
# )

# add_library(llvm_orcjit_example_packaged_zip_extract STATIC src/extract.cpp)
# target_link_libraries(llvm_orcjit_example_packaged_zip_extract llvm_orcjit_example_packaged_zip)
# target_include_directories(llvm_orcjit_example_packaged_zip_extract PRIVATE ${CMAKE_BINARY_DIR}/LLVM_18_STATIC_EMBEDDED_RESOURCES/GEN)

# set(PDC_BUILD_SHARED OFF CACHE BOOL "" FORCE)
# set(PDC_SDL2_BUILD OFF CACHE BOOL "" FORCE)
# set(PDC_SDL2_DEPS_BUILD OFF CACHE BOOL "" FORCE)
# set(PDC_GL_BUILD OFF CACHE BOOL "" FORCE)
# add_subdirectory(PDCursesMod)

# add_library(pdcurses STATIC empty.c)
# target_link_libraries(pdcurses vt_pdcursesstatic)
# target_include_directories(pdcurses PUBLIC PDCursesMod)

# add_subdirectory(clang_driver)

# add_subdirectory(replxx)
# set(ARGPARSE_INSTALL OFF CACHE BOOL "" FORCE)
# set(ARGPARSE_BUILD_SAMPLES OFF CACHE BOOL "" FORCE)
# set(ARGPARSE_BUILD_TESTS OFF CACHE BOOL "" FORCE)
# add_subdirectory(argparse)

# add_library(llvm_orcjit STATIC src/jit.cpp)
# target_include_directories(llvm_orcjit PUBLIC include)
# target_link_libraries(llvm_orcjit clang_driver)

# add_executable(llvm_orcjit_example src/example.cpp)

# target_link_libraries(llvm_orcjit_example llvm_orcjit replxx argparse pdcurses llvm_orcjit_example_packaged_zip_extract)

# target_link_options(llvm_orcjit_example PRIVATE "-Wl,--export-dynamic")

# target_compile_options(replxx PRIVATE "-O0")
# target_compile_options(replxx PRIVATE "-g3")
# target_compile_options(zip PRIVATE "-O0")
# target_compile_options(zip PRIVATE "-g3")
# target_compile_options(llvm_orcjit_example_packaged_zip_extract PRIVATE "-O0")
# target_compile_options(llvm_orcjit_example_packaged_zip_extract PRIVATE "-g3")
# target_compile_options(llvm_orcjit_example PRIVATE "-O0")
# target_compile_options(llvm_orcjit_example PRIVATE "-g3")
