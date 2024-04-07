macro (build_root_exec)
    message(STATUS "build_root_exec ARGN = \"${ARGN}\"")
    unset(command_list)
    unset(command_list CACHE)
    string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" command_list "${ARGN}")
    unset(command_str)
    unset(command_str CACHE)
    foreach(ARG IN ITEMS ${command_list})
        if (command_str)
          string(APPEND command_str " ")
        endif()
        string(APPEND command_str "${ARG}")
    endforeach()
    execute_process(
        COMMAND ${command_list}
        COMMAND_ECHO STDOUT
        RESULT_VARIABLE EXEC_FAILED
    )
    if (EXEC_FAILED)
        message(FATAL_ERROR "failed to execute command: '${command_str}'")
    endif()
endmacro()

macro (build_root_exec_working_directory working_directory)
    message(STATUS "build_root_exec_working_directory ARGN = \"${ARGN}\"")
    unset(command_list)
    unset(command_list CACHE)
    string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" command_list "${ARGN}")
    unset(command_str)
    unset(command_str CACHE)
    foreach(ARG IN ITEMS ${command_list})
        if (command_str)
          string(APPEND command_str " ")
        endif()
        string(APPEND command_str "${ARG}")
    endforeach()
    execute_process(
        COMMAND ${command_list}
        COMMAND_ECHO STDOUT
        RESULT_VARIABLE EXEC_FAILED
        WORKING_DIRECTORY ${working_directory}
    )
    if (EXEC_FAILED)
        message(FATAL_ERROR "failed to execute command: 'cd ${working_directory} ; ${command_str}'")
    endif()
endmacro()

macro (build_root_exec_cmake)
    message(STATUS "build_root_exec_cmake ARGN = \"${ARGN}\"")
    unset(command_list)
    unset(command_list CACHE)
    string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" command_list "${ARGN}")
    unset(command_str)
    unset(command_str CACHE)
    foreach(ARG IN ITEMS ${command_list})
        if (command_str)
          string(APPEND command_str " ")
        endif()
        string(APPEND command_str "${ARG}")
    endforeach()
    execute_process(
        COMMAND
        ${command_list}
        "-DCMAKE_COLOR_DIAGNOSTICS=${CMAKE_COLOR_DIAGNOSTICS}"
        "-DCMAKE_COLOR_MAKEFILE=${CMAKE_COLOR_MAKEFILE}"
        "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
        "-DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}"
        "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
        "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
        "-DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}"
        "-DCMAKE_C_STANDARD=${CMAKE_C_STANDARD}"
        "-DCMAKE_C_STANDARD_REQUIRED=${CMAKE_C_STANDARD_REQUIRED}"
        "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} ${new_line_seperated_extra_c_flags} ${BUILD_ROOT_____________ADDITIONAL_C_FLAGS}"
        "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
        "-DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}"
        "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}"
        "-DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}"
        "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} ${new_line_seperated_extra_cxx_flags} ${BUILD_ROOT_____________ADDITIONAL_C_FLAGS}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${CMAKE_MODULE_LINKER_FLAGS}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}"
        "-DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}"
        "-DCMAKE_INSTALL_PREFIX=${BUILD_ROOT_BUILD_DIRECTORY}/ROOTFS"
        "-DCMAKE_POLICY_DEFAULT_CMP0074=${CMAKE_POLICY_DEFAULT_CMP0074}"
        "-DCMAKE_POLICY_DEFAULT_CMP0075=${CMAKE_POLICY_DEFAULT_CMP0075}"
        "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
        "-DCMAKE_SYSROOT=${CMAKE_SYSROOT}"
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
        "-DCMAKE_SYSTEM_PREFIX_PATH=${CMAKE_SYSTEM_PREFIX_PATH}"
        "-DLLVM_BUILD_ROOT__ROOTFS=${LLVM_BUILD_ROOT__ROOTFS}"
        "-DANDROID_ABI=${ANDROID_ABI}"
        "-DANDROID_ARM_MODE=${ANDROID_ARM_MODE}"
        "-DANDROID_ARM_NEON=${ANDROID_ARM_NEON}"
        "-DANDROID_PLATFORM=${ANDROID_PLATFORM}"
        "-DANDROID_STL=${ANDROID_STL}"
        COMMAND_ECHO STDOUT
        RESULT_VARIABLE EXEC_FAILED
    )
    if (EXEC_FAILED)
        message(FATAL_ERROR "failed to execute command: '${command_str}'")
    endif()
endmacro()

macro(build_root_message str)
  message(${str})
endmacro()

macro(build_root_fatal str)
  message(FATAL_ERROR ${str})
endmacro()

macro(build_root_init cmake_packages_dir build_root_dir)
  if (NOT EXISTS ${cmake_packages_dir})
    build_root_fatal("error: cmake package directory '${cmake_packages_dir}' does not exist")
  endif()
  unset(LLVM_BUILD_ROOT__ROOTFS)
  unset(LLVM_BUILD_ROOT__ROOTFS CACHE)
  set(LLVM_BUILD_ROOT__ROOTFS "${build_root_dir}/ROOTFS" CACHE BOOL "" FORCE)
  list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake/packages")
  list(INSERT CMAKE_SYSTEM_PREFIX_PATH 0 "${build_root_dir}/ROOTFS")

  if (NOT EXISTS ${build_root_dir})
    build_root_exec(mkdir -p ${build_root_dir})
    build_root_exec(mkdir -p ${build_root_dir}/ROOTFS)
    build_root_exec(mkdir -p ${build_root_dir}/BUILD)
    build_root_exec(mkdir -p ${build_root_dir}/SRC)
    if (NOT EXISTS ${build_root_dir})
      build_root_fatal("error: failed to create build root directory '${build_root_dir}'")
    endif()
  endif()

  unset(BUILD_ROOT_CMAKE_PACKAGE_DIRECTORY)
  unset(BUILD_ROOT_CMAKE_PACKAGE_DIRECTORY CACHE)
  set(BUILD_ROOT_CMAKE_PACKAGE_DIRECTORY "${cmake_packages_dir}")
  unset(BUILD_ROOT_BUILD_DIRECTORY)
  unset(BUILD_ROOT_BUILD_DIRECTORY CACHE)
  set(BUILD_ROOT_BUILD_DIRECTORY "${build_root_dir}")

  set(BUILD_ROOT_____________BASH_PROGRAM sh)

  if(ANDROID)
    build_root_exec(ls -l /lib/android-sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin)
    set(BUILD_ROOT_____________android_toolchain_suffix linux-android)
    set(BUILD_ROOT_____________android_compiler_suffix linux-android${ANDROID_PLATFORM})
    set(BUILD_ROOT_____________cross_rc "")
    # NDK 25 specifies the following, see ./ndk_25_bin.txt in this repo
    if(CMAKE_ANDROID_ARCH_ABI MATCHES x86_64)
      set(BUILD_ROOT_____________android_machine x86_64)
      set(BUILD_ROOT_____________cross_host "--host=x86_64-linux-android")
      set(BUILD_ROOT_____________android_compiler_prefix x86_64)
      set(BUILD_ROOT_____________android_compiler_suffix linux-android${ANDROID_PLATFORM})
      set(BUILD_ROOT_____________android_toolchain_prefix x86_64)
      set(BUILD_ROOT_____________android_toolchain_suffix linux-android)
      set(BUILD_ROOT_____________NBBY 8)
    elseif(CMAKE_ANDROID_ARCH_ABI MATCHES x86)
      set(BUILD_ROOT_____________android_machine i686)
      set(BUILD_ROOT_____________cross_host "--host=i686-linux-android")
      set(BUILD_ROOT_____________android_compiler_prefix i686)
      set(BUILD_ROOT_____________android_compiler_suffix linux-android${ANDROID_PLATFORM})
      set(BUILD_ROOT_____________android_toolchain_prefix i686)
      set(BUILD_ROOT_____________android_toolchain_suffix linux-android)
      set(BUILD_ROOT_____________NBBY 4)
    elseif(CMAKE_ANDROID_ARCH_ABI MATCHES armeabi-v7a)
      set(BUILD_ROOT_____________android_machine armv7)
      set(BUILD_ROOT_____________cross_host "--host=armv7a-linux-androideabi")
      set(BUILD_ROOT_____________android_compiler_prefix armv7a)
      set(BUILD_ROOT_____________android_compiler_suffix linux-androideabi${ANDROID_PLATFORM})
      set(BUILD_ROOT_____________android_toolchain_prefix arm)
      set(BUILD_ROOT_____________android_toolchain_suffix linux-androideabi)
      set(BUILD_ROOT_____________NBBY 4)
    elseif(CMAKE_ANDROID_ARCH_ABI MATCHES arm64-v8a)
      set(BUILD_ROOT_____________android_machine aarch64)
      set(BUILD_ROOT_____________cross_host "--host=aarch64-linux-android")
      set(BUILD_ROOT_____________android_compiler_prefix aarch64)
      set(BUILD_ROOT_____________android_compiler_suffix linux-android${ANDROID_PLATFORM})
      set(BUILD_ROOT_____________android_toolchain_prefix aarch64)
      set(BUILD_ROOT_____________android_toolchain_suffix linux-android)
      set(BUILD_ROOT_____________NBBY 8)
    else()
      message(FATAL_ERROR "unknown android arch: ${CMAKE_ANDROID_ARCH_ABI}")
    endif()
    set(BUILD_ROOT_____________deps_cc "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/${BUILD_ROOT_____________android_compiler_prefix}-${BUILD_ROOT_____________android_compiler_suffix}-clang")
    set(BUILD_ROOT_____________deps_cxx "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/${BUILD_ROOT_____________android_compiler_prefix}-${BUILD_ROOT_____________android_compiler_suffix}-clang++")
    set(BUILD_ROOT_____________deps_ld "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/ld")
    set(BUILD_ROOT_____________deps_ranlib "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ranlib")
    set(BUILD_ROOT_____________deps_as "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-as")
    set(BUILD_ROOT_____________deps_nm "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-nm")
    set(BUILD_ROOT_____________deps_objdump "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-objdump")
    set(BUILD_ROOT_____________deps_ar "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar")
    set(BUILD_ROOT_____________deps_strip "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip")
    set(BUILD_ROOT_____________deps_strings "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strings")
    set(BUILD_ROOT_____________FLAGS_CORE "export LD=${BUILD_ROOT_____________deps_ld} \; export RANLIB=${BUILD_ROOT_____________deps_ranlib} \; export AR=${BUILD_ROOT_____________deps_ar} \; export NM=${BUILD_ROOT_____________deps_nm} \; export AS=${BUILD_ROOT_____________deps_as} \; export OBJDUMP=${BUILD_ROOT_____________deps_objdump} \; export STRIP=${BUILD_ROOT_____________deps_strip} \; export INSTALL_STRIP_PROGRAM=${BUILD_ROOT_____________deps_strip} \; export STRINGS=${BUILD_ROOT_____________deps_strings} \;")
  else()
    if (CMAKE_CROSSCOMPILING)
      set(BUILD_ROOT_____________cross_host "--host=${ARCH_TRIPLET}")
    else()
      set(BUILD_ROOT_____________cross_host "")
    endif()
    if (WIN32)
      # TODO: figure out how to locate windres on windows platform
      #set(BUILD_ROOT_____________cross_rc "WINDRES=${CMAKE_RC_COMPILER}")
    else()
      set(BUILD_ROOT_____________cross_rc "")
    endif()
    set(BUILD_ROOT_____________deps_cc "${CMAKE_C_COMPILER}")
    set(BUILD_ROOT_____________deps_cxx "${CMAKE_CXX_COMPILER}")
    set(BUILD_ROOT_____________FLAGS_CORE "")
  endif()
  set(BUILD_ROOT_____________COMMON_LINK_FLAGS "-L${LLVM_BUILD_ROOT__ROOTFS}/lib")
  set(BUILD_ROOT_____________COMMON_INCLUDE_FLAGS "-I${LLVM_BUILD_ROOT__ROOTFS}/include")
  set(BUILD_ROOT_____________COMMON_FLAGS "${BUILD_ROOT_____________COMMON_INCLUDE_FLAGS} ${BUILD_ROOT_____________COMMON_LINK_FLAGS}")
  if (ANDROID)
    unset(BUILD_ROOT_____________ADDITIONAL_C_FLAGS)
    unset(BUILD_ROOT_____________ADDITIONAL_C_FLAGS CACHE)
    set(BUILD_ROOT_____________ADDITIONAL_C_FLAGS "-DANDROID_API=${ANDROID_PLATFORM}")
  else()
    unset(BUILD_ROOT_____________ADDITIONAL_C_FLAGS)
    unset(BUILD_ROOT_____________ADDITIONAL_C_FLAGS CACHE)
    set(BUILD_ROOT_____________ADDITIONAL_C_FLAGS "")
  endif()

  # kept for static archive notes
  if (NOT APPLE)
    unset(BUILD_ROOT_LINK_GROUP_START)
    unset(BUILD_ROOT_LINK_GROUP_START CACHE)
    set(BUILD_ROOT_LINK_GROUP_START "-Wl,--start-group")
    unset(BUILD_ROOT_LINK_GROUP_END)
    unset(BUILD_ROOT_LINK_GROUP_END)
    set(BUILD_ROOT_LINK_GROUP_END "-Wl,--end-group")
  else()
    # apple's linker automatically behaves as-if start-group and end-group, and it does not accept such options
    unset(BUILD_ROOT_LINK_GROUP_START)
    unset(BUILD_ROOT_LINK_GROUP_START CACHE)
    set(BUILD_ROOT_LINK_GROUP_START "")
    unset(BUILD_ROOT_LINK_GROUP_END)
    unset(BUILD_ROOT_LINK_GROUP_END)
    set(BUILD_ROOT_LINK_GROUP_END "")
  endif()

  message("CMAKE_SYSTEM_NAME = ${CMAKE_SYSTEM_NAME}")
  message("CMAKE_ANDROID_NDK = ${CMAKE_ANDROID_NDK}")
  message("CMAKE_ANDROID_NDK_VERSION = ${CMAKE_ANDROID_NDK_VERSION}")
  message("CMAKE_ANDROID_NDK_TOOLCHAIN_HOST_TAG = ${CMAKE_ANDROID_NDK_TOOLCHAIN_HOST_TAG}")
  message("CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION = ${CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION}")
  message("-DCMAKE_COLOR_DIAGNOSTICS=${CMAKE_COLOR_DIAGNOSTICS}")
  message("-DCMAKE_COLOR_MAKEFILE=${CMAKE_COLOR_MAKEFILE}")
  message("-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
  message("-DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}")
  message("-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
  message("-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
  message("-DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}")
  message("-DCMAKE_C_STANDARD=${CMAKE_C_STANDARD}")
  message("-DCMAKE_C_STANDARD_REQUIRED=${CMAKE_C_STANDARD_REQUIRED}")
  message("-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}")
  message("-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
  message("-DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}")
  message("-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}")
  message("-DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}")
  message("-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")
  message("-DCMAKE_MODULE_LINKER_FLAGS=${CMAKE_MODULE_LINKER_FLAGS}")
  message("-DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}")
  message("-DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}")
  message("-DCMAKE_INSTALL_PREFIX=${BUILD_ROOT_BUILD_DIRECTORY}/ROOTFS")
  message("-DCMAKE_POLICY_DEFAULT_CMP0074=${CMAKE_POLICY_DEFAULT_CMP0074}")
  message("-DCMAKE_POLICY_DEFAULT_CMP0075=${CMAKE_POLICY_DEFAULT_CMP0075}")
  message("-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
  message("-DCMAKE_SYSROOT=${CMAKE_SYSROOT}")
  message("-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")
  message("-DCMAKE_SYSTEM_PREFIX_PATH=${CMAKE_SYSTEM_PREFIX_PATH}")
  message("-DLLVM_BUILD_ROOT__ROOTFS=${LLVM_BUILD_ROOT__ROOTFS}")
  message("-DANDROID_ABI=${ANDROID_ABI}")
  message("-DANDROID_ARM_MODE=${ANDROID_ARM_MODE}")
  message("-DANDROID_ARM_NEON=${ANDROID_ARM_NEON}")
  message("-DANDROID_PLATFORM=${ANDROID_PLATFORM}")
  message("-DANDROID_STL=${ANDROID_STL}")
endmacro()

macro(build_root_add_cmake_package src relative_path_to_cmake_dir build_dir new_line_seperated_extra_c_flags new_line_seperated_extra_cxx_flags new_line_seperated_extra_cmake_config)
  build_root_message("BUILD_ROOT_CMAKE_PACKAGE_DIRECTORY is '${BUILD_ROOT_CMAKE_PACKAGE_DIRECTORY}'")
  build_root_message("BUILD_ROOT_BUILD_DIRECTORY is '${BUILD_ROOT_BUILD_DIRECTORY}'")
  unset(${build_dir}_ROOT)
  unset(${build_dir}_ROOT CACHE)
  set(${build_dir}_ROOT "${build_dir}")
  if (NOT EXISTS "${src}")
    build_root_fatal("source directory '${src}' does not exist")
  endif()
  if (NOT EXISTS "${src}/${relative_path_to_cmake_dir}")
    build_root_fatal("relative source directory '${relative_path_to_cmake_dir}' does not exist inside source directory '${src}'")
  endif()
  if (NOT EXISTS "${src}/${relative_path_to_cmake_dir}/CMakeLists.txt")
    build_root_fatal("cmake file 'CMakeLists.txt' does not exist inside relative source directory '${relative_path_to_cmake_dir}' inside source directory '${src}'")
  endif()
  if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/SRC/${build_dir}")
    build_root_exec(cp -r "${src}" "${BUILD_ROOT_BUILD_DIRECTORY}/SRC/${build_dir}")
  endif()
  if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}")
    build_root_exec(mkdir "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}")
  endif()

  unset(HAS_CMAKE_COLOR)
  unset(HAS_CMAKE_COLOR CACHE)

  if (CMAKE_COLOR_MAKEFILE OR CMAKE_COLOR_DIAGNOSTICS)
    set(HAS_CMAKE_COLOR ON)
  endif()

  message(STATUS "(could be empty) new_line_seperated_extra_cmake_config = ${new_line_seperated_extra_cmake_config}")
  unset(new_line_seperated_extra_cmake_config_list)
  unset(new_line_seperated_extra_cmake_config_list CACHE)
  message(STATUS "(should be empty) new_line_seperated_extra_cmake_config_list = ${new_line_seperated_extra_cmake_config_list}")
  string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" new_line_seperated_extra_cmake_config_list "${new_line_seperated_extra_cmake_config}")
  message(STATUS "(could be empty) new_line_seperated_extra_cmake_config_list = ${new_line_seperated_extra_cmake_config_list}")
  unset(new_line_seperated_extra_cmake_config_list_str)
  unset(new_line_seperated_extra_cmake_config_list_str CACHE)
  foreach(ARG IN ITEMS ${new_line_seperated_extra_cmake_config_list})
      if (new_line_seperated_extra_cmake_config_list_str)
        string(APPEND new_line_seperated_extra_cmake_config_list_str " ")
      endif()
      string(APPEND new_line_seperated_extra_cmake_config_list_str "'${ARG}'")
  endforeach()
  message(STATUS "(could be empty) new_line_seperated_extra_cmake_config_list_str = ${new_line_seperated_extra_cmake_config_list_str}")

  build_root_message("-------- BUILDING CMAKE PROJECT: '${build_dir}'")
  
  build_root_message("-------- BUILDING CMAKE PROJECT: '${build_dir}' -- CONFIGURING")
  build_root_exec_cmake(
    # configure
    ${CMAKE_COMMAND}
    ${new_line_seperated_extra_cmake_config_list_str}
    -G "${CMAKE_GENERATOR}"
    -S "${BUILD_ROOT_BUILD_DIRECTORY}/SRC/${build_dir}/${relative_path_to_cmake_dir}"
    -B "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}"
  )
  build_root_message("-------- BUILDING CMAKE PROJECT: '${build_dir}' -- CONFIGURED")
  build_root_message("-------- BUILDING CMAKE PROJECT: '${build_dir}' -- BUILDING")
  build_root_exec(
    # build
    ${CMAKE_COMMAND}
    --build "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}"
  )
  build_root_message("-------- BUILDING CMAKE PROJECT: '${build_dir}' -- BUILT")
  build_root_message("-------- BUILDING CMAKE PROJECT: '${build_dir}' -- INSTALLING")
  build_root_exec(
    # install
    ${CMAKE_COMMAND}
    --install
    "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}"
  )
  build_root_message("-------- BUILDING CMAKE PROJECT: '${build_dir}' -- INSTALLED")
  #build_root_exec_working_directory("${BUILD_ROOT_BUILD_DIRECTORY}" sh -c "/usr/bin/find ROOTFS")
  build_root_message("-------- BUILT CMAKE PROJECT: '${build_dir}'")
endmacro()

macro(build_root_add_makefile_package src relative_path_to_makefile_dir build_dir new_line_seperated_extra_c_flags new_line_seperated_extra_cxx_flags new_line_seperated_extra_makefile_config)
  build_root_message("BUILD_ROOT_BUILD_DIRECTORY is '${BUILD_ROOT_BUILD_DIRECTORY}'")
  unset(${build_dir}_ROOT)
  unset(${build_dir}_ROOT CACHE)
  set(${build_dir}_ROOT "${build_dir}")
  if (NOT EXISTS ${src})
    build_root_fatal("source directory '${src}' does not exist")
  endif()
  if (NOT EXISTS ${src}/${relative_path_to_makefile_dir})
    build_root_fatal("relative source directory '${relative_path_to_makefile_dir}' does not exist inside source directory '${src}'")
  endif()
  if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}")
    build_root_exec(cp -r "${src}" "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}")
  endif()
  
  message(STATUS "(could be empty) new_line_seperated_extra_makefile_config = ${new_line_seperated_extra_makefile_config}")
  unset(new_line_seperated_extra_makefile_config_list)
  unset(new_line_seperated_extra_makefile_config_list CACHE)
  message(STATUS "(should be empty) new_line_seperated_extra_makefile_config_list = ${new_line_seperated_extra_makefile_config_list}")
  string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" new_line_seperated_extra_makefile_config_list "${new_line_seperated_extra_makefile_config}")
  message(STATUS "(could be empty) new_line_seperated_extra_makefile_config_list = ${new_line_seperated_extra_makefile_config_list}")
  unset(new_line_seperated_extra_makefile_config_list_str)
  unset(new_line_seperated_extra_makefile_config_list_str CACHE)
  foreach(ARG IN ITEMS ${new_line_seperated_extra_makefile_config_list})
      if (new_line_seperated_extra_makefile_config_list_str)
        string(APPEND new_line_seperated_extra_makefile_config_list_str " ")
      endif()
      string(APPEND new_line_seperated_extra_makefile_config_list_str "${ARG}")
  endforeach()
  message(STATUS "(could be empty) new_line_seperated_extra_makefile_config_list_str = ${new_line_seperated_extra_makefile_config_list_str}")

  message(STATUS "(could be empty) new_line_seperated_extra_c_flags = ${new_line_seperated_extra_c_flags}")
  unset(new_line_seperated_extra_c_flags_list)
  unset(new_line_seperated_extra_c_flags_list CACHE)
  message(STATUS "(should be empty) new_line_seperated_extra_c_flags_list = ${new_line_seperated_extra_c_flags_list}")
  string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" new_line_seperated_extra_c_flags_list "${new_line_seperated_extra_c_flags}")
  message(STATUS "(could be empty) new_line_seperated_extra_c_flags_list = ${new_line_seperated_extra_c_flags_list}")
  unset(new_line_seperated_extra_c_flags_list_str)
  unset(new_line_seperated_extra_c_flags_list_str CACHE)
  foreach(ARG IN ITEMS ${new_line_seperated_extra_c_flags_list})
      if (new_line_seperated_extra_c_flags_list_str)
        string(APPEND new_line_seperated_extra_c_flags_list_str " ")
      endif()
      string(APPEND new_line_seperated_extra_c_flags_list_str "${ARG}")
  endforeach()
  message(STATUS "(could be empty) new_line_seperated_extra_c_flags_list_str = ${new_line_seperated_extra_c_flags_list_str}")

  message(STATUS "(could be empty) new_line_seperated_extra_cxx_flags = ${new_line_seperated_extra_cxx_flags}")
  unset(new_line_seperated_extra_cxx_flags_list)
  unset(new_line_seperated_extra_cxx_flags_list CACHE)
  message(STATUS "(should be empty) new_line_seperated_extra_cxx_flags_list = ${new_line_seperated_extra_cxx_flags_list}")
  string(REGEX MATCHALL "([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+( +([^\"' \r\n\t;\\]+|[\\].|\"([^\"\\]+|[\\].)*\")+)*" new_line_seperated_extra_cxx_flags_list "${new_line_seperated_extra_cxx_flags}")
  message(STATUS "(could be empty) new_line_seperated_extra_cxx_flags_list = ${new_line_seperated_extra_cxx_flags_list}")
  unset(new_line_seperated_extra_cxx_flags_list_str)
  unset(new_line_seperated_extra_cxx_flags_list_str CACHE)
  foreach(ARG IN ITEMS ${new_line_seperated_extra_cxx_flags_list})
      if (new_line_seperated_extra_cxx_flags_list_str)
        string(APPEND new_line_seperated_extra_cxx_flags_list_str " ")
      endif()
      string(APPEND new_line_seperated_extra_cxx_flags_list_str "${ARG}")
  endforeach()
  message(STATUS "(could be empty) new_line_seperated_extra_cxx_flags_list_str = ${new_line_seperated_extra_cxx_flags_list_str}")

  unset(BUILD_ROOT_____________FLAGS)
  unset(BUILD_ROOT_____________FLAGS CACHE)

  if (WIN32)
      # LLVM_BUILD_ROOT__ROOTFS is an absolute path
      #  LLVM_BUILD_ROOT__ROOTFS = C:/...
      #
      #  we need to chop off the drive letter so PKG_CONFIG_PATH works
      #
      string(LENGTH "${LLVM_BUILD_ROOT__ROOTFS}" LLVM_BUILD_ROOT__ROOTFS__MSYS_TMP_LENGTH)
      math(EXPR LLVM_BUILD_ROOT__ROOTFS__MSYS_TMP_LENGTH_ADJUSTED "${LLVM_BUILD_ROOT__ROOTFS__MSYS_TMP_LENGTH} - 2" OUTPUT_FORMAT DECIMAL)
      string(SUBSTRING "${LLVM_BUILD_ROOT__ROOTFS}" 2 ${LLVM_BUILD_ROOT__ROOTFS__MSYS_TMP_LENGTH_ADJUSTED} LLVM_BUILD_ROOT__ROOTFS__MSYS)
  else()
    set(LLVM_BUILD_ROOT__ROOTFS__MSYS ${LLVM_BUILD_ROOT__ROOTFS})
  endif()

  set(BUILD_ROOT_____________FLAGS "${BUILD_ROOT_____________FLAGS_CORE} export PKG_CONFIG_PATH=\"${LLVM_BUILD_ROOT__ROOTFS__MSYS}/lib/pkgconfig:${LLVM_BUILD_ROOT__ROOTFS__MSYS}/share/pkgconfig:\$PKG_CONFIG_PATH\" \; export CC=\"${BUILD_ROOT_____________deps_cc}\" \; export LDFLAGS=\"${BUILD_ROOT_____________COMMON_LINK_FLAGS}\" \; export CFLAGS=\"${BUILD_ROOT_____________COMMON_FLAGS} ${BUILD_ROOT_____________ADDITIONAL_C_FLAGS} ${new_line_seperated_extra_c_flags_list_str} ${CMAKE_C_FLAGS}\" \; export CXX=\"${BUILD_ROOT_____________deps_cxx}\" \; export CXXFLAGS=\"${BUILD_ROOT_____________COMMON_FLAGS} ${BUILD_ROOT_____________ADDITIONAL_C_FLAGS} ${new_line_seperated_extra_cxx_flags_list_str} ${CMAKE_CXX_FLAGS}\" \;")

  build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}'")

  unset(BUILD_ROOT_____________HAS_M)
  unset(BUILD_ROOT_____________HAS_M CACHE)
  unset(BUILD_ROOT_____________HAS_C)
  unset(BUILD_ROOT_____________HAS_C CACHE)
  unset(BUILD_ROOT_____________HAS_A)
  unset(BUILD_ROOT_____________HAS_A CACHE)
  unset(BUILD_ROOT_____________HAS_DIR)
  unset(BUILD_ROOT_____________HAS_DIR CACHE)
  if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/${relative_path_to_makefile_dir}/Makefile")
      if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/${relative_path_to_makefile_dir}/configure")
          if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/${relative_path_to_makefile_dir}/autogen.sh")
              if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/Makefile")
                  if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/configure")
                      if (NOT EXISTS "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/autogen.sh")
                          build_root_fatal("could not find any of the following files 'Makefile', 'configure', 'autogen.sh', searched inside relative source directory '${relative_path_to_makefile_dir}' inside source directory '${src}', searched inside source directory '${src}'")
                      else()
                          set(BUILD_ROOT_____________HAS_A true)
                          set(BUILD_ROOT_____________HAS_DIR "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}")
                      endif()
                  else()
                      set(BUILD_ROOT_____________HAS_C true)
                      set(BUILD_ROOT_____________HAS_DIR "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}")
                  endif()
              else()
                  set(BUILD_ROOT_____________HAS_M true)
                  set(BUILD_ROOT_____________HAS_DIR "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}")
              endif()
          else()
              set(BUILD_ROOT_____________HAS_A true)
              set(BUILD_ROOT_____________HAS_DIR "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/${relative_path_to_makefile_dir}")
          endif()
      else()
          set(BUILD_ROOT_____________HAS_C true)
          set(BUILD_ROOT_____________HAS_DIR "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/${relative_path_to_makefile_dir}")
      endif()
  else()
      set(BUILD_ROOT_____________HAS_M true)
      set(BUILD_ROOT_____________HAS_DIR "${BUILD_ROOT_BUILD_DIRECTORY}/BUILD/${build_dir}/${relative_path_to_makefile_dir}")
  endif()
  
  if (BUILD_ROOT_____________HAS_A)
      # autogen.sh does not provide a --help option
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- GENERATING (AUTOGEN)")
      build_root_exec_working_directory("${BUILD_ROOT_____________HAS_DIR}"
        ${BUILD_ROOT_____________BASH_PROGRAM} ./autogen.sh
      )
      if (NOT EXISTS "${BUILD_ROOT_____________HAS_DIR}/configure")
          build_root_fatal("'autogen.sh' failed to generate a 'configure' file inside the directory '${BUILD_ROOT_____________HAS_DIR}'")
      else()
          set(BUILD_ROOT_____________HAS_C true)
      endif()
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- GENERATED (AUTOGEN)")
  endif()
  if (BUILD_ROOT_____________HAS_C)
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- CONFIGURING (--help)")
      build_root_exec_working_directory("${BUILD_ROOT_____________HAS_DIR}"
        ${BUILD_ROOT_____________BASH_PROGRAM} -c "${BUILD_ROOT_____________FLAGS} sh ./configure --help"
      )
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- CONFIGURING")
      build_root_exec_working_directory("${BUILD_ROOT_____________HAS_DIR}"
        ${BUILD_ROOT_____________BASH_PROGRAM} -c "${BUILD_ROOT_____________FLAGS} sh ./configure ${BUILD_ROOT_____________cross_host} ${BUILD_ROOT_____________cross_rc} --prefix=${BUILD_ROOT_BUILD_DIRECTORY}/ROOTFS ${new_line_seperated_extra_makefile_config_list_str}"
      )
      if (NOT EXISTS "${BUILD_ROOT_____________HAS_DIR}/Makefile")
          build_root_fatal("'configure' failed to generate a 'Makefile' file inside the directory '${BUILD_ROOT_____________HAS_DIR}'")
      else()
          set(BUILD_ROOT_____________HAS_M true)
      endif()
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- CONFIGURED")
  endif()
  if (BUILD_ROOT_____________HAS_M)
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- BUILDING (--help)")
      build_root_exec_working_directory("${BUILD_ROOT_____________HAS_DIR}"
        ${BUILD_ROOT_____________BASH_PROGRAM} -c "${BUILD_ROOT_____________FLAGS} make --help"
      )
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- BUILDING (--trace)")
      build_root_exec_working_directory("${BUILD_ROOT_____________HAS_DIR}"
        ${BUILD_ROOT_____________BASH_PROGRAM} -c "${BUILD_ROOT_____________FLAGS} make --trace"
      )
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- BUILT")
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- INSTALLING (--help)")
      build_root_exec_working_directory("${BUILD_ROOT_____________HAS_DIR}"
        ${BUILD_ROOT_____________BASH_PROGRAM} -c "${BUILD_ROOT_____________FLAGS} make install --help"
      )
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- INSTALLING")
      build_root_exec_working_directory("${BUILD_ROOT_____________HAS_DIR}"
        ${BUILD_ROOT_____________BASH_PROGRAM} -c "${BUILD_ROOT_____________FLAGS} make install"
      )
      build_root_message("-------- BUILDING MAKEFILE PROJECT: '${build_dir}' -- INSTALLED")
      #build_root_exec_working_directory("${BUILD_ROOT_BUILD_DIRECTORY}" sh -c "/usr/bin/find ROOTFS")
  endif()
  build_root_message("-------- BUILT MAKEFILE PROJECT: '${build_dir}'")
endmacro()
