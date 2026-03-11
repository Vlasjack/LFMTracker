# LFMTracker

Addon for WoW Vanilla (1.12) that tracks LFM messages in the `World` channel and displays them in a compact, filterable UI.

## Features

- Captures `World` channel messages that look like LFM, case‑insensitive and handling numbers/variants in text.
- Role filter: `ALL`, `DPS`, `HEAL`, `TANK`.
- Raid multi‑select filter (select several raids at once).
- Compact mode: hides filter controls to reduce window size.
- Hidden‑window alerts: you still get notifications in chat (and optional sound) when the window is hidden.
- Movable launcher icon:
  - Left‑click: show/hide the main window,
  - Right‑click: open options panel,
  - Hold and drag: reposition the icon anywhere on screen.
- Options panel:
  - Adjust window opacity,
  - Toggle launcher icon visibility,
  - Enable/disable hidden‑window alerts,
  - Enable/disable alert sound.
- Clicking a row prepares a whisper with the saved whisper template (`/w playername msg`).
- Hovering over a row shows the full message in a tooltip.
- Slash commands:
  - `/lfm` or `/lfmtracker` – show/hide the main window
  - `/lfm config` – open the options panel
  - `/lfm compact` – toggle compact mode
  - `/lfm msg <text>` – set the whisper template
  - `/lfm msg` – show the current whisper template

## Installation

1. Download the latest release archive.
2. Extract the archive.
3. Copy the folder `LFMTracker` into your `World of Warcraft/Interface/AddOns/` directory.
4. Restart the game or reload the UI with `/reload`.

---

# LFMTracker (RU)

Аддон для WoW Vanilla (1.12), который отслеживает сообщения LFM в канале `World` и отображает их в компактном, фильтруемом окне.

## Возможности

- Отслеживает сообщения в канале `World`, похожие на LFM, без учёта регистра и с учётом любых цифр в названиях.
- Фильтр ролей: `ALL`, `DPS`, `HEAL`, `TANK`.
- Множественный выбор рейдов (несколько одновременно).
- Компактный режим: скрывает блок фильтров для уменьшения размера окна.
- Оповещения, даже когда окно скрыто (в чат и звуком, если включено).
- Перемещаемый значок‑запускатель:
  - ЛКМ: показать/скрыть главное окно,
  - ПКМ: открыть панель настроек,
  - Удерживание + перетаскивание: переместить значок в любое место экрана.
- Панель настроек:
  - Прозрачность окна,
  - Показ/скрытие значка,
  - Включение/отключение оповещений при скрытом окне,
  - Включение/отключение звука оповещений.
- Клик по строке подготавливает whisper с сохранённым шаблоном (`/w playername msg`) .
- Наведение мыши показывает полный текст сообщения во всплывающей подсказке.
- Команды чата:
  - `/lfm` или `/lfmtracker` – показать/скрыть окно,
  - `/lfm config` – открыть настройки,
  - `/lfm compact` – переключить компактный режим,
  - `/lfm msg <текст>` – установить шаблон whisper,
  - `/lfm msg` – показать текущий шаблон whisper

## Установка

1. Скачайте последний релиз.
2. Распакуйте архив.
3. Переместите папку `LFMTracker` в каталог `World of Warcraft/Interface/AddOns/`.
4. Перезапустите игру или обновите интерфейс командой `/reload`.
