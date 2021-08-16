cmake_minimum_required(VERSION 3.4.1)

# Compiler options
add_compile_options(-Wall)

# Submodule library
add_library(sqlite3
            STATIC

            # Source
            sqlite3.c)

# Linking
target_link_libraries(sqlite3)
