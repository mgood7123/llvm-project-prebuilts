# /c/msys64/msys2_shell.cmd -defterm -here -no-start -msys2 -shell bash -c "rm -rf BUILD_RELEASE_GCC ; ./make_gcc.sh"
# /c/msys64/msys2_shell.cmd -defterm -here -no-start -clang64 -shell bash -c "rm -rf BUILD_RELEASE_CLANG ; ./make_clang.sh"

export TERM=xterm-256color
M="Unix Makefiles"
N="Ninja"
d=BUILD_RELEASE_GCC
c1=gcc
c2=g++
cmake -G "$M" -DCMAKE_BUILD_TYPE=Debug $1 -DCMAKE_VERBOSE_MAKEFILE=OFF -DCMAKE_INSTALL_PREFIX="$(pwd)/$d/BUILD_ROOT/ROOTFS" -DLLVM_BUILD_ROOT__ROOTFS="$(pwd)/$d/BUILD_ROOT/ROOTFS" -DCMAKE_C_COMPILER=$c1 -DCMAKE_CXX_COMPILER=$c2 -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_COLOR_MAKEFILE=ON -S . -B $d &&
cmake --build $d &&
cmake --install $d
