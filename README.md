# undertale-ceiling-fan

This is an Undertale battle engine I made that I don't have any plans with. It includes a few example battle scripts I mainly made for testing purposes. I may add things to it in the future if I get bored, but don't count on it, so feel free to fork it or submit a pull request for new features or bug fixes. Credit is appreciated if you use this in a personal project, but not required.

## Running the source code

This project was written in Lua with [LOVE2D](https://love2d.org/), so make sure you have that installed. Download the code, open a command line in the base folder and run the command `lovec .`

## Known Issues

- Missing an attack will not progress the battle and instead result in a softlock
- Attack, spare, and death animations are not finished
- An enemy can still prevent the player from fleeing even if they are already spared or killed
- Items do not exist
- There is no easy way to define an enemy with more than one sprite or moving parts
- Pre-attack enemy dialogue is not possible
- Flavor text appears before the battle box has fully expanded to fit it after a turn resulting in a minor visual glitch