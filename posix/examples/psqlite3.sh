#!/bin/bash

source ../aliases.sh

cat foo.json | psqlite3 "select line from lines_read(getenv('INPUT'))"

