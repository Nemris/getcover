# getcover

`getcover` is a Bash script that fetches the boxart of Nintendo DS games.

The boxarts are compatible with [TWiLightMenu++](https://github.com/RocketRobz/TWiLightMenu), and are courtesy of [GameTDB](https://gametdb.com).

-----

## Requirements

To run, `getcover` requires `awk`, `wget`, `xxd`, `sed` and `crc32`.

-----

## Usage

Running `getcover` without arguments will result in a brief usage message:

    Usage: getcover titleID | rom.nds [titleID | rom.nds ...]

A titleID is a DS game's four-letter identifier.
For example, `AXFP` is the titleID of _Final Fantasy XII: Revenant Wings (EUR)_.

You can supply titleIDs and actual `.nds` files. `getcover` is case insensitive.
If an `.nds` file is specified, the titleID will be obtained automatically.

**Boxarts will be placed inside the current directory.**

-----

## Contributing

Before contributing: 

* analyze your code with `shellcheck` and address the possible warnings;
* make sure all indentations are 4-spaces wide.

-----

## License

This project is licensed under the terms of the BSD-3-Clause license.
See the [LICENSE](LICENSE) file for details.
