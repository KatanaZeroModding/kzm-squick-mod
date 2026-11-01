# Speedrun Quickstart (KZM)

Skip the startup prompt chain and, when a saved speedrun exists, load it the same way as choosing **Continue previous speedrun? → YES** on the title screen.

| | |
| --- | --- |
| **ID** | `speedrun-quickstart` |
| **Author** | An1by |
| **Requires** | KZM base inject (libLassebq), Katana ZERO with speedrun unlocked |

## Behavior

1. **Intro skip** — On first launch, `obj_saveprompt`, `obj_optionsprompt`, `obj_logo`, and `obj_splash` redirect to `room_title` (once per game session until the title menu has stepped).
2. **Auto-resume** — On the first frame of `obj_titlemenu` Step, if `global.mid_speedrun` is set (from `KatanaSpeedrunOpt.zero` / game options), the mod calls `load_current_speedrun()`, sets `global.speedrun = 1`, and `room_goto(global.continue_room)`.
3. **Opt out** — Hold **Shift** while starting if you want the title menu without auto-resume.
4. **Logging** — `<game>/mods/speedrun-quickstart/quickstart.log` records resume success or reason for skip.

Works alongside **Katana SNOW** and other mods that use the merged loadlist (`kzm/bootstrap.lua` + extras).

## Install

From this folder (with [KZM CLI](../kzm/docs/CLI.md) on `PATH` and `KZM_GAME_PATH` set):

```bash
kzm build
kzm validate .
```

Enable **Speedrun Quickstart** in the launcher profile, then **Play** (deploy + launch).

## For authors

Gameplay hooks live in **`lua/quickstart.lua`**, deployed as `mods/speedrun-quickstart/quickstart.lua` and registered via **`[lua].loadlistExtra`** in `mod.toml`. They are **not** applied through `lua/main.lua` alone when worm/SNOW loadlist layout is active.

libLassebq re-runs loadlist scripts on every hook dispatch. The file **must return the same cached hook table** every time. See [ADR 0022](../kzm/docs/adr/0022-loadlist-extra-hook-table-cache.md).

Do not pass GML array userdata back into GML from these hooks.

## License

Katana ZERO is property of Askiisoft. This mod does not ship game assets. See [KZM community IP notes](../kzm/docs/COMMUNITY_AND_GAME_IP.md).
