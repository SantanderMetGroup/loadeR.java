#' @importFrom rJava .jpackage

.onLoad <- function(libname, pkgname) {
  if (!rJava::.jniInitialized) {
    options(java.parameters = "-Xmx2g")
  } else {
    warning("JVM is already initialized; java.parameters could not be set.")
  }

  # Get the correct path to the 'java' directory inside the package
  java_path <- system.file("java", package = pkgname)

  # Initialize rJava and add all JARs in the 'java' directory to the classpath
  rJava::.jpackage(pkgname, lib.loc = dirname(java_path))
}
