# LFMTracker

Addon for WoW Vanilla (1.12) that tracks LFM messages in the `World` channel and displays them in a compact, filterable UI.

## Features

- Captures `World` channel messages that look like LFM, case-insensitive and handling numbers/variants in text.
- Raid multi-select filter (select several raids at once).
- Compact mode: hides filter controls to reduce window size.
- Hidden-window alerts: you still get an alert sound when the window is hidden.
- Movable launcher icon:
  - Left-click: show/hide the main window,
  - Right-click: open options panel,
  - Hold `Shift` or `Ctrl` and drag: move the icon,
  - Detached mode keeps the icon clamped on-screen.
- Options panel:
  - Adjust window opacity,
  - Toggle launcher icon visibility,
  - Enable/disable hidden-window alerts,
  - Enable/disable launcher detach from minimap,
  - Edit the whisper template.
- Clicking a row prepares a whisper with the saved whisper template (`/w playername msg`).
- Hovering over a row shows the full message in a tooltip.
- Slash commands:
  - `/lfm` or `/lfmtracker` – show/hide the main window
  - `/lfm config` – open the options panel
  - `/lfm compact` – toggle compact mode
  - `/lfm msg <text>` – set the whisper template
  - `/lfm msg` – show the current whisper template

## Installation

1. Download the latest release archive or click **<>Code** -> **Download ZIP**.
2. Extract the archive.
3. If the extracted folder name ends with `-main`, rename it from something like `LFMTracker-main` to `LFMTracker`.
4. Copy the folder `LFMTracker` into your `World of Warcraft/Interface/AddOns/` directory.
5. Restart the game or reload the UI with `/reload`.

---

# LFMTracker (RU)

Аддон для WoW Vanilla (1.12), который отслеживает сообщения LFM в канале `World` и отображает их в компактном, фильтруемом окне.

## Возможности

- Отслеживает сообщения в канале `World`, похожие на LFM, без учёта регистра и с учётом цифр/вариантов в названиях.
- Множественный выбор рейдов (несколько одновременно).
- Компактный режим: скрывает блок фильтров для уменьшения размера окна.
- Оповещения при скрытом окне: если окно скрыто, аддон всё равно проигрывает звуковой сигнал.
- Перемещаемый значок-запускатель:
  - ЛКМ: показать/скрыть главное окно,
  - ПКМ: открыть панель настроек,
  - Удерживайте `Shift` или `Ctrl` и перетаскивайте, чтобы двигать значок,
  - В откреплённом режиме значок остаётся в пределах экрана.
- Панель настроек:
  - Прозрачность окна,
  - Показ/скрытие значка,
  - Включение/отключение оповещений при скрытом окне,
  - Открепление значка от миникарты,
  - Редактирование шаблона whisper.
- Клик по строке подготавливает whisper с сохранённым шаблоном (`/w playername msg`).
- Наведение мыши показывает полный текст сообщения во всплывающей подсказке.
- Команды чата:
  - `/lfm` или `/lfmtracker` – показать/скрыть окно
  - `/lfm config` – открыть настройки
  - `/lfm compact` – переключить компактный режим
  - `/lfm msg <текст>` – установить шаблон whisper
  - `/lfm msg` – показать текущий шаблон whisper

## Установка

1. Скачайте последний релиз или нажмите **<>Code** -> **Download ZIP**.
2. Распакуйте архив.
3. Если после распаковки папка называется, например, `LFMTracker-main`, уберите суффикс `-main` и переименуйте её в `LFMTracker`.
4. Переместите папку `LFMTracker` в каталог `World of Warcraft/Interface/AddOns/`.
5. Перезапустите игру или обновите интерфейс командой `/reload`.