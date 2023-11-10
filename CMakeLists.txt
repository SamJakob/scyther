# Scyther project
CMAKE_MINIMUM_REQUIRED(VERSION 3.20)
project(Scyther)

# Compile with Clang by default
set(CMAKE_C_COMPILER clang)

# Set up directory structure
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)

# Apply the target-specific configuration
include(platform/DetectPlatform.cmake)

# Include project source files
add_subdirectory(src)
