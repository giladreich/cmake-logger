## =============================================================================== ##
## The MIT License (MIT)                                                           ##
##                                                                                 ##
## Copyright (c) 2020-present Gilad Reich                                          ##
##                                                                                 ##
## Permission is hereby granted, free of charge, to any person obtaining a copy    ##
## of this software and associated documentation files (the "Software"), to deal   ##
## in the Software without restriction, including without limitation the rights    ##
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell       ##
## copies of the Software, and to permit persons to whom the Software is           ##
## furnished to do so, subject to the following conditions:                        ##
##                                                                                 ##
## The above copyright notice and this permission notice shall be included in all  ##
## copies or substantial portions of the Software.                                 ##
##                                                                                 ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR      ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     ##
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   ##
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   ##
## SOFTWARE.                                                                       ##
## =============================================================================== ##

# How to use
#   1. Copy me under: 'your_project/cmake/CMakeLogger.cmake'
#   2. Add right at the beginning in the root CMakeLists.txt:
#      include(cmake/CMakeLogger.cmake)
#   3. Use anywhere the following functions:
#        * log_fatal
#        * log_error
#        * log_warn
#        * log_info
#        * log_debug
#        * log_success
#      e.g. log_info("Hello CMakeLogger")
#
#   Additionaly, you can configure in your root CMakeLists.txt how logs will be outputed.
cmake_minimum_required(VERSION 3.10)

set(CMLOGGER_VERSION "v1.0.1"
  CACHE STRING "CMakeLogger: Version")

##################################################################################################################
# Configurations
# NOTE: It would be better overriding default configurations from your own CMake scripts as needed, instead
# of modifying them here. e.g. right after including:
# include(cmake/CMakeLogger.cmake)
# set(CMLOGGER_OUTPUT_COLORIZED OFF CACHE STRING "" FORCE)

# Log Level Colors. Available colors: normal|black|red|green|yellow|blue|magenta|cyan|white
set(CMLOGGER_COLOR_FATAL       "red")
set(CMLOGGER_COLOR_ERROR       "bold;red")
set(CMLOGGER_COLOR_WARN        "bold;yellow")
set(CMLOGGER_COLOR_INFO        "bold;cyan")
set(CMLOGGER_COLOR_DEBUG       "bold;blue")
set(CMLOGGER_COLOR_SUCCESS     "bold;green")

set(CMLOGGER_OUTPUT_COLORIZED ON
  CACHE STRING "CMakeLogger: Colorized output")
set_property(CACHE CMLOGGER_OUTPUT_COLORIZED PROPERTY STRINGS ON OFF)

set(CMLOGGER_OUTPUT_TIMESTAMP ON
  CACHE STRING "CMakeLogger: Include timestamp in the log output. e.g. '~~ 15:05:14 INFO    My Log'")
set_property(CACHE CMLOGGER_OUTPUT_TIMESTAMP PROPERTY STRINGS ON OFF)

set(CMLOGGER_OUTPUT_TIMESTAMP_FORMAT "%H:%M:%S"
  CACHE STRING "CMakeLogger: Timestamp format")

set(CMLOGGER_OUTPUT_WRAP "********"
  CACHE STRING "CMakeLogger: String to surround your log. e.g. '~~ INFO    **** My Log ****'")

set(CMLOGGER_OUTPUT_PREFIX "~~ "
  CACHE STRING "CMakeLogger: Log out prefix. e.g. '~~ INFO    My Log'")

set(CMLOGGER_OUTPUT_PROJECTNAME ON
  CACHE STRING "CMakeLogger: Include current project name in the log output if exists. e.g. '~~ INFO    [MyProjectName]: My Log'")
set_property(CACHE CMLOGGER_OUTPUT_PROJECTNAME PROPERTY STRINGS ON OFF)

set(CMLOGGER_TIMERS ON
  CACHE STRING "CMakeLogger: Turn this off if not desired to use any of the timers functions")

# END Configurations
##################################################################################################################

##################################################################################################################
# Log Levels

function(log_fatal msg)
  CMakeLogger_log(FATAL_ERROR "FATAL  " "${msg}" "${CMLOGGER_COLOR_FATAL}")
endfunction()

function(log_error msg)
  CMakeLogger_log(SEND_ERROR  "ERROR  " "${msg}" "${CMLOGGER_COLOR_ERROR}")
endfunction()

function(log_warn msg)
  CMakeLogger_log(WARNING     "WARN   " "${msg}" "${CMLOGGER_COLOR_WARN}")
endfunction()

function(log_info msg)
  CMakeLogger_log(STATUS      "INFO   " "${msg}" "${CMLOGGER_COLOR_INFO}")
endfunction()

function(log_debug msg)
  CMakeLogger_log(STATUS      "DEBUG  " "${msg}" "${CMLOGGER_COLOR_DEBUG}")
endfunction()

function(log_success msg)
  CMakeLogger_log(STATUS      "SUCCESS" "${msg}" "${CMLOGGER_COLOR_SUCCESS}")
endfunction()

# END Log Levels
##################################################################################################################

##################################################################################################################
# Timers

# Saving initial time when cmake started in UNIX format (remains untouched).
set(CMLOGGER_TIME_STARTED "0")

# Saving initial time when log_reset_timer was called in UNIX format.
set(CMLOGGER_TIMER_STARTED "0")

# Usage example:
#   log_reset_timer()
#   very long task....
#   log_print_time_taken()
function(log_reset_timer)
  if(NOT CMLOGGER_TIMERS)
    return()
  endif()

  string(TIMESTAMP CMLOGGER_TIMER_STARTED "%s")
  set(CMLOGGER_TIMER_STARTED ${CMLOGGER_TIMER_STARTED} PARENT_SCOPE)

    # If it's 0, meaning it's the first time this function is called and cmake started
  if("${CMLOGGER_TIME_STARTED}" STREQUAL "0")
    set(CMLOGGER_TIME_STARTED "${CMLOGGER_TIMER_STARTED}" PARENT_SCOPE)
  endif()
endfunction()

# Prints the initial time taken in seconds since since this file was first included or cmake started.
# Substracts current time with CMLOGGER_TIME_STARTED and print it.
function(log_print_initial_time_taken)
  if(NOT CMLOGGER_TIMERS)
    return()
  endif()

  string(TIMESTAMP CMLOGGER_TIMER_CURRENT "%s")
  math(EXPR CMLOGGER_TIME_TAKEN ${CMLOGGER_TIMER_CURRENT}-${CMLOGGER_TIME_STARTED})
  log_info("Initial Time Taken: ${CMLOGGER_TIME_TAKEN} seconds.")
endfunction()

# Prints the time taken in seconds since log_reset_timer() was last called.
# Substracts current time with CMLOGGER_TIMER_STARTED and print it.
function(log_print_time_taken)
  if(NOT CMLOGGER_TIMERS)
    return()
  endif()

  string(TIMESTAMP CMLOGGER_TIMER_CURRENT "%s")
  math(EXPR CMLOGGER_TIME_TAKEN ${CMLOGGER_TIMER_CURRENT}-${CMLOGGER_TIMER_STARTED})
  log_info("Time Taken: ${CMLOGGER_TIME_TAKEN} seconds.")
endfunction()

# Call to update timestamps when this file is included.
log_reset_timer()

# END Timers
##################################################################################################################

function(CMakeLogger_is_valid_color color)
  unset(CMLOGGER_IS_VALID_COLOR)
  if("${color}" MATCHES "^(normal|black|red|green|yellow|blue|magenta|cyan|white)$")
    set(CMLOGGER_IS_VALID_COLOR true PARENT_SCOPE)
  endif()
endfunction()

function(CMakeLogger_log cmakeMsgType level msg color)
  set(LOG_COLOR        normal)
  set(LOG_COLOR_BOLD   false)
  foreach(c ${color})
    if("${c}" STREQUAL "bold")
      set(LOG_COLOR_BOLD true)
    else()
      CMakeLogger_is_valid_color(${c})
      if(${CMLOGGER_IS_VALID_COLOR})
        set(LOG_COLOR ${c})
      endif()
    endif()
  endforeach()

  CMakeLogger_format(${msg} ${level})

  CMakeLogger_can_print_colors()
  if("${CMLOGGER_OUTPUT_COLORIZED}" STREQUAL "ON" AND "${CMLOGGER_CAN_PRINT_COLORS}" STREQUAL "true")
    CMakeLogger_execute_echo_color("${CMLOGGER_OUTPUT_PREFIX}${msg}" ${LOG_COLOR} ${LOG_COLOR_BOLD} false)

    # For FATAL_ERROR and WARNING modes, cmake will print the call stack and stop the execution, therefore
    # we passing the original message-mode forward (without text) to maintain the defined behavior of cmake.
    if(NOT "${cmakeMsgType}" STREQUAL "STATUS")
      message(${cmakeMsgType})
    endif()
  else()
    message(${cmakeMsgType} "${msg}")
  endif()
endfunction()

function(CMakeLogger_format msg level)
  set(MSG_FORMAT "${msg}")

  # Add project name
  if(CMLOGGER_OUTPUT_PROJECTNAME AND NOT "${PROJECT_NAME}" STREQUAL "")
    set(MSG_FORMAT "[${PROJECT_NAME}]: ${MSG_FORMAT}")
  endif()

  # Add wrappers
  if(NOT "${CMLOGGER_OUTPUT_WRAP}" STREQUAL "")
    set(MSG_FORMAT "${CMLOGGER_OUTPUT_WRAP} ${MSG_FORMAT} ${CMLOGGER_OUTPUT_WRAP}")
  endif()

  # Add debug level
  set(MSG_FORMAT "${level} ${MSG_FORMAT}")

  # Add timestamp
  if(CMLOGGER_OUTPUT_TIMESTAMP)
    string(TIMESTAMP TIME_NOW "${CMLOGGER_OUTPUT_TIMESTAMP_FORMAT}")
    set(MSG_FORMAT "${TIME_NOW} ${MSG_FORMAT}")
  endif()

  # Result
  set(msg "${MSG_FORMAT}" PARENT_SCOPE)
endfunction()

# NOTE(Gilad): CMake does not support ANSI colors on Windows (cmCTest::ColoredOutputSupportedByConsole), but some
# terminals (e.g. ConEmu) worked around this. We therefore do our own determinations for printing with colors.
# cmSystemTools::MakefileColorEcho -> cmsysTerminal_Color_AssumeTTY
# https://cmake.org/pipermail/cmake-developers/2015-October/026730.html
function(CMakeLogger_can_print_colors)
  unset(CMLOGGER_CAN_PRINT_COLORS)

  # To print the current environment
  # execute_process(COMMAND ${CMAKE_COMMAND} -E environment)
  # TODO(Gilad): Find how to get the name of the process that were calling this script. this will improve
  # these checks.
  if(NOT WIN32)
    if(NOT "$ENV{_}" MATCHES "cmake-gui$")
      set(CMLOGGER_CAN_PRINT_COLORS true PARENT_SCOPE)
    endif()
  else()
    # Excluded apps determined by defining the following variables
    if(
      NOT "$ENV{VSAPPIDNAME}"        STREQUAL "devenv.exe"           AND # Visual Studio
      NOT "$ENV{__COMPAT_LAYER}"     STREQUAL "DetectorsAppHealth"   AND # cmake-gui
      NOT "$ENV{TERMINAL_EMULATOR}"  STREQUAL "JetBrains-JediTerm"       # CLion TODO(Gilad): Check on UNIX systems
    )
      # We managed to get through the excluded environment variables, now let's check
      # for any variables that make it possible printing with colors on Windows
      if(
        NOT "$ENV{TERM}"           STREQUAL ""         OR
        NOT "$ENV{ANSICON}"        STREQUAL ""         OR
            "$ENV{CLICOLOR}"       STREQUAL "1"        OR
            "$ENV{CLICOLOR_FORCE}" STREQUAL "1"        OR
            "$ENV{TERM_PROGRAM}"   STREQUAL "vscode"
      )
        set(CMLOGGER_CAN_PRINT_COLORS true PARENT_SCOPE)
      endif()
    endif()
  endif()
endfunction()

function(CMakeLogger_execute_echo_color text color bold sameLine)
  CMakeLogger_is_valid_color(color)
  set(ARG_COLOR_OUTPUT)
  if(${CMLOGGER_IS_VALID_COLOR})
    set(ARG_COLOR_OUTPUT --${color})
    if(${bold})
      set(ARG_COLOR_OUTPUT ${ARG_COLOR_OUTPUT} --bold)
    endif()
  endif()

  set(ARG_SAME_LINE)
  if(${sameLine})
    set(ARG_SAME_LINE --no-newline)
  endif()

#   unset(CLICOLOR_STATE)
#   if(ENV{CLICOLOR_FORCE})
#     set(CLICOLOR_STATE 1)
#   else()
#     set(CLICOLOR_STATE 0)
#   endif()
#   set(ENV{CLICOLOR_FORCE} 1)
  execute_process(COMMAND
      ${CMAKE_COMMAND} -E env CLICOLOR_FORCE=1
      ${CMAKE_COMMAND} -E cmake_echo_color ${ARG_COLOR_OUTPUT} ${ARG_SAME_LINE} "${text}"
  )
  # set(ENV{CLICOLOR_FORCE} ${CLICOLOR_STATE})
endfunction()
