## v2.3.5
- Update for The War Within (11.0.0) (new interface number)
- Differentiates between Skyriding and steady flying mounts depending on the chosen flight style
- Since (most) flying mounts can be used for Skyriding, the addon includes a checkbox to combine both tables---Skyriding and steady flying mounts---when a mount of a non-specified type is summoned
- Removed Dragonriding toggle (and keybind) since it is now controlled via WoW's own flight style toggle

## v2.2.5
- Fixed Dragonriding toggle priority (in the Dragon Isles---when having the pathfinder achievement)
- Allowed dragonriding in The Nokhud Offensive

## v2.2.4
- Removed the level check in `phis.IsFlyableArea()` (since *World of Warcraft Remix: Mists of Pandaria* allows flying on a lower level)
- Removed thwe beta version indicator from the addon version (though I have not yet tested, if dragonriding inside Amirdrassil works)

## v2.2.3-beta
- Update for Dark Heart (10.2.7) (new interface number)

## v2.2.2-beta
- Fixed an error when using the Dragonriding toggle keybind before opening the mount journal
- Implemented a check whether the player has the 'Empowered Feather' or 'Blessing of the Emerald Dream' buff and let them dragonride even inside an instance (i.e. Amirdrassil raid); not really tested since I don't have a suitable character

## v2.2.1-beta
- Implemented a keybinding to toggle Dragonriding in non-Dragonflight zones
- WoW's `IsFlyableArea()` method seems to respect the *Dragonflight Pathfinder* achievement; so there is (probably) no special edge case handling required

## v2.2-beta
- Update for Dragonflight (10.2.6) (new interface number)
- Checkbox to use Dragonriding in "ordinary" flyable zones
- *Not yet implemented*: Edge case handling when the player doesn't have the *Dragonflight Pathfinder* achievement and switches the Dragonriding checkbox off

## v2.1.7
- Update for Dragonflight (10.2.0) (new interface number)
- Icon in `toc` file

## v2.1.6
- Update for Dragonflight (10.0.5) (new interface number)

## v2.1.5
- Includes Dragonriding and the respective mounts
- New CC0 icons for the checkboxes

## v2.1.4
- Fixed interface taint (changed bindings `category` to `ADDON`)

## v2.1.3
- Update for Dragonflight (10.0.2) (new interface number)
- *Known bug*: Personal favorite icons only update when scrolling with mouse wheel, not when dragging the scroll bar

## v2.1.2
- Update for Chains of Domination (9.1.0) (new interface number)

## v2.1.1
- Update for Shadowlands (9.0.5) (new interface number)

## v2.1
- Mounts in mount journal scroll list now show icons if they're marked as personal favorites

## v2.0-beta
- Table of mounts is now generated ingame (checkboxes in the mount journal) and saved per character (using WoW's saved variables)

## v1.2
- Now checks player level in addition to flyable status of an area

## v1.1-alpha
- Now uses a table of (mount name, mount id) pairs to summon mounts

## v1.0
- Initial release