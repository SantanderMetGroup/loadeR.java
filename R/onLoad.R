#' @importFrom rJava .jpackage

.onLoad <- function(libname, pkgname) {
      # Read custom memory option (if it exists)
      mem_option <- getOption("loadeR.java.memory") 

      # Read JAVA_TOOL_OPTIONS environment variable (if it exists)
      mem_env  <- Sys.getenv("JAVA_TOOL_OPTIONS", unset = "")  

      # Set memory value (-Xmx2g as default)
      mem_value  <- if (!is.null(mem_option)) mem_option else if (nzchar(mem_env)) mem_env else "-Xmx2g" 
      
      # Configure java.parameters if JVM not yet initialized
      if (!rJava::.jniInitialized) {
            options(java.parameters = mem_value)
      } else {
            warning("JVM is already initialized; java.parameters could not be set.")
      }

      # Get the correct path to the 'java' directory inside the package
      java_path <- system.file("java", package = pkgname)
      
      # Initialize rJava and add all JARs in the 'java' directory to the classpath
      rJava::.jpackage(pkgname, lib.loc = dirname(java_path))

      # Report JVM maximum memory 
      runtime <- rJava::.jcall("java/lang/Runtime", "Ljava/lang/Runtime;", "getRuntime")
      max_mem_bytes <- rJava::.jcall(runtime, "J", "maxMemory")
      max_mem_gb <- round(max_mem_bytes / (1024^3), 2)
      packageStartupMessage(sprintf("The maximum JVM heap space available is: %.2f GB", max_mem_gb))
}
