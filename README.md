loadeR.java
===============

Java stuff on which other java-based R packages depend.

### JVM Memory Configuration:
If the Java Virtual Machine (JVM) is already initialized (e.g., by another package), the memory configuration cannot be changed, and a warning will be shown. If the JVM has not yet been initialized and the user has already set a `-Xmx` value, it will be respected only if it is greater than 2 GB; otherwise, it will be automatically increased to 2 GB. In all cases, once the JVM is initialized, the actual maximum available memory will be reported. To override the default memory setting, set `java.parameters` *before* loading the package:

```r
options(java.parameters = "-Xmx4g") # Set maximum heap space to 4 GB
library(loadeR.java)
```

### Configuring the netCDF-Java Classpath

By default, **loadeR.java** will use the bundled JARs found in the java package directory.  
Advanced users can override this behavior to point to their own `netCDF-Java` setup (e.g., for development or production deployments).

Classpath precedence:
1. R option: `loadeR.netcdf_java_classpath`
2. Environment variable: `LOADER_NETCDF_JAVA_CLASSPATH`
3. Bundled fallback: java package directory

Each method accepts one or more classpath entries, separated by the platform path separator (`:` on Linux/macOS, `;` on Windows). Wildcards (`*`) are supported.

#### Example: Production (single JAR)
```r
options(loadeR.netcdf_java_classpath = "/opt/netcdf-java/netcdfAll-5.9.0.jar")
library(loadeR.java)
```

#### Example: Development (directories + jars)
```r
options(loadeR.netcdf_java_classpath = paste(
  "~/dev/netcdf-java/cdm/build/classes/java/main",
  "~/dev/netcdf-java/cdm/build/resources/main",
  "~/dev/netcdf-java/grib/build/classes/java/main",
  "~/dev/netcdf-java/grib/build/resources/main",
  sep = .Platform$path.sep
))
library(loadeR.java)
```
#### Example: Environment variable (persistent, default)
```bash
# Linux/macOS
export LOADER_NETCDF_JAVA_CLASSPATH="/opt/netcdf-java/lib/*"
R -q -e "library(loadeR.java)"

# Windows PowerShell
$env:LOADER_NETCDF_JAVA_CLASSPATH = "C:\netcdf-java\lib\*"
R -NoSave -e "library(loadeR.java)"
```

#### Bundled fallback (no config)
* Drop any required jars and directory into the java package directory.

### NetCDF-Java Version Detection (MANIFEST.MF)

On startup, **loadeR.java** tries to detect the `netCDF-Java` version from the JAR’s `MANIFEST.MF` file.  

If you are using development directories or classpaths without a MANIFEST, the version cannot be detected automatically.  
In that case, you can set it manually before loading the package:

```r
options(loadeR.java.forced_version = "5.9.0")
library(loadeR.java)
```
