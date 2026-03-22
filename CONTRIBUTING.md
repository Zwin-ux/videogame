# Contributing To Killer Queen

Thanks for jumping in.

This project is still shaping its first strong public slice, so the best contributions are focused and concrete.

## What Helps Most

- movement and combat feel fixes
- UI readability cleanup
- sprite and animation polish that improves gameplay clarity
- encounter tuning and boss readability
- documentation that removes friction for the next contributor

## Before You Start

For anything bigger than a small fix:
1. Open an issue first.
2. Describe the problem you want to solve.
3. Keep the proposed change tight.

Do not open giant “here is the whole future of the game” PRs. Small, shippable improvements are much easier to land.

## Setup

1. Install Godot `4.6.1` or newer.
2. Open the repo root as a Godot project.
3. Run `scenes/main_menu.tscn` or `scenes/main.tscn`.

For art exports:
1. Edit source files in `art/source`.
2. Export runtime assets with `tools/export_aseprite.ps1`.

## Contribution Rules

- Respect the existing tone and visual direction.
- Prefer fewer, stronger decisions over more systems.
- Do not add generic UI or placeholder copy.
- Do not dump prompt transcripts or planning sludge into the repo root.
- Keep code changes readable and production-leaning.
- If you touch visuals, optimize for gameplay readability first.

## Pull Requests

Good PRs:
- fix one clear problem
- explain what changed
- say how you tested it
- include screenshots or clips when visuals changed

Bad PRs:
- mix unrelated systems
- add speculative architecture
- rewrite the project without alignment
- bury the useful change in a wall of generated text

## Community

Be direct, respectful, and useful. Strong critique is welcome when it improves the game.

## License

By contributing, you agree that your contributions ship under the repository license.
