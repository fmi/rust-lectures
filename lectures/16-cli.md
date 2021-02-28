---
title: Command-Line Interfaces
author: Rust@FMI team
speaker: Андрей Радев
date: 14 декември 2020
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

* Предизвикателство 3: https://fmi.rust-lang.bg/challenges/3
--
* Последна лекция за годината в сряда
--
* Домашно 3, може би? (За ваканцията + 1-2 седмици около)
--
* Проекти: Ще напишем един guide

---

# Hangman

### Demo 1

(Initial commit: 7aa860c0376710bf47c84a8758b24bb6a9d2362e)

Пълния код: [rust-hangman](https://github.com/AndrewRadev/rust-hangman)

---

# Преговор: IO типове и trait-ове

* `std::io::Read`, `std::io::Write`: Базови trait-ове за четене и писане
--
* `File`, `Stdin`, `&[u8]`, `BufReader` -- имплементират `Read`
* `BufReader` -- имплементира `BufRead`
--
* `File`, `Stdout` и `Stderr`, `Vec<u8>`, `BufWriter` -- имплементират `Write`

---

# Преговор: IO типове и trait-ове

Добре е да ползваме trait-ове когато можем.

```rust
# //ignore
impl InputFile {
    fn from(mut contents: impl io::Read) -> io::Result<InputFile> {
        // ...
    }

    // или:
    fn from<R: io::Read>(mut contents: R) -> io::Result<InputFile> {
        // ...
    }
}
```

Така, функцията `InputFile::from` може да се извика с файл, но може и със stdin, а може и просто със slice от байтове, идващи от някакъв тестов низ.

"Program to an interface, not an implementation" -- често срещан съвет, който често е прав.

---

# Странична бележка

"Program to an interface, not an implementation" -- не е *закон*, просто добър съвет.

* `File` vs `TcpStream`
* `File` vs `Vec<u8>`
* `File` vs `Stdin`/`Stdout`
* `File` -- няма име

---

# `String` vs `&str`

* `fn from_str(s: &str)` -> Защо `&str`, а не `String`?
--
* Със `&str` -- можем да извикаме функцията и със `&str`, и със `&String`
* `from_str("foobar")`
* `from_str(&String::from("foobar"))`
--
* Аналогично, обикновено използваме `&[T]` като вход на функция, а не `&Vec<T>`

---

# `PathBuf` и `Path`

--
* `std::path::PathBuf` -- стойност със ownership (като `String`, `Vec`)
* `std::path::Path` -- нейния "slice" тип (еквивалент на `&str`, `&[T]`)
--

```rust
# use std::path::{PathBuf,Path};
# fn main() {
let home_dir = PathBuf::from("/home/andrew");
println!("{:?}", home_dir);

let home_dir_slice: &Path = home_dir.as_path();
println!("{:?}", home_dir_slice);
# }
```

---

# `PathBuf` и `Path`

```rust
# use std::path::{PathBuf,Path};
# fn main() {
let file_path = PathBuf::from("/home/andrew/file.txt");
println!("{:?}", file_path);

let only_file: &Path = file_path.strip_prefix("/home/andrew").unwrap();
println!("{:?}", only_file);

let standalone_path: &Path = Path::new("file.txt");
println!("{:?}", standalone_path);
# }
```

---

# `PathBuf` и `Path`

```rust
# use std::path::Path;
# fn main() {
let file_path: &Path = Path::new("file.txt");

println!("{:?}", file_path.to_path_buf());
println!("{:?}", file_path.to_owned());
println!("{:?}", file_path.canonicalize());
# }
```

---

# `Debug` & `Display`

```rust
# use std::path::PathBuf;
# fn main() {
println!("{:?}", PathBuf::from("file.txt"));
# }
```
```rust
# use std::path::PathBuf;
# fn main() {
println!("{}", PathBuf::from("file.txt"));
# }
```

---

# `Debug` & `Display`

```rust
# use std::path::{PathBuf,Path};
# fn main() {
println!("{}", PathBuf::from("file.txt").display());
println!("{}", Path::new("file.txt").display());
# }
```

Пътищата на файловата система не са задължително UTF-8-кодирани. Как точно са кодирани зависи супер много от операционната система.

---

# Пътища и низове

* `pub fn as_os_str(&self) -> &OsStr` -- Връща ви низ, както е кодиран natively за операционната система.
* `pub fn to_str(&self) -> Option<&str>` -- Връща ви UTF-8 string slice, *ако е възможно* да се кодира като UTF-8.
* `pub fn to_string_lossy(&self) -> Cow<'_, str>` -- Връща ви низ с въпросчета за невалиден UTF-8 (U+FFFD: �).
--
* Ако искате да манипулирате пътища -- ползвате методите на `PathBuf` и `Path`.
* Ако искате да ги показвате на потребителя, викате им `.display()`.

---

# Полезни пакети

* [walkdir](https://crates.io/crates/walkdir): За ефективно обикаляне на файловата система.
* [dirs](https://crates.io/crates/directories): За намиране на "стандартни" директории в зависимост от операционната система.
* [directories](https://crates.io/crates/directories): Подобно на `dirs`, но включва и конфигурационни директории за инсталиране на приложения.

---

# Файлове

* `std::fs`
--
* `File::open` -- отваря път за четене
--
* `File::open<P: AsRef<Path>>(path: P) -> fs::Result<File>`
--
* `AsRef<Path>` -- нещо, което може евтино да се конвертира до `Path`, с метода `.as_ref()`
* `File::open(PathBuf::from("..."))`
* `File::open(Path::new("..."))`
* `File::open("...")`

---

# Файлове

* `File::create` -- отваря файл за писане
* Ако не съществува, ще го създаде, ако съществува, ще премахне съдържанието му

---

# Файлове

`fs::OpenOptions::new` -- отваря файл за четене, писане, append-ване, каквото ви душа иска

```rust
# //ignore
let file = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open("foo.txt");
```

---

# Файлове

`fs::read_to_string` -- най-лесния и удобен начин за четене на целия файл директно в низ. Ползвайте го смело за тестове, пък и не само. Понякога, просто знаете, че файла няма да е огромен и че ще ви трябва целия in-memory.

---

# Файлове

* `std::io::stdin() -> Stdin` -- имплементира `Read`
* `std::io::stdout() -> Stdout` -- имплементира `Write`
* `std::io::stderr() -> Stderr` -- имплементира `Write`
--
* Буферират се по редове -- при писане, може да ползвате `.flush()` за да изкарате нещо, което не е цял ред.
--
* Lock-ват се автомагично с мутекс, но можете ръчно да викнете `.lock()` за ексклузивен достъп.

---

# include макроси

* Четене на данни по време на компилация.
--
* `include_bytes!` -- набива някакъв файл в кода като статичен комплект от байтове (`&'static [u8; N]`).
* `include_str!` -- набива някакъв файл в кода като `&'static str`.
--

```rust
# //ignore
const MAIN_JS:    &'static str = include_str!("../res/js/main.js");
const MAIN_CSS:   &'static str = include_str!("../res/style/main.css");
const GITHUB_CSS: &'static str = include_str!("../res/style/github.css");
```

С `include_bin!` можете да вкарвате и други ресурси, като картинки, аудио...

---

# `std::env`

`env::args()` -- дава итератор по входа на програмата. Примерно:

```
$ cargo run one two three
```

```rust
# //ignore
use std::env;

fn main() {
    println!("{:?}", env::args().collect::<Vec<String>>());
    // => ["target/debug/scratch", "one", "two", "three"]

    use std::ffi::OsString;
    println!("{:?}", env::args_os().collect::<Vec<OsString>>());
    // => ["target/debug/scratch", "one", "two", "three"]
}
```

---

# `std::env`

`env::var()` -- достъп до environment променливи, може да извади грешка, ако не са валиден unicode, имат `\0` байтове и т.н. Ако супер много се налага, има `env::var_os()`.

```rust
# //ignore
if env::var("DEBUG").is_ok() {
    println!("Debug info: ...");
}
```

```
$ DEBUG=1 cargo run
```

---

# Hangman

### Demo 2

Пълния код: [rust-hangman](https://github.com/AndrewRadev/rust-hangman)

---

# Env logger

Удобен проект за по-сериозно log-ване: [env_logger](https://crates.io/crates/env_logger) + [log](https://crates.io/crates/log) (пример от друг проект, [rust-quickmd](https://github.com/AndrewRadev/rust-quickmd))

```rust
# //ignore
fn init_logging() {
    // Release logging:
    // - Warnings and errors
    // - No timestamps
    // - No module info
    #[cfg(not(debug_assertions))]
    env_logger::builder().
        default_format_module_path(false).
        default_format_timestamp(false).
        filter_level(log::LevelFilter::Warn).
        init();

    // Debug logging:
    // - All logs
    // - Full info
    #[cfg(debug_assertions)]
    env_logger::builder().
        filter_level(log::LevelFilter::Debug).
        init();
}
```

---

# Env logger

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
use structopt_derive::StructOpt;

#[derive(StructOpt, Debug)]
#[structopt(name="hangman", about="A game of Hangman")]
pub struct Options {
    #[structopt(short="w", long="wordlist", help="The path to a word list")]
    wordlist_path: Option<PathBuf>,

    #[structopt(short="a", long="attempts", help="The number of attempts to guess the word", default_value="10")]
    attempts: u32,

    #[structopt(short="d", long="debug", help="Show debug info")]
    debug: bool,
}
# }
```

---

# По-сложна обработка на аргументи чрез structopt

```
$ hangman --help
hangman 0.1.0
A game of Hangman

USAGE:
    hangman [FLAGS] [OPTIONS]

FLAGS:
    -d, --debug      Show debug info
    -h, --help       Prints help information
    -V, --version    Prints version information

OPTIONS:
    -a, --attempts <attempts>         The number of attempts to guess the word [default: 10]
    -w, --wordlist <wordlist-path>    The path to a word list
```

(С `cargo run` ще е `cargo run -- --help`)

---

# Ограничения на structopt

* Трудно дебъгване на грешки (доста compile-time магия)
* Липса на гъвкавост?
* В краен случай, може би решението е (използвания отдолу пакет) [clap](https://github.com/kbknapp/clap-rs)
* За по-прости неща, и [docopt](https://crates.io/crates/docopt) може да е удобен вариант

---

# Локално инсталиране на пакет

* `cargo install --path .`
* Инсталира нещата в `~/.cargo/bin/`
* `hangman -w wordlist.txt`
* Може да имаме повече от един executable file. Слагаме ги в `src/bin/`, всеки си има собствен main. Може да ги викаме локално със `cargo run --bin <име-на-файла>`, а при cargo install ще си се инсталират като отделни binary-та. Пример от друг проект: [rust-id3-image](https://github.com/AndrewRadev/id3-image/blob/master/src)

---

# Features

Може да си намалите малко броя dependencies, като премахнете default features:

```
[dependencies]
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

* [lazy_static](https://github.com/rust-lang-nursery/lazy-static.rs) -- дефиниране на константи с код
* [serde](https://github.com/serde-rs/serde) -- за писане и четене на структурирани данни (конфигурация, например)
* [crossterm](https://github.com/crossterm-rs/crossterm), [cursive](https://github.com/gyscos/Cursive), [termion](https://github.com/redox-os/termion) -- повече контрол над терминали
* [human-panic](https://github.com/rust-cli/human-panic) -- защото човек и добре да живее, може да му panic-не кода
