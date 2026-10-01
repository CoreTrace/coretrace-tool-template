# Contributing to CoreTrace Tool Template

## Local setup

This template builds a C++20 tool with LLVM and fetches `coretrace-compiler` unless that target is already provided. CMake requires 3.16 or newer; the template's default LLVM floor is 19. LLVM 20 matches the CoreTrace analyzers. Use matching LLVM and Clang CMake packages and a Clang executable of the same major version:

```bash
cmake -S . -B build \
  -DLLVM_DIR=/path/to/llvm/lib/cmake/llvm \
  -DClang_DIR=/path/to/llvm/lib/cmake/clang \
  -DCLANG_EXECUTABLE=/path/to/llvm/bin/clang
cmake --build build
./scripts/format-check.sh
```

The template currently has no CTest suite. When adding behavior, validate a generated tool or a consumer build and include the commands in your pull request. Keep the `USER CONFIG` block in `CMakeLists.txt` usable by downstream tools, and avoid machine-specific paths. Use an English Conventional Commit subject.

For vulnerabilities in this template, follow [SECURITY.md](SECURITY.md).
