function(SHUFFILE_ADD_TEST name args outputs)

  # job launcher
  if(${VELOC_RESOURCE_MANAGER} STREQUAL "NONE")
    # Assume mpirun if no resource manager in place
    set(test_param_s mpirun -np 1)
    set(test_param_p mpirun -np ${parallel_nodes})
  elseif(${VELOC_RESOURCE_MANAGER} STREQUAL "LSF")
    set(test_param jsrun -nnodes 3 -n 6)
  elseif(${VELOC_RESOURCE_MANAGER} STREQUAL "SLURM")
    set(test_param_s srun -N 3 -n 6)
  endif()

  # Tests
  add_test(NAME serial_${name}_start COMMAND ${test_param} ./${name} ${args} )

endfunction(SHUFFILE_ADD_TEST)
