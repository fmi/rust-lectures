---
title: GUI-та с GTK
author: Rust@FMI team
speaker: Андрей Радев
date: 11 януари 2021
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Административни неща

* Домашно 3: приключи ([пълен тест](https://github.com/AndrewRadev/rust-secrets/blob/a38fa40ae570b954e4ad7d92766da4063f99e2e6/tasks/csv_filter/tests/test_full.rs))
* Мислете за проекти (https://fmi.rust-lang.bg/guides/projects)

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

Типа [`gtk::MessageDialog`](https://docs.rs/gtk/0.9.2/gtk/struct.MessageDialog.html) има само и единствено една асоциирана функция `new`. (Други типове могат да имат и други асоциирани методи, но предимно само за конструиране).

Оттам нататък, всички собствени методи на този "клас" се намират в trait-а [`MessageDialogExt`](https://docs.rs/gtk/0.9.2/gtk/trait.MessageDialogExt.html).

Всички наследени методи се намират в trait-овете: `DialogExt`, `GtkWindowExt`, `BinExt`, `ContainerExt`, `WidgetExt`, `glib::object::ObjectExt`, `BuildableExt`. Това са всички типове, за които имаме `IsA` имплементация за `MessageDialog`.

Това работи, когато повечето код е автоматично-генерирани binding-и, но би било доста тегаво да се поддържа ръчно.

---

# ООП-style наследяване

### `IsA<T>`

(Вижте и https://gtk-rs.org/docs-src/tutorial/object_oriented)

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

Външните библиотеки вероятно ще са най-досадната част, особено под Windows: https://www.gtk.org/docs/installations/

```toml
[dependencies]
gtk = { version = "0.9", features = ["v3_16"] }
```

В main файла:

```rust
# //ignore
// За да може всички trait-ове да се include-нат,
// иначе ще трябва да се изброяват *доста*:
use gtk::prelude::*;
use gio::prelude::*;
```

---

# Версии

Ако намерите tutorial online, който не се компилира, добра идея е да пробвате да пуснете `cargo update` -- това ще опита да инсталира по-нови версии на пакетите, които продължават да са съвместими с изискванията.

Примерно, проекта може да е фиксирал libc версия "0.2.33", но пакетите просто да търсят версия "0.2.x". Един `cargo update` може да вдигне до версия "0.2.82", която е API-compatible, но просто оправя някакви вътрешни проблеми.

---

# Размери на пакетите

Досадно големи. Моя "quickmd" пакет има 3.7GB "target" директория. Проекти, които сте пробвали да компилирате веднъж и сте ги изоставили, може да ги зачистите с `cargo clean`.

---

# Demo

### Markdown previewer

Обяснение: https://mmstick.github.io/gtkrs-tutorials/chapter_04/index.html

Малко остарял проект вече, за нещастие. Ползвайте моя форк за кода: https://github.com/AndrewRadev/gtkrs-tutorials/tree/7f51f0f37a20fb0b4ab6217e90a17dc132cf8c71/demos/chapter_04

Промени от оригинала:

* `cargo update` за оправяне на счупени зависимости
* Update на gtk (и свързани библиотеки) до 0.9.2
* edition = "2018"

---

# Markdown previewer

### Интересни неща

--
* Разделение на "модел" и "ui"
--
* Тестване на модела в изолация
--
* `App` се превръща в `ConnectedApp` -- интересен вариант за разделение на отговорностите на типовете, но може би по-сложен отколкото си заслужава.
--
* `Sourceview`, `Webkit2gtk` -- отделни пакети, които са съвместими с GTK и ви дават готини инструменти за разнообразни неща.

---

# Glade

При твърде сложен дизайн на интерфейса, може да си заслужава да минем на Glade: https://gtk-rs.org/docs-src/tutorial/glade

Тук обаче "опаковането" на gui компоненти в наши си типове може да се окаже по-сложно... Експериментирайте с разделение на кода, за да достигнете до нещо, което ви е удобно.

---

# Demo

### Cameraview

Source: https://github.com/sdroege/rustfest-rome18-gtk-gst-workshop

---

# Cameraview

### Интересни неща

--
* Reference-counting: `App`, `AppInner`, `AppWeak` (вместо това може да ползвате [`clone!`](https://gtk-rs.org/docs/glib/macro.clone.html) макросa, но е полезно да го разгледате, за да разберете как да използвате въпросния макрос)
--
* Конвертиране на всичко от и до наши типове с `From`: `SnapshotState`, `RecordState`
--
* RAII (SnapshotTimer)
--
* Връзване и енкапсулиране на "actions": `gtk::SimpleAction`
--
* [`serde_any`](https://docs.rs/serde_any/0.5.0/serde_any/): толкова чудесен пакет
--
* Gstreamer

---

# Demo

### Quickmd

Source: https://github.com/AndrewRadev/rust-quickmd

(Използване на `gtk::Application` в отделен branch: https://github.com/AndrewRadev/rust-quickmd/tree/use-gtk-application)

---

# Комуникиране между нишки

В GTK, widget-ите трябва да им се викат методи в главния thread. Това означава, че ако искате да предавате ownership напред-назад, вероятно е добре да ги опаковате в клонируеми smart pointer-и, но дори тогава може да не сработят нещата.

Проблема е добре описан в този blog post: https://coaxion.net/blog/2019/02/mpsc-channel-api-for-painless-usage-of-threads-with-gtk-in-rust/

Решението на статията е доста добро -- използвайте канали! В quickmd, има две нишки, които си комуникират със съобщения с канали:

- UI thread
- Watcher loop

Когато watcher-а, докато си цикли безкрайно, намери промяна във файл, изпраща съобщение по канал, и това съобщение стига до UI нишката и предизвиква update. На практика, би било добре да има и още един цикъл -- Renderer -- но това е бъдещо рефакториране :).

В някои отношения, това усложнява нещата. В други, ги опростява *значително*. Няма нужда да си мислите как ще споделите някакво парче данни -- дръжте му ownership-а на едно-единствено място и просто изпращайте съобщения по канал. Това улеснява много и тестването на неща в изолация.

---

# gtk::Application vs gtk::main

"Стария" стил на писане на GTK приложения (GTK 2.0):

--
* `gtk::init()`
--
* Правим каквото правим, създаваме си дървото от GUI елементи
--
* Викаме на най-главния прозорец `window.show_all()`
--
* `gtk::main()`
--
* За да приключим, някъде викаме `gtk::main_quit()`

---

# gtk::Application vs gtk::main

"Новия" стил на писане на GTK приложения (GTK 3.0+):

--
* `let application = gtk::Application::new(<уникално име>, <флагове>)?;`
--
* `application.connect_startup(|application| <инициализираме си всичко>);`
--
* Стартираме приложението със `application.run(&args().collect::<Vec<_>>());`
--
* (или може би със `application.run(&[]);`)
--
* (Вместо `gtk::Window`, използваме `gtk::ApplicationWindow`)
--
* За да приключим, някъде викаме *на приложението* `application.quit()` (или очакваме автоматично да приключи при затваряне на всички прозорци)

---

# gtk::Application vs gtk::main

Двата модела не са съвсем еквивалентни -- стария стил означава, че приложението е self-contained -- стартира, прави нещо, приключва. Ако пуснете второ такова приложение, то ще е отделно.

С новия модел, ако пуснете второ приложение, то просто ще "активира" първото. Примерно, ако в командния ред пуснете `firefox http://google.com`, това ще ви отвори firefox и ще чака в терминала. Ако след това в друг терминал пуснете `firefox http://duckduckgo.com`, това веднага ще приключи, и ще отвори DuckDuckGo във вече отворения firefox.

Това усложнява малко логиката, но е нещо, което е oчаквано донякъде в повечето модерни GUI приложения. Един application, множество прозорци. Има и бонуси, като интеграция с DBUS и разни други неща.

---

# Command-line handling

В [rust-quickmd](https://github.com/AndrewRadev/rust-quickmd):

```rust
# //ignore
use gio::prelude::*;
use gio::ApplicationFlags;

fn main() {
    let app = gtk::Application::new(
        Some("com.andrewradev.quickmd"),
        ApplicationFlags::HANDLES_OPEN | ApplicationFlags::HANDLES_COMMAND_LINE
    ).expect("GTK initialization failed");

    app.connect_command_line(move |app, cmdline| {
        if let Err(e) = run(&app, cmdline.get_arguments()) {
            eprintln!("{}", e);
            1 // неуспешен резултат
        } else {
            0 // успешен резултат
        }
    });

    app.run(&env::args().collect::<Vec<_>>());
}
```

Тоест, вместо да чакаме `connect_startup`, чакаме `connect_command_line`, защото очакваме някакъв потенциално различен вход при всяко изпълнение.

---

# GTK4

Още не виждам много документация по въпроса, но го има: https://github.com/gtk-rs/gtk4-rs

---

# Други интересни ресурси

* Добра лекция, която прави един UI с GTK и също с терминален интерфейс: https://www.youtube.com/watch?v=dK9-oXptFcM
--
* [fltk](https://github.com/MoAlyousef/fltk-rs): Малко по-дървен интерфейс, но популярен за базови неща.
--
* [relm](https://github.com/antoyo/relm): Библиотека, която седи отгоре на GTK и предоставя elm-подобен интерфейс.
* [vgtk](https://github.com/bodil/vgtk): Също седи отгоре на GTK, прави интересни неща с макроси.
--
* [conrod](https://github.com/PistonDevelopers/conrod/): Immediate-mode GUI, което e доста различно откъм widget-и. Target-а му е UI за игри.
--
* [tauri](https://github.com/tauri-apps/tauri): Hot new stuff, използва webview, като electron, но с доста по-малък overhead (твърдят).
--
* И всичко друго в секция "GUI" в ["awesome-rust"](https://github.com/rust-unofficial/awesome-rust#gui).
* Също, ["Are we GUI Yet?"](https://areweguiyet.com/)
