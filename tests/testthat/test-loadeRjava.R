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
 
# ============================
# Test: Classpath precedence
# ============================

test_that("user-defined classpath precedes system CLASSPATH", {
  res <- callr::r(function() {
    # Temporary directories for system CLASSPATH and user-defined classpath
    sys_cp <- tempfile("syscp_"); dir.create(sys_cp)
    usr_cp <- tempfile("usrcp_"); dir.create(usr_cp)

    # Set system CLASSPATH before starting the JVM
    Sys.setenv(CLASSPATH = sys_cp)

    # Start the JVM with an explicit user-defined classpath
    rJava::.jinit(classpath = usr_cp)

    # Normalized paths for system CLASSPATH and user-defined classpath
    paths <- normalizePath(rJava::.jclassPath(), winslash = "/", mustWork = FALSE)
    sys_cp <- normalizePath(sys_cp, winslash = "/", mustWork = FALSE)
    usr_cp <- normalizePath(usr_cp, winslash = "/", mustWork = FALSE)

    # Return 
    list(paths = paths, sys_cp = sys_cp, usr_cp = usr_cp)
  })

  # Results
  paths <- res$paths
  sys_cp <- res$sys_cp
  usr_cp <- res$usr_cp

  # Assertions
  expect_true(any(paths == usr_cp)) # User-defined classpath is present
  expect_true(any(paths == sys_cp)) # System CLASSPATH is present
  expect_lt(which(paths == usr_cp), which(paths == sys_cp)) # User comes before system
})