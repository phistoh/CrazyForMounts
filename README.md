# CrazyForMounts
WoW addon which provides a slash command to summon a random mount out of a predefined table

## Usage
In *CrazyForMounts_Tables.lua*, define a table of tables:
```lua
name = {
  -- flying mounts
  {
    "Default name of a flying mount",
    "Default name of another flying mount",
    ...
  },
  -- ground mounts
  {
    "Default name of a ground mount",
    "Default name of another ground mount",
    ...
  }
}
```
Summon a random mount from this list ingame with the command `/cfm name`.

## File Description
- **CrazyForMounts.lua** contains the main code
- **CrazyForMounts.toc** is the standard table-of-contents file containing addon information
- **CrazyForMounts_Tables.lua** contains tables with mount names (don't overwrite yours if you've already edited it)

## Changes
- **1.2**: Now checks player level in addition to flyable status of an area
- **1.1a**: Now uses a table of (mount name, mount id) pairs to summon mounts
- **1.0**: Initial release

## To-Do
- [ ] Implement the generation of (mount name, mount id) table (using saved vars?)
- [x] Don't use a table of tables, use the "inner" tables directly instead
