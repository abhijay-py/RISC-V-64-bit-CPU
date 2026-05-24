# Called at build time by the clean_artifacts target.
# Variables passed in: BUILD_DIR, SOURCE_DIR

file(REMOVE_RECURSE "${BUILD_DIR}/out")

file(GLOB VCD_FILES  "${SOURCE_DIR}/*.vcd")
file(GLOB LOG_FILES  "${SOURCE_DIR}/*.log")

file(REMOVE
    ${VCD_FILES}
    ${LOG_FILES}
    "${SOURCE_DIR}/coverage.dat"
)
