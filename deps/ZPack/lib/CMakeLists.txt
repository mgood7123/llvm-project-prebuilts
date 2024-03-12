set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

# check library type
if(NOT DEFINED ZPACK_LIBRARY_TYPE)
    if(BUILD_SHARED_LIBS)
        set(ZPACK_LIBRARY_TYPE SHARED)
    else()
        set(ZPACK_LIBRARY_TYPE STATIC)
    endif()
endif()

# detect endianness
if(${CMAKE_VERSION} VERSION_LESS "3.20.0")
    # old method
    include(TestBigEndian)
    test_big_endian(ZPACK_IS_BIG_ENDIAN)
    if(NOT ZPACK_IS_BIG_ENDIAN)
        set(ZPACK_ENDIAN_DEFS ZPACK_LITTLE_ENDIAN)
    endif()
else()
    # new method
    if(CMAKE_C_BYTE_ORDER STREQUAL "LITTLE_ENDIAN")
        set(ZPACK_ENDIAN_DEFS ZPACK_LITTLE_ENDIAN)
    endif()
endif()

add_library(zpack ${ZPACK_LIBRARY_TYPE}
    zpack_common.c
    zpack_read.c
    zpack_stream.c
    zpack_write.c
)

file(COPY ${PROJECT_SOURCE_DIR}/lib/zpack.h DESTINATION ${CMAKE_BINARY_DIR}/zpack_include)
file(COPY ${PROJECT_SOURCE_DIR}/lib/zpack_common.h DESTINATION ${CMAKE_BINARY_DIR}/zpack_include)

target_link_libraries(zpack ${xxHash_TARGET} ${zstd_TARGET} ${LZ4_TARGET})
target_include_directories(zpack PUBLIC  ${CMAKE_BINARY_DIR}/zpack_include)
target_compile_definitions(zpack PRIVATE ${ZPACK_ENDIAN_DEFS} ${ZPACK_LFS_DEFS} ${ZPACK_DISABLE_DEFS})
set_target_properties(zpack PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    PUBLIC_HEADER zpack.h
)

if(ZPACK_INSTALL)
    include(GNUInstallDirs)
    install(TARGETS zpack
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    )
endif()
