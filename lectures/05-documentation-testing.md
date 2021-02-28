---
title: Те(к)стови работи
description: |
    низове, тестване и една торба с инструменти
    (най-рошавата лекция в курса (засега))
author: Rust@FMI team
speaker: Никола Стоянов
date: 21 октомври 2020
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 20px
font-family: Arial, Helvetica, sans-serif
# code blocks color theme
code-theme: github
---

# Преговор

### Енумерации

```rust
# #[allow(path_statements)]
# fn main() {
enum Message {
    Quit,
    Move { x: i64, y: i64 },
    Write(String),
    ChangeColor(i64, i64, i64),
}

Message::Quit;
Message::Move { x: 3, y: 4 };
Message::Write(String::from("baba"));
Message::ChangeColor(255, 0, 0);
# }
```

---

# Преговор

### Съпоставяне на образци (pattern matching)

```rust
# fn main() {
# #[allow(dead_code)]
# enum Message {
#     Quit,
#     Move { x: i64, y: i64 },
#     Write(String),
#     ChangeColor(u8, u8, u8),
# }
#
let message = Message::Move { x: 1, y: 3 };

match message {
    Message::Quit => println!("What a quitter!"),
    Message::Move { x, y } => println!("Going to ({}, {})!", x, y),
    Message::Write(_) => println!("Pfff.. whatevs"),
    Message::ChangeColor(_, _, b) if b > 200 => println!("So much blue!"),
    _ => println!("Don't care."),
}
# }
```

---

# Преговор

### Option и представяне на липсваща стойност

```rust
# fn main() {
enum Option<T> {
    Some(T),
    None,
}
# }
```

---

# Преговор

### Refutable/Irrefutable patterns

```rust
# #[allow(unused_variables)]
# fn main() {
let (a, b) = (1, 2); // -> Irrefutable pattern

if let Some(val) = Some(5) { // -> Refutable pattern
    println!("Okay!");
}
# }
```

---

# Административни неща

- първото домашно е пуснато
--
- https://fmi.rust-lang.bg/tasks/1
--
- срок - една седмица (до 28.10.2020 17:00)

---

# Съдържание

![](images/bag-of-tools.jpg)

---

# Кодиране на низове

---

# Кодиране на низове

### ASCII

--
- един от по-ранните стандарти за кодиране
--
- 128 символа, кодирани с числа от 0 до 127
    - 32 контролни символа
    - 96 - латинската азбука, арабските цифри и най-често използваната пунктуация
--
- недостатък - много ограничен набор от символи

---

# Кодиране на низове

### Кодови таблици

--
- разширение на ASCII
--
- 256 символа, кодирани с числа от 0 до 255
    - 0 до 127 - ascii
    - 128 до 255 - други символи (зависи от таблицата)
--
- появили са се много (стотици) разширени таблици с кодове за различни случаи
--
- например: [latin-1](https://en.wikipedia.org/wiki/ISO/IEC_8859-1), [windows-1251](https://en.wikipedia.org/wiki/Windows-1251), [cp437](https://en.wikipedia.org/wiki/Code_page_437), ...

---

# Кодиране на низове

### Кодови таблици

Недостатъци:

--
- много ограничен набор от символи в една таблица - трябва да се използват различни таблици
--
- ако не знаем с коя таблица е кодиран низа, не знаем какви символи съдържа
--
- никой не казва с коя таблица е кодиран низа

---

# Кодиране на низове

### Unicode

--
- стандарт, създаден да оправи цялата тази бъркотия
--
- голяма таблица която съдържа всички символи
--
- дефинира съответствие от число (code point) до символ
--
- ℕ → символ
--
- не дефинира как да се кодира числото (code point-а) като битове

---

# Кодиране на низове

### Chars

- типа `char` в Rust означава unicode code point
--
- пример:
  Code: U+044F
  Glyph: я
  Description: Cyrillic Small Letter Ya

```rust
# fn main() {
println!("0x{:x}", 'я' as u32);

use std::char;
println!("{:?}", char::from_u32(0x044f));
# }
```

---

# Кодиране на низове

### UTF-32

- всеки символ се кодира с 32-битово число - стойността на code point-а
--
- все едно `Vec<char>`

---

# Кодиране на низове

### UTF-16

--
- всеки символ се кодира с едно или две 16-битови числа
--
- използва се в Windows API-та
--
- и за вътрешна репрезентация на низове в някои езици (напр. Java, JavaScript)

---

# Кодиране на низове

### UTF-8

--
- символите се кодират с 1, 2, 3 или 4 байта
--
- най-разпространения метод за кодиране
--
- низовете в Rust (`&str`, `String`) са utf-8

---

# Кодиране на низове

### UTF-8

Схема на кодирането

| Брой байтове | Първи code point | Последен code point | Байт 1   | Байт 2   | Байт 3   | Байт 4   |
|--------------|------------------|---------------------|----------|----------|----------|----------|
| 1            | U+0000           | U+007F              | 0xxxxxxx |          |          |          |
| 2            | U+0080           | U+07FF              | 110xxxxx | 10xxxxxx |          |          |
| 3            | U+0800           | U+FFFF              | 1110xxxx | 10xxxxxx | 10xxxxxx |          |
| 4            | U+10000          | U+10FFFF            | 11110xxx | 10xxxxxx | 10xxxxxx | 10xxxxxx |

---

# Кодиране на низове

### UTF-8

Предимства:
--
- съвместим с ASCII
--
    - всеки ASCII низ е и utf-8 низ!
--
    - не-ASCII символите не съдържат ASCII байтове (0x00 - 0x7f)!
--
    - с две думи - код който очаква да работи с ASCII низ би приел utf-8 низ *подобаващо*
--
- поток от байтове - няма значение от [endianness](https://en.wikipedia.org/wiki/Endianness)
--
- устойчив на корупция на данните
--
- и други

--
<br/>
Недостатъци:
- variable lenght encoding - преброяването на символите или намирането на n-тия символ изисква итерация по низа

---

# Низове

### Итерация

```rust
# fn main() {
// bytes() връща итератор по байтовете на низа
let bytes: Vec<u8> = "Здравей! 😊".bytes().collect();

// chars() връща итератор по символите в низа
let chars: Vec<char> = "Здравей! 😊".chars().collect();

// аs_bytes() преобразува &str в &[u8]
println!("{:x?}", "Здравей! 😊".as_bytes());
println!("{:x?}", bytes);
println!("{:?}", chars);
# }
```

---

# Низове

### Итерация

```rust
# fn main() {
for c in "Здравей! 😊".chars() {
    let c_string: String = c.to_string();
    let c_utf8 = c_string.as_bytes();

    println!("{}: code_point={:x}, utf8={:x?}", c, c as u32, c_utf8);
}
# }
```

---

# Низове

### Дължина

`str::len()` връща дължината на низ в брой байтове

```rust
# fn main() {
let hi = "Здравей! 😊";

println!("{}", hi.len());
println!("{}", hi.chars().count());
# }
```

---

# Низове

### Индексация

При взимане на резен от низ се оказват брой байтове

```rust
# fn main() {
let sub_hi = &"Здравей! 😊"[0..6];
println!("{:?}", sub_hi);
# }
```

```rust
# fn main() {
let sub_hi = &"Здравей! 😊"[0..3];
println!("{:?}", sub_hi);
# }
```

---

# Низове

### Заключение

--
- Внимавайте с UTF-8! Обработката на низове изисква итерация през всички символи
--
- Вижте документацията на:
    - `str`: https://doc.rust-lang.org/std/primitive.str.html
    - `String`: https://doc.rust-lang.org/std/string/struct.String.html
    - `char`: https://doc.rust-lang.org/std/primitive.char.html

---

# Документация

--
```rust
fn main() {
    /// Ако мислихте, че коментарите не водят до компилационни грешки...
}
```

---

# Документация

### Док-коментари

--
- коментар, който започва с три наклонени черти (`///`)
--
- служи за документация на следващата декларация
--
- поддържа форматиране с markdown

---

# Документация

### На структури и полета

```rust
# #![allow(dead_code)]
/// A (half-open) range bounded inclusively below and exclusively above (start..end).
///
/// The `Range` `start..end` contains all values with `x >= start` and `x < end`.
/// It is empty unless `start < end`.
pub struct Range<Idx> {
    /// The lower bound of the range (inclusive).
    pub start: Idx,
    /// The upper bound of the range (exclusive).
    pub end: Idx,
}
# fn main() {}
```

---

# Документация

### На функции и методи

```rust
# struct String;
impl String {
    /// Appends a given string slice onto the end of this `String`.
    ///
    /// # Examples
    ///
    /// Basic usage:
    ///
    /// \`\`\`
    /// let mut s = String::from("foo");
    /// s.push_str("bar");
    /// assert_eq!("foobar", s);
    /// \`\`\`
    pub fn push_str(&mut self, string: &str) {}
}
# fn main() {}
```

---

# Документация

### Вътрешни док-коментари

Коментари, които започват с `//!`, документират елемента в който се намират.

```rust
mod fs {
    //! Filesystem manipulation operations.
    //!
    //! This module contains basic methods to manipulate the
    //! contents of the local filesystem. All methods in this
    //! module represent cross-platform filesystem operations.

    /* ... */
}
# fn main() {}
```

---

# Документация

--
- `rustdoc` - инструмент за генериране на API документация
--
- инсталира се заедно с Rust
--
- най-лесно се използва през `cargo`
--
- `cargo doc`
--
- `cargo doc --open`

---

# Документация

### Тестване на примери

```java
/**
 * Always returns true.
 */
public boolean isAvailable() {
    return false;
}
```

---

# Документация

### Тестване на примери

--
- автоматично се добавят тестове за блоковете код в документацията
--
- тества се, че примера се компилира
--
- тества се, че кодът се изпълнява без грешка (напр. `assert`-ите не гърмят)
--
- тестовете за примерите могат да се изпълнят с `cargo test`

---

# Документация

### Тестване на примери

````rust
# // ignore
/// Converts a `char` to a digit in the given radix.
///
///
/// # Examples
///
/// \`\`\`
/// assert_eq!('1'.to_digit(10), Some(1));
/// assert_eq!('f'.to_digit(16), Some(15));
/// \`\`\`
pub fn to_digit(self, radix: u32) -> Option<u32>;
````

--
<div class="code-block"><div class="code-container"><pre class="hljs">
   Doc-tests example

running 1 test
test src/lib.rs - to_digit (line 8) ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
</pre></div></div>

---

# Документация

### The rustdoc book

Подробности относно документацията и тестването на примери можете да намерите в Rustdoc книгата
https://doc.rust-lang.org/rustdoc/index.html

--
- примери които които се компилират, но не се изпълняват
--
- примери които нито се компилират, нито се изпълняват
--
- скриване на редове
--
- и други специфики

---

# Атрибути

---

# Атрибути

- `#[derive(Debug)]`
- `#[cfg(target_os = "macos")]`
- `#[allow(unused_variables)]`
- `#[warn(missing_docs)]`
- `#[deny(unsafe_code)]`

---

# Атрибути

- `#[attribute]` - важи за елемента след него
--
- `#![attribute]` - важи за елемента в който се намира
--
- `#[attribute(arg)]`
--
- `#[attribute(arg1, arg2)]`
--
- `#[attribute(key = val)]`

---

# Атрибути

Служат за различни неща

--
- флагове към компилатора
--
- conditional compilation
--
- генериране на код в стил макроси
--
- и други

---

# Атрибути

Mожем да използваме атрибути за да имплементираме някои често използвани трейтове за наш тип

```rust
# #![allow(dead_code)]
# fn main() {
#[derive(Debug)]
struct User {
    name: String,
    age: i32,
}
# }
```

---

# Атрибути

Mожем да използваме атрибути за да имплементираме някои често използвани трейтове за наш тип

```rust
# #![allow(dead_code)]
# fn main() {
#[derive(Debug)]
struct User {
    name: String,
    age: i32,
}

// `User` вече имплементира `Debug`
let user = User { name: String::from("Пешо"), age: 14 };
println!("{:?}", user);
# }
```

---

# Тестове

---

# Тестове

Ако си създадем проект - библиотека, cargo създава примерен код с един тест

```sh
cargo new --lib example
```

--
```rust
// src/lib.rs

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
# fn main() {}
```

---

# Тестове

Тестовете са функции, анотирани с `#[test]`

```rust
# #![allow(dead_code)]
fn add_two(x: i32) -> i32 {
    x + 2
}

#[test]
fn it_works() {
    assert_eq!(add_two(2), 4);
}
# fn main() {}
```

---

# Тестове

- тестовите функции не приемат аргументи и не връщат нищо
- теста е минал успешно ако функцията завърши
- теста е фейлнал ако функцията "гръмне"

```rust
# #![allow(dead_code)]
#[test]
fn always_succeeds() {
}

#[test]
fn always_fails() {
    panic!(":@");
}
# fn main() {}
```

---

# Тестове

С `cargo test` се изпълняват всички тестове

<div class="code-block"><div class="code-container"><pre class="hljs">
     Running target/debug/deps/example-32a7ca0b7a4e165f

running 3 tests
test always_succeeds ... ok
test it_works ... ok
test always_fails ... FAILED

failures:

---- always_fails stdout ----
thread 'always_fails' panicked at ':@', src/lib.rs:16:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.


failures:
    always_fails

test result: FAILED. 2 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out
</pre></div></div>

---

# Panic

--
- грешка, от която програмата ни не може да се възстанови
--
- unwind-ва стека, и терминира текущата нишка
--
- при паника в главната нишка се убива цялата програма и се изписва съобщение за грешка
--
- не са exceptions, не се използват за error handling

---

# Panic

### Примери

* `panic!("something terrible happened")`
* `assert_eq!(1, 2)`
* `None.unwrap()`

---

# Panic

### Макроси

--
- `panic!("съобщение")`
--
- `todo!()`, `unimplemented!()`
--
- `unreachable!()`
--
- `assert_*`, `debug_assert_*`

---

# Тестове

### Asserts

- в тестове е удобно да използваме `assert_*` макросите
--
- те проверяват дали условие е изпълнено, и ако не вдигат паника
--
- `assert!`
--
- `assert_eq!`
--
- `assert_ne!`

---

# Тестове

### Asserts

```rust
fn add_two(x: i32) -> i32 { x + 2 }

fn main() {
    assert!(add_two(2) == 5);
}
```

---

# Тестове

### Asserts

`assert_eq!` и `assert_ne!` показват и какви са стойностите, които сравняваме

```rust
fn add_two(x: i32) -> i32 { x + 2 }

fn main() {
    assert_eq!(add_two(2), 5);
}
```

---

# Тестове

### Panics

За да тестваме, че при определен вход програмата гърми, има допълнителен атрибут `#[should_panic]`

```rust
# #![allow(dead_code)]
# #![allow(unused_variables)]
# use std::net::Ipv4Addr;
fn connect(addr: &str) {
    // no error handling, will panic if it can't parse `addr`
    let ip_addr: Ipv4Addr = addr.parse().unwrap();
}

#[test]
#[should_panic]
fn cant_connect_to_invalid_ip() {
    connect("10.20.30.1234");
}
# fn main(){}
```

---

# Организация на тестовете

Практика е тестовете да стоят в отделен модул

```rust
# #![allow(dead_code)]
fn add_two(x: i32) -> i32 {
    x + 2
}

mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(add_two(2), 4);
    }
}
# fn main() {}
```

---

# Тестове

С `#[cfg(test)]` тестовете се компилират само при `cargo test`

```rust
# #![allow(dead_code)]
fn add_two(x: i32) -> i32 {
    x + 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(add_two(2), 4);
    }
}
# fn main() {}
```

---

# Организация на тестовете

### Unit tests

--
- тестове, които покриват отделна малка компонента от кода
--
- например тестове за функционалността на определен модул
--
- удобно е тестовете да са подмодул на модула, който тестват

```rust
# #![allow(dead_code)]
fn add_two(x: i32) -> i32 {
    x + 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn adder_adds() {
        assert_eq!(add_two(2), 4);
    }
}
# fn main() {}
```

---

# Организация на тестовете

### Unit tests

Като подмодул тестовете имат достъп до private функционалността на модула

```rust
# #![allow(dead_code)]
pub fn add_two(x: i32) -> i32 { internal_adder(x) }

fn internal_adder(x: i32) -> i32 { x + 2 }

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn adder_adds() {
        assert_eq!(internal_adder(2), 4);
    }
}
# fn main() {}
```

---

# Организация на тестовете

### Integration tests

--
- тестове, които покриват функционалността на програмата или библиотеката като цяло
--
- намират се отделно от сорс кода, в папка tests
--
- името на файла може да е произволно

```sh
adder
├── Cargo.lock
├── Cargo.toml
├── src
│   └── lib.rs
└── tests
    └── adder.rs
```

---

# Организация на тестовете

### Integration tests

```rust
# // ignore
// tests/adder.rs

#[test]
fn adder_adds() {
    assert_eq!(adder::add_two(2), 4);
}
```

--
- тестът се компилира отделно от библиотеката ни
--
- библиотеката ни може да се използва като външно dependency
--
- имаме достъп само до публичния интерфейс
--
- `cargo test` компилира и изпълнява всички файлове в `tests/`
