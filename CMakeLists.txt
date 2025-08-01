
# NOTE: This is an example usuage file
cmake_minimum_required(VERSION 3.10)

include(cmake/CMakeLogger.cmake)

project(ExampleProject
  LANGUAGES C CXX
  VERSION 1.0.1
  DESCRIPTION "Example project using CMakeLogger."
  HOMEPAGE_URL "https://github.com/giladreich/cmake-logger"
)

log_success("Hello CMakeLogger")
log_debug("Hello CMakeLogger")
log_info("Hello CMakeLogger")
log_warn("Hello CMakeLogger")
log_error("Hello CMakeLogger")
log_fatal("Hello CMakeLogger")

log_info("Timer examples:")

log_info("Example 1 - Short task (milliseconds format)")
log_reset_timer()
execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 0.3)
log_print_time_taken()

log_info("Example 2 - Medium task (seconds format)")
log_reset_timer()
execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 1.3)
log_print_time_taken()

log_info("Example 3 - Long task (minutes format)")
log_reset_timer()
# execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 63) # Uncomment to test long task
log_print_time_taken()

log_info("Example 4 - Manual timer usage")
log_reset_timer()
execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 1.2)
log_time_taken(duration_ms)
log_format_duration_ms(formatted_duration ${duration_ms})
log_info("Raw milliseconds: ${duration_ms}ms")
log_info("Formatted duration: ${formatted_duration}")

add_executable(${PROJECT_NAME} main.cpp)

# print the time taken since cmake initially started.
log_print_initial_time_taken()
