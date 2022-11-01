CMAKE_MINIMUM_REQUIRED(VERSION 3.14)
PROJECT(SHUFFILE VERSION 0.2.0)

# Mac rpath Policy
IF(POLICY CMP0042)
          CMAKE_POLICY(SET CMP0042 NEW)
ENDIF(POLICY CMP0042)
SET(CMAKE_MACOSX_RPATH ON)

SET(CMAKE_POSITION_INDEPENDENT_CODE ON)

#SET(CMAKE_C_FLAGS "-Wall")

# Configuration Options
OPTION(BUILD_SHARED_LIBS "Whether to build shared libraries" ON)
MESSAGE(STATUS "BUILD_SHARED_LIBS: ${BUILD_SHARED_LIBS}")

if (BUILD_SHARED_LIBS)
   OPTION(SHUFFILE_LINK_STATIC "Default to static linking? (Needed for Cray)" OFF)
else()
   OPTION(SHUFFILE_LINK_STATIC "Default to static linking? (Needed for Cray)" ON)
endif()
MESSAGE(STATUS "SHUFFILE_LINK_STATIC: ${SHUFFILE_LINK_STATIC}")

OPTION(ENABLE_TESTS "Whether to build tests" ON)
MESSAGE(STATUS "ENABLE_TESTS: ${ENABLE_TESTS}")

# Find Packages & Files

LIST(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

## KVTREE
FIND_PACKAGE(kvtree REQUIRED)
LIST(APPEND SHUFFILE_EXTERNAL_LIBS kvtree::kvtree)

## MPI
INCLUDE(SetupMPI)
IF(MPI_C_FOUND)
    INCLUDE_DIRECTORIES(${MPI_C_INCLUDE_PATH})
    LIST(APPEND SHUFFILE_EXTERNAL_LIBS ${MPI_C_LIBRARIES})
ELSE(MPI_C_FOUND)
    MESSAGE(FATAL_ERROR
        "Could not find MPI! "
        "Either add an MPI compiler to your path "
        "or force CMake to build using the correct compiler (`export CC=mpicc`).")
ENDIF(MPI_C_FOUND)

## ZLIB
FIND_PACKAGE(ZLIB REQUIRED)
LIST(APPEND SHUFFILE_EXTERNAL_LIBS ZLIB::ZLIB)

## HEADERS
INCLUDE(CheckIncludeFile)
INCLUDE(GNUInstallDirs)

# Subdirectories
ADD_SUBDIRECTORY(src)


SET(SHUFFILE_TEST_BASE "/dev/shm" CACHE PATH "Default base path for SCR cache directory")
IF(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
  SET(SHUFFILE_TEST_BASE "/tmp")
ENDIF(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
MESSAGE("TEST base is: " ${SHUFFILE_TEST_BASE})


IF(ENABLE_TESTS)
   INCLUDE(CTest)
   INCLUDE(SHUFFILE_ADD_TEST)
   ADD_SUBDIRECTORY(test)
ENDIF(ENABLE_TESTS)

# Generate config.h with all our build #defs
CONFIGURE_FILE(${PROJECT_SOURCE_DIR}/cmake/config.h.in ${PROJECT_BINARY_DIR}/config.h)
SET_SOURCE_FILES_PROPERTIES(${PROJECT_BINARY_DIR}/config.h PROPERTIES GENERATED TRUE)

# Special Install Files
# INSTALL(FILES README.md DESTINATION ${CMAKE_INSTALL_DATADIR}/kvtree)

# CMake configs

# Install the exports file
INSTALL(EXPORT shuffileTargets FILE shuffileTargets.cmake NAMESPACE shuffile:: DESTINATION share/shuffile/cmake)

# Export so we can use in-tree
EXPORT(EXPORT shuffileTargets NAMESPACE shuffile:: FILE shuffileTargets.cmake)

# Setup the package config
INCLUDE(CMakePackageConfigHelpers)
CONFIGURE_PACKAGE_CONFIG_FILE(cmake/shuffileConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/shuffileConfig.cmake INSTALL_DESTINATION share/shuffile/cmake)
WRITE_BASIC_PACKAGE_VERSION_FILE(${CMAKE_CURRENT_BINARY_DIR}/shuffileConfigVersion.cmake COMPATIBILITY SameMajorVersion)

# Install package config
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/shuffileConfig.cmake ${CMAKE_CURRENT_BINARY_DIR}/shuffileConfigVersion.cmake DESTINATION share/shuffile/cmake)

# Package
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "SHUFFILE Shuffle files between processes")
SET(CPACK_PACKAGE_VENDOR "Lawrence Livermore National Laboratory")
# SET(CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_SOURCE_DIR}/README.md")
# SET(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE.TXT")
