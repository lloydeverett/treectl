#!/bin/bash

# homebrew sqlite3 (in case system sqlite3 needs to stay on the $PATH)
hsqlite3() {
    /opt/homebrew/opt/sqlite/bin/sqlite3 "$@"
}

# sqlite3 with extra goodies
xsqlite3() {
    /opt/homebrew/opt/sqlite/bin/sqlite3 \
        -cmd ".load $(sqlpkg which nalgeon/sqlean)" \
        -cmd ".load $(sqlpkg which asg017/lines)" \
        -cmd ".load $(sqlpkg which jhowie/envfuncs)" \
        "$@"
}

# wrapper that allows piping input data by consuming SQL from arguments
psqlite3() {
    3<&0 INPUT="/dev/fd/3" xsqlite3 <<< "$@"
}

