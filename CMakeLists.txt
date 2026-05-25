cmake_minimum_required(VERSION 3.20)
project(RISCV64CPU NONE)

include(ProcessorCount)
ProcessorCount(NPROC)
if(NPROC EQUAL 0)
    set(NPROC 1)
endif()

find_program(VERILATOR          verilator          REQUIRED)
find_program(VERILATOR_COVERAGE verilator_coverage REQUIRED)
find_program(GTKWAVE            gtkwave)
find_program(GENHTML            genhtml)

set(SRC_DIR  ${CMAKE_SOURCE_DIR}/src)
set(INC_DIR  ${CMAKE_SOURCE_DIR}/inc)
set(TB_DIR   ${CMAKE_SOURCE_DIR}/tb)
set(GTKW_DIR ${CMAKE_SOURCE_DIR}/gtkw)
set(OUT_DIR  ${CMAKE_BINARY_DIR}/out)

set(VLT_FLAGS
    --binary --timing -sv --assert -Wall -O2
    --threads ${NPROC} --clk CLK
    -I${INC_DIR}
)

if(WIN32)
    set(EXE_EXT .exe)
else()
    set(EXE_EXT "")
endif()

# ---------------------------------------------------------------------------
# Parse "// DEPS: dep1 dep2 ..." from the first 10 lines of a TB file.
# Only list modules whose .sv contains a module definition the DUT instantiates.
# src/<module>.sv and all .vh files are always included automatically.
# ---------------------------------------------------------------------------
function(parse_deps TB_FILE OUT_VAR)
    file(STRINGS "${TB_FILE}" LINES LIMIT_COUNT 10)
    set(RESULT)
    foreach(LINE IN LISTS LINES)
        if(LINE MATCHES "^[ \t]*// DEPS:(.*)$")
            string(STRIP "${CMAKE_MATCH_1}" DEPS_STR)
            string(REPLACE " " ";" DEP_LIST "${DEPS_STR}")
            foreach(DEP IN LISTS DEP_LIST)
                if(NOT DEP STREQUAL "")
                    list(APPEND RESULT ${SRC_DIR}/${DEP}.sv)
                endif()
            endforeach()
            break()
        endif()
    endforeach()
    set(${OUT_VAR} "${RESULT}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# Register sim_<MOD>, coverage_<MOD>, wave_<MOD> for one module.
# src/<MOD>.sv is always compiled — only list extra instantiated modules in DEPS.
# ---------------------------------------------------------------------------
function(add_module_targets MOD TB_FILE)
    set(SRC_FILE ${SRC_DIR}/${MOD}.sv)
    set(MOD_OUT  ${OUT_DIR}/${MOD})
    set(SIM_LOG  ${CMAKE_BINARY_DIR}/sim.log)
    set(COV_LOG  ${CMAKE_BINARY_DIR}/coverage.log)

    parse_deps(${TB_FILE} DEP_SRCS)

    string(JOIN " " VLT_FLAGS_STR ${VLT_FLAGS})
    string(JOIN " " DEP_SRCS_STR  ${DEP_SRCS})

    # -- sim ----------------------------------------------------------------
    add_custom_target(sim_${MOD}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${MOD_OUT}
        COMMAND ${CMAKE_COMMAND} -E touch ${SIM_LOG}
        COMMAND sh -c "${VERILATOR} ${VLT_FLAGS_STR} --trace ${SRC_FILE} ${DEP_SRCS_STR} ${TB_FILE} --top ${MOD}_tb --Mdir ${MOD_OUT} -o ${MOD}_sim 2>&1 | tee ${SIM_LOG}"
        COMMAND sh -c "${MOD_OUT}/${MOD}_sim${EXE_EXT} 2>&1 | tee -a ${SIM_LOG}"
        COMMAND ${CMAKE_COMMAND} -E rename
                ${CMAKE_BINARY_DIR}/dump.vcd
                ${CMAKE_BINARY_DIR}/${MOD}.vcd
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "[sim] ${MOD}"
        VERBATIM
    )

    # -- coverage -----------------------------------------------------------
    set(EXTRA_COV_CMDS)
    if(GENHTML)
        list(APPEND EXTRA_COV_CMDS
            COMMAND sh -c "${VERILATOR_COVERAGE} --write-info ${CMAKE_BINARY_DIR}/coverage.info ${CMAKE_BINARY_DIR}/coverage.dat 2>&1 | tee -a ${COV_LOG}"
            COMMAND sh -c "${GENHTML} ${CMAKE_BINARY_DIR}/coverage.info --output-directory ${CMAKE_BINARY_DIR}/coverage_html 2>&1 | tee -a ${COV_LOG}"
            COMMAND ${CMAKE_COMMAND} -E echo "[coverage] HTML report: ${CMAKE_BINARY_DIR}/coverage_html/index.html"
        )
    else()
        list(APPEND EXTRA_COV_CMDS
            COMMAND sh -c "${VERILATOR_COVERAGE} --annotate ${CMAKE_BINARY_DIR}/coverage_annotated ${CMAKE_BINARY_DIR}/coverage.dat 2>&1 | tee -a ${COV_LOG}"
            COMMAND ${CMAKE_COMMAND} -E echo "[coverage] Annotated source: ${CMAKE_BINARY_DIR}/coverage_annotated/"
        )
    endif()

    add_custom_target(coverage_${MOD}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${MOD_OUT}
        COMMAND ${CMAKE_COMMAND} -E touch ${COV_LOG}
        COMMAND sh -c "${VERILATOR} ${VLT_FLAGS_STR} --coverage ${SRC_FILE} ${DEP_SRCS_STR} ${TB_FILE} --top ${MOD}_tb --Mdir ${MOD_OUT} -o ${MOD}_cov 2>&1 | tee ${COV_LOG}"
        COMMAND sh -c "${MOD_OUT}/${MOD}_cov${EXE_EXT} 2>&1 | tee -a ${COV_LOG}"
        COMMAND sh -c "${VERILATOR_COVERAGE} ${CMAKE_BINARY_DIR}/coverage.dat 2>&1 | tee -a ${COV_LOG}"
        ${EXTRA_COV_CMDS}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "[coverage] ${MOD}"
        VERBATIM
    )

    # -- wave ---------------------------------------------------------------
    add_custom_target(wave_${MOD}
        COMMAND ${CMAKE_COMMAND}
                -DGTKWAVE=${GTKWAVE}
                -DVCD=${CMAKE_BINARY_DIR}/${MOD}.vcd
                -DGTKW=${GTKW_DIR}/${MOD}.gtkw
                -P ${CMAKE_SOURCE_DIR}/cmake/wave.cmake
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "[wave] ${MOD}"
        VERBATIM
    )
endfunction()

# ---------------------------------------------------------------------------
# Auto-discover: every tb/<mod>_tb.sv with a matching src/<mod>.sv
# CONFIGURE_DEPENDS re-runs cmake when tb/ changes
# ---------------------------------------------------------------------------
file(GLOB TB_FILES CONFIGURE_DEPENDS ${TB_DIR}/*_tb.sv)
set(DISCOVERED_MODS)
foreach(TB_FILE IN LISTS TB_FILES)
    get_filename_component(TB_STEM ${TB_FILE} NAME_WE)
    string(REGEX REPLACE "_tb$" "" MOD "${TB_STEM}")
    if(EXISTS ${SRC_DIR}/${MOD}.sv)
        add_module_targets(${MOD} ${TB_FILE})
        list(APPEND DISCOVERED_MODS ${MOD})
    endif()
endforeach()

# ---------------------------------------------------------------------------
# Extend the built-in `clean` target to also remove logs, VCDs, coverage.dat,
# and the verilator out/ directory.
# ---------------------------------------------------------------------------
set(EXTRA_CLEAN_FILES
    ${CMAKE_BINARY_DIR}/sim.log
    ${CMAKE_BINARY_DIR}/coverage.log
    ${CMAKE_BINARY_DIR}/coverage.dat
    ${CMAKE_BINARY_DIR}/coverage.info
    ${CMAKE_BINARY_DIR}/coverage_html
    ${CMAKE_BINARY_DIR}/coverage_annotated
    ${CMAKE_BINARY_DIR}/out
)
foreach(MOD IN LISTS DISCOVERED_MODS)
    list(APPEND EXTRA_CLEAN_FILES ${CMAKE_BINARY_DIR}/${MOD}.vcd)
endforeach()
set_directory_properties(PROPERTIES ADDITIONAL_CLEAN_FILES "${EXTRA_CLEAN_FILES}")

# ---------------------------------------------------------------------------
# help
# ---------------------------------------------------------------------------
string(REPLACE ";" "  " MODS_PRETTY "${DISCOVERED_MODS}")
add_custom_target(help_vlt
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Usage:"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build <build_dir> --target sim_<module>        compile + run testbench"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build <build_dir> --target coverage_<module>   compile + run with coverage"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build <build_dir> --target wave_<module>        open GTKWave waveform viewer"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build <build_dir> --target clean               remove all build artifacts"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Deps:"
    COMMAND ${CMAKE_COMMAND} -E echo "  Add '// DEPS: mod1 mod2' on the first line of tb/<module>_tb.sv"
    COMMAND ${CMAKE_COMMAND} -E echo "  to pull in extra src/*.sv files the DUT instantiates."
    COMMAND ${CMAKE_COMMAND} -E echo "  src/<module>.sv and all .vh files are always included automatically."
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Output (all under <build_dir>/):"
    COMMAND ${CMAKE_COMMAND} -E echo "  sim.log / coverage.log        simulation and coverage logs"
    COMMAND ${CMAKE_COMMAND} -E echo "  <module>.vcd                  waveform for GTKWave"
    COMMAND ${CMAKE_COMMAND} -E echo "  out/<module>/                 verilator obj + binary"
    COMMAND ${CMAKE_COMMAND} -E echo "  coverage_html/index.html      HTML coverage report (requires genhtml)"
    COMMAND ${CMAKE_COMMAND} -E echo "  coverage_annotated/           annotated source (fallback, no genhtml)"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Discovered modules: ${MODS_PRETTY}"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMENT "Printing help"
    VERBATIM
)
