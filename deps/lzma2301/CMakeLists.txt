cmake_minimum_required(VERSION 3.5)

project(7z LANGUAGES C)

file(GLOB HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/C/*.h)
file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/C/*.c)

add_library(7z STATIC ${SOURCES})
target_compile_definitions(7z PUBLIC Z7_AFFINITY_DISABLE)
target_compile_definitions(7z PUBLIC _7ZIP_ST)
target_compile_definitions(7z PUBLIC Z7_SHOW_AES_STATUS)
target_compile_definitions(7z PUBLIC Z7_SHOW_HW_STATUS)
target_include_directories(7z PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/C)

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE PATH "Installation directory for executables")
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE PATH "Installation directory for libraries")
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "Installation directory for headers")

install(TARGETS 7z
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )

install(FILES ${HEADERS} DESTINATION "${INSTALL_INC_DIR}")
