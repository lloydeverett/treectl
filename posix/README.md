
# POSIX Module Environment

## Setup

```bash
# needed on macOS; system sqlite install lacks functionality
# on linux, you should be able to use the distribution package, e.g.
#   sudo apt install sqlite3 sqlite3-tools libsqlite3-0
brew install sqlite

# install sqlpkg for managing sqlite modules
# webinstall.dev can also be used in favour of brew:
#   curl -sS https://webi.sh/sqlpkg | sh; \
#   source ~/.config/envman/PATH.env
brew tap nalgeon/sqlpkg https://github.com/nalgeon/sqlpkg-cli
brew install sqlpkg

# install packages via sqlpkg
# NOTE: builds are not available for all distributions;
#       we may want to look at compiling from source or supplying
#       precompiled binaries for more platforms
sqlpkg install asg017/lines
sqlpkg install nalgeon/sqlean
sqlpkg install jhowie/envfuncs
```

## Example

```bash
source aliases.sh
xsqlite3 <<< "
select math_sqrt(9); -- sqlean math
"
```

Additional examples are given in the `examples/` directory.

You may want to source `aliases.sh` in your shell startup script to keep these helper functions at hand.

