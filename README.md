# coretrace-tool-template
Standardized template repository for building CoreTrace tools with a unified architecture, CI pipeline, and best practices for scalable static and dynamic analysis tooling.

## Repository documents

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [AUTHORS.md](AUTHORS.md)
- [CHANGELOG.md](CHANGELOG.md)
- [LICENSE](LICENSE)
- [SECURITY.md](SECURITY.md)

## Code style (clang-format)

- Version cible : `clang-format` 20 (version 20.1.8 utilisée dans la CI).
- Formater : `./scripts/format.sh`
- Vérifier sans modifier : `./scripts/format-check.sh`
- CMake : `cmake --build build --target format` ou `--target format-check`
- CI : job GitHub Actions `clang-format` qui échoue si le formatage diverge.
