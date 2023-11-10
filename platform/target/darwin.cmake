message(STATUS "Building for Darwin x86_64 and arm64 (macOS Universal binary)")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mmacosx-version-min=10.6 -arch x86_64 -arch arm64")

# Set the output executable name
set(SCYTHER_EXECUTABLE_NAME "scyther-mac")
