# LFMTracker

Addon for WoW Vanilla (1.12) that tracks LFM messages in the `World` channel and displays them in a compact, filterable UI.

## Features

- Captures `World` channel messages that look like LFM, case-insensitive and handles numbers/variants.
- Role filter: `ALL`, `DPS`, `HEAL`, `TANK`.
- Raid multi-select filter (select several raids at once).
- Compact mode: hide filter blocks to reduce window size.
- Hidden-window alerts: get notifications in chat (and optional sound) even when the window is hidden.
- Movable launcher icon:
  - Left click: show/hide window
  - Right click: open options
  - Drag: move anywhere on screen
- Options panel:
  - Window opacity
  - Show/hide launcher icon
  - Hidden-window alerts
  - Alert sound toggle
- Click a row to prepare a whisper to the message author (uses saved whisper template)
- Tooltip shows full message text on hover
- Slash commands:
  - `/lfm` or `/lfmtracker` – show/hide window
  - `/lfm config` – open options
  - `/lfm compact` – toggle compact mode
  - `/lfm msg <text>` – set whisper template
  - `/lfm msg` – show current whisper template

## Installation

1. Download the latest release archive.
2. Extract the contents of the archive.
3. Copy the folder `LFMTracker` to your WoW `Interface/AddOns/` directory.
4. Restart the game or reload UI (`/reload`).

---

# LFMTracker (RU)

Аддон для WoW Vanilla (1.12) для отслеживания сообщений LFM в канале `World` и отображения их в интерфейсе с фильтрацией.

## Возможности

- Отслеживает сообщения в канале `World`, похожие на LFM, без учёта регистра и с учётом любых цифр.
- Фильтр ролей: `ALL`, `DPS`, `HEAL`, `TANK`.
- Множественный выбор рейдов (можно выбрать несколько одновременно).
- Компактный режим: скрывает блоки фильтров для уменьшения окна.
- Скрытое окно: получение оповещений в чат (опционально со звуком) при появлении подходящих записей.
- Перемещаемый значок:
  - ЛКМ: показать/скрыть окно
  - ПКМ: открыть настройки
  - Перетаскивание: перемещение по экрану
- Панель настроек:
  - Прозрачность окна
  - Показ/скрытие значка
  - Оповещения при скрытом окне
  - Включение/отключение звука оповещений
- Клик по строке готовит whisper автору сообщения (используется сохранённый шаблон)
- Подсказка при наведении показывает полный текст сообщения
- Команды чата:
  - `/lfm` или `/lfmtracker` – показать/скрыть окно
  - `/lfm config` – открыть настройки
  - `/lfm compact` – переключить компактный режим
  - `/lfm msg <текст>` – установить шаблон whisper
  - `/lfm msg` – показать текущий шаблон whisper

## Установка

1. Скачайте архив с последней версией.
2. Распакуйте содержимое архива.
3. Скопируйте папку `LFMTracker` в директорию `Interface/AddOns/` вашей игры.
4. Перезапустите игру или перезагрузите интерфейс (`/reload`).