# BACKGROUND PACKAGE 01

This package is the first real runtime backdrop pass for Killer Queen.

It is not meant to be the final hand-authored sprite background set. It is the in-engine composition package that establishes the region language, parallax hierarchy, and transition story for the current prototype.

## Regions Included

- Hive Shaft
- Sunset Ruin Skyline

## Runtime Mode

The active tower backdrop should default to `ESCAPE_BLEND`.

That mode does three jobs:

1. keeps the lower and middle climb inside the Hive Shaft
2. leaks sunset color and skyline mass into the upper climb
3. makes the breach into the outside world readable before the player clears the shaft

The same script also supports:

- `HIVE_SHAFT`
- `SUNSET_RUIN`

Those are for future rooms or prototype scenes that want a single-region backdrop.

## Layer Order

The package is designed around a clean background stack:

1. sky gradient and horizon glow
2. distant sunset ruin silhouettes
3. monumental columns and bridges
4. breach light and opening shell
5. hive shaft walls, ribs, pods, cells, and mite silhouettes
6. kill-floor warning band

The rule is simple:

- skyline layers carry scale
- hive layers carry threat
- neither should overpower the player or platform reads

## Palette Intent

### Hive Shaft

- night navy
- foundry blue
- steel slate
- oxidized teal
- signal amber
- warning ember red

### Sunset Ruin Skyline

- dusk violet
- hot rust rose
- sunset gold
- dust cream
- steel slate
- muted teal

## Readability Rules

- The top breach should feel brighter than the shaft, but not brighter than the player silhouette.
- Near-background shaft walls should stay darker than future collision tiles.
- The skyline should read as monumental shape language, not texture.
- Amber is the active danger color. Do not spend it freely on decorative skyline accents.
- The kill floor must remain the hottest active band on screen.

## Future Swap Rules

When final art replaces this package:

- preserve the same region break between shaft and skyline
- keep collision readability higher than decorative richness
- keep the breach opening large and obvious
- keep large landmark columns outside the main traversal lane
- keep bright horizon colors out of the player value range

If a prettier version weakens traversal reads, the prettier version is wrong.
