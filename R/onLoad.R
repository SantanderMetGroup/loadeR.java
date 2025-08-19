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

      # Determine classpath for netCDF-Java based on R option, environment variable, or fallback
      cp_opt <- getOption("loadeR.netcdf_java_classpath", "")
      cp_env <- Sys.getenv("LOADER_NETCDF_JAVA_CLASSPATH", "")
      cp_source <- NULL # Selected classpath source (cp_opt, cp_env, or fallback)
      cp_msg <- NULL # Message of selected classpath source (for display when attaching the package)
      cp_entries <- character()

      # If both R option and environment variable are set, R option takes precedence
      if (cp_opt != "" && cp_env != "" && cp_opt != cp_env) {
            # Check if the user has enabled strict mode: if TRUE, stop on conflicting classpath values; if FALSE (default), just warn
            if (getOption("loadeR.java.strict_classpath", FALSE)) {
                  stop("Conflicting netCDF-Java classpath: both R option and environment variable are set")
            } else {
                  warning("Conflicting netCDF-Java classpath: both R option and environment variable are set. Using R option value.")
            }
      }
      if (cp_opt != "") {
            # Use the classpath specified in the R option
            cp_msg <- "R option loadeR.netcdf_java_classpath"
            cp_source <- cp_opt
            cp_entries <- strsplit(cp_opt, .Platform$path.sep, fixed = TRUE)[[1]]
      } else if (cp_env != "") {
            # Use the classpath specified in the environment variable
            cp_msg <- "env LOADER_NETCDF_JAVA_CLASSPATH"
            cp_source <- cp_env
            cp_entries <- strsplit(cp_env, .Platform$path.sep, fixed = TRUE)[[1]]
      } else {
            # Use bundled JARs and directories under inst/java as fallback
            cp_msg <- "bundled inst/java/*"
            java_path <- system.file("java", package = pkgname)
            cp_source <- file.path(java_path, "*")
            # Include all JAR files in inst/java
            jar_files <- list.files(java_path, pattern = "\\.jar$", full.names = TRUE)
            # Include all directories in inst/java
            all_entries <- list.files(java_path, full.names = TRUE)
            dir_entries <- all_entries[file.info(all_entries)$isdir]
            # Include inst/java itself 
            cp_entries <- c(java_path, jar_files, dir_entries)
      }
      # Clean empty or whitespace entries
      cp_entries <- unique(trimws(cp_entries))
      cp_entries <- cp_entries[cp_entries != ""]

      # Expand entries
      expanded_entries <- unique(unlist(lapply(path.expand(cp_entries), Sys.glob)))

      # Initialize the JVM with the determined classpath if not already running
      if (!rJava::.jniInitialized) {
            rJava::.jinit(classpath = expanded_entries)
      } else {
            # If JVM is already running, add classpath entries 
            for (cp in expanded_entries) {
                  rJava::.jaddClassPath(cp)
            }
            warning("JVM is already initialized; the netCDF-Java classpath was added at runtime (consider restarting R to apply it from startup).")
      }
      # Save classpath info for display when attaching the package
      options(loadeR.netcdf_java_classpath_msg = cp_msg, loadeR.netcdf_java_classpath_source = cp_source)
}
