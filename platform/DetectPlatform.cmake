# Determine the intended target OS using the target system from CMake.
if (NOT DEFINED TARGET_PLATFORM)
    if(CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(TARGET_PLATFORM "linux")
    elseif(CMAKE_SYSTEM_NAME MATCHES "Windows"
            OR CMAKE_SYSTEM_NAME MATCHES "CYGWIN"
            OR CMAKE_SYSTEM_NAME MATCHES "MSYS"
            OR CMAKE_SYSTEM_NAME MATCHES "MINGW")
        set(TARGET_PLATFORM "windows")
    elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        set(TARGET_PLATFORM "darwin")
    else()
        message(FATAL_ERROR "Unrecognized or unsupported target OS: ${CMAKE_SYSTEM_NAME}")
    endif()
endif()

# Include the target OS-specific build configuration.
include("platform/target/${TARGET_PLATFORM}.cmake")
