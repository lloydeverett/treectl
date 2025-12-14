#!/bin/bash

source ../aliases.sh

INPUT=<(cat foo.json) xsqlite3 << EOF
    select line from lines_read(getenv('INPUT'))
EOF

