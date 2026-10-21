# Changelog

## Unreleased

## 2.1.7 - 2026-10-21

- Fixed the hire window not opening when a recruit has no level ups left (e.g. high level veterans).
- Fixed a single recruit Clever Recruiter can't handle stopping the whole hire window from opening: that recruit now just shows the vanilla information, and the error is logged.
- Restored the attribute order from before 2.1.4 (the same layout as the character screen), without breaking the max level predictions.
- Fixed the shown maximum of a stat being below the recruit's actual value with Legends (and other mods that change how stats are rolled). Recruits generated before this update still use the old calculation.
- Fixed Legends perk groups not being shown in a recruit's details before tryout.
- Fixed Legends' talent stars cluttering the traits row after tryout; Clever Recruiter's stats grid already shows them.
- Fixed the arrow before the level 11 projection showing as a box; it's now a ».
