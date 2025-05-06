#' @importFrom rJava .jpackage

.onLoad <- function(libname, pkgname) {
  # Set the maximum memory for the Java Virtual Machine (JVM)
  options(java.parameters = "-Xmx2g")
  
  # Get the correct path to the 'java' directory inside the package
  java_path <- system.file("java", package = pkgname)
  
  # Initialize rJava and add all JARs in the 'java' directory to the classpath
  rJava::.jpackage(pkgname, lib.loc = dirname(java_path))
}
