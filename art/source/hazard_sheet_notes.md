# Hazard Sheet Notes

Generator:
- `tools/generate_hazard_sheets.gd`

Intended outputs when run with `--write`:
- `art/export/hazard_drone_sheet.png`
- `art/export/hazard_drone_sheet_preview.png`
- `art/export/hazard_mine_sheet.png`
- `art/export/hazard_mine_sheet_preview.png`

## Drone Sheet

Frame order, left to right:
1. `hover_a`
2. `hover_b`
3. `patrol_a`
4. `patrol_b`
5. `strike`
6. `hurt`
7. `break`

Intended runtime states:
- `idle_hover`
- `patrol_left`
- `patrol_right`
- `windup`
- `strike`
- `hurt`
- `break`

## Mine Sheet

Frame order, left to right:
1. `idle_a`
2. `idle_b`
3. `armed`
4. `charge`
5. `flash`
6. `inert`

Intended runtime states:
- `idle_pulse`
- `armed`
- `charge`
- `flash`
- `destroyed`
- `inert`

## Direction

- Wasp-like drone silhouette.
- Hive-pod mine silhouette.
- Keep both assets readable at gameplay zoom and compatible with a high-contrast SNES action-platformer presentation.
- Treat this as a first-pass asset generator scaffold. Final art can replace the generated output later without changing the frame order unless the runtime mapping changes too.
