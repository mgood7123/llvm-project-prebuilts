cmake_minimum_required(VERSION 3.5)

project(glob LANGUAGES C)

add_library(glob STATIC glob.c)
target_include_directories(glob PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE PATH "Installation directory for executables")
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE PATH "Installation directory for libraries")
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "Installation directory for headers")

install(TARGETS glob
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/glob.h DESTINATION "${INSTALL_INC_DIR}")
