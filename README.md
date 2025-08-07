loadeR.java
===============

Java stuff on which other java-based R packages depend.

### JVM Memory Configuration:
If the Java Virtual Machine (JVM) is already initialized (e.g., by another package), the memory configuration cannot be changed, and a warning will be shown. If the JVM has not yet been initialized and the user has already set a `-Xmx` value, it will be respected only if it is greater than 2 GB; otherwise, it will be automatically increased to 2 GB. In all cases, once the JVM is initialized, the actual maximum available memory will be reported. To override the default memory setting, set `java.parameters` *before* loading the package:

```r
options(java.parameters = "-Xmx4g") # Set maximum heap space to 4 GB
library(loadeR.java) 