# This file controls Flutter-level build steps. It should not be edited.
cmake_minimum_required(VERSION 3.10)

# Set absolute paths
get_filename_component(ABSOLUTE_PATH "${CMAKE_CURRENT_SOURCE_DIR}" ABSOLUTE)
set(EPHEMERAL_DIR "${ABSOLUTE_PATH}/ephemeral")

# Ensure Flutter root is set
if(NOT DEFINED FLUTTER_ROOT)
  set(FLUTTER_ROOT "/usr/lib/flutter")
endif()

# Ensure ephemeral directory exists
if(NOT EXISTS ${EPHEMERAL_DIR})
  file(MAKE_DIRECTORY ${EPHEMERAL_DIR})
endif()

# Include configuration
if(EXISTS ${EPHEMERAL_DIR}/generated_config.cmake)
  include(${EPHEMERAL_DIR}/generated_config.cmake)
else()
  message(WARNING "Flutter config not found, attempting to generate...")
  execute_process(
    COMMAND flutter build linux
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../
    RESULT_VARIABLE FLUTTER_BUILD
  )
  if(FLUTTER_BUILD EQUAL 0)
    include(${EPHEMERAL_DIR}/generated_config.cmake)
  else()
    message(FATAL_ERROR "Failed to generate Flutter configuration")
  endif()
endif()

# Generate build files
execute_process(
  COMMAND ${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.sh linux-x64 debug
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../
)

# Set Chrome executable path
set(ENV{CHROME_EXECUTABLE} "/usr/bin/google-chrome-stable")

# Add Chrome executable check
if(NOT EXISTS "$ENV{CHROME_EXECUTABLE}")
  message(WARNING "Chrome executable not found at $ENV{CHROME_EXECUTABLE}")
  execute_process(
    COMMAND which google-chrome-stable
    OUTPUT_VARIABLE CHROME_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(CHROME_PATH)
    set(ENV{CHROME_EXECUTABLE} "${CHROME_PATH}")
  endif()
endif()

# Helper function to prepend a prefix to all items in a list.
function(list_prepend LIST_NAME PREFIX)
    set(NEW_LIST "")
    foreach(element ${${LIST_NAME}})
        list(APPEND NEW_LIST "${PREFIX}${element}")
    endforeach(element)
    set(${LIST_NAME} "${NEW_LIST}" PARENT_SCOPE)
endfunction()

# === Flutter Library ===
# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)

set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/libflutter_linux_gtk.so")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${CMAKE_BINARY_DIR}" PARENT_SCOPE)
set(AOT_LIBRARY "${CMAKE_BINARY_DIR}/lib/libapp.so" PARENT_SCOPE)

list(APPEND FLUTTER_LIBRARY_HEADERS
  "fl_basic_message_channel.h"
  "fl_binary_codec.h"
  "fl_binary_messenger.h"
  "fl_dart_project.h"
  "fl_engine.h"
  "fl_json_message_codec.h"
  "fl_json_method_codec.h"
  "fl_message_codec.h"
  "fl_method_call.h"
  "fl_method_channel.h"
  "fl_method_codec.h"
  "fl_method_response.h"
  "fl_plugin_registrar.h"
  "fl_plugin_registry.h"
  "fl_standard_message_codec.h"
  "fl_standard_method_codec.h"
  "fl_string_codec.h"
  "fl_value.h"
  "fl_view.h"
  "flutter_linux.h"
)
list_prepend(FLUTTER_LIBRARY_HEADERS "${EPHEMERAL_DIR}/flutter_linux/")
add_library(flutter SHARED IMPORTED)
set_target_properties(flutter PROPERTIES
  IMPORTED_LOCATION ${FLUTTER_LIBRARY}
  INTERFACE_INCLUDE_DIRECTORIES "${EPHEMERAL_DIR}"
)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")
target_link_libraries(flutter INTERFACE
  PkgConfig::GTK
  PkgConfig::GLIB
  PkgConfig::GIO
)
add_dependencies(flutter flutter_assemble)

# === Flutter tool backend ===
add_custom_command(
  OUTPUT ${FLUTTER_LIBRARY} ${CMAKE_CURRENT_BINARY_DIR}/_phony_
  COMMAND ${CMAKE_COMMAND} -E env
    ${FLUTTER_TOOL_ENVIRONMENT}
    "${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.sh"
      ${FLUTTER_TARGET_PLATFORM} ${CMAKE_BUILD_TYPE}
  DEPENDS ${FLUTTER_LIBRARY_HEADERS}
  VERBATIM
)

add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_LIBRARY}"
  ${FLUTTER_LIBRARY_HEADERS}
  ${FLUTTER_ICU_DATA_FILE}
)
