loadeR.java
===============

Java stuff on which other java-based R packages depend.

### JVM Memory Configuration:
If the Java Virtual Machine (JVM) is already initialized (e.g., by another package), the memory configuration cannot be changed, and a warning will be shown. In all cases, the package will report the actual maximum memory available to the JVM after loading. If the JVM is not yet initialized, `loadeR.java` sets the maximum heap size to **2 GB** (`-Xmx2g`) by default. You can override this setting *before* loading the package using one of the following methods:

```r
# Set an R option
options(loadeR.java.memory = "-Xmx4g")
library(loadeR.java)

# Or use an environment variable
Sys.setenv(JAVA_TOOL_OPTIONS = "-Xmx4g")
library(loadeR.java)
