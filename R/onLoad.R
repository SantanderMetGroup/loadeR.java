#' @importFrom rJava .jpackage

.onLoad <- function(libname, pkgname) {
      # Get the current java.parameters
      #current_params <- getOption("java.parameters", default = "")
      current_params <- getOption("java.parameters", default = character())
      current_params <- trimws(current_params)
      current_params <- current_params[nzchar(current_params)]
      
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

      # Determine classpath for netCDF-Java based on R option, environment variable, or fallback
      cp_opt <- getOption("loadeR.java_classpath", "")
      cp_env <- Sys.getenv("LOADER_JAVA_CLASSPATH", "")
       
      cp_msg <- NULL
      cp_entries <- character()
 
      if (cp_opt != "") {
            # Use the classpath specified in the R option
            cp_msg <- "R option loadeR.java_classpath" 
            cp_entries <- c(cp_entries, strsplit(cp_opt, .Platform$path.sep, fixed = TRUE)[[1]])
      } 
      if (cp_env != "") {
            # Use the classpath specified in the environment variable
            cp_msg <- if (is.null(cp_msg)) "env LOADER_JAVA_CLASSPATH" else paste(cp_msg, "+ env LOADER_JAVA_CLASSPATH")
            cp_entries <- c(cp_entries, strsplit(cp_env, .Platform$path.sep, fixed = TRUE)[[1]])
      } 
      # Use java package directory as fallback
      cp_msg <- if (is.null(cp_msg)) "bundled java package directory" else paste(cp_msg, "+ bundled java package directory")
      # Include jar/zip files and first-level subdirectories from java package directory
      java_path <- system.file("java", package = pkgname) 
      java_entries <- c(
            list.files(java_path, pattern = "\\.(jar|zip)$", full.names = TRUE), 
            setdiff(list.dirs(java_path, recursive = FALSE, full.names = TRUE), java_path)
      )
      java_entries <- sort(java_entries, decreasing = FALSE)
      cp_entries <- c(cp_entries, java_path, java_entries)

      # Clean empty or whitespace entries
      cp_entries <- trimws(cp_entries)
      cp_entries <- cp_entries[cp_entries != ""]

      # Expand entries
      cp_entries <- unique(unlist(lapply(path.expand(cp_entries), Sys.glob)))

      # Initialize the JVM with the determined classpath if not already running
      if (!rJava::.jniInitialized) {
            rJava::.jinit(classpath = cp_entries)
      } else {
            # If JVM is already running, add classpath entries 
            for (cp in cp_entries) {
                  rJava::.jaddClassPath(cp)
            }
            warning("JVM is already initialized; the netCDF-Java classpath was added at runtime (consider restarting R to apply it from startup).")
      }
      # Save classpath info for display when attaching the package
      options(loadeR.java_classpath_msg = cp_msg, loadeR.java_classpath_entries = cp_entries)
}
