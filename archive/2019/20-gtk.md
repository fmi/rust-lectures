---
title: GUI-та с GTK
author: Rust@FMI team
speaker: Андрей Радев
date: 17 декември 2019
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Административни неща

--
* Първо предизвикателство приключи
--
* Четвъртък няма да имаме лекция
--
* Мислете за проекти

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
gtk = { version = "0.8", features = ["v3_16"] }
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

# Demo

### Markdown previewer

Обяснение: https://mmstick.github.io/gtkrs-tutorials/chapter_04/index.html

Код: https://github.com/mmstick/gtkrs-tutorials/tree/47e1e54667fafd941ac623c8007e60d07738763a/demos/chapter_04

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
* Reference-counting: `App`, `AppInner`, `AppWeak` (вероятно няма да ви е полезно с новия `clone!` макрос, но е полезно да го разгледате, за да разберете как да използвате въпросния макрос)
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

# Версия 0.8.0 на GTK-rs

https://gtk-rs.org/blog/2019/12/15/new-release.html

Някои нови неща:

--
* Макрос за клониране, често срещан механизъм за споделяне на widget-и, но трябва да се внимава дали използвате силни или слаби references ("трябва" == "иначе ще имате memory leaks", което може да не е твърде голяма драма в зависимост какво правите)
--
* Възможност за правене на ваши "subclass"-ове на widget-и... макар че изглежда по-сложно, отколкото си заслужава :)
--
* Async/await поддръжка -- това означава че I/O нещата в `gio` пакета (които GTK си използва вместо native rust-ките) могат на теория да са съвместими с rust-ките futures. На практика, вероятно иска известно количество работа.

---

# Други интересни ресурси

--
* [relm](https://github.com/antoyo/relm): Библиотека, която седи отгоре на GTK и предоставя elm-подобен интерфейс.
--
* [conrod](https://github.com/PistonDevelopers/conrod/): Immediate-mode GUI, което e доста различно откъм widget-и.
--
* [tauri](https://github.com/tauri-apps/tauri): Hot new stuff, използва webview, като electron, но с доста по-малък overhead (твърдят).
--
* И всичко друго в секция "GUI" в ["awesome-rust"](https://github.com/rust-unofficial/awesome-rust#gui).
