---
title: Command-Line Interfaces
author: Rust@FMI team
speaker: Андрей Радев
date: 29 ноември 2018
lang: bg
keywords: rust,fmi
# description:
slide-width: 80%
font-size: 20px
font-family: Arial, Helvetica, sans-serif
# code blocks color theme
code-theme: github
---

# Hangman

### Demo

Пълния код: [rust-hangman](https://github.com/AndrewRadev/rust-hangman)

---

# Откъде вземаме данни за играта?

* От предефиниран път на системата -- `$HOME/.hangman_words.txt` (`dirs::home_dir`, от пакета [dirs](https://github.com/soc/dirs-rs))
* От аргументите на командния ред -- `$ hangman wordlist.txt` (`std::env::{args, args_os}`)
* Вградени в binary-то по време на компилация (`include_str!`, `include_bin!`)

---

# Вграждане в binary-то

Лесен начин, и доста удобен за разнообразни други неща. Макроса `include_str!` чете файл и го набива в кода по време на компилация, все едно си е бил там, ограден с кавички. Така може да вграждате всякакви текстови ресурси в binary-то (а със `include_bin!`, може да вграждате и примерно картинки, аудио...). Пътищата са релативни на текущия файл.

Пример от друг проект ([rust-quickmd](https://github.com/AndrewRadev/rust-quickmd)):

```rust
# //ignore
const MAIN_JS:    &'static str = include_str!("../res/js/main.js");
const MAIN_CSS:   &'static str = include_str!("../res/style/main.css");
const GITHUB_CSS: &'static str = include_str!("../res/style/github.css");
```

---

# Локално инсталиране на пакет

* `cargo install --path .`, а ако вече е било викнато, `cargo install --path . --force`
* Инсталира нещата в `~/.cargo/bin/`
* `hangman wordlist.txt`
* Може да имаме повече от един executable file. Слагаме ги в `src/bin/`, всеки си има собствен main. Може да ги викаме локално със `cargo run --bin <име-на-файла>`, а при cargo install ще си се инсталират като отделни binary-та. Пример от друг проект: [rust-id3-image](https://github.com/AndrewRadev/id3-image/blob/master/src/bin/id3-image-embed.rs)

---

# Debug-ване

### ENV vars

```rust
# //ignore
# fn main() {
pub fn clear_screen() {
    if env::var("DEBUG").is_ok() {
        return;
    }

    print!("{}[2J", 27 as char);
    print!("{}[1;1H", 27 as char);
}
# }
```

```
$ DEBUG=1 cargo run some-file.txt
$ DEBUG=1 hangman some-file.txt
```

---

# Debug-ване

### ENV Logger

Удобен проект за по-сериозно log-ване: https://docs.rs/env_logger

Пример от друг проект ([rust-quickmd](https://github.com/AndrewRadev/rust-quickmd)):

```rust
# //ignore
fn init_logging() {
    // Release logging:
    // - Warnings and errors
    // - No timestamps
    // - No module info
    //
    #[cfg(not(debug_assertions))]
    env_logger::builder().
        default_format_module_path(false).
        default_format_timestamp(false).
        filter_level(log::LevelFilter::Warn).
        init();

    // Debug logging:
    // - All logs
    // - Full info
    //
    #[cfg(debug_assertions)]
    env_logger::builder().
        filter_level(log::LevelFilter::Debug).
        init();
}
```

Примерна употреба:

```rust
# //ignore
debug!("Building HTML:");
debug!(" > home_path  = {}", home_path);
debug!(" > scroll_top = {}", scroll_top);
```

При пускане на програмата в release mode, премахваме много допълнителна информация като модули и timestamp, и показваме всичко от "warning" нагоре.

При пускане в debug mode (стандарното при `cargo run`):

```
[2019-11-29T08:57:33Z DEBUG quickmd::assets] Building HTML:
[2019-11-29T08:57:33Z DEBUG quickmd::assets]  > home_path  = /home/andrew
[2019-11-29T08:57:33Z DEBUG quickmd::assets]  > scroll_top = 0
[2019-11-29T08:57:33Z DEBUG quickmd::ui] Loading HTML:
[2019-11-29T08:57:33Z DEBUG quickmd::ui]  > output_path = /tmp/.tmpWq7EYh/output.html
[2019-11-29T08:57:33Z DEBUG quickmd::background] Watching ~/.quickmd.css

```

---

# По-сложна обработка на аргументи чрез structopt

```rust
# //ignore
# fn main() {
[dependencies]
rand = "*"
structopt = "*"
structopt-derive = "*"
# }
```

---

# По-сложна обработка на аргументи чрез structopt

```
$ hangman --wordlist=words.txt --attempts=10 --debug
$ hangman -w words.txt -a 10 -d
$ hangman --help
$ hangman --version
```

---

# По-сложна обработка на аргументи чрез structopt

```rust
# //ignore
# fn main() {
extern crate structopt;
#[macro_use]
extern crate structopt_derive;
use structopt::StructOpt;

#[derive(StructOpt, Debug)]
#[structopt(name="hangman", about="A game of Hangman")]
pub struct Options {
    #[structopt(short="w", long="wordlist", help="The path to a word list")]
    wordlist_path: Option<String>,

    #[structopt(short="a", long="attempts", help="The number of attempts to guess the word", default_value="10")]
    attempts: u32,

    #[structopt(short="d", long="debug", help="Show debug info")]
    debug: bool,
}
# }
```

---

# Ограничения на structopt

* Трудно дебъгване на грешки (доста compile-time магия)
* Липса на гъвкавост?
* В краен случай, може би решението е (използвания отдолу пакет) [clap](https://github.com/kbknapp/clap-rs)
* За по-прости неща, и [docopt](https://crates.io/crates/docopt) може да е удобен вариант

---

# Features

Може да си намалите малко броя dependencies, като премахнете default features:

```
[dependencies]
rand = "*"
structopt = { version = "*", default-features = false }
structopt-derive = "*"
```

Документацията е в clap: https://docs.rs/clap/*/clap/#features-enabled-by-default

---

# Версии

Окей е да използваме `*` за версия, когато си пишем кода -- конкретните версии се фиксират в `Cargo.lock`. Ако искаме да го публикуваме като пакет в crates.io, използвайки `cargo publish`, трябва да фиксираме конкретни версии, примерно:

```
[dependencies]
dirs = "2.0.2"
rand = "0.7.2"
structopt = { version = "0.3.5", default-features = false }
structopt-derive = "0.3.5"
```

Може да намерите плъгини за редакторите си, които да ви помогнат с избора на версии:

* VSCode: https://github.com/serayuzgur/crates
* Vim: https://github.com/mhinz/vim-crates

---

# Още полезни пакети

* [dirs](https://github.com/soc/dirs-rs) -- Заместител на `env::home_dir`, дава достъп до системни директории
* [lazy_static](https://github.com/rust-lang-nursery/lazy-static.rs) -- дефиниране на константи с код
* [serde](https://github.com/serde-rs/serde) -- за писане и четене на структурирани данни (конфигурация, например)
* [crossterm](https://github.com/crossterm-rs/crossterm), [cursive](https://github.com/gyscos/Cursive), [termion](https://github.com/redox-os/termion) -- повече контрол над терминали
* [human-panic](https://github.com/rust-cli/human-panic) -- защото човек и добре да живее, може да му panic-не кода
