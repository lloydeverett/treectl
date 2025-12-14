#!/bin/bash

# look for user sqlite3; system sqlite3 may need to stay on the $PATH
ALIASES_SQLITE_BIN="/opt/homebrew/opt/sqlite/bin/sqlite3"
if ! command -v "$ALIASES_SQLITE_BIN" >/dev/null 2>&1
then
    # homebrew sqlite3 not found; use the binary on the $PATH
    ALIASES_SQLITE_BIN="sqlite3"
fi
hsqlite3() {
    $ALIASES_SQLITE_BIN "$@"
}

# sqlite3 with extra goodies
xsqlite3() {
    $ALIASES_SQLITE_BIN \
        -cmd ".load $(sqlpkg which nalgeon/sqlean)" \
        -cmd ".load $(sqlpkg which asg017/lines)" \
        -cmd ".load $(sqlpkg which jhowie/envfuncs)" \:
        "$@"
}

# wrapper that allows piping input data by consuming SQL from arguments
psqlite3() {
    3<&0 INPUT="/dev/fd/3" xsqlite3 <<< "$@"
}

