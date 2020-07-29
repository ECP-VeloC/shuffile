function(SHUFFILE_ADD_TEST name args outputs)

  # job launcher
  if(${VELOC_RESOURCE_MANAGER} STREQUAL "LSF")
    set(test_param jsrun -r 2)
  elseif(${VELOC_RESOURCE_MANAGER} STREQUAL "SLURM")
    set(test_param srun -N 3 -n 6)
  endif()

  # Tests
  add_test(NAME ${name} COMMAND ${test_param} ./${name} ${args} )

endfunction(SHUFFILE_ADD_TEST)
