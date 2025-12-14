#!/bin/bash

source ../aliases.sh

cat foo.jsonl | psqlite3 "select line -> '$.a' from lines_read(getenv('INPUT'))"

