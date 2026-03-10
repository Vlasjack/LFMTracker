# LFMTracker

Addon for WoW Vanilla (1.12) that tracks LFM messages in the `World` channel and shows them in a compact filterable UI.

## Features

- Captures `World` channel messages that look like LFM.
- Role filter: `ALL`, `DPS`, `HEAL`, `TANK`.
- Raid multi-select filter (you can select several raids at once).
- Compact mode: hide filter blocks to keep the window small.
- Hide the main window and still get alerts in chat (and optional sound) for matching entries.
- Movable launcher icon:
  - Left click: show/hide window,
  - Right click: options,
  - Drag: move anywhere on screen.
- Options panel:
  - window opacity,
  - show/hide launcher icon,
  - hidden-window alerts,
  - alert sound toggle.
- Click row to prepare whisper to message author (uses saved whisper template).
- Tooltip shows full message text.
- Slash commands:
  - `/lfm` or `/lfmtracker` to show/hide window,
  - `/lfm config` to open options,
  - `/lfm compact` to toggle compact mode,
  - `/lfm msg <text>` to set whisper template,
  - `/lfm msg` to show current whisper template.

## Install

1. Download the latest release archive.
2. Extract the contents of the archive.
3. Copy the folder `LFMTracker` to your WoW `Interface/AddOns/` directory.
4. Restart the game or reload UI (`/reload`).

---
# LFMTracker

Аддон для WoW Vanilla (1.12) для отслеживания сообщений LFM в канале `World` и отображения их в интерфейсе с фильтрацией.

## Возможности

- Отслеживает сообщения в канале `World`, похожие на LFM.
- Фильтр ролей: `ALL`, `DPS`, `HEAL`, `TANK`.
- Множественный выбор рейдов (можно выбрать несколько одновременно).
- Компактный режим: скрывает блоки фильтров для уменьшения окна.
- Скрытое окно: получение оповещений в чат (опционально звук) при появлении подходящих записей.
- Перемещаемый значок:
  - ЛКМ: показать/скрыть окно,
  - ПКМ: настройки,
  - Перетаскивание: перемещение по экрану.
- Панель настроек:
  - прозрачность окна,
  - показать/скрыть значок,
  - оповещения при скрытом окне,
  - включение/отключение звука оповещений.
- Клик по строке для подготовки whisper автору сообщения (используется сохраненный шаблон).
- Подсказка при наведении показывает полный текст сообщения.
- Команды чата:
  - `/lfm` или `/lfmtracker` показать/скрыть окно,
  - `/lfm config` открыть настройки,
  - `/lfm compact` переключить компактный режим,
  - `/lfm msg <текст>` установить шаблон whisper,
  - `/lfm msg` показать текущий шаблон whisper.

## Установка

1. Скачайте архив с последней версией.
2. Распакуйте содержимое архива.
3. Скопируйте папку `LFMTracker` в директорию `Interface/AddOns/` вашей игры.
4. Перезапустите игру или перезагрузите интерфейс (`/reload`).
