cmake_minimum_required(VERSION 3.12)

project(editline_windows C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_POLICY_DEFAULT_CMP0074 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0075 NEW)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

include(./build_root.cmake)

build_root_init(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/packages ${CMAKE_CURRENT_BINARY_DIR}/BUILD_ROOT)

BUILD_ROOT_EXEC(rm -rf ${LLVM_BUILD_ROOT__ROOTFS})
BUILD_ROOT_EXEC(cp -r rootfs ${LLVM_BUILD_ROOT__ROOTFS})

if (BUILD_ROOT_OS__WIN32 OR BUILD_ROOT_OS__MSYS)
    # win/msys
    #
    build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/../deps/wcwidth . wcwidth
        "" # no extra c flags
        "" # no extra cxx flags
        "" # no extra configure arguments
    )
    find_program(CYGPATH_EXE NAMES cygpath.exe)
    if (CYGPATH_EXE)
      execute_process(COMMAND "${CYGPATH_EXE}" "-u" "${LLVM_BUILD_ROOT__ROOTFS}/lib" OUTPUT_VARIABLE CYG_LLVM_BUILD_ROOT__ROOTFS_LIB)
      string(STRIP ${CYG_LLVM_BUILD_ROOT__ROOTFS_LIB} CYG_LLVM_BUILD_ROOT__ROOTFS_LIB)
    endif()
    if (false)
    build_root_add_makefile_package(${CMAKE_CURRENT_SOURCE_DIR}/../deps/ncurses . ncurses
        "-lpthread" # extra c flags
        "-lpthread" # extra cxx flags
        "
            --disable-stripping --with-xterm-kbs=BS --enable-exp-win32 --enable-term-driver --enable-termcap --without-ada --enable-pc-files --disable-echo --with-pkg-config-libdir=\"${CYG_LLVM_BUILD_ROOT__ROOTFS_LIB}\"
        " # extra configure arguments
    )
    endif()
    build_root_add_cmake_package(${CMAKE_CURRENT_SOURCE_DIR}/../deps/libedit-20230828-3.1 . LibEdit
        # wchar_t must store ISO 10646 characters
        "-D__STDC_ISO_10646__ -DNBBY=${BUILD_ROOT_____________NBBY}" # extra c flags
        "-D__STDC_ISO_10646__ -DNBBY=${BUILD_ROOT_____________NBBY}" # extra cxx flags
        "
          -D BUILD_SHARED_LIBS=OFF
        " # extra configure arguments
    )
else()
    # unix/cygwin
    #
    if (false)
    build_root_add_makefile_package(${CMAKE_CURRENT_SOURCE_DIR}/../deps/ncurses . ncurses
        "-lpthread" # extra c flags
        "-lpthread" # extra cxx flags
        "
            --disable-stripping --with-xterm-kbs=BS --enable-term-driver --enable-termcap --without-ada --enable-pc-files --disable-echo --with-pkg-config-libdir=\"${CYG_LLVM_BUILD_ROOT__ROOTFS_LIB}\"
        " # extra configure arguments
    )
    endif()
    build_root_add_makefile_package(${CMAKE_CURRENT_SOURCE_DIR}/../deps/libedit-20230828-3.1 . LibEdit
        # wchar_t must store ISO 10646 characters
        "-I${LLVM_BUILD_ROOT__ROOTFS}/include/ncurses -D__STDC_ISO_10646__ -DNBBY=${BUILD_ROOT_____________NBBY}" # extra c flags
        "-I${LLVM_BUILD_ROOT__ROOTFS}/include/ncurses -D__STDC_ISO_10646__ -DNBBY=${BUILD_ROOT_____________NBBY}" # extra cxx flags
        "
            --enable-static=yes
            --enable-shared=no
        " # extra configure arguments
    )
endif()
