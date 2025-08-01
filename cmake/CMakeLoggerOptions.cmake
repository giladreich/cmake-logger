# Example configuration file for CMakeLogger
#
# This file is used to set default configurations for CMakeLogger.
# It is recommended to use this file to better manage configurations, as it allows
# for easy overrides and is compatible with cmake-gui for user-friendly
# configuration management.
#
# CMakeLogger will automatically load configurations from this file if it exists.
#
# Configuration override methods (because these are cached variables):
# 1. Use CMakeLoggerOptions.cmake file (recommended)
# 2. Use command line options (e.g., -DCMLOGGER_OUTPUT_COLORIZED=OFF)
# 3. Set cached variables in your CMakeLists.txt before include(cmake/CMakeLogger.cmake)
# 4. Set cached variables anywhere with FORCE (not recommended for cmake-gui compatibility)
#
# Using CMakeLoggerOptions.cmake is the recommended approach for managing configurations.

set(CMLOGGER_OUTPUT_COLORIZED ON
  CACHE BOOL
  "CMakeLogger: Colorized output"
)

set(CMLOGGER_OUTPUT_PREFIX ">>"
  CACHE STRING
  "CMakeLogger: Log out prefix. e.g. '>> INFO    My Log'"
)
