# ============================
# Test: Memory Options
# ============================

test_that("loadeR.java respects 4GB memory via options()", {
    # Run in a new R process using callr
    result <- callr::r(function() {
        # Set the global option before loading the package
        options(java.parameters = "-Xmx4g") 
        # Load loadeR.java and capture startup messages
        capture.output(library(loadeR.java), type = "message")
    })

    # Check that the captured messages include "JVM maximum memory: 4.00 GB"
    expect_true(any(grepl("The maximum JVM heap space available is:\\s*4\\.00\\s*GB", result)))
})

# ============================
# Test: javaCalendarDate2rPOSIXlt.R
# ============================

test_that("javaCalendarDate2rPOSIXlt", {
  calendar_class <- J("ucar.nc2.time.CalendarDate") # Java class ucar.nc2.time.CalendarDate
  calendar_now <- calendar_class$present() # Get current calendar date 
  r_date <- javaCalendarDate2rPOSIXlt(calendar_now) # Convert to R POSIXlt
  
  # Test conversion
  expect_s3_class(r_date, "POSIXlt")
  expect_true(!is.null(r_date))
})

# ============================
# Test: javaString2rChar.R
# ============================

test_that("javaString2rChar", {
  jstr <- rJava::.jnew("java/lang/String", "Word") # Java class java.lang.String ("Hello world")
  rstr <- rJava::.jcall(jstr, "S", "toString") 
  rstr <- javaString2rChar(rstr) # Convert to R character string
  
  # Test conversion
  expect_equal(rstr, "Word")
  expect_type(rstr, "character")
})