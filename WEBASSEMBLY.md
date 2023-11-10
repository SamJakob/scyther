# Building Scyther with Emscripten

1. Install Emscripten (https://emscripten.org/docs/getting_started/downloads.html)
    - On macOS, this can be done with Homebrew: `brew install emscripten`
2. Configure CMake with a web build by specifying the following options:
   `-DTARGET_PLATFORM=Web -DCMAKE_SYSTEM_NAME=Generic`
