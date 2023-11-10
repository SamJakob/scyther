################################################################
# Name:		ScannerParser.cmake
# Purpose:	If flex/bison are available, generate parser and scanner
# Author:	Cas Cremers
################################################################

find_package(FLEX)
find_package(BISON)

if(FLEX_FOUND)
    message(STATUS "Flex found.")
    flex_target(SCANNER scanner.l scanner.c)
else()
    message(FATAL_ERROR "Flex wasn't found. The existing scanner.c will be used.")
endif()

if(BISON_FOUND)
    message(STATUS "Bison found.")
    bison_target(PARSER parser.y parser.c)
else()
    message(FATAL_ERROR "Bison wasn't found. The existing parser.c will be used.")
endif()
