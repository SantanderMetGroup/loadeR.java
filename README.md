loadeR.java
===============

Java stuff on which other java-based R packages depend.

### JVM Memory Configuration:
If the Java Virtual Machine (JVM) is already initialized (e.g., by another package), the memory configuration cannot be changed, and a warning will be shown. If the JVM has not yet been initialized and the user has already set a `-Xmx` value, it will be respected only if it is greater than 2 GB; otherwise, it will be automatically increased to 2 GB. In all cases, once the JVM is initialized, the actual maximum available memory will be reported. To override the default memory setting, set `java.parameters` *before* loading the package:

```r
options(java.parameters = "-Xmx4g") # Set maximum heap space to 4 GB
library(loadeR.java)
```

### Configuring netCDF-Java classpath

By default, **loadeR.java** will use `netCDF-Java` JARs found in the java package directory. Users can point to their own `netCDF-Java` classpath, using a [netCDF-Java library](https://downloads.unidata.ucar.edu/netcdf-java/) installation.

**loadeR.java** provides options for defining the `netCDF-Java` classpath, which are considered in the following order of precedence:
1. R option: `loadeR.java_classpath`
2. Environment variable: `LOADER_JAVA_CLASSPATH`
3. Bundled fallback: java package directory

Each method accepts one or more classpath entries, separated by the platform path separator (`:` on Linux/macOS, `;` on Windows). Wildcards (`*`) are supported. In the case of using `*`, the order of precedence within the same option follows lexicographic order (ascending).

#### Example: R option
```r
options(loadeR.java_classpath = "/opt/netcdf-java/netcdfAll-5.9.0.jar")
library(loadeR.java)
```
 
#### Example: Environment variable 
```bash
# Linux/macOS
export LOADER_JAVA_CLASSPATH="/opt/netcdf-java/lib/*"
R -q -e "library(loadeR.java)"

# Windows PowerShell
$env:LOADER_JAVA_CLASSPATH = "C:\netcdf-java\lib\*"
R -NoSave -e "library(loadeR.java)"
```

#### Bundled fallback 
* Drop any required JARs into the java package directory.

### Configuring netCDF-Java version

On startup, **loadeR.java** tries to detect the `netCDF-Java` version from the JAR’s `MANIFEST.MF` file.  

If no `MANIFEST.MF` is found, the version cannot be detected automatically. You can manually set the `netCDF-Java` library version using an R option before loading the package:

```r
options(loadeR.java_forced_version = "5.9.0")
library(loadeR.java)
```
