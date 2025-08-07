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