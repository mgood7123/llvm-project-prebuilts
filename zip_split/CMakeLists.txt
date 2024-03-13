cmake_minimum_required(VERSION 3.12)

project(llvm_project_prebuilt_deps C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_POLICY_DEFAULT_CMP0074 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0075 NEW)

if (WIN32)
    set(PLATFORM Windows)
else()
    set(PLATFORM Linux)
endif()

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

add_subdirectory(cppfs)
add_subdirectory(mmaptwo-plus)

add_executable(zip_split zip_split.cpp mmap.cpp)
target_include_directories(zip_split PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(zip_split PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/mmaptwo-plus)
target_include_directories(zip_split PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/cppfs)
target_link_libraries(zip_split mmaptwo_plus cppfs)

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE PATH "Installation directory for executables")
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE PATH "Installation directory for libraries")
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "Installation directory for headers")

install(TARGETS zip_split
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )
