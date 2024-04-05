# llvm-project-prebuilts

# compiler preprocessor defines

```sh
# list all macro's predefined by gcc
gcc -dM -E - < /dev/null | sort

# list all macro's predefined by g++
g++ -dM -E - < /dev/null | sort

# list all macro's predefined by clang
clang -dM -E - < /dev/null | sort

# list all macro's predefined by clang++
clang++ -dM -E - < /dev/null | sort
```
