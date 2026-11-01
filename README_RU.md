# Speedrun Quickstart (KZM)

Пропуск цепочки стартовых комнат и автоматическое продолжение последнего спидрана (если сохранение есть) — как **Continue previous speedrun? → YES** на титульном экране.

| | |
| --- | --- |
| **ID** | `speedrun-quickstart` |
| **Автор** | An1by |
| **Нужно** | База KZM (libLassebq), разблокированный режим спидрана в игре |

## Что делает мод

1. **Пропуск интро** — при первом запуске сессии комнаты saveprompt / options / logo / splash сразу переводят в `room_title`.
2. **Автопродолжение** — на первом Step `obj_titlemenu`, если в опциях есть незавершённый забег (`global.mid_speedrun`), вызывается `load_current_speedrun()`, выставляется `global.speedrun = 1` и переход в `global.continue_room`.
3. **Отключить автозаход** — зажми **Shift** при запуске игры.
4. **Лог** — `<игра>/mods/speedrun-quickstart/quickstart.log`.

Совместим с **Katana SNOW** и другими модами в общем loadlist.

## Установка

```bash
kzm build
kzm validate .
```

Включи мод в профиле лаунчера → **Play**.

## Для разработчиков

Хуки в **`lua/quickstart.lua`**, в манифесте — **`loadlistExtra`**. libLassebq заново выполняет файл loadlist на **каждом** событии; нужно возвращать **закэшированную** таблицу хуков из `_G`. Подробно: [ADR 0022](../kzm/docs/adr/0022-loadlist-extra-hook-table-cache.md).

Не передавай GML-массивы (userdata) обратно в GML из этих хуков.

## Право

Katana ZERO — Askiisoft. Мод не распространяет файлы игры.
