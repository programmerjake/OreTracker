# Oretracker

Combines various tech to allow advanced mining operations.

## What's in the box

* Orehud: The original Oretracker mod with a single command to toggle the mod on or off per individual player.
* Xray: Based on Orehud except tracks non-ores and makes them appear invisible.

## What's New (July 1st 2024)

* Iterate ores and generate names and detection via that (No more hard coding for itemstring to Name, but no more colors based on ore)

## Orehud

Displays ore positions via the player's HUD.

> `/orehud` toggles the rendering of the ore positions on or off.

## Xray

Hides unwanted stone (and other variants) from view, only showing a empty node in it's wake.

> `/xray` toggles the unwanted stone from visible to invisible (on or off).

Yes, because xray interacts server side, all clients can make use of a single players client with xray. (This means you can see other players and ores they can see too by their xray)

## Common Issues

* It was found that if the server crashes while a player is using xray, xray's nodes are kept. Created a special mode (fix_mode) to attempt to repair nodes which should return back to their original upon detection. (If fix_mode is left on in production other players xrays can be overriden)
* It is possible to get xray nodes to say simply by logging off, xray attempts to cleanup nodes by players who are attempting to log out. (Please make an issue report with any logs and screenshots/video showing this still occurs)

## Things planned

* Improve Xray and Orehud so the api can literally add new nodes (so I don't need to release updates for others to add support for their mods/games)
* Possibly add a formspec for Xray so you could customize your xray, per player (i.e. know a node you don't want to see, just add it via the formspec)
