# CrazyForMounts
WoW addon which provides a slash command to summon a random mount out of a predefined table

## Usage
Select both ground and flying mounts via checkbox in the mount journal from which one will randomly be chosen depending on the circumstances (i. e. is the player in a flyable area). Summon a random mount from this list ingame with the command `/crazyformounts` or `/cfm` or use the provided option to assign a keybind.

## File Description
- **CrazyForMounts.lua** contains the main code
- **CrazyForMounts.toc** is the standard table-of-contents file containing addon information
- **Bindings.xml** is needed to provide keybinds
- **horse.tga** and **bird.tga** are used as backgrounds for the checkboxes

## Changes
- **2.1.2**: Update for Chains of Domination (9.1.0) (new interface number)
- **2.1.1**: Update for Shadowlands (9.0.5) (new interface number)
- **2.1**: Mounts in mount journal scroll list now show icons if they're marked as personal favorites
- **2.0b**: Table of mounts is now generated ingame (checkboxes in the mount journal) and saved per character (using WoW's saved variables)
- **1.2**: Now checks player level in addition to flyable status of an area
- **1.1a**: Now uses a table of (mount name, mount id) pairs to summon mounts
- **1.0**: Initial release

## To-Do
- [ ] Filtering/searching of personal favorites
- [x] Mark selected mounts in the scroll list
- [x] Implement the generation of (mount name, mount id) table (using saved vars?)
- [x] Don't use a table of tables, use the "inner" tables directly instead