message(STATUS "Building for Microsoft Windows (win32) with MinGW32")

# Build with mingw32
set(CMAKE_C_COMPILER "i686-w64-mingw32-gcc")
set(CMAKE_CXX_COMPILER "i686-w64-mingw32-g++")
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS)	# to get rid of -rdynamic

# Mark the build as for Windows
set(CMAKE_C_FLAGS "-DFORWINDOWS")

# Build a statically linked executable.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static -m32")

# Set the output executable name
set(SCYTHER_EXECUTABLE_NAME "scyther-w32.exe")
