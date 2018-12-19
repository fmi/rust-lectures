---
title: Входни данни, CLI
author: Rust@FMI team
date: 27 ноември 2018
lang: bg
keywords: rust,fmi
# description:
slide-width: 80%
font-size: 20px
font-family: Arial, Helvetica, sans-serif
# code blocks color theme
code-theme: github
---

# Административни неща

--
* Домашно 2 приключи
--
* RustFest Rome!

---

# Преговор

### Event emitter

--
* HashMap
--
* Връщане и съхраняване на функции
--
* impl Trait
--
* Borrow
--
* TCP demo
--
* Една торба ръбове и фиксове

---

# Домашно 2

### Demo

--
* floating-point сравнения
--
* [approx](https://docs.rs/approx/latest/approx/)
--
* [quickheck](https://github.com/BurntSushi/quickcheck)

---

# Hangman

### Demo

Пълния код: [rust-hangman](https://github.com/AndrewRadev/rust-hangman)

---

# Данни за играта?

--
* От предефиниран път на системата -- `$HOME/.hangman_words.txt` (`dirs::home_dir`, от пакета [dirs](https://github.com/soc/dirs-rs))
--
* От аргументите на командния ред -- `$ hangman wordlist.txt` (`std::env::{args, args_os}`)
--
* Вградени в binary-то (`include_str!`, `include_bin!`)

---

# Локално инсталиране на пакет

--
* `cargo install`, а ако вече е било викнато, `cargo install --force`
--
* Инсталира нещата в `~/.cargo/bin/`
--
* `hangman wordlist.txt`

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

--
* Трудно дебъгване на грешки (доста магия)
--
* Липса на гъвкавост?
--
* В краен случай, може би решението е (използвания отдолу пакет) [clap](https://github.com/kbknapp/clap-rs)

---

# Още полезни пакети

--
* [clap](https://github.com/kbknapp/clap-rs) -- по-сложен command-line parsing, мощен, доста за четене
--
* [path](https://github.com/soc/dirs-rs) -- Заместител на `env::home_dir`, дава достъп до системни директории
--
* [lazy_static](https://github.com/rust-lang-nursery/lazy-static.rs) -- дефиниране на константи с код
--
* [serde](https://github.com/serde-rs/serde) -- за писане и четене на структурирани данни
