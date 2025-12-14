
# POSIX Module Environment

## Setup

```bash
brew install sqlite
brew tap nalgeon/sqlpkg https://github.com/nalgeon/sqlpkg-cli
brew install sqlpkg
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

