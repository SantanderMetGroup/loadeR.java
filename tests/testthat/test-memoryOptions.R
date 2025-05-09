test_that("loadeR.java respects 4GB memory via options()", {
    # Run in a new R process using callr
    result <- callr::r(function() {
        # Set the global option before loading the package
        options(loadeR.java.memory = "-Xmx4g")
        # Load loadeR.java and capture startup messages
        capture.output(library(loadeR.java), type = "message")
    })

    # Check that the captured messages include "JVM maximum memory: 4.00 GB"
    expect_true(any(grepl("The maximum JVM heap space available is:\\s*4\\.00\\s*GB", result)))
})

test_that("loadeR.java respects 4GB memory via JAVA_TOOL_OPTIONS", {
    # Run in a new R process using callr
    result <- callr::r(function() {
        # Load loadeR.java (the environment variable will be set in this process)
        capture.output(library(loadeR.java), type = "message")
    }, env = c(JAVA_TOOL_OPTIONS = "-Xmx4g"))

    # Check that the captured messages include "JVM maximum memory: 4.00 GB"
    expect_true(any(grepl("The maximum JVM heap space available is:\\s*4\\.00\\s*GB", result)))
})