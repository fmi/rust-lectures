---
title: GUI-та с GTK
author: Rust@FMI team
date: 18 декември 2018
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Административни неща

--
* Трето домашно и второ предизвикателство приключиха
--
* Четвъртък няма да имаме лекция
--
* Мислете за проекти

---

# Предизвикателство (demo)

* Базова имплементация
* Правилни и грешни решения

---

# Домашно (demo)

* Базова имплементация
* Интересни грешки
* Тестване
* Паралелизъм

---

# GTK

https://gtk-rs.org/

---

# ООП-style наследяване

--
* `Deref`: Ограничен, само за един тип
--
* Делегация, в някоя бъдеща версия на Rust ([RFC](https://github.com/elahn/rfcs/blob/delegation2018/text/0000-delegation.md#guide-level-explanation))
--
* Trait-ове

---

# ООП-style наследяване

### Ext-traits

Типа `gtk::MessageDialog` има само и единствено една асоциирана функция `new`. (Други типове могат да имат и други асоциирани методи, но предимно само за конструиране).

Оттам нататък, всички собствени методи на този "клас" се намират в trait-а `MessageDialogExt`.

Всички наследени методи се намират в trait-овете: `DialogExt`, `GtkWindowExt`, `BinExt`, `ContainerExt`, `WidgetExt`, `glib::object::ObjectExt`, `BuildableExt`.

Това работи, когато повечето код е автоматично-генерирани binding-и, но би било доста тегаво да се поддържа ръчно.

---

# ООП-style наследяване

### `IsA<T>`

(Вижте и https://gtk-rs.org/tuto/upcast_downcast)

Примерно, имаме

```rust
# //ignore
MessageDialog::new<T: IsA<Window>>(parent: Option<&T>, /* ... */)
```

Това ни позволява да cast-ваме неща напред-назад:

```rust
# //ignore
let button = gtk::Button::new();
let widget = button.upcast::<gtk::Widget>();
assert!(widget.downcast::<gtk::Button>().is_ok());
```

Забележете, че `upcast` не връща резултат, а връща директно структура от правилния тип. Това се проверява **compile-time**, така че `upcast` няма да се компилира, ако cast-а е несъвместим.

Downcast, от друга страна, няма как да се провери at compile-time, затова връща `Result`.

Native rust-ки аналог (kind of): [Any](https://doc.rust-lang.org/std/any/)

---

# Инсталация

Външните библиотеки вероятно ще са най-досадната част, особено под Windows: https://gtk-rs.org/docs-src/requirements.html

```toml
[dependencies]
gtk = { version = "0.5", features = ["v3_10"] }
```

В main файла:

```rust
# //ignore
extern crate gtk;

// За да може всички trait-ове да се include-нат,
// иначе ще трябва да се изброяват *доста*:
use gtk::prelude::*;
```

---

# Demo

### Markdown previewer

Source: https://mmstick.github.io/gtkrs-tutorials/chapter_04/index.html

---

# Markdown previewer

### Интересни неща

--
* Разделение на "модел" и "ui"
--
* Тестване на модела в изолация
--
* `App` се превръща в `ConnectedApp` -- интересен вариант за разделение на отговорностите на типовете.
--
* `Sourceview`, `Webkit2gtk`

---

# Glade

При твърде сложен дизайн на интерфейса, вероятно си заслужава да минем на Glade: https://gtk-rs.org/tuto/glade

Тук обаче "опаковането" на gui компоненти в наши си типове може да се окаже по-сложно... Експериментирайте с разделение на кода, за да достигнете до нещо, което ви е удобно.

---

# Demo

### Cameraview

Source: https://github.com/sdroege/rustfest-rome18-gtk-gst-workshop

---

# Cameraview

### Интересни неща

--
* Reference-counting: `App`, `AppInner`, `AppWeak`
--
* Конвертиране на всичко до наши типове с `From`: `SnapshotState`, `RecordState`
--
* RAII (SnapshotTimer)
--
* Връзване и енкапсулиране на "actions": `gtk::SimpleAction`
--
* Gstreamer

---

# Други интересни ресурси

--
* [relm](https://github.com/antoyo/relm): Библиотека, която седи отгоре на GTK и предоставя elm-подобен интерфейс.
--
* [conrod](https://github.com/PistonDevelopers/conrod/): Immediate-mode GUI, което e доста различно откъм widget-и.
--
* И всичко друго в секция "GUI" в ["awesome-rust"](https://github.com/rust-unofficial/awesome-rust#gui).
