export TERM=xterm-256color
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=build/root_fs -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_COLOR_MAKEFILE=ON -S . -B build &&
cmake --build build &&
cmake --install build # && ./build/root_fs/bin/zip_split.exe "$(pwd)"
