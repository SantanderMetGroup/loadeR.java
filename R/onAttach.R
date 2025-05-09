#' @importFrom rJava .jcall J

.onAttach <- function(...) {
    jversion <- .jcall("java/lang/System", "S", "getProperty", "java.specification.version")
    jarch <- .jcall("java/lang/System", "S", "getProperty", "os.arch")
    jvendor <- .jcall("java/lang/System", "S", "getProperty", "java.vendor")
    packageStartupMessage("Java version ", jversion, "x ",jarch, " by ", jvendor, " detected")
    if (as.numeric(jversion) < 1.7) {
        packageStartupMessage("WARNING: Java versions under 1.7x not supported by the netCDF API. Please upgrade\n<https://github.com/SantanderMetGroup/loadeR/wiki/installation>.")
    } else {
        packageStartupMessage("NetCDF Java Library v4.6.0-SNAPSHOT (23 Apr 2015) loaded and ready")

        # Print full MANIFEST.MF content from netCDF JAR if available
        jar_path <- system.file("java", "netcdfAll-4.6.0-SNAPSHOT.jar", package = "loadeR.java")
        if (file.exists(jar_path)) {
            manifest_info <- tryCatch({
                lines <- readLines(unz(jar_path, "META-INF/MANIFEST.MF"))
                paste(lines, collapse = "\n")
            }, error = function(e) {
                paste("Could not read MANIFEST.MF from JAR:", e$message)
            })
            packageStartupMessage("Manifest content from netCDF JAR:\n", manifest_info)
        } else {
            packageStartupMessage("Warning: netCDF JAR not found at expected location.")
        }

    }
    J("java.util.logging.Logger")$getLogger("")$setLevel(J("java.util.logging.Level")$SEVERE)
} 



