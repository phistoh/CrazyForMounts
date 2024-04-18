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