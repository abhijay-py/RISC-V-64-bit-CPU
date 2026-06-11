# Called at build time by wave_<mod> targets.
# Variables passed in: GTKWAVE, WAVE, GTKW, MOD, BUILD_DIR

if(NOT EXISTS "${WAVE}")
    message(STATUS "Waveform not found: ${WAVE} -- running sim_${MOD}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR} --target sim_${MOD}
        RESULT_VARIABLE SIM_RESULT
    )
    if(NOT SIM_RESULT EQUAL 0)
        message(FATAL_ERROR "sim_${MOD} failed")
    endif()
endif()

if(NOT EXISTS "${WAVE}")
    message(FATAL_ERROR "Waveform still not found after running sim_${MOD}: ${WAVE}")
endif()

if(EXISTS "${GTKW}")
    execute_process(COMMAND ${GTKWAVE} -f ${WAVE} -a ${GTKW})
else()
    execute_process(COMMAND ${GTKWAVE} -f ${WAVE})
endif()
