#!/usr/bin/env bash

CLANG_FORMAT_VERSION="${CLANG_FORMAT_VERSION:-20}"
CLANG_FORMAT="${CLANG_FORMAT:-clang-format-${CLANG_FORMAT_VERSION}}"

resolve_clang_format() {
    if [[ ! "${CLANG_FORMAT_VERSION}" =~ ^[0-9]+$ ]]; then
        echo "error: CLANG_FORMAT_VERSION must be a numeric major version." >&2
        return 1
    fi

    local candidate=""
    if command -v "${CLANG_FORMAT}" >/dev/null 2>&1; then
        candidate="${CLANG_FORMAT}"
    elif [ "${CLANG_FORMAT}" = "clang-format-${CLANG_FORMAT_VERSION}" ] && command -v clang-format >/dev/null 2>&1; then
        candidate="clang-format"
    else
        echo "error: clang-format ${CLANG_FORMAT_VERSION}.x was not found." >&2
        echo "Set CLANG_FORMAT to the clang-format binary to use." >&2
        return 1
    fi

    local version_output
    version_output="$("${candidate}" --version)"
    if [[ ! "${version_output}" =~ (^|[[:space:]])version[[:space:]]+${CLANG_FORMAT_VERSION}\. ]]; then
        echo "error: expected clang-format ${CLANG_FORMAT_VERSION}.x, got: ${version_output}" >&2
        echo "Set CLANG_FORMAT_VERSION to override the required major version." >&2
        return 1
    fi

    printf '%s\n' "${candidate}"
}
