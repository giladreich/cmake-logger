
# NOTE: This is an example usuage file
cmake_minimum_required(VERSION 3.11)

include("cmake/CMakeLogger.cmake")

project(ExampleProject
  LANGUAGES CXX
  VERSION 1.0.0
  DESCRIPTION "A simple CMake logger."
  HOMEPAGE_URL "https://github.com/giladreich/CMakeLogger"
)

# Enable colorized logs output (by default it's set to ON)
set(CMLOGGER_OUTPUT_COLORIZED ON CACHE STRING "" FORCE)

log_reset_timer() # Start the timer to see how long it takes cloning gtest
log_info("Fetching googletest...this might take some time...")
include(FetchContent)
FetchContent_Declare(googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
)
FetchContent_MakeAvailable(googletest)

# Print time taken
log_print_initial_time_taken() # print the time taken since cmake initially started.
log_print_time_taken() # print the time taken since `log_reset_timer` was last called.

log_success("Hello CMakeLogger")
log_debug("Hello CMakeLogger")
log_info("Hello CMakeLogger")
log_warn("Hello CMakeLogger")
log_error("Hello CMakeLogger")
log_fatal("Hello CMakeLogger")

add_executable(${PROJECT_NAME} main.cpp)
