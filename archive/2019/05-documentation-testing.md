---
title: Документация, тестване
description: и една торба с инструменти
author: Rust@FMI team
speaker: Никола Стоянов
date: 24 октомври 2019
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

# Съдържание

![](images/bag-of-tools.jpg)

---

# Кодиране на низове

### ASCII

--
- (един от) най-ранните стандарти за кодиране, създаден през 60-те
--
- 128 символа, кодирани с числа от 0 до 127
    - 32 контролни символа
    - 96 - латинската азбука, арабските цифри и най-често използваната пунктуация
--
- повечето модерни схеми за кодиране се базират на него

---

# Кодиране на низове

### Разширено ASCII

--
- има нужда да се представят други символи (нелатинска азбука, друга пунктоация, емотикони, ..)
--
- в `u8` се побират 256 различни стойности, ASCII кодирането заема само 128
--
- затова са се появили много (стотици) разширени таблици с кодове за различни случаи
--
- във всяка таблица от 128 до 255 се кодират различни символи
--
- пример: `latin-1`, `windows-1251`, ...
--
- ако не знаем с коя таблица е кодиран низа, не знаем какви символи съдържа

---

# Кодиране на низове

### Unicode

--
- различните разширени ASCII таблици се оказват проблемни
--
- като решение е измислен Unicode стандарта

---

# Кодиране на низове

### Unicode

символ → ℕ

--
- голяма таблица която съдържа всички символи
--
- на всеки символ съответства число - code point

---

# Кодиране на низове

### Chars

- типа `char` в Rust означава unicode code point

--
Пример:
Code: U+044F
Glyph: я
Description: Cyrillic Small Letter Ya

```rust
# fn main() {
println!("0x{:x}", 'я' as u32);
# }
```

---

# Кодиране на низове

- има различни варианти за кодиране на unicode code points до битове

---

# Кодиране на низове

### UTF-32

- всеки символ се кодира с 32-битово число - стойността на code point-а

---

# Кодиране на низове

### UTF-32

- Предимства:
    - операцията "преброяване на символите" е константна
    - както и намирането на n-тия символ

--
- Недостатъци:
    - заема много памет

---

# Кодиране на низове

### UTF-32

```rust
# #![allow(unused_variables)]
# fn main() {
let utf32 = "Hello😊".chars().collect::<Vec<char>>();
# }
```

<div style="overflow: auto;">
<table>
<tr>
    <td>Glyphs</td>
    <td colspan="4">H</td>
    <td colspan="4">e</td>
    <td colspan="4">l</td>
    <td colspan="4">l</td>
    <td colspan="4">o</td>
    <td colspan="4">😊</td>
</tr>
<tr>
    <td>Chars</td>
    <td colspan="4">0x48</td>
    <td colspan="4">0x65</td>
    <td colspan="4">0x6c</td>
    <td colspan="4">0x6c</td>
    <td colspan="4">0x6f</td>
    <td colspan="4">0x1f60a</td>
</tr>
<tr>
    <td>Bytes (be)</td>
    <td>00</td>
    <td>00</td>
    <td>00</td>
    <td>48</td>
    <td>00</td>
    <td>00</td>
    <td>00</td>
    <td>65</td>
    <td>00</td>
    <td>00</td>
    <td>00</td>
    <td>6c</td>
    <td>00</td>
    <td>00</td>
    <td>00</td>
    <td>6c</td>
    <td>00</td>
    <td>00</td>
    <td>00</td>
    <td>6f</td>
    <td>00</td>
    <td>01</td>
    <td>f6</td>
    <td>0a</td>
</tr>
</table>

<table>
<tr>
    <td>Glyphs</td>
    <td colspan="4">З</td>
    <td colspan="4">д</td>
    <td colspan="4">р</td>
    <td colspan="4">а</td>
    <td colspan="4">в</td>
    <td colspan="4">е</td>
    <td colspan="4">й</td>
</tr>
<tr>
    <td>Chars</td>
    <td colspan="4">0x417</td>
    <td colspan="4">0x434</td>
    <td colspan="4">0x440</td>
    <td colspan="4">0x430</td>
    <td colspan="4">0x432</td>
    <td colspan="4">0x435</td>
    <td colspan="4">0x439</td>
</tr>
<tr>
    <td>Bytes (be)</td>
    <td>00</td>
    <td>00</td>
    <td>04</td>
    <td>17</td>
    <td>00</td>
    <td>00</td>
    <td>04</td>
    <td>34</td>
    <td>00</td>
    <td>00</td>
    <td>04</td>
    <td>40</td>
    <td>00</td>
    <td>00</td>
    <td>04</td>
    <td>30</td>
    <td>00</td>
    <td>00</td>
    <td>04</td>
    <td>32</td>
    <td>00</td>
    <td>00</td>
    <td>04</td>
    <td>35</td>
    <td>00</td>
    <td>00</td>
    <td>04</td>
    <td>39</td>
</tr>
</table>
</div>

---

# Кодиране на низове

### UTF-16

- всеки символ се кодира с едно или две 16-битови числа
- често се използва в Windows API-та
- и за вътрешна репрезентация на низове в някои езици (напр. JavaScript)

---

# Кодиране на низове

### UTF-16

- Предимства:
--
    - азбуките на всички говорими езици се кодират с 16 бита
    - почти "fixed length"

--
- Недостатъци:
    - няма предимствата нито на utf-8, нито на utf-32

---

# Кодиране на низове

### UTF-16

```rust
# #![allow(unused_variables)]
# fn main() {
let utf16 = "Hello😊".encode_utf16().collect::<Vec<u16>>();
# }
```

<div style="overflow: auto;">
<table>
<tr>
    <td>Glyphs</td>
    <td colspan="2">H</td>
    <td colspan="2">e</td>
    <td colspan="2">l</td>
    <td colspan="2">l</td>
    <td colspan="2">o</td>
    <td colspan="4">😊</td>
</tr>
<tr>
    <td>Chars</td>
    <td colspan="2">0x48</td>
    <td colspan="2">0x65</td>
    <td colspan="2">0x6c</td>
    <td colspan="2">0x6c</td>
    <td colspan="2">0x6f</td>
    <td colspan="4">0x1f60a</td>
</tr>
<tr>
    <td>Bytes (be)</td>
    <td>00</td>
    <td>48</td>
    <td>00</td>
    <td>65</td>
    <td>00</td>
    <td>6c</td>
    <td>00</td>
    <td>6c</td>
    <td>00</td>
    <td>6f</td>
    <td>d8</td>
    <td>3d</td>
    <td>de</td>
    <td>0a</td>
</tr>
</table>

<table>
<tr>
    <td>Glyphs</td>
    <td colspan="2">З</td>
    <td colspan="2">д</td>
    <td colspan="2">р</td>
    <td colspan="2">а</td>
    <td colspan="2">в</td>
    <td colspan="2">е</td>
    <td colspan="2">й</td>
</tr>
<tr>
    <td>Chars</td>
    <td colspan="2">0x417</td>
    <td colspan="2">0x434</td>
    <td colspan="2">0x440</td>
    <td colspan="2">0x430</td>
    <td colspan="2">0x432</td>
    <td colspan="2">0x435</td>
    <td colspan="2">0x439</td>
</tr>
<tr>
    <td>Bytes (be)</td>
    <td>04</td>
    <td>17</td>
    <td>04</td>
    <td>34</td>
    <td>04</td>
    <td>40</td>
    <td>04</td>
    <td>30</td>
    <td>04</td>
    <td>32</td>
    <td>04</td>
    <td>35</td>
    <td>04</td>
    <td>39</td>
</tr>
</table>
</div>

---

# Кодиране на низове

### UTF-8

- символите се кодират с 1, 2, 3 или 4 байта
- ASCII символите (0x00 - 0x7f) се кодират с един байт
- останалите символи се кодират с 2, 3 или 4 байта, като се използват само стойности от 0x80 - 0xff
- най-разпространения метод за кодиране
- низовете в Rust (`&str`, `String`) са utf-8

---

# Кодиране на низове

### UTF-8

- Предимства:
    - съвместим с ASCII - всеки ASCII низ е и utf-8 низ!
    - не-ASCII символите не съдържат ASCII байтове (0x00 - 0x7f)!
    - с две думи - код който очаква да работи с ASCII низ би приел utf-8 низ *подобаващо*
--
    - поток от байтове - няма разлика между [big endian и little endian](https://en.wikipedia.org/wiki/Endianness)
    - устойчив на корупция на данните
    - и други

--
- Недостатъци:
    - variable lenght encoding - преброяването на символите или намирането на n-тия символ изисква итерация по низа

---

# Кодиране на низове

### UTF-8

```rust
# #![allow(unused_variables)]
# fn main() {
let bytes: &[u8] = "Hello😊".as_bytes();
# }
```

<div style="overflow: auto;">
<table>
<tr>
    <td>Glyphs</td>
    <td>H</td>
    <td>e</td>
    <td>l</td>
    <td>l</td>
    <td>o</td>
    <td colspan="4">😊</td>
</tr>
<tr>
    <td>Chars</td>
    <td>0x48</td>
    <td>0x65</td>
    <td>0x6c</td>
    <td>0x6c</td>
    <td>0x6f</td>
    <td colspan="4">0x1f60a</td>
</tr>
<tr>
    <td>Bytes</td>
    <td>48</td>
    <td>65</td>
    <td>6c</td>
    <td>6c</td>
    <td>6f</td>
    <td>f0</td>
    <td>9f</td>
    <td>98</td>
    <td>8a</td>
</tr>
</table>

<table>
<tr>
    <td>Glyphs</td>
    <td colspan="2">З</td>
    <td colspan="2">д</td>
    <td colspan="2">р</td>
    <td colspan="2">а</td>
    <td colspan="2">в</td>
    <td colspan="2">е</td>
    <td colspan="2">й</td>
</tr>
<tr>
    <td>Chars</td>
    <td colspan="2">0x417</td>
    <td colspan="2">0x434</td>
    <td colspan="2">0x440</td>
    <td colspan="2">0x430</td>
    <td colspan="2">0x432</td>
    <td colspan="2">0x435</td>
    <td colspan="2">0x439</td>
</tr>
<tr>
    <td>Bytes</td>
    <td>d0</td>
    <td>97</td>
    <td>d0</td>
    <td>b4</td>
    <td>d1</td>
    <td>80</td>
    <td>d0</td>
    <td>b0</td>
    <td>d0</td>
    <td>b2</td>
    <td>d0</td>
    <td>b5</td>
    <td>d0</td>
    <td>b9</td>
</tr>
</table>
</div>

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
- `rustdoc` - инструмент за генериране на API документация
--
- инсталира се заедно с Rust
--
- най-лесно се използва през `cargo`
--
- `cargo doc`

---

# Документация

### rustdoc

--
- документира всички публично видими декларации
--
- документира и всички библиотеки (crates) на който зависим
--
- `cargo doc --open` - генерира документацията и я отваря в уеб браузър
--
- `cargo doc --no-deps` - ако dependency-тата се компилират твърде бавно
--
- `cargo doc --document-private-items` - документира всички декларации
--
- `cargo doc --help`

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

### На структури

```rust
# #![allow(dead_code)]
/// A (half-open) range bounded inclusively below and exclusively above (start..end).
///
/// The `Range` `start..end` contains all values with `x >= start` and `x < end`.
/// It is empty unless `start < end`.
pub struct Range<Idx> {
    pub start: Idx,
    pub end: Idx,
}
# fn main() {}
```

--
- първият ред е кратко описание, останалите са подробно

---

# Документация

### На полета

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

### На модули

```rust
/// Filesystem manipulation operations.
///
/// This module contains basic methods to manipulate the
/// contents of the local filesystem. All methods in this
/// module represent cross-platform filesystem operations.
mod fs {
    /* ... */
}
# fn main() {}
```

---

# Документация

### Вътрешни док-коментари

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

--
Коментари, които започват с `//!`, документират елемента, в който се намират.

---

# Примери

Мarkdown поддържа блокове код. Чрез тях може да се добавят примери за използване на библиотеката

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

---

# Тестване на примери

"Защото единственото по-лошо от липсваща документация, е грешна документация"

```java
/**
 * Always returns true.
 */
public boolean isAvailable() {
    return false;
}
```

---

# Тестване на примери

--
- автоматично се добавят тестове за примери в документацията
--
- тества се, че примера се компилира
--
- тества се, че кодът се изпълнява без грешка (напр. `assert`-ите не гърмят)
--
- тестовете за примерите могат да се изпълнят с `cargo test`

---

# Тестване на примери

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

# Тестване на примери

### Как работи това?

--
- всеки пример се компилира до изпълнимо binary
--
- ако липсва main функция, rustdoc загражда кода с `main`

--
````rust
# // ignore
/// \`\`\`
/// assert_eq!('1'.to_digit(10), Some(1));
/// assert_eq!('f'.to_digit(16), Some(15));
/// \`\`\`
````

--
````rust
# // ignore
/// \`\`\`
/// fn main() {
/// assert_eq!('1'.to_digit(10), Some(1));
/// assert_eq!('f'.to_digit(16), Some(15));
/// }
/// \`\`\`
````

---

# Тестване на примери

### Как работи това?

--
- нашият crate е достъпен в примера като външна библиотека
--
- трябва да се използва `use <my_crate_name>::` вместо `use crate::`
--
- но това е начина по който потребителя ще ползва библиотеката така или иначе

--

````rust
# // ignore
/// \`\`\`
/// use my_crate_name::{Foo, Bar};
///
/// let foo = Foo::new();
/// let bar = Bar::from(foo);
/// \`\`\`
````

---

# Тестване на примери

### Скриване на редове

Ако ред в пример започва с "# " този ред няма да се покаже в документацията

```rust
# // ignore
/// # struct User { username: String, email: String, sign_in_count: u64 }
/// # fn main() {
/// let user = User {
///     username: String::from("Иванчо"),
///     email: String::from("ivan40@abv.bg"),
///     sign_in_count: 10,
/// };
/// # }
```

---

# The rustdoc book

Подробности относно документацията и тестването на примери можете да намерите в Rustdoc книгата
https://doc.rust-lang.org/rustdoc/index.html

--
- примери които които се компилират, но не се изпълняват
--
- примери които нито се компилират, нито се изпълняват
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

Ще говорим повече следващия път, но.. можем да използваме атрибути за да имплементираме някои често използвани трейтове за наш тип

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

Ще говорим повече следващия път, но.. можем да използваме атрибути за да имплементираме някои често използвани трейтове за наш тип

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

# Тестове

### Asserts

- в тестове е удобно да използваме `assert_*` макросите
--
- те проверяват дали условие е изпълнено, и ако не спират програмата
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
# fn add_two(x: i32) -> i32 { x + 2 }
fn main() {
    assert!(add_two(2) == 5);
}
```

---

# Тестове

### Asserts

`assert_eq!` и `assert_ne!` показват и какви са стойностите, които сравняваме

```rust
# fn add_two(x: i32) -> i32 { x + 2 }
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
fn connect(addr: String) {
    // no error handling, will panic if it can't parse `addr`
    let ip_addr: Ipv4Addr = addr.parse().unwrap();
}

#[test]
#[should_panic]
fn cant_connect_to_invalid_ip() {
    connect("10.20.30.1234".to_string());
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

```sh
adder
├── Cargo.lock
├── Cargo.toml
├── src
│   └── lib.rs
└── tests
    └── adder.rs
```

--
- името на файла може да е произволно

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
