---
title: Lifetimes
author: Rust@FMI team
speaker: Никола Стоянов
date: 05 ноември 2019
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

- първото домашно приключи

---

# Преговор

--
- конвертиране: `From`, `Into`
--
- парсене на низове: `FromStr, str::parse`
--
- error handling: `Result`
--
- error handling: `panic!`
--
- error handling: `try!`, оператор `?`
--
- IO: `Read`, `Write`, `BufRead`, `BufWrite`

---

# Жизнени цикли

<img src="images/circle_of_life.jpg" style="width: 100%;" />

---

# Жизнени цикли

Интервалът в който една стойност е жива

```rust
# fn main()
{
    {
        let x = 5; // --+
                   //   |
    } // <--------------+
}
```

---

# Lifetime на променлива със собственост

Стойността живее докато е в scope - очевидно

```rust
# fn main()
{
    let s = String::from("five"); // --+
                                  //   |
} // <---------------------------------+
```

---

# Lifetime на референция

Референцията живее до мястото където е използвана за последно

```rust
# fn main()
{
    let x = 5;
    let r = &x; // ----+
                //     |
                // v---+
    println!("{}", r);
}
```

---

# Lifetime на референция

Референцията също така не може да надживее стойността към която сочи

```rust
# fn main()
{
    let x = 5;  //--------+
    let r = &x; // ----+  |
                //     |  |
                // v---+  |
    println!("{}", r); // |
} // <--------------------+
```

---

# Lifetime на референция

Иначе borrow checker-а ще изръмжи

```rust
# // ignore
# fn main()
{
    let r;
    {
        let x = 5;  //----+
        r = &x; // ----+  |
                //     |  |
    } // <----------------+
                // v---+
    println!("{}", r);
}
```

---

# Lifetime на референция

Иначе borrow checker-а ще изръмжи

```rust
# fn main()
{
    let r;
    {
        let x = 5;  //----+
        r = &x; // ----+  |
                //     |  |
    } // <----------------+
                // v---+
    println!("{}", r);
}
```

---

# Lifetimes

Нека пробваме с малко по-сложен пример

```rust
# // norun
# fn main()
{
    let x = 5;

    let r2 = {
        let r1 = &x;


        &*r1
    };

    println!("{}", r2);
}
```

---

# Lifetimes

Работи

```rust
# fn main()
{
    let x = 5;

    let r2 = {
        let r1 = &x;


        &*r1
    };

    println!("{}", r2);
}
```

---

# Lifetimes

Можем да означим колко дълго живеят `x`, `r1` и `r2`

```rust
# fn main()
{
    let x = 5; //-----------+
               //           |
    let r2 = { //           |
        let r1 = &x; // --+ |
                     //   | |
        // v--------------+ |
        &*r1 // --------+   |
    };           //     |   |
                 // v---+   |
    println!("{}", r2); //  |
} // <----------------------+
```

--
`r2` е референция към стойността `x`. Важно е `r2` да не надживява `x`

---

# Lifetimes

- можем ли да счупим borrow checker-а?
--
- нека си дефинираме следната функция

```rust
# // ignore
/// Връща по-дългия от двата низа
fn longer(s1: &str, s2: &str) -> &str {
    if s1.len() > s2.len() { s1 } else { s2 }
}
```

--
- ок?

---

# Lifetimes

Как би работило в следния случай?

```rust
# fn longer(_: &str, _: &str) {}
# fn main() {
let s1 = String::from("looong");
let l = {
    let s2 = String::from("123");
    longer(&s1[..], &s2[..])
};
# }
```

---

# Lifetimes

Как би работило в следния случай?

```rust
# #![allow(unused_must_use)]
# fn longer(_: &str, _: &str) {}
# fn main() {
let s1 = { let mut s = String::new(); std::io::stdin().read_line(&mut s); s };
let l = {
    let s2 = { let mut s = String::new(); std::io::stdin().read_line(&mut s); s };
    longer(&s1[..], &s2[..])
};
# }
```

---

# Lifetimes

- не може валидността на функцията да зависи от това какви аргументи ѝ подаваме
--
- и действително тази функция не се компилира

```rust
# // norun
# fn main() {}
/// Връща по-дългия от двата низа
fn longer(s1: &str, s2: &str) -> &str {
    if s1.len() > s2.len() { s1 } else { s2 }
}
```

---

# Lifetime анотации

![](images/brick_wall.jpg)

---

# Lifetime анотации

Какъв е проблема

--
- искаме да поддържаме функции като `longer`
--
- функции които връщат референции
--
- `fn function(...) -> &X`
--
- следователно ни трябва начин да означим колко дълго живее върнатата референция

---

# Lifetime анотации

Грешката ни казва, че трябва да означим дали върнатият резултат живее колкото параметъра `a` или колкото параметъра `b`

```rust
# // norun
# fn main() {}
/// Връща по-дългия от двата низа
fn longer(s1: &str, s2: &str) -> &str {
    if s1.len() > s2.len() { s1 } else { s2 }
}
```

---

# Lifetime анотации

Отговорът: и трите живеят еднакво дълго

```rust
# // norun
# fn main() {}
/// Връща по-дългия от двата низа
fn longer<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() > s2.len() { s1 } else { s2 }
}
```

---

# 'a

--
- `'а` се нарича lifetime параметър или lifetime анотация
--
- използва се да се означи колко дълго живее референция
--
- `&'a X`, `&'b mut Y`
--
- може да е всякакъв идентификатор, но практиката е да са кратки или еднобуквени
--
- `&'my_lifetime X`

---

# 'a

```rust
fn foo<'a>(x: &'a str) { }
# fn main() {}
```

- отделно `x: &'a str` не ни дава информация
--
- измислили сме си име `a` за периода за който живее референцията `x`

---

# 'a

```rust
fn foo<'a>(x: &'a str, y: &'a str) { }
# fn main() {}
```

- заедно `x: &'a str` и `y: &'a str` задават ограничение
--
- `x` живее колкото `y`
--
- (в случая отново не получаваме много информация, защото и двете са аргументи)

---

# Lifetimes - примери

Функцията `trim` връща резултат който живее колкото аргумента

```rust
# // norun
fn trim<'a>(s: &'a str) -> &'a str
# { s.trim() }

fn main() {
    {
        let s = String::from("  низ  \n"); // --+
        let trimmed = trim(&s);            // --|-+
                                           //   | |
    } // <--------------------------------------+-+
}
```

---

# Lifetimes - примери

Функцията `longer` връща резултат който живее колкото общия период в който живеят двата ѝ аргумента.

```rust
# // norun
fn longer<'a>(s1: &'a str, s2: &'a str) -> &'a str
# { unimplemented!() }

fn main() {
    let s1 = String::from("дългият низ е дълъг");
    {
        let s2 = String::from("къс низ");
        let result = longer(&s1, &s2);
    }
}
```

---

# Lifetimes - примери

Ако двата аргумента живеят различно - ще се вземе по-малкия период

```rust
# // norun
fn longer<'a>(s1: &'a str, s2: &'a str) -> &'a str
# { unimplemented!() }

fn main() {
    let s1 = String::from("дългият низ е дълъг"); // --+
    {                                             //   |
        let s2 = String::from("къс низ"); // --+       |
        let result = longer(&s1, &s2);    // --|--+    |
                                          //   |  |    |
    } // <-------------------------------------+--+    |
} // <-------------------------------------------------+
```

--
- има автоматично конвертиране от по-голям до по-малък lifetime

---

# Lifetimes - примери

Не е нужно всички lifetime-и да са еднакви

```rust
fn first_occurrence<'a, 'b>(s: &'a str, pattern: &'b str) -> Option<&'a str> {
    s.matches(pattern).next()
}

fn main() {
    let text = String::from("обичам мач и боза");
    let result = {
        let pattern = String::from("боза");
        first_occurrence(&text, &pattern)
    };

    println!("{:?}", result);
}
```

---

# Lifetime elision

--
- всяка референция има lifetime параметър
--
- но не е задължително винаги да ги пишем
--
- когато ситуацията не е двусмислена може да се пропуснат
--
- това се нарича lifetime elision

---

# Lifetime elision

Следните дефиниции са еквивалентни:

```rust
fn trim(s: &str) -> &str {
    // ...
#   unimplemented!()
}
# fn main() {}
```

```rust
fn trim<'a>(s: &'a str) -> &'a str {
    // ...
#   unimplemented!()
}
# fn main() {}
```

---

# Lifetime elision

### Кога трябва да пишем lifetimes?

--
- блок код
    - никога
    - компилаторът винаги има всичката нужна информация да определи правилния lifetime

--
<br/>
- дефиниция на функция
    - понякога
    - тук се прилага lifetime elision

--
<br/>
- структура
    - винаги

---

# Lifetime elision

### Как работи

За всеки пропуснат lifetime в аргументите се добавя нов lifetime параметър

```rust
# // ignore
fn print(s: &str);                                  // elided
fn print<'a>(s: &'a str);                           // expanded

fn foo(x: (&u32, &u32), y: usize);                  // elided
fn foo<'a, 'b>(x: (&'a u32, &'b u32), y: usize);    // expanded
```

---

# Lifetime elision

### Как работи

Ако за *аргументите* има само един lifetime параметър (експлицитен или пропуснат), този lifetime се налага на всички пропуснати lifetimes в *резултата*

```rust
# // ignore
fn substr(s: &str, until: usize) -> &str;                         // elided
fn substr<'a>(s: &'a str, until: usize) -> &'a str;               // expanded

fn split_at(s: &str, pos: usize) -> (&str, &str);                 // elided
fn split_at<'a>(s: &'a str, pos: usize) -> (&'a str, &'a str);    // expanded
```

---

# Lifetime elision

### Как работи

Ако първият аргумент е `&self` или `&mut self`, неговият lifetime се налага на всички пропуснати lifetimes в резултата

```rust
# // ignore
fn get_mut(&mut self) -> &mut T;                                // elided
fn get_mut<'a>(&'a mut self) -> &'a mut T;                      // expanded

fn args(&mut self, args: &[T]) -> &mut Self;                    // elided
fn args<'a, 'b>(&'a mut self, args: &'b [T]) -> &'a mut Self;   // expanded
```

---

# Lifetime elision

### Как работи

Във всички останали случаи е грешка да не напишем lifetime анотацията.

```rust
fn get_str() -> &str {
    // ...
#   unimplemented!()
}

fn longest(x: &str, y: &str) -> &str {
    // ...
#   unimplemented!()
}
# fn main() {}
```

---

# Lifetimes

### Обобщение

--
- всички референции имат lifetime параметър (`&'a X`)
--
- показваме че две референции живеят еднакво дълго като им зададем еднакъв lifetime параметър
--
- в много случаи lifetime параметрите могат да не се пишат благодарение на lifetime elision

---

# Статичен живот

![Static Life](images/static_life.jpg)

---

# Статичен живот

Специалният lifetime `'static`.

Оказва че променливата живее за целия живот на програмата.

```rust
# fn main() {
let s: &'static str = "I have a static lifetime.";
# }
```

---

# Референции в структури

Нека имаме структура, която връща думите от текст.

```rust
# // ignore
struct Words {
    text: ??,
}

impl Words {
    fn new(text: &str) -> Words {
        unimplemented!()
    }

    fn next_word(&mut self) -> Option<&str> {
        unimplemented!()
    }
}
```

--
- какъв да е типа на полето `text`?
--
- може да е тип който държи стойност, като `String`, но тогава ще имаме излишно копиране
--
- а може и да е референция

---

# Референции в структури

```rust
struct Words {
    text: &str,
}
# fn main() {}
```

---

# Референции в структури

```rust
struct Words<'a> {
    text: &'a str,
}
# fn main() {}
```

---

# Референции в структури

Съответно трябва да добавим lifetime параметъра и към `impl` блока

```rust
#[derive(Debug)]
struct Words<'a> {
    text: &'a str,
}

impl<'a> Words<'a> {
    fn new(text: &str) -> Words {
        Words { text }
    }
}
# fn main() {}
```

---

# Референции в структури

Животът на структурата е ограничен до това колко живее обектът, от който сме взели референция

```rust
# #[derive(Debug)]
# struct Words<'a> {
#     text: &'a str,
# }
# impl<'a> Words<'a> {
#     fn new(text: &str) -> Words {
#         Words { text }
#     }
# }
# fn main() {
let t1 = Words::new("a b c");                // Words<'static>

{
    let s = String::from("мой таен низ");   // ---+- 'a
    Words::new(s.as_str());                 //    |- Words<'a>
}; // <-------------------------------------------+
# }
```

---

# Lifetime elision в impl блок

Как се попълват пропуснатите lifetimes за функцията `new`?

```rust
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new(text: &str) -> Words {
        Words { text }
    }
}
# fn main() {}
```

---

# Lifetime elision в impl блок

Expanded:

```rust
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new<'b>(text: &'b str) -> Words<'b> {
        Words { text }
    }
}
# fn main() {}
```

--
- aлгоритъмът не взима под внимание lifetime-а `'a`
--
- пропуснати lifetime параметри на структури се попълват по същия начин като референциите

---

# Lifetime elision в impl блок

Ами ако използваме `Self`?

```rust
# // ignore
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new(text: &str) -> Self {
        Words { text }
    }
}
# fn main() {}
```

---

# Lifetime elision в impl блок

Ами ако използваме `Self`?

```rust
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new(text: &str) -> Self {
        Words { text }
    }
}
# fn main() {}
```

---

# Lifetime elision в impl блок

В случая `Self` означава `Words<'a>`:

```rust
# // ignore
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new(text: &str) -> Words<'a> {
        Words { text }
    }
}
# fn main() {}
```

--

Expanded:

```rust
# // ignore
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new<'b>(text: &'b str) -> Words<'a> {
        Words { text }
    }
}
# fn main() {}
```

---

# Lifetime elision в impl блок

В случая `Self` означава `Words<'a>`:

```rust
# // ignore
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new(text: &str) -> Words<'a> {
        Words { text }
    }
}
# fn main() {}
```

Expanded:

```rust
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new<'b>(text: &'b str) -> Words<'a> {
        Words { text }
    }
}
# fn main() {}
```

---

# Lifetime elision в impl блок

Ако искаме да използваме `Self`, правилния вариант е:

```rust
# struct Words<'a> {
#     text: &'a str,
# }
impl<'a> Words<'a> {
    fn new(text: &'a str) -> Self {
        Words { text }
    }
}
# fn main() {}
```

---

# Имплементация на `next_word` метода

Live demo

---

# Имплементация на `next_word` метода

Финален код

```rust
#[derive(Debug)]
struct Words<'a> {
    text: Option<&'a str>,
}

impl<'a> Words<'a> {
    fn new(text: &'a str) -> Self {
        Words { text: Some(text) }
    }

    fn next_word(&mut self) -> Option<&str> {
        let text = self.text?;
        let mut iter = text.splitn(2, char::is_whitespace);

        match (iter.next(), iter.next()) {
            (Some(word), rest) => {
                self.text = rest;
                Some(word)
            },
            _ => unreachable!()
        }
    }
}
# fn main() {}
```

---

# Имплементация на `next_word` метода

Всичко работи, но дали имаме правилните lifetimes?

```rust
# // ignore
# #[derive(Debug)]
# struct Words<'a> {
#     text: Option<&'a str>,
# }
# impl<'a> Words<'a> {
#     fn new(text: &'a str) -> Self {
#         Words { text: Some(text) }
#     }
#     fn next_word(&mut self) -> Option<&str> {
#         let text = self.text?;
#         let mut iter = text.splitn(2, char::is_whitespace);
#         match (iter.next(), iter.next()) {
#             (Some(word), rest) => {
#                 self.text = rest;
#                 Some(word)
#             },
#             _ => unreachable!()
#         }
#     }
# }
fn hello() -> &'static str {
    let mut words = Words::new("hello world");
    words.next_word().unwrap()
}
# fn main() {}
```

---

# Имплементация на `next_word` метода

Всичко работи, но дали имаме правилните lifetimes?

```rust
# #[derive(Debug)]
# struct Words<'a> {
#     text: Option<&'a str>,
# }
# impl<'a> Words<'a> {
#     fn new(text: &'a str) -> Self {
#         Words { text: Some(text) }
#     }
#     fn next_word(&mut self) -> Option<&str> {
#         let text = self.text?;
#         let mut iter = text.splitn(2, char::is_whitespace);
#         match (iter.next(), iter.next()) {
#             (Some(word), rest) => {
#                 self.text = rest;
#                 Some(word)
#             },
#             _ => unreachable!()
#         }
#     }
# }
fn hello() -> &'static str {
    let mut words = Words::new("hello world");
    words.next_word().unwrap()
}
# fn main() {}
```

---

# Имплементация на `next_word` метода

Това става, защото резултата от `next_word` има lifetime колкото `self` (`'b`).

```rust
# #[derive(Debug)]
# struct Words<'a> {
#     text: Option<&'a str>,
# }
impl<'a> Words<'a> {
    fn next_word<'b>(&'b mut self) -> Option<&'b str> {
        let text = self.text?;
        let mut iter = text.splitn(2, char::is_whitespace);

        match (iter.next(), iter.next()) {
            (Some(word), rest) => {
                self.text = rest;
                Some(word)
            },
            _ => unreachable!()
        }
    }
}
# fn main() {}
```

---

# Имплементация на `next_word` метода

Вместо това може да върнем резултат с lifetime-а на оригиналния низ в полето `text` (`'a`).

```rust
# #[derive(Debug)]
# struct Words<'a> {
#     text: Option<&'a str>,
# }
# impl<'a> Words<'a> {
#     fn new(text: &'a str) -> Self {
#         Words { text: Some(text) }
#     }
# }
impl<'a> Words<'a> {
    fn next_word(&mut self) -> Option<&'a str> {
        // използваме lifetime 'a тук  ^^

        let text = self.text?;
        let mut iter = text.splitn(2, char::is_whitespace);

        match (iter.next(), iter.next()) {
            (Some(word), rest) => {
                self.text = rest;
                Some(word)
            },
            _ => unreachable!()
        }
    }
}

fn hello() -> &'static str {
    let mut words = Words::new("hello world");
    words.next_word().unwrap()
}

fn main() {
    println!("{}", hello());
}
```

---

# Lifetimes & generics

```rust
# trait ToJson { fn to_json(&self) -> String; }
impl ToJson for String {
    fn to_json(&self) -> String {
        format!("{:?}", self)
    }
}

fn save_for_later<T: ToJson>(to_json: T) -> Box<T> {
    Box::new(to_json)
}

fn main() {
    let saved = {
        let s = String::from("yippie");
        save_for_later(s)
    };

    let inner = &*saved;
    println!("{}", inner.to_json());
}
```

---

# Lifetimes & generics

```rust
# trait ToJson { fn to_json(&self) -> String; }
impl<'a> ToJson for &'a String {
    fn to_json(&self) -> String {
        format!("{:?}", self)
    }
}

fn save_for_later<T: ToJson>(to_json: T) -> Box<T> {
    Box::new(to_json)
}

fn main() {
    let saved = {
        let s = String::from("yippie");
        save_for_later(&s)
    };

    let inner = &*saved;
    println!("{}", inner.to_json());
}
```

---

# Lifetimes & generics

- шаблонен тип `T` може да е референция
--
- тогава той има lifetime, макар че няма lifetime параметър
--
- и всеки тип който съдържа `T` също има lifetime, защото съдържа референция

---

# Lifetimes & generics

- приема се, че тип който има собственост над стойността която съдържа има lifetime `'static`
--
- ако искаме да запазим нещо за дълго можем да използваме ограничение `'static`
--

```rust
# trait ToJson { fn to_json(&self) -> String; }
# impl ToJson for String {
#     fn to_json(&self) -> String { format!("{:?}", self) }
# }
# impl<'a> ToJson for &'a String {
#     fn to_json(&self) -> String { format!("{:?}", self) }
# }
#
fn save_for_later<T: ToJson + 'static>(to_json: T) -> Box<T> {
    Box::new(to_json)
}

fn main() {
    let saved = {
        let s = String::from("yippie");
        save_for_later(s)   // OK, T = String => T: 'static
    };

    let saved = {
        let s = String::from("yippie");
        save_for_later(&s)   // Err, T = &'a String => T: 'a
    };
}
```
