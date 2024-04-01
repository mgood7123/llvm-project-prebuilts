# Try to find the OPENSSL library
#
# If successful, the following variables will be defined:
# OPENSSL_INCLUDE_DIR
# OPENSSL_LIBRARIES
# OPENSSL_FOUND
#
# Additionally, one of the following import targets will be defined:
# z

find_package(PkgConfig QUIET)
pkg_check_modules(PC_OPENSSL QUIET OPENSSL)

set(CMAKE_FIND_DEBUG_MODE FALSE) # TRUE)

find_path(OPENSSL_INCLUDE_DIRS NAMES openssl/ssl.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(OPENSSL_LIBRARIES NAMES libssl_1_1.a libssl.a
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/lib
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

find_path(OPENSSL_CRYPTO_INCLUDE_DIRS NAMES openssl/crypto.h
  PATHS ${LLVM_BUILD_ROOT__ROOTFS}/include
  NO_DEFAULT_PATH
  NO_PACKAGE_ROOT_PATH
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
find_library(OPENSSL_CRYPTO_LIBRARIES NAMES libcrypto_1_1.a libcrypto.a
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

if(OPENSSL_INCLUDE_DIRS AND EXISTS "${OPENSSL_INCLUDE_DIRS}/openssl/ssl.h")
    set(OPENSSL_VERSION_STRING "1.1")
    set(OPENSSL_CRYPTO_VERSION_STRING "1.1")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenSSL
                                  FOUND_VAR
                                    OPENSSL_FOUND
                                  REQUIRED_VARS
                                    OPENSSL_INCLUDE_DIRS
                                    OPENSSL_LIBRARIES
                                  VERSION_VAR
                                    OPENSSL_VERSION_STRING)
mark_as_advanced(OPENSSL_INCLUDE_DIRS OPENSSL_LIBRARIES)

find_package_handle_standard_args(OpenSSL
                                  FOUND_VAR
                                    OPENSSL_CRYPTO_FOUND
                                  REQUIRED_VARS
                                    OPENSSL_CRYPTO_INCLUDE_DIRS
                                    OPENSSL_CRYPTO_LIBRARIES
                                  VERSION_VAR
                                    OPENSSL_VERSION_STRING)
mark_as_advanced(OPENSSL_CRYPTO_INCLUDE_DIRS OPENSSL_CRYPTO_LIBRARIES)

if (OPENSSL_FOUND AND NOT TARGET LLVM_STATIC_OPENSSL)
  add_library(LLVM_STATIC_OPENSSL UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_OPENSSL PROPERTIES
                        IMPORTED_LOCATION ${OPENSSL_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIRS})
  set(OPENSSL_TARGET LLVM_STATIC_OPENSSL)
endif()
if (OPENSSL_CRYPTO_FOUND AND NOT TARGET LLVM_STATIC_OPENSSL_CRYPTO)
  add_library(LLVM_STATIC_OPENSSL_CRYPTO UNKNOWN IMPORTED)
  set_target_properties(LLVM_STATIC_OPENSSL_CRYPTO PROPERTIES
                        IMPORTED_LOCATION ${OPENSSL_CRYPTO_LIBRARIES}
                        INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_CRYPTO_INCLUDE_DIRS})
  set(OPENSSL_CRYPTO_TARGET LLVM_STATIC_OPENSSL_CRYPTO)
endif()
