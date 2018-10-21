---
title: Документация и тестване
author: Rust@FMI team
date: 18 октомври 2018
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
* Първо домашно днес! Вижте новината в сайта: https://fmi.rust-lang.bg/announcements/2
--
* Ако не сте се регистрирали в https://fmi.rust-lang.bg, направете го!
--
* Качете си снимки?

---

# Преговор

# Enums and pattern matching

```rust
# fn main() {
# #[allow(dead_code)]
enum Message {
    Quit,
    Move { x: i64, y: i64 },
    Write(String),
    ChangeColor(u8, u8, u8),
}

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

### A long time ago....

```rust
# #[allow(dead_code)]
# enum Token { Text(String), Number(i32) }
# fn main() {
let mut token = Token::Text(String::from("Отговора е 42"));

match &mut token {
    &mut Token::Text(ref mut text) => {
        *text = String::from("Може би");
        println!("Токена е Text('{}')", text)
    },
    &mut Token::Number(n) => println!("Токена е Number({})", n),
}
# }
```

---

# Преговор

### Today

```rust
# #[allow(dead_code)]
# enum Token { Text(String), Number(i32) }
# fn main() {
let mut token = Token::Text(String::from("Отговора е 42"));

match &mut token {
    Token::Text(text) => {
        *text = String::from("Може би");
        println!("Токена е Text('{}')", text)
    },
    Token::Number(n) => println!("Токена е Number({})", n),
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

# Преговор

### Refutable/Irrefutable patterns

```rust
# #[allow(unused_variables)]
# fn main() {
if let (a, b) = (1, 2) {
    println!("Boom!");
}

let Some(val) = Some(5);
# }
```

---

# Низове

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
- `rustdoc` - инструмент за генериране на презентация
--
- инсталира се заедно с Rust
--
- най-лесно се използва през `cargo`
--
- `cargo doc`

---

# Документация

### Kоментари

--
- "докоментари"
--
- коментар, който започва с три наклонени черти (`///`)
--
- служи за документация на това, което е декларирано след него (следващия item)
--
- поддържа форматиране с markdown

---

# Документация

### Структури

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

---

# Документация

### Полета

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

### Функции и Методи

````rust
# #![allow(dead_code)]
# #![allow(unused_variables)]
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
````

---

# Документация

### Модули

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

### Модули

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
Коментари, които започват с `//!`, документират елемента, в който се намират (parent item).

---

# Атрибути

---

# Атрибути

- `#[derive(Debug)]`
- `#[feature(nll)]`
- `#[cfg(target_os = "macos")]`
- `#[allow(unused_variables)]`
- `#[deny(unsafe_code)]`

---

# Атрибути

- `#[attribute]` - важи за елемента след него
--
- `#![attribute]` - важи за елемента в който се намира

---

# Атрибути

### Пример

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

### Пример

```rust
# #![allow(dead_code)]
# fn main() {
#[derive(Debug)]
struct User {
    name: String,
    age: i32,
}

let user = User { name: "Пешо".to_string(), age: 14 };
println!("{:?}", user);
# }
```

---

# Тестове

--
```sh
cargo new --lib example
```

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

С `cargo test` се изпълняват всички тестове

<div class="code-block"><div class="code-container"><pre class="hljs">
     Running target/debug/deps/example-1359d134fea57abe

running 1 test
test it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests example

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
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

За да тестваме, че при определен вход функция спира програмата, има допълнителен атрибут `#[should_panic]`

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

# Тестове

Стандартно е тестовете да стоят в отеделен модул

```rust
# #![allow(dead_code)]
fn add_two(x: i32) -> i32 {
    x + 2
}

mod tests {
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
    #[test]
    fn it_works() {
        assert_eq!(add_two(2), 4);
    }
}
# fn main() {}
```

---

# Тестове на документацията

```java
/**
 * Always returns true.
 */
public boolean isAvailable() {
    return false;
}
```

---

# Тестове на документацията

- `cargo test` по подразбиране компилира и изпълнява всички примери в документацията
--
- за пример се счита всичко написано в блок за код (\`\`\` ... \`\`\`)
--
- така се гарантира, че примерите в документацията винаги работят

---

# Тестове на документацията

### Пример

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
````

--
<div class="code-block"><div class="code-container"><pre class="hljs">
   Doc-tests example

running 1 test
test src/lib.rs - to_digit (line 8) ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
</pre></div></div>

---

# Тестове на документацията

Понякога искаме примерите да се компилират, но да не се изпълняват, защото имат странични ефекти.
Тогава може да подадем `no_run` като език.

--
````rust
# // ignore
/// Create a new file and write bytes to it:
///
/// \`\`\`no_run
/// use std::fs::File;
/// use std::io::prelude::*;
///
/// fn main() -> std::io::Result<()> {
///     let mut file = File::create("foo.txt")?;
///     file.write_all(b"Hello, world!")?;
///     Ok(())
/// }
/// \`\`\`
````
---

# Тестове на документацията

Ако не искаме дори да се компилират, се използва `ignore`.

--

Има и други специфики, които може да намерите в Rustdoc книгата:
- https://doc.rust-lang.org/rustdoc/documentation-tests.html
- rustup doc

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
// tests//adder.rs

extern crate adder;

#[test]
fn adder_adds() {
    assert_eq!(adder::add_two(2), 4);
}
```

--
- тестът се компилира отделно от библиотеката ни
--
- трябва да използваме `extern crate`
--
- имаме достъп само до публичния интерфейс на библиотеката ни
--
- `cargo test` компилира и изпълнява всички файлове в `tests/`
