# CrazyForMounts
WoW addon which provides a slash command to summon a random mount out of a predefined table

## Usage
Select both ground and flying mounts from the mount journal which from which one will randomly be chosen depending on the circumstances (i. e. is the player in a flyable area). Summon a random mount from this list ingame with the command `/cfm`.

## File Description
- **CrazyForMounts.lua** contains the main code
- **CrazyForMounts.toc** is the standard table-of-contents file containing addon information

## Changes
- **2.0b**: Table of mounts is now generated ingame (checkboxes in the mount journal) and saved per character (using WoW's saved variables)
- **1.2**: Now checks player level in addition to flyable status of an area
- **1.1a**: Now uses a table of (mount name, mount id) pairs to summon mounts
- **1.0**: Initial release

## To-Do
- [x] Implement the generation of (mount name, mount id) table (using saved vars?)
- [x] Don't use a table of tables, use the "inner" tables directly instead
