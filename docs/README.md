
<p align="center"><img src="/media/logo.png" width=175 height=175></p>

<p align="center">
    <a href="https://cmake.org/" alt="CMake">
        <img src="https://img.shields.io/badge/CMake-logs-brightgreen.svg?logo=cmake" /></a>
    <a href="http://makeapullrequest.com" alt="Pull Requests">
        <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?logo=pre-commit" /></a>
</p>

---
# CMakeLogger

CMakeLogger is a CMake standalone script which eases the usage of printing logs and measuring time.

<img src="/media/cmakelogger.png" alt="Create Profile"/>

## Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [Authors](#authors)
- [License](#license)

## Features

CMakeLogger defines a set of functions that can be used in your scripts, such as:
- `log_fatal`
- `log_error`
- `log_warn`
- `log_info`
- `log_debug`
- `log_success`

Each of the functions above receives a string as an argument for the log message.

CMakeLogger also allows convenient use of measuring time:
- `log_reset_timer` - use before starting measuring time
- `log_print_time_taken` - use after operation is finished
- `log_print_initial_time_taken` - use to know how long since cmake started

This is useful if certain operations in your scripts take a while and you want to print how long in seconds it took.

Apart from the functions mentioned above, CMakeLogger allows different customization by giving the option to override some of configurations that can be found at the beginning of `CMakeLogger.cmake` file.


See [CMakeLists.txt](https://github.com/giladreich/CMakeLogger/blob/master/CMakeLists.txt) in the root directory for example usage.

Note that colorized output is not supported by all terminals, therefore CMakeLogger tries to determine in which environment the current execution is and allows it to print if supported. If you suspect your terminal supports printing in colors and CMakeLogger determination is wrong, opening an issue or sending a PR would be greatly appreciated.

## Getting Started

Download links can be found in [GitHub's releases page](https://github.com/giladreich/CMakeLogger/releases).

Download the `cmake/CMakeLogger.cmake` file into your project and add this in the root `CMakeLists.txt` of your project:
```cmake
include("cmake/CMakeLogger.cmake")
```

This will define a set of functions for you to use (listed above).

Another possible way if you don't want to copy it into your project, is by adding this into your root `CMakeLists.txt`:
```cmake
if(NOT EXISTS "${CMAKE_BINARY_DIR}/CMakeLogger.cmake")
  file(DOWNLOAD
    "https://raw.githubusercontent.com/giladreich/CMakeLogger/v1.0.1/cmake/CMakeLogger.cmake"
    "${CMAKE_BINARY_DIR}/CMakeLogger.cmake")
endif()
include("${CMAKE_BINARY_DIR}/CMakeLogger.cmake")
```

## Contributing

Pull-Requests are greatly appreciated should you like to contribute to the project.

Same goes for opening issues; if you have any suggestions, feedback or you found any bugs, please do not hesitate to open an [issue](https://github.com/giladreich/CMakeLogger/issues).

## Authors

* **Gilad Reich** - *Initial work* - [giladreich](https://github.com/giladreich)

See also the list of [contributors](https://github.com/giladreich/CMakeLogger/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.
