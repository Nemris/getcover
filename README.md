# getcover

`getcover` is a Bash script that fetches the boxart of Nintendo DS games.

The boxarts are compatible with [TWiLightMenu++], and are courtesy of [GameTDB].

-----

## Requirements

To run, `getcover` requires `wget`.

-----

## Usage

Running `getcover` without arguments will display a brief usage message:

    Usage: getcover titleid | ndsfile [titleid | ndsfile ...]

A title ID is a DS game's four-letter identifier, and `getcover` will ignore
its case. Thus, `axfp`, `AXFP` and `aXfP` will be evaluated the same.

On the other hand, DS ROMs must end with the `.nds` extension. If you supply
a ROM, `getcover` will try to parse it to obtain its game ID automatically.

To download multiple covers, you can provide as many title IDs and/or ROMs in a
go as you wish, and mixing the two is allowed.

**Boxarts will be placed inside the current directory.**

-----

## Contributing

Before contributing: 

* analyze your code with `shellcheck` and address the possible warnings;
* make sure all indentations are 4-spaces wide.

AI-generated code will be rejected.

-----

## License

This project is licensed under the terms of the MIT license.
See the [LICENSE] file for details.

[TWiLightMenu++]:https://github.com/RocketRobz/TWiLightMenu
[GameTDB]:https://gametdb.com
[LICENSE]:./LICENSE
