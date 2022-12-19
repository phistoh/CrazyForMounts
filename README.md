# CrazyForMounts
WoW addon which provides a slash command to summon a random mount out of a predefined table

## Usage
Select both ground and flying mounts via checkbox in the mount journal from which one will randomly be chosen depending on the circumstances (i. e. is the player in a flyable area). Summon a random mount from this list ingame with the command `/crazyformounts` or `/cfm` or use the provided option to assign a keybind.

## Screenshots
#### Not a personal mount
![Not a personal mount](.github/1.png?raw=true)

#### Personal ground mount
![Personal ground mount](.github/2.png?raw=true)

#### Personal flying mount
![Personal flying mount](.github/3.png?raw=true)

#### Keybind settings
(In Dragonflight, those keybinds are grouped under '*Addons*')
![Keybind settings](.github/4.png?raw=true)

## File Description
- **CrazyForMounts.lua** contains the main code
- **CrazyForMounts.toc** is the standard table-of-contents file containing addon information
- **Bindings.xml** is needed to provide keybinds
- **horse.tga** and **bird.tga** are used as backgrounds for the checkboxes

## To-Do
- [ ] Filtering/searching of personal favorites
- [ ] Implement Dragon riding

## Known Bugs
- Personal favorite icons only update when scrolling with mouse wheel, not when dragging the scroll bar
