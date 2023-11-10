message(STATUS "Building for Linux")

set("SCYTHER_EXECUTABLES:scyther-linux:CMAKE_C_FLAGS" "${CMAKE_C_FLAGS} -static")

# Set the output executable name
set(SCYTHER_EXECUTABLE_NAME "scyther-linux")
