#' @importFrom rJava .jcall J

.onAttach <- function(...) {
    jversion <- .jcall("java/lang/System", "S", "getProperty", "java.specification.version")
    jarch <- .jcall("java/lang/System", "S", "getProperty", "os.arch")
    jvendor <- .jcall("java/lang/System", "S", "getProperty", "java.vendor")
    packageStartupMessage("Java version ", jversion, "x ",jarch, " by ", jvendor, " detected")
    if (as.numeric(jversion) < 1.7) {
        packageStartupMessage("WARNING: Java versions under 1.7x not supported by the netCDF API. Please upgrade\n<https://github.com/SantanderMetGroup/loadeR/wiki/installation>.")
    } else {
        # Report JVM maximum heap memory 
        runtime <- rJava::.jcall("java/lang/Runtime", "Ljava/lang/Runtime;", "getRuntime")
        max_mem_bytes <- rJava::.jcall(runtime, "J", "maxMemory")
        max_mem_gb <- round(max_mem_bytes / (1024^3), 2)
        packageStartupMessage(sprintf("The maximum JVM heap space available is: %.2f GB", max_mem_gb))
        
        # Get forced netcdf version
        forced <- getOption("loadeR.java.forced_version", "")

        # Use ClassLoader to access MANIFEST.MF
        manifest_info <- tryCatch({
            # Load NetcdfFile class loader
            netcdf_class <- rJava::.jfindClass("ucar/nc2/NetcdfFile")
            class_loader <- rJava::.jcall(netcdf_class, "Ljava/lang/ClassLoader;", "getClassLoader")
            manifest_url <- rJava::.jcall(class_loader, "Ljava/net/URL;", "getResource", "META-INF/MANIFEST.MF")

            if (rJava::is.jnull(manifest_url)) {
                if (nzchar(forced)) {
                    packageStartupMessage(sprintf(
                        "NetCDF Java Library Forced Version: %s",
                        forced
                    ))
                } else {
                    packageStartupMessage(
                        "NetCDF Java Library version could not be detected. You can set it manually via R option before loading the package"
                    )
                }
                stop("MANIFEST.MF not found via NetcdfFile class loader")
            }

            input_stream <- rJava::.jcall(manifest_url, "Ljava/io/InputStream;", "openStream")
            manifest <- rJava::.jnew("java/util/jar/Manifest", input_stream)
            attributes <- rJava::.jcall(manifest, "Ljava/util/jar/Attributes;", "getMainAttributes")

            # Extract specific fields
            fields <- c("Implementation-Version", "Built-On", "Build-Jdk")
            extracted_fields <- lapply(fields, function(field) {
                value <- rJava::.jcall(attributes, "Ljava/lang/String;", "getValue", field)
                if (!is.null(value)) value else NA
            })
            names(extracted_fields) <- fields

            # Save netcdf version 
            options(loadeR.java.detected_version = extracted_fields[["Implementation-Version"]])
            extracted_fields
        }, error = function(e) {
            packageStartupMessage(e$message)
            NULL
        })

        if (!is.null(manifest_info)) {
            packageStartupMessage(sprintf(
                "NetCDF Java Library Version: %s (Built-On: %s) loaded and ready",
                manifest_info[["Implementation-Version"]],
                manifest_info[["Built-On"]]
            ))
        }
        # Show the source of the netCDF-Java classpath used
        cp_entries <- getOption("loadeR.netcdf_java_classpath_entries")
        cp_msg <- getOption("loadeR.netcdf_java_classpath_msg")
        if (!is.null(cp_entries) && !is.null(cp_msg)) {
            packageStartupMessage(sprintf("netCDF-Java CLASSPATH from %s: %s", cp_msg,  paste(cp_entries, collapse = .Platform$path.sep)))
        } 
    }
    
    J("java.util.logging.Logger")$getLogger("")$setLevel(J("java.util.logging.Level")$SEVERE)
} 



