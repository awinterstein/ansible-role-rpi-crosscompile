SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)

# specify the cross compiler
SET(CMAKE_C_COMPILER   "{{toolchains_dir}}/{{toolchain_prefix}}/bin/{{toolchain_prefix}}-gcc")
SET(CMAKE_CXX_COMPILER "{{toolchains_dir}}/{{toolchain_prefix}}/bin/{{toolchain_prefix}}-g++")

# where is the target environment
SET(CMAKE_FIND_ROOT_PATH  "{{toolchains_dir}}/{{toolchain_prefix}}/{{toolchain_prefix}}/sysroot/")

# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# help the boost find script to locate the headers
SET(BOOST_INCLUDEDIR ${CMAKE_FIND_ROOT_PATH}/usr/include)
SET(BOOST_LIBRARYDIR ${CMAKE_FIND_ROOT_PATH}/usr/lib/arm-linux-gnueabihf)
