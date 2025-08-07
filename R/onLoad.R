#' @importFrom rJava .jpackage

.onLoad <- function(libname, pkgname) {
      # Get the current java.parameters
      current_params <- getOption("java.parameters", default = "")
      
      # Check if "-Xmx" is already present
      xmx_index <- grep("-Xmx[0-9]+[mMgG]", current_params)
      if (length(xmx_index) > 0) {
            # Extract the current -Xmx value
            current_xmx <- sub("-Xmx([0-9]+[mMgG])", "\\1", current_params[xmx_index])
            # Convert to numeric value in gigabytes
            current_xmx_gb <- as.numeric(sub("[mMgG]", "", current_xmx)) / ifelse(grepl("[mM]", current_xmx), 1024, 1)
            # Replace with "-Xmx2g" if the current value is less than 2g
            if (!is.na(current_xmx_gb) && current_xmx_gb < 2) {
                  current_params[xmx_index] <- "-Xmx2g"
            }
      } else {
            # Add "-Xmx2g" if no -Xmx is present
            current_params <- c(current_params, "-Xmx2g")
      }
      
      # Update java.parameters
      options(java.parameters = current_params)
      
      # Warn if JVM is already initialized
      if (rJava::.jniInitialized) {
            warning("JVM is already initialized; java.parameters could not be set.")
      }

      # Get the correct path to the 'java' directory inside the package
      java_path <- system.file("java", package = pkgname)

      # Get path to all JAR files in the 'java' directory 
      jar_files <- list.files(java_path, pattern = "\\.jar$", full.names = TRUE)

      # Force JVM initialization with JAR classpath if not already done 
      if (!rJava::.jniInitialized) rJava::.jinit(classpath = jar_files)
}
