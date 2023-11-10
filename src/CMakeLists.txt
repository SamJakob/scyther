# Run the describe-version.py script to generate the version.h file
add_custom_command(
	OUTPUT version.h
	COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/describe-version.py
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/describe-version.py
)

# If we are in a debug mode we want to be strict
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall -DDEBUG")

# c11 standard has different inline semantics, yields warning.
# Since c11 is the default for gcc 5, we explicitly include the switch.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu89")

# Make scanner and parser
include(ScannerParser.cmake)

# List all the source files
set(SCYTHER_SOURCES
	arachne.c binding.c claim.c color.c compiler.c cost.c
	debug.c depend.c dotout.c error.c heuristic.c hidelevel.c
	intruderknowledge.c knowledge.c label.c list.c main.c mgu.c
	prune_bounds.c prune_theorems.c role.c
	specialterm.c states.c switches.c symbol.c system.c tac.c
	tempfile.c
	termlist.c termmap.c term.c timer.c type.c warshall.c xmlout.c
	${BISON_PARSER_OUTPUTS} ${FLEX_SCANNER_OUTPUTS}
  )

# Build the executable
add_executable(${SCYTHER_EXECUTABLE_NAME}
		${SCYTHER_SOURCES}
		version.h)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
