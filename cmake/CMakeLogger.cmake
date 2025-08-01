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

set(CMLOGGER_VERSION "v1.0.1")

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
  CACHE BOOL
  "CMakeLogger: Colorized output"
)

set(CMLOGGER_OUTPUT_TIMESTAMP ON
  CACHE BOOL
  "CMakeLogger: Include timestamp in the log output. e.g. '>> 15:05:14.123456 INFO    My Log'"
)

set(CMLOGGER_OUTPUT_TIMESTAMP_FORMAT "%H:%M:%S.%f"
  CACHE STRING
  "CMakeLogger: Timestamp format"
)

set(CMLOGGER_OUTPUT_WRAP ""
  CACHE STRING
  "CMakeLogger: String to surround your log. e.g. '>> INFO    ##### My Log #####'"
)

set(CMLOGGER_OUTPUT_PREFIX ">>"
  CACHE STRING
  "CMakeLogger: Log out prefix. e.g. '>> INFO    My Log'"
)

set(CMLOGGER_OUTPUT_PROJECTNAME ON
  CACHE BOOL
  "CMakeLogger: Include current project name in the log output if exists. e.g. '>> INFO    [MyProjectName]: My Log'"
)

set(CMLOGGER_VERBOSE ON
  CACHE BOOL
  "CMakeLogger: Turn this off if not desired to see CMakeLogger internal messages."
)

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

# High-precision timing using CMake's built-in capabilities
set(_CMLOGGER_TIME_STARTED_MS 0 CACHE INTERNAL "")
set(_CMLOGGER_TIMER_STARTED_MS 0 CACHE INTERNAL "")

# Get current timestamp in milliseconds
function(_cmlogger_get_timestamp_ms out_string)
  # Get current timestamp in seconds with microseconds
  string(TIMESTAMP timestamp_us "%s%f")

  # Convert microseconds to milliseconds by truncating the last 3 digits.
  # This is equivalent to dividing by 1000, but done using string manipulation
  # because:
  #   - CMake only supports integer math (no floating point division)
  #   - The timestamp is a large string that may exceed integer limits
  #   - String truncation is safer and more portable across platforms
  string(LENGTH "${timestamp_us}" len)
  math(EXPR ms_len "${len} - 3")
  string(SUBSTRING "${timestamp_us}" 0 ${ms_len} timestamp_ms)

  set(${out_string} ${timestamp_ms} PARENT_SCOPE)
endfunction()

function(log_format_duration_ms out_string duration_ms)
  math(EXPR total_seconds "${duration_ms} / 1000")
  math(EXPR milliseconds "${duration_ms} % 1000")
  math(EXPR minutes "${total_seconds} / 60")
  math(EXPR seconds "${total_seconds} % 60")

  if(minutes GREATER 0)
    # Format: "Xm Ys" or "Xm Ys.ZZZs" depending on milliseconds
    if(milliseconds GREATER 0)
      # Format milliseconds with leading zeros if needed
      if(milliseconds LESS 10)
        set(ms_padded "00${milliseconds}")
      elseif(milliseconds LESS 100)
        set(ms_padded "0${milliseconds}")
      else()
        set(ms_padded "${milliseconds}")
      endif()
      set(${out_string} "${minutes}m ${seconds}.${ms_padded}s" PARENT_SCOPE)
    else()
      set(${out_string} "${minutes}m ${seconds}s" PARENT_SCOPE)
    endif()
  elseif(total_seconds GREATER 0)
    # Format: "X.ZZZs" for seconds with milliseconds
    if(milliseconds GREATER 0)
      # Format milliseconds with leading zeros if needed
      if(milliseconds LESS 10)
        set(ms_padded "00${milliseconds}")
      elseif(milliseconds LESS 100)
        set(ms_padded "0${milliseconds}")
      else()
        set(ms_padded "${milliseconds}")
      endif()
      set(${out_string} "${seconds}.${ms_padded}s" PARENT_SCOPE)
    else()
      set(${out_string} "${seconds}s" PARENT_SCOPE)
    endif()
  else()
    # Format: "ZZZms" for pure milliseconds
    set(${out_string} "${milliseconds}ms" PARENT_SCOPE)
  endif()
endfunction()

# Reset the timer to current time
function(log_reset_timer)
  _cmlogger_get_timestamp_ms(current_time_ms)
  set(_CMLOGGER_TIMER_STARTED_MS ${current_time_ms} CACHE INTERNAL "")

  # Initialize start time on first call
  if(_CMLOGGER_TIME_STARTED_MS EQUAL 0)
    set(_CMLOGGER_TIME_STARTED_MS ${current_time_ms} CACHE INTERNAL "")
  endif()
endfunction()

# Get elapsed time since log_reset_timer() in milliseconds
function(log_time_taken out_int)
  _cmlogger_get_timestamp_ms(current_time_ms)
  math(EXPR duration_ms "${current_time_ms} - ${_CMLOGGER_TIMER_STARTED_MS}")
  set(${out_int} ${duration_ms} PARENT_SCOPE)
endfunction()

# Get elapsed time since CMakeLogger initialization in milliseconds
function(log_initial_time_taken out_int)
  _cmlogger_get_timestamp_ms(current_time_ms)
  math(EXPR duration_ms "${current_time_ms} - ${_CMLOGGER_TIME_STARTED_MS}")
  set(${out_int} ${duration_ms} PARENT_SCOPE)
endfunction()

# Print the time taken since log_reset_timer()
function(log_print_time_taken)
  log_time_taken(duration_ms)
  log_format_duration_ms(formatted_duration ${duration_ms})
  log_info("Time taken: ${formatted_duration}")
endfunction()

# Print the initial time taken since CMakeLogger started
function(log_print_initial_time_taken)
  log_initial_time_taken(duration_ms)
  log_format_duration_ms(formatted_duration ${duration_ms})
  log_info("Total time since start: ${formatted_duration}")
endfunction()

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

  if(_CMLOGGER_COLORIZED_OUTPUT)
    CMakeLogger_execute_echo_color("${CMLOGGER_OUTPUT_PREFIX} ${msg}" ${LOG_COLOR} ${LOG_COLOR_BOLD} false)

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
    set(MSG_FORMAT "[${PROJECT_NAME}] ${MSG_FORMAT}")
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

function(_cmlogger_message msg)
  if(CMLOGGER_VERBOSE)
    message(STATUS "[CMakeLogger] ${msg}")
  endif()
endfunction()

function(_cmlogger_get_process_tree out_list)
  set(process_tree)
  if(WIN32)
    set(process_tree_ps [=[
    $names = @()
    $cur_pid = $PID
    while ($cur_pid) {
      $p = Get-CimInstance Win32_Process -Filter "ProcessId=$cur_pid" -ea 0
      if ($p.Name) { $names = @($p.Name) + $names }
      $cur_pid = $p.ParentProcessId
    }
    $names -join ';'
    ]=])

    execute_process(
      COMMAND powershell -NoProfile -Command "${process_tree_ps}"
      OUTPUT_VARIABLE process_tree
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  else()
    set(process_tree_sh [=[
      pid=$$
      names=()

      while [ "$pid" -ne 0 ]; do
        name=$(ps -p "$pid" -o comm=)
        # Extract basename manually to handle edge cases like -zsh and paths with spaces
        basename_name=$(basename "$name" 2>/dev/null || echo "$name")
        names=("$basename_name" "${names[@]}")
        pid=$(ps -p "$pid" -o ppid= | tr -d ' ')
      done

      (IFS=\; ; echo "${names[*]}")
    ]=])

    execute_process(
      COMMAND bash -c "${process_tree_sh}"
      OUTPUT_VARIABLE process_tree
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  endif()

  set(${out_list} "${process_tree}" PARENT_SCOPE)
endfunction()

function(_cmlogger_has_ansi_incompatible_known_tools_win32 out_bool process_tree)
  if("cmake-gui.exe" IN_LIST process_tree)
    _cmlogger_message("Detected cmake-gui, disabling colors")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  # Check for Visual Studio GUI -> MSBuild chain (VS Output window doesn't support ANSI)
  # VS integrated terminal creates a different chain: devenv.exe -> ServiceHub -> powershell.exe -> cmake.exe
  if("${process_tree}" MATCHES "devenv.exe;msbuild.exe")
    _cmlogger_message("Detected Visual Studio GUI -> MSBuild, disabling colors")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  set(${out_bool} FALSE PARENT_SCOPE)
endfunction()

function(_cmlogger_has_ansi_incompatible_known_tools_unix out_bool process_tree)
  if("cmake-gui" IN_LIST process_tree)
    _cmlogger_message("Detected cmake-gui, disabling colors")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  if(APPLE)
    # macOS cmake-gui detection complexity: Unlike Linux/Windows where cmake-gui is standalone,
    # on macOS it's a symbolic link to the actual CMake executable, requiring multi-scenario detection.
    #
    # Detection scenarios:
    # 1. Terminal launch (`cmake-gui .`): Caught by previous unix check - process name is "cmake-gui"
    # 2. Finder app bundle launch (CMake.app): Detectable via XPC_SERVICE_NAME="application.org.cmake*"
    # 3. Finder direct binary launch (CMake.app/Contents/bin/cmake-gui): Problematic case - spawns terminal
    #    that launches cmake in GUI mode, but XPC_SERVICE_NAME is unset and process tree shows "cmake"
    #    instead of "cmake-gui". This is uncommon but creates a detection gap.
    #
    # TODO: Request Kitware add CMAKE_GUI environment variable (like JetBrains' CLION_IDE)
    # to eliminate ambiguity between cmake CLI and cmake-gui on macOS.
    if("cmake" IN_LIST process_tree AND "$ENV{XPC_SERVICE_NAME}" MATCHES "^application\\.org\\.cmake")
      _cmlogger_message("Detected cmake-gui app bundle, disabling colors")
      set(${out_bool} TRUE PARENT_SCOPE)
      return()
    endif()

    # Xcode detection: Child processes inherit environment variables, causing false color detection.
    # Terminal-launched Xcode (e.g. `open project.xcodeproj`) inherits COLORTERM but Xcode's
    # output window doesn't support ANSI colors.
    # Detect system-launched Xcode via launchd->Xcode process chain to disable colors correctly.
    if("${process_tree}" MATCHES "launchd;xcode")
      _cmlogger_message("Detected Xcode, disabling colors")
      set(${out_bool} TRUE PARENT_SCOPE)
      return()
    endif()
  endif()

  set(${out_bool} FALSE PARENT_SCOPE)
endfunction()

function(_cmlogger_is_terminal_ansi_colors_supported_win32 out_bool)
  if(DEFINED ENV{WT_SESSION})
    _cmlogger_message("Detected Windows Terminal")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  if(DEFINED ENV{ConEmuBuild})
    _cmlogger_message("Detected ConEmu terminal")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  if(DEFINED ENV{ANSICON})
    _cmlogger_message("Detected ANSICON support")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  # Windows 10+ native ANSI support
  # https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/about/about_ansi_terminals
  execute_process(
    COMMAND cmd /c "ver"
    OUTPUT_VARIABLE windows_version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  if(windows_version MATCHES "Version ([0-9]+)\\.")
    set(windows_version_major ${CMAKE_MATCH_1})
    if(windows_version_major GREATER_EQUAL 10)
      _cmlogger_message("Detected Windows ${windows_version_major}+ with native ANSI support")
      set(${out_bool} TRUE PARENT_SCOPE)
      return()
    endif()
  else()
    _cmlogger_message("Could not determine Windows version (${windows_version})")
  endif()

  set(${out_bool} FALSE PARENT_SCOPE)
endfunction()

function(_cmlogger_is_terminal_ansi_colors_supported_unix out_bool)
  # Check if output is a TTY
  execute_process(
    COMMAND tty
    RESULT_VARIABLE is_tty_result
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if(NOT is_tty_result EQUAL 0)
    _cmlogger_message("Output not a TTY")
    set(${out_bool} FALSE PARENT_SCOPE)
    return()
  endif()

  # Check against known VT100-compatible terminals (based on CMake's kVT100Names)
  if(DEFINED ENV{TERM})
    set(vt100_terminals
      "Eterm"
      "alacritty"
      "alacritty-direct"
      "ansi"
      "color-xterm"
      "con132x25"
      "con132x30"
      "con132x43"
      "con132x60"
      "con80x25"
      "con80x28"
      "con80x30"
      "con80x43"
      "con80x50"
      "con80x60"
      "cons25"
      "console"
      "cygwin"
      "dtterm"
      "eterm-color"
      "gnome"
      "gnome-256color"
      "konsole"
      "konsole-256color"
      "kterm"
      "linux"
      "linux-c"
      "mach-color"
      "mlterm"
      "msys"
      "putty"
      "putty-256color"
      "rxvt"
      "rxvt-256color"
      "rxvt-cygwin"
      "rxvt-cygwin-native"
      "rxvt-unicode"
      "rxvt-unicode-256color"
      "screen"
      "screen-256color"
      "screen-256color-bce"
      "screen-bce"
      "screen-w"
      "screen.linux"
      "st-256color"
      "tmux"
      "tmux-256color"
      "vt100"
      "xterm"
      "xterm-16color"
      "xterm-256color"
      "xterm-88color"
      "xterm-color"
      "xterm-debian"
      "xterm-kitty"
      "xterm-termite"
    )

    if("$ENV{TERM}" IN_LIST vt100_terminals)
      _cmlogger_message("Detected VT100-compatible terminal: $ENV{TERM}")
      set(${out_bool} TRUE PARENT_SCOPE)
      return()
    else()
      _cmlogger_message("Unknown terminal type: $ENV{TERM}")
    endif()
  endif()

  set(${out_bool} FALSE PARENT_SCOPE)
endfunction()

# Color detection with priority order:
# 1. Override environment variables (NO_COLOR, FORCE_COLOR, CLICOLOR_FORCE)
# 2. Process tree checks for incompatible tools
# 3. Standard environment variables (CLICOLOR, COLORTERM, MAKE_TERMOUT, etc.)
# 4. Terminal capability detection
function(_cmlogger_should_colorize_output out_bool)
  if(NOT CMLOGGER_OUTPUT_COLORIZED)
    _cmlogger_message("Colorized output disabled by configuration")
    set(${out_bool} FALSE PARENT_SCOPE)
    return()
  endif()

  # Override: NO_COLOR disables colors (https://no-color.org/)
  if(DEFINED ENV{NO_COLOR})
    _cmlogger_message("Colors disabled by NO_COLOR")
    set(${out_bool} FALSE PARENT_SCOPE)
    return()
  endif()

  # Override: FORCE_COLOR enables colors (https://force-color.org/)
  if(DEFINED ENV{FORCE_COLOR})
    _cmlogger_message("Colors forced by FORCE_COLOR")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  # Override: CLICOLOR_FORCE enables colors (https://bixense.com/clicolors/)
  if(DEFINED ENV{CLICOLOR_FORCE})
    _cmlogger_message("Colors forced by CLICOLOR_FORCE")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  # Check process tree for incompatible tools
  # Environment variables can be inherited by child processes (e.g., cmake-gui launched from VS Code
  # inherits COLORTERM), so we check the actual execution context first
  _cmlogger_get_process_tree(process_tree)
  string(TOLOWER "${process_tree}" process_tree)
  set(has_ansi_incompatible_tool FALSE)
  if(WIN32)
    _cmlogger_has_ansi_incompatible_known_tools_win32(has_ansi_incompatible_tool "${process_tree}")
  else()
    _cmlogger_has_ansi_incompatible_known_tools_unix(has_ansi_incompatible_tool "${process_tree}")
  endif()
  if(has_ansi_incompatible_tool)
    set(${out_bool} FALSE PARENT_SCOPE)
    return()
  endif()

  # Standard: CLICOLOR=0 disables colors
  if(DEFINED ENV{CLICOLOR} AND "$ENV{CLICOLOR}" STREQUAL "0")
    _cmlogger_message("Colors disabled by CLICOLOR")
    set(${out_bool} FALSE PARENT_SCOPE)
    return()
  endif()

  # Standard: COLORTERM indicates color support
  if(DEFINED ENV{COLORTERM})
    _cmlogger_message("Colors enabled by COLORTERM")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  # Standard: MAKE_TERMOUT indicates GNU make 4.1+ color support
  if(DEFINED ENV{MAKE_TERMOUT} AND NOT "$ENV{MAKE_TERMOUT}" STREQUAL "")
    _cmlogger_message("Colors enabled by MAKE_TERMOUT")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  # Standard: TERM=dumb indicates no color support (https://man7.org/linux/man-pages/man7/term.7.html)
  if(DEFINED ENV{TERM} AND "$ENV{TERM}" STREQUAL "dumb")
    _cmlogger_message("Colors disabled by TERM=dumb")
    set(${out_bool} FALSE PARENT_SCOPE)
    return()
  endif()

  # VS Code integrated terminal detection
  if(DEFINED ENV{TERM_PROGRAM} AND "$ENV{TERM_PROGRAM}" STREQUAL "vscode")
    if(DEFINED ENV{VSCODE_INJECTION})
      _cmlogger_message("Detected VS Code integrated terminal")
      set(${out_bool} TRUE PARENT_SCOPE)
      return()
    endif()
  endif()

  # JetBrains IDE cmake output window is not a TTY, but it supports colors
  if(DEFINED ENV{JETBRAINS_IDE} OR DEFINED ENV{CLION_IDE})
    _cmlogger_message("Detected JetBrains IDE")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  # QtCreator normally enables CLICOLOR_FORCE, but this is just a fallback
  if(DEFINED ENV{QTC_RUN})
    _cmlogger_message("Detected QtCreator")
    set(${out_bool} TRUE PARENT_SCOPE)
    return()
  endif()

  # Terminal capability detection
  set(is_terminal_ansi_colors_supported TRUE)
  if(WIN32)
    _cmlogger_is_terminal_ansi_colors_supported_win32(is_terminal_ansi_colors_supported)
  else()
    _cmlogger_is_terminal_ansi_colors_supported_unix(is_terminal_ansi_colors_supported)
  endif()
  if(NOT is_terminal_ansi_colors_supported)
    set(${out_bool} FALSE PARENT_SCOPE)
    return()
  endif()

  set(${out_bool} TRUE PARENT_SCOPE)
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

function(_cmlogger_main)
  # Call to update timestamps when this file is included.
  log_reset_timer()

  _cmlogger_should_colorize_output(colorized_output)
  if(colorized_output)
    if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.24")
      set(CMAKE_COLOR_DIAGNOSTICS ON CACHE BOOL "Enable colored diagnostics throughout." FORCE)
    endif()
  endif()
  _cmlogger_message("Colorized output: ${colorized_output}")
  set(_CMLOGGER_COLORIZED_OUTPUT ${colorized_output} PARENT_SCOPE)
endfunction()

_cmlogger_main()
