message(STATUS "Building for Web")

set(CMAKE_C_COMPILER "emcc")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O1")
set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -O1 -sEXPORTED_FUNCTIONS=_main -sEXPORT_ES6=1 -sWASM=1 -sMODULARIZE")

# Set the output executable name
set(SCYTHER_EXECUTABLE_NAME "scyther-web.js")
