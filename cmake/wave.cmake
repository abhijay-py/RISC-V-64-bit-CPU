# Called at build time by wave_<mod> targets.
# Variables passed in: GTKWAVE, VCD, GTKW

if(NOT EXISTS "${VCD}")
    message(FATAL_ERROR "VCD not found: ${VCD}\nRun sim_<module> first.")
endif()

if(EXISTS "${GTKW}")
    execute_process(COMMAND ${GTKWAVE} -f ${VCD} -a ${GTKW})
else()
    execute_process(COMMAND ${GTKWAVE} -f ${VCD})
endif()
