###############
# Build tests
###############

################
# Add tests to ctest
################

INCLUDE_DIRECTORIES(${PROJECT_BINARY_DIR})

IF(SHUFFILE_LINK_STATIC)
   SET(shuffile_lib shuffile::shuffile-static)
ELSE()
   SET(shuffile_lib shuffile::shuffile)
ENDIF()

ADD_EXECUTABLE(shuffile_test test1.c)
TARGET_LINK_LIBRARIES(shuffile_test ${shuffile_lib})
#ADD_TEST(NAME shuffile_test COMMAND ${MPIEXEC} -n6 -N3 -m block ./shuffile_test)
SHUFFILE_ADD_TEST(shuffile_test 256 "")

ADD_EXECUTABLE(test_config test_config.c)
TARGET_LINK_LIBRARIES(test_config ${shuffile_lib})
ADD_TEST(NAME test_config COMMAND ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 1 ./test_config)

####################
# make a verbose "test" target named "check"
####################

ADD_CUSTOM_TARGET(check COMMAND ${CMAKE_CTEST_COMMAND} --verbose)
