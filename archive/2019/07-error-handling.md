---
title: Справяне с грешки
author: Rust@FMI team
speaker: Андрей Радев
date: 25 октомври 2018
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
* Първо домашно тече, пускайте го рано!
--
* Въпроси по условието -- тук или в discord
--
* Пишете си тестове

---

# Преговор

--
* Generics (мономорфизация)
--
* Traits (като интерфейси, необходими за практическа употреба на generics)
--
* Асоциирани типове в trait-ове

---

# Конвертиране

<img src="images/universal_converter_box.png">

---

# Конвертиране

```rust
# //ignore
# fn main() {
struct Celsius(f64);
struct Fahrenheit(f64);
struct Kelvin(f64);

fn room_temperature() -> Fahrenheit {
    Fahrenheit(68.0)
}
# }
```

---

# Конвертиране

```rust
# //ignore
# fn main() {
struct Celsius(f64);
struct Fahrenheit(f64);
struct Kelvin(f64);

fn room_temperature() -> Fahrenheit {
    Fahrenheit(68.0)
}

fn energy_to_heat_water(from: Kelvin, to: Kelvin, mass: f64) -> f64 {
    // whatever
}
# }
```

---

# Конвертиране

### From

```rust
# //ignore
# fn main() {
impl From<Celsius> for Kelvin {
    fn from(t: Celsius) -> Kelvin { Kelvin(t.0 + 273.15) }
}

impl From<Fahrenheit> for Celsius {
    fn from(t: Fahrenheit) -> Celsius { Celsius((t.0 - 32) / 1.8) }
}

impl From<Fahrenheit> for Kelvin {
    fn from(t: Fahrenheit) -> Kelvin { Kelvin::from(Celsius::from(t)) }
}
# }
```

---

# Конвертиране

### From

Сега вече можем да си сварим яйца

```rust
# //ignore
# fn main() {
let e = energy_to_heat_water(
    Kelvin::from(room_temperature()),
    Kelvin::from(Celsius(100.0)),
    1.0
);
println!("Heating water will cost {}J", e);
# }
```

---

# Конвертиране

### From

```rust
# //ignore
# fn main() {
pub trait From<T> {
    fn from(T) -> Self;
}
# }
```

--
* `From<T> for U` конвертира от `T` до `U`
* `From<T> for T` е имплементирано автоматично
* Конвертирането не може да се провали

---

# Конвертиране

### Into

* `U::from(t)` е дълго за писане
* Затова съществува "реципрочен" метод

```rust
# //ignore
# fn main() {
pub trait Into<T> {
    fn into(self) -> T;
}
# }
```

--
* `Into<U> for T` конвертира от `T` до `U`
--
* `Into<T> for T` е имплементирано автоматично
--
* `Into<U> for T` се имплементира автоматично като имплементираме `From<T> for U`
* Практиката е ръчно да се имплементира `From`

---

# Конвертиране

### Into

```rust
# //ignore
impl From<Celsius> for Kelvin {
```

Е еквивалентно на:

```rust
# //ignore
impl Into<Kelvin> for Celsius {
```

---

# Конвертиране

### Into

```rust
# //ignore
# fn main() {
// използвайки From
let e = energy_to_heat_water(
    Kelvin::from(room_temperature()),
    Kelvin::from(Celsius(100.0)),
    1.0
);

// използвайки Into
let e = energy_to_heat_water(
    room_temperature().into(),
    Celsius(100.0).into(),
    1.0
);
# }
```

---

# Конвертиране

### Generics

Честа практика е библиотечни функции да не взимат <code>T</code>, а нещо което може да се конвертира до <code>T</code>

```rust
# //ignore
# fn main() {
fn energy_to_heat_water<T1, T2>(from: T1, to: T2, mass: f64) -> f64
where
    T1: Into<Kelvin>,
    T2: Into<Kelvin>
{
    let from = from.into();
    let to   = to.into();
    // whatever
}

let e = energy_to_heat_water(room_temperature(), Celsius(100.0), 1.0);
# }
```

---

# String parsing

--
* Ами ако искаме да създадем обект от низ? (от JSON низ, от XML)
--
* Не можем да използваме `From`, защото не сме сигурни че създаването ще е успешно
* Има специален trait за това

---

# String parsing

### FromStr

```rust
# //ignore
# fn main() {
trait FromStr {
    type Err;

    fn from_str(s: &str) -> Result<Self, Self::Err>;
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}
# }
```

* Конвертиране от низ до наш си тип
* Връща `Result` който показва дали конвертирането е успешно

---

# String parsing

### FromStr

```rust
# fn main() {
use std::str::FromStr;

let x = i32::from_str("-13");
let y = u8::from_str("323");
let z = f32::from_str("5e-3");

println!("{:?}\n{:?}\n{:?}", x, y, z);
# }
```

---

# String parsing

### parse

Има и по-ергономичен начин

```rust
# //ignore
# fn main() {
trait FromStr {
    type Err;
    fn from_str(s: &str) -> Result<Self, Self::Err>;
}

impl str {
    fn parse<F: FromStr>(&self) -> Result<F, <F as FromStr>::Err> { ... }
}
# }
```

* Типа `<F as FromStr>::Err` е "типа `Err`, който е дефиниран за `FromStr` имплементацията на `F`"
--
* Generic параметъра F трябва да имплементира `FromStr` (подобно на `Into` за `From`)
--
* Метода `parse` е имплементиран върху `str`
--
* Метода `parse` е generic по *return* стойността си

---

# String parsing

### parse

```rust
# fn main() {
let x = "-13".parse::<i32>();
let y = "323".parse::<u8>();
let z = "5e-3".parse::<f32>();

println!("{:?}\n{:?}\n{:?}", x, y, z);
# }
```

---

# String parsing

### parse

```rust
# use std::str::FromStr;
# fn main() {
let x: Result<i32, <i32 as FromStr>::Err> = "-13".parse();
let y: Result<u8, <u8 as FromStr>::Err>   = "323".parse();
let z: Result<f32, <f32 as FromStr>::Err> = "5e-3".parse();

println!("{:?}\n{:?}\n{:?}", x, y, z);
# }
```

---

# String parsing

### parse

```rust
# fn main() {
let x: Result<i32, _> = "-13".parse();
let y: Result<u8, _>  = "323".parse();
let z: Result<f32, _> = "5e-3".parse();

println!("{:?}\n{:?}\n{:?}", x, y, z);
# }
```

---

# String parsing

### parse

```rust
# //ignore
use std::str::FromStr;

#[derive(Debug)]
struct Potato {
    is_a_potato: bool,
}
```

---

# String parsing

### parse

```rust
# use std::str::FromStr;
# #[derive(Debug)]
# struct Potato {
#     is_a_potato: bool,
# }
# fn main() {
impl FromStr for Potato {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        if s == "картоф" {
            Ok(Potato { is_a_potato: true })
        } else {
            Err(String::from("what is this even"))
        }
    }
}
# }
```

---

# String parsing

### parse

```rust
# use std::str::FromStr;
# #[derive(Debug)]
# struct Potato {
#     is_a_potato: bool,
# }
# impl FromStr for Potato {
#     type Err = String;
#     fn from_str(s: &str) -> Result<Self, Self::Err> {
#         if s == "картоф" {
#             Ok(Potato { is_a_potato: true })
#         } else {
#             Err(String::from("what is this even"))
#         }
#     }
# }
fn main() {
    let p1: Result<Potato, _> = "картоф".parse();
    let p2: Result<Potato, _> = "патладжан".parse();

    println!("{:?}\n{:?}", p1, p2);
}
```

---

# String parsing

### parse

```rust
# use std::str::FromStr;
# #[derive(Debug)]
# struct Potato {
#     is_a_potato: bool,
# }
# impl FromStr for Potato {
#     type Err = String;
#     fn from_str(s: &str) -> Result<Self, Self::Err> {
#         if s == "картоф" {
#             Ok(Potato { is_a_potato: true })
#         } else {
#             Err(String::from("what is this even"))
#         }
#     }
# }
fn main() {
    let p1 = "картоф".parse::<Potato>();
    let p2 = "патладжан".parse::<Potato>();

    println!("{:?}\n{:?}", p1, p2);
}
```

---

# Error handling

--

```rust
# //ignore
use std::fs::File;
use std::io::Read;

fn main() {
    let mut file = File::open("deep_quotes.txt");

    let mut contents = String::new();
    file.read_to_string(&mut contents);

    println!("{}", contents);
}
```

---

# Error handling

```rust
use std::fs::File;
use std::io::Read;

fn main() {
    let mut file = File::open("deep_quotes.txt");

    let mut contents = String::new();
    file.read_to_string(&mut contents);

    println!("{}", contents);
}
```

---

# Error handling

```rust
# //ignore
enum Result<T, E> {
    Ok(T),
    Err(E),
}

File::open("excellent_file.txt")
    // => Ok(std::fs::File)
File::open("broken_file.txt")
    // => Err(std::io::Error)
```

---

# Error handling

```rust
use std::fs::File;
use std::io::Read;

fn main() {
# let file_contents = "Failure is just success rounded down, my friend!\n";
# std::fs::write("deep_quotes.txt", file_contents.as_bytes()).unwrap();
    let mut file = match File::open("deep_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };

    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();
    println!("{}", contents);
}
```

---

# Error handling

```rust
use std::fs::File;
use std::io::Read;

fn main() {
    let mut file = match File::open("shallow_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };

    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();
    println!("{}", contents);
}
```

---

# Error handling

```rust
# use std::fs::File;
# use std::io::Read;
fn main() {
# let file_contents = "Failure is just success rounded down, my friend!\n";
# std::fs::write("deep_quotes.txt", file_contents.as_bytes()).unwrap();
# let file_contents = "F a i l u r e  i s  j u s t  s u c c e s s  r o u n d e d  d o w n ,  m y  f r i e n d !\n";
# std::fs::write("wide_quotes.txt", file_contents.as_bytes()).unwrap();
    let mut deep = match File::open("deep_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };
    let mut wide = match File::open("wide_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };

    let mut contents = String::new();
    deep.read_to_string(&mut contents).unwrap();
    wide.read_to_string(&mut contents).unwrap();
    println!("{}", contents);
}
```

---

# Error handling

```rust
# use std::fs::File;
# use std::io::Read;
fn main() {
# let file_contents = "Failure is just success rounded down, my friend!\n";
# std::fs::write("deep_quotes.txt", file_contents.as_bytes()).unwrap();
# let file_contents = "F a i l u r e  i s  j u s t  s u c c e s s  r o u n d e d  d o w n ,  m y  f r i e n d !\n";
# std::fs::write("wide_quotes.txt", file_contents.as_bytes()).unwrap();
    all_your_quotes_are_belong_to_us();
}

fn all_your_quotes_are_belong_to_us() {
    let mut deep = match File::open("deep_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };
    let mut wide = match File::open("wide_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };

    let mut contents = String::new();
    deep.read_to_string(&mut contents).unwrap();
    wide.read_to_string(&mut contents).unwrap();
    println!("{}", contents);
}
```

---

# Error handling

```rust
# use std::fs::File;
# use std::io::{self, Read};
fn main() {
# let file_contents = "Failure is just success rounded down, my friend!\n";
# std::fs::write("deep_quotes.txt", file_contents.as_bytes()).unwrap();
# let file_contents = "F a i l u r e  i s  j u s t  s u c c e s s  r o u n d e d  d o w n ,  m y  f r i e n d !\n";
# std::fs::write("wide_quotes.txt", file_contents.as_bytes()).unwrap();
    match all_your_quotes_are_belong_to_us() {
        Ok(contents) => println!("{}", contents),
        Err(e) => panic!("😞 {}", e),
    }
}

fn all_your_quotes_are_belong_to_us() -> Result<String, io::Error> {
    let mut deep = match File::open("deep_quotes.txt") {
        Ok(f) => f,
        Err(e) => return Err(e),
    };
    let mut wide = match File::open("wide_quotes.txt") {
        Ok(f) => f,
        Err(e) => return Err(e),
    };

    let mut contents = String::new();
    deep.read_to_string(&mut contents).unwrap();
    wide.read_to_string(&mut contents).unwrap();
    Ok(contents)
}
```

---

# Error handling

### A wild macro appears

```rust
# //ignore
macro_rules! try {
    ($expr:expr) => {
        match $expr {
            Ok(result) => result,
            Err(e) => return Err(e),
        }
    }
}
```

---

# Error handling

```rust
# use std::fs::File;
# use std::io::{self, Read};
fn main() {
# let file_contents = "Failure is just success rounded down, my friend!\n";
# std::fs::write("deep_quotes.txt", file_contents.as_bytes()).unwrap();
# let file_contents = "F a i l u r e  i s  j u s t  s u c c e s s  r o u n d e d  d o w n ,  m y  f r i e n d !\n";
# std::fs::write("wide_quotes.txt", file_contents.as_bytes()).unwrap();
    match all_your_quotes_are_belong_to_us() {
        Ok(contents) => println!("{}", contents),
        Err(e) => panic!("😞 {}", e),
    }
}

fn all_your_quotes_are_belong_to_us() -> Result<String, io::Error> {
    let mut deep = try!(File::open("deep_quotes.txt"));
    let mut wide = try!(File::open("wide_quotes.txt"));

    let mut contents = String::new();
    deep.read_to_string(&mut contents).unwrap();
    wide.read_to_string(&mut contents).unwrap();

    Ok(contents)
}
```

---

# Error handling

### А без онзи `unwrap`?

```rust
# //ignore
# use std::fs::File;
# use std::io::Read;
fn main() {
# let file_contents = "Failure is just success rounded down, my friend!\n";
# std::fs::write("deep_quotes.txt", file_contents.as_bytes()).unwrap();
# let file_contents = "F a i l u r e  i s  j u s t  s u c c e s s  r o u n d e d  d o w n ,  m y  f r i e n d !\n";
# std::fs::write("wide_quotes.txt", file_contents.as_bytes()).unwrap();
    let mut file = match File::open("deep_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };

    let mut contents = String::new();
    file.read_to_string(&mut contents); //.unwrap()

    println!("{}", contents);
}
```

---

# Error handling

### А без онзи `unwrap`?

```rust
# use std::fs::File;
# use std::io::Read;
fn main() {
# let file_contents = "Failure is just success rounded down, my friend!\n";
# std::fs::write("deep_quotes.txt", file_contents.as_bytes()).unwrap();
    let mut file = match File::open("deep_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };

    let mut contents = String::new();
    file.read_to_string(&mut contents); //.unwrap()

    println!("{}", contents);
}
```

---

# Error handling

### А без онзи `unwrap`?

```rust
# use std::fs::File;
# use std::io::Read;
fn main() {
# let file_contents = "Failure is just success rounded down, my friend!\n";
# std::fs::write("deep_quotes.txt", file_contents.as_bytes()).unwrap();
    let mut file = match File::open("deep_quotes.txt") {
        Ok(f) => f,
        Err(e) => panic!("😞 {}", e),
    };

    let mut contents = String::new();
    let _ = file.read_to_string(&mut contents); // Result<usize, io::Error>

    println!("{}", contents);
}
```

---

# Error handling

```rust
# //ignore
fn main() {
    match all_your_quotes_are_belong_to_us() {
        Ok(contents) => println!("{}", contents),
        Err(e) => panic!("😞 {}", e),
    }
}

fn all_your_quotes_are_belong_to_us() -> Result<String, io::Error> {
    let mut deep = try!(File::open("deep_quotes.txt"));
    let mut wide = try!(File::open("wide_quotes.txt"));

    let mut contents = String::new();
    try!(deep.read_to_string(&mut contents));
    try!(wide.read_to_string(&mut contents));

    Ok(contents)
}
# }
```

---

# Error handling

### Въпрос

```rust
# //ignore
// ??

fn main() {
    try!(all_your_quotes_are_belong_to_us());
}
```

---

# Error handling

### Въпрос

```rust
# fn all_your_quotes_are_belong_to_us() -> Result<(), String> {
#   println!("Bla-bla failure success");
#   Ok(())
# }
fn main() {
    try!(all_your_quotes_are_belong_to_us());
}
```

---

# Error handling

### Въпрос

```rust
# fn all_your_quotes_are_belong_to_us() -> Result<(), String> {
#   println!("Bla-bla failure success");
#   Ok(())
# }
fn main() -> Result<(), String> {
    try!(all_your_quotes_are_belong_to_us());
    println!("This is okay");
    Ok(())
}
```

---

# Error handling

### Въпрос

```rust
# fn all_your_quotes_are_belong_to_us() -> Result<(), String> {
#   println!("Bla-bla failure success");
#   Ok(())
# }
fn main() -> Result<(), String> {
    try!(all_your_quotes_are_belong_to_us());
    Err(String::from("All your Err are belong to us"))
}
```

---

# Error handling

А ако не са всичките грешки io::Error?

---

# Error handling

```rust
# use std::fs::File;
# use std::io::{self, Read};
fn all_your_numbers_are_belong_to_us() -> Result<i32, io::Error> {
    let mut numbers = try!(File::open("numbers.txt"));

    let mut contents = String::new();
    try!(numbers.read_to_string(&mut contents));

    let n =
        match contents.lines().next() {
            Some(first_line) => try!(first_line.parse::<i32>()),
            None => 0,
        };
    Ok(n)
}

fn main() {
    println!("{:?}", all_your_numbers_are_belong_to_us());
}
```

---

# Error handling

```rust
# //ignore
# fn main() {
macro_rules! try {

    ($expr:expr) => {
        match $expr {
            Ok(n) => n,
            //Err(e) => return Err(e),
            Err(e) => return Err(e.into()),
        }
    }

}
# }
```

---

# Error handling

```rust
# //ignore
# fn main() {
struct FancyError { message: String }

impl From<io::Error> for FancyError {
    fn from(e: io::Error) -> Self {
        FancyError { message: format!("IO Error: {}", e) }
    }
}

impl From<num::ParseIntError> for FancyError {
    fn from(e: num::ParseIntError) -> Self {
        FancyError { message: format!("ParseError: {}", e) }
    }
}
# }
```

---

# Error handling

```rust
# //ignore
# fn main() {
fn all_your_numbers_are_belong_to_us() -> Result<i32, FancyError> {
    let mut numbers = try!(File::open("numbers.txt"));

    let mut contents = String::new();
    try!(numbers.read_to_string(&mut contents));

    let n =
        match contents.lines().next() {
            Some(first_line) => try!(first_line.parse::<i32>()),
            None => 0,
        };

    Ok(n)
}
# }
```

---

# Error handling

`try!` използва твърде много скоби и удивителни. И е deprecated.

```rust
# //ignore
# fn main() {
fn all_your_quotes_are_belong_to_us() -> Result<String, io::Error> {
    let mut deep = try!(File::open("deep_quotes.txt"));
    let mut wide = try!(File::open("wide_quotes.txt"));

    let mut contents = String::new();
    try!(deep.read_to_string(&mut contents));
    try!(wide.read_to_string(&mut contents));

    Ok(contents)
}
# }
```

---

# Error handling

Има по-прост синтаксис:

```rust
# //ignore
# fn main() {
fn all_your_quotes_are_belong_to_us() -> Result<String, io::Error> {
    let mut deep = File::open("deep_quotes.txt")?;
    let mut wide = File::open("wide_quotes.txt")?;

    let mut contents = String::new();
    deep.read_to_string(&mut contents)?;
    wide.read_to_string(&mut contents)?;

    Ok(contents)
}
# }
```

---

# Error handling

(Има и по-прост метод за четене на файлове:)

```rust
# //norun
use std::fs;
use std::io;

# #[allow(dead_code)]
fn all_your_quotes_are_belong_to_us() -> Result<String, io::Error> {
    let mut quotes = String::new();
    quotes.push_str(&fs::read_to_string("deep_quotes.txt")?);
    quotes.push_str(&fs::read_to_string("wide_quotes.txt")?);
    Ok(quotes)
}
# fn main() {
# }
```

---

# Error handling

### методи върху Result

```rust
# //ignore
# fn main() {
let mut fun = File::open("fun.txt").
    or_else(|_error| File::open("passable.txt")).
    or_else(|_error| File::open("okay_i_guess.txt"))?;
# }
```

---

# Error handling

### методи върху Result

```rust
# //ignore
# fn main() {
let optional_fun = File::open("fun.txt").
    or_else(|_error| File::open("passable.txt")).
    or_else(|_error| File::open("okay_i_guess.txt"));

if let Ok(mut fun) = optional_fun {
    // Super-special Fun Time!
}
# }
```

---

# Error handling

### методи върху Result

```rust
# //ignore
# fn main() {
if let Err(_) = some_side_effects() {
    // Едно warning-че, да се знае...
}
# }
```

---

# Error handling

### методи върху Result

```rust
# //ignore
# fn main() {
let number = "-13".parse::<i32>().unwrap();
let number = "foo".parse::<i32>().unwrap(); // BOOM!

let number = "-13".parse::<i32>().expect("BOOM!");
let number = "foo".parse::<i32>().expect("BOOM!"); // BOOM!

let number = "-13".parse::<i32>().unwrap_or(0);
let number = "foo".parse::<i32>().unwrap_or(0); // 👌

let number = "foo".parse::<i32>().unwrap_or_else(|e| {
    println!("Warning: couldn't parse: {}", e);
    0
});
# }
```

---

# Panic

Виждали сме panic:

--
* `panic!("something terrible happened")`
--
* `assert_eq!(1, 2)`
--
* `None.unwrap()`

---

# Panic

### Какво прави паниката

--
* работи на ниво нишки
--
* терминира нишката в която е извикана и изписва съобщение за грешка
--
* unwind-ва стека (по подразбиране, може да се променя при компилация)
--
* при паника в главната нишка се прекратява цялата програма

--
* паниките не могат да бъдат хванати (няма catch)
--
* (освен ако много, много не искаме, но това е за специални случаи)

---

# Panic

### Кога?

--
* грешки в логиката на програмата
* (или при използване на библиотека)
--
* които **не зависят** от user input
* и няма смисъл да се опитаме да се възстановим от тях

--
* тестове
* примери
* rapid prototyping

---

# Error handling

### Обобщение

Грешките в rust се разделят на два вида
--
* такива от които можем да се възстановим - `Result`, `Option`, etc
--
* такива от които не можем да се възстановим - `panic!`
--
* `unreachable!()`, `unimplemented!()` са от втория тип
--
* няма exceptions!

---

# Интересни пакети

- Failure: https://github.com/rust-lang-nursery/failure
- Fehler: https://github.com/withoutboats/fehler
- Thiserror: https://github.com/dtolnay/thiserror

---

# Read & Write

Има стандартни типажи, които ни помагат за четене и писане

---

# Read & Write

### `std::io::Read`

Един от тях е <code>Read</code>

```rust
# //ignore
# fn main() {
pub trait Read {
    // Required:
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize>;

    // Provided:
    fn read_to_end(&mut self, buf: &mut Vec<u8>) -> io::Result<usize> { ... }
    fn read_to_string(&mut self, buf: &mut String) -> io::Result<usize> { ... }
    fn read_exact(&mut self, buf: &mut [u8]) -> io::Result<()> { ... }
    fn by_ref(&mut self) -> &mut Self where Self: Sized { ... }
    fn bytes(self) -> Bytes<Self> where Self: Sized { ... }
    fn chain<R: Read>(self, next: R) -> Chain<Self, R> where Self: Sized { ... }
    fn take(self, limit: u64) -> Take<Self> where Self: Sized { ... }

    // +nightly:
    unsafe fn initializer(&self) -> Initializer { ... }
}
# }
```

---

# Read & Write

### Бележка:

В модула `std::io` има следната дефиниция:

```rust
# //ignore
type Result<T> = Result<T, Error>;
```

Този синтаксис дефинира type alias ("тип-синоним"). Типа `std::io::Result<T>` е еквивалентен на `Result<T, std::io::Error>`.

Това се използва за улеснение, и спокойно може да use-нем `std::io` и да адресираме `io::Result<usize>` без да указваме типа за грешка -- той вече е конкретизиран в alias-а.

---

# Read

Имплементира се за някои очаквани структури

```rust
# //ignore
# fn main() {
impl Read for File
impl Read for Stdin
impl Read for TcpStream
# }
```

---

# Read

Видяхме как може да четем от файл, а сега и от Stdin

```rust
# //ignore
# fn main() {
use std::io::{self, Read};

let mut buffer = String::new();
io::stdin().read_to_string(&mut buffer)?;
# }
```

---

# Read & Write

### `std::io::Write`

За писане се използва <code>Write</code>

```rust
# //ignore
# fn main() {
pub trait Write {
    // Required:
    fn write(&mut self, buf: &[u8]) -> io::Result<usize>;
    fn flush(&mut self) -> io::Result<()>;

    // Provided:
    fn write_all(&mut self, buf: &[u8]) -> io::Result<()> { ... }
    fn write_fmt(&mut self, fmt: Arguments) -> io::Result<()> { ... }
    fn by_ref(&mut self) -> &mut Self where Self: Sized { ... }
}
# }
```

---

# Write

Както <code>Read</code> се имплементира за очаквани структури

```rust
# //ignore
# fn main() {
impl Write for File
impl Write for Stdout
impl Write for Stderr
impl Write for TcpStream
impl Write for Vec<u8>
# }
```

---

# Write

```rust
# //ignore
# fn main() {
use std::fs::File;
use std::io::Write;

let mut f = File::create("foo.txt")?;
f.write_all(b"Hello, world!")?;
# }
```

---

# Read & Write

Като цяло са интуитивни, но не винаги ефективни когато правим много, но малки операции

---

# BufReader & BufWriter

--
* Затова са създадени <code>BufReader</code> и <code>BufWriter</code>
--
* Използват се да буферират операциите, както се досещате от имената им

---

# BufReader & BufWriter

### `std::io::BufReader`

<code>BufReader</code> е wrapper за структури, които имплементират <code>Read</code>

```rust
use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn main() -> Result<(), std::io::Error> {
# std::fs::write("log.txt", b"Some stuff").unwrap();
    let f = File::open("log.txt")?;
    let mut reader = BufReader::new(f);

    let mut line = String::new();
    let len = reader.read_line(&mut line)?;
    println!("First line is {} bytes long", len);
    Ok(())
}
```

---

# BufReader & BufWriter

### std::io::BufRead

Тук се появява нов метод <code>read_line</code>:

```rust
# //ignore
# fn main() {
pub trait BufRead: Read {
    // Required:
    fn fill_buf(&mut self) -> io::Result<&[u8]>;
    fn consume(&mut self, amt: usize);

    // Provided:
    fn read_until(&mut self, byte: u8, buf: &mut Vec<u8>) -> io::Result<usize> { ... }
    fn read_line(&mut self, buf: &mut String) -> io::Result<usize> { ... }
    fn split(self, byte: u8) -> Split<Self> where Self: Sized { ... }
    fn lines(self) -> Lines<Self> where Self: Sized { ... }
}
# }
```

---

# BufReader & BufWriter

### BufWriter

Подобно, <code>BufWriter</code> е wrapper за структури, които имплементират <code>Write</code>

```rust
# //ignore
# fn main() {
use std::io::prelude::*;
use std::io::BufWriter;
use std::net::TcpStream;

let mut stream = BufWriter::new(TcpStream::connect("127.0.0.1:34254").unwrap());

for i in 1..10 {
    stream.write(&[i]).unwrap();
}
# }
```

В този пример чрез <code>BufWriter</code> превръщаме 10 system calls в 1

---

# BufReader & BufWriter

### BufWrite

Сори, няма <code>BufWrite</code> :(

---

# BufReader & BufWriter

* `Read`: Trait, който е имплементиран от файлове, сокети, и т.н., за четене на брой байтове.
* `BufReader`: Структура, която обвива нещо, което е `Read`, която **също e** `Read` и която имплементира `BufRead`.
* `BufRead`: Trait за структури като `BufReader`, които четат, буферирайки.
--
<hr>
* `Write`: Trait, който е имплементиран от файлове, сокети, и т.н., за писане на брой байтове.
* `BufWriter`: Структура, която обвива нещо, което е `Write`, която **също e** `Write` и която позволява буферирано писане
* `BufWrite`: Не съществува :/.

---

# Read & Write

<code>Write</code> може да се използва и за тестване чрез <code>mock</code>

```rust
# //ignore
# fn main() {
fn write_u8<W>(writer: &mut W, data: u8) -> io::Result<usize>
where W: Write {
    // Do cool stuff with `writer`
}

#[test]
fn test_write_u8() {
    let mut mock: Vec<u8> = Vec::new();

    write_u8(&mut mock, 42).unwrap();

    assert_eq!(mock.len(), 1);
    assert_eq!(mock[0], 42);
}
# }
```
