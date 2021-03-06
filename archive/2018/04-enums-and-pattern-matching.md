---
title: Изброени типове и съпоставяне на образци
author: Rust@FMI team
date: 16 октомври 2018
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
* Първо домашно идва тоя четвъртък!
--
* Ако не сте се регистрирали във https://fmi.rust-lang.bg, ще се наложи!

---

# Преговор

--
* `String` и `&str`
--
* `Vec<T>` и `&[T]`
--
* Структури (асоциирани функции, методи)
--
* `self`, `&self`, `&mut self`
--
* Организация на кода в модули
--
* Видимост (`pub` за типове, полета, функции)

---

# Enums

```rust
# //ignore
enum IpAddrKind {
    V4,
    V6,
}
```

---

# Enums

### Инстанциране

```rust
# //ignore
let four = IpAddrKind::V4;
let six = IpAddrKind::V6;
```

---

# Enums

### Параметър

```rust
# //ignore
fn route(ip_type: IpAddrKind) { }

route(IpAddrKind::V4);
route(IpAddrKind::V6);
```

---

# Enums

### Данни

```rust
# //ignore
struct IpAddr {
    kind: IpAddrKind,
    address: String,
}

let home = IpAddr {
    kind: IpAddrKind::V4,
    address: String::from("127.0.0.1"),
};

let loopback = IpAddr {
    kind: IpAddrKind::V6,
    address: String::from("::1"),
};
```

---

# Enums

### Данни

По-удобен и четим начин

```rust
# //ignore
enum IpAddr {
    V4(String),
    V6(String),
}

let home = IpAddr::V4(String::from("127.0.0.1"));

let loopback = IpAddr::V6(String::from("::1"));
```

---

# Enums

### Данни

Може да спестим памет като знаем че `IPv4` използва стойности от 0-255

```rust
# //ignore
# fn main() {
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);

let loopback = IpAddr::V6(String::from("::1"));
# }
```

---

# Enums

### Варианти

```rust
# //ignore
# fn main() {
enum Message {
    Quit,
    Move { x: i64, y: i64 },
    Write(String),
    ChangeColor(i64, i64, i64),
}
# }
```

---

# Enum варианти като структури

```rust
# //ignore
# fn main() {
struct QuitMessage; // unit struct
struct MoveMessage {
    x: i64,
    y: i64,
}
struct WriteMessage(String); // tuple struct
struct ChangeColorMessage(i64, i64, i64); // tuple struct
# }
```

---

# Разполагане в паметта

<table style="table-layout: fixed; text-align: center;">
<thead>
  <tr>
    <th rowspan="2" style="width: 33%;">Вариант</th>
    <th colspan="13">Памет</th>
  </tr>
  <tr>
    <th>8B</th>
    <th colspan="12">24B</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td style="text-align: left;">Quit</td>
    <td style="background: #BBE;">0</td>
    <td colspan="12"></td>
  </tr>
  <tr>
  <td style="text-align: left;">Move { x: i64, y: i64 }</td>
    <td style="background: #BBE;">1</td>
    <td colspan="4" style="background: #EBB;">i64</td>
    <td colspan="4" style="background: #EBB;">i64</td>
    <td colspan="4"></td>
  </tr>
  <tr>
    <td style="text-align: left;">Write(String)</td>
    <td style="background: #BBE;">2</td>
    <td colspan="12" style="background: #EBB;">String</td>
  </tr>
  <tr>
    <td style="text-align: left;">ChangeColor(i64, i64, i64)</td>
    <td style="background: #BBE;">3</td>
    <td colspan="4" style="background: #EBB;">i64</td>
    <td colspan="4" style="background: #EBB;">i64</td>
    <td colspan="4" style="background: #EBB;">i64</td>
  </tr>
</tbody>
</table>

* 8 байта за дискриминанта
* 24 байта за данните

---

# Методи

```rust
# //ignore
enum Message { ... }

impl Message {
    fn call(&self) {
        // ...
    }
}

let m = Message::Write(String::from("hello"));
m.call();
```

---

# Енумерации

* Скучно име, идващо от C, където са доста ограничени
--
* По-готиното име е "алгебричен тип", и е мощно средство за типови шмекерии

---

# Енумерацията Option

--
* Понякога искаме да изразим липсваща стойност.
--
* Проблема обикновено се решава със специалната стойност `NULL`.
--
* Това води до готини неща като "тройни булеви стойности" и любимите на всички null pointer exceptions.
--
* Тук-таме `NULL` се използва и за "имаше грешка, но `¯\_(ツ)_/¯` каква"
--
* В Rust няма `NULL`!

---

# Енумерацията Option

Option има 2 стойности:

* `Some(val)`
* `None`

---

# Енумерацията Option

```rust
# fn main() {
let some_number = Some(5);
let some_string = Some("string");
let absent_number: Option<i32> = None;

println!("{:?}", some_number);
println!("{:?}", some_string);
println!("{:?}", absent_number);
# }
```

---

# Pattern Matching

### Съпоставяне на образци

--
* Идея идваща от функционалното програмиране
--
* Може да се ползва с енумерации и стойности в тях
--
* Използва се чрез `match` оператора

---

# Pattern Matching

### Съпоставяне на образци

```rust
# fn main() {
let x = Some(42_u32);

match x {
    Some(val) => println!("Value : {}", val),
    None      => println!("No value found"),
}
# }
```

---

# Pattern Matching

### Съпоставяне на образци

```rust
# fn main() {
let x: Option<u32> = None;

match x {
    Some(val) => println!("Value : {}", val),
    None      => println!("No value found"),
}
# }
```

---

# Pattern Matching

### Съпоставяне на образци

`match` може да върне стойност:

```rust
# fn main() {
let x = Some(4);

let y = match x {
    Some(val) => Some(val * val),
    None => None,
};

println!("{:?}", y);
# }
```

---

# Pattern Matching

### Съпоставяне на образци

`match` може да върне стойност:

```rust
# fn main() {
let x = Some(4);

let y = match x {
    Some(val) => val * val,
    None => 0,
};

println!("{:?}", y);
# }
```

---

# Pattern Matching

### Съпоставяне на образци

`match` може да излезе от функцията

```rust
# //ignore
# fn main() {
let y = match x {
    Some(val) => val * val,
    None => return None,
};
# }
```

---

# Pattern Matching

### Съпоставяне на образци

`match` може да съдържа блокове от код:

```rust
# //ignore
# fn main() {
let y = match x {
    Some(val) => {
        println!("Will return {}", val * val);
        Some(val * val)
    },
    None => {
        println!("Will do nothing!!");
        None
    },
};
# }
```

---

# Pattern Matching

### Съпоставяне на образци

Задължително трябва да се покрият всички случаи!

```rust
# fn main() {
let x = Some(3);

let y = match x {
    Some(i) => Some(i + 1),
};
# }
```
---

# Pattern Matching

### Съпоставяне на образци

Работи и с прости стойности: `_` означава всичко останало

```rust
# //ignore
# fn main() {
match x {
    69  => println!("Nice."),
    666 => println!("\m/"),
    _   => println!("¯\_(ツ)_/¯"),
}
# }
```

---

# More control flow

### if let

Понякога да използваме `match` за един случай и да покрием всички други с `_` е прекалено много код

```rust
# fn main() {
let some_value = Some(8);

match some_value {
    Some(8) => println!("8)"),
    _ => (),
}
# }
```

---

# More control flow

### if let

Запознайте се с `if let`:

```rust
# fn main() {
let some_value = Some(8);

if let Some(8) = some_value {
    println!("::::)");
}
# }
```

---

# More control flow

### while let

А защо не и `while let`:

```rust
# fn main() {
let so_eighty = [8, 8, 8, 88, 8];
let mut iter8or = so_eighty.iter();

while let Some(8) = iter8or.next() {
    println!("∞");
}
# }
```

---

# Итерация

```rust
# //ignore
# fn main() {
let numbers = [1, 2, 3].iter();                   // std::slice::Iter
let chars   = "abc".chars();                      // std::str::Chars
let words   = "one two three".split_whitespace(); // std::str::SplitWhitespace
# }
```

---

# Итерация

```rust
# fn main() {
let numbers = [1, 2, 3].iter();                   // std::slice::Iter
let chars   = "abc".chars();                      // std::str::Chars
let words   = "one two three".split_whitespace(); // std::str::SplitWhitespace

println!("{:?}", numbers);
println!("{:?}", chars);
println!("{:?}", words);
# }
```

---

# Итерация

```rust
# fn main() {
let numbers: Vec<&u32> = [1, 2, 3].iter().collect();
let chars: Vec<char>  = "abc".chars().collect();
let words: Vec<&str>  = "one two three".split_whitespace().collect();

println!("{:?}", numbers);
println!("{:?}", chars);
println!("{:?}", words);
# }
```

---

# Итерация

```rust
# //ignore
# fn main() {
let chars = String::from("abc").chars();

println!("{:?}", chars); // ???
# }
```

---

# Итерация

```rust
# fn main() {
let chars = String::from("abc").chars();

println!("{:?}", chars);
# }
```

---

# Итерация

```rust
# fn main() {
let string = String::from("abc");
let chars = string.chars();

println!("{:?}", chars);
# }
```

---

# Итерация

```rust
# fn main() {
let string = String::from("abc");
let mut chars = string.chars(); // Mutable!

println!("{:?}", chars.next());
println!("{:?}", chars.next());
println!("{:?}", chars.next());
println!("{:?}", chars.next());
# }
```

---

# Итерация

```rust
# fn main() {
let string = String::from("abc");
let mut chars = string.chars(); // Mutable!

while let Some(c) = chars.next() {
    println!("{:?}", c);
}
# }
```

---

# Итерация

```rust
# //ignore
# fn main() {
let string = String::from("abc");
let mut chars = string.chars();

for c in chars {
    println!("{:?}", c);
}
# }
```

---

# Итерация

```rust
# fn main() {
let string = String::from("abc");
let mut chars = string.chars();

for c in chars {
    println!("{:?}", c);
}
# }
```

---

# Итерация

```rust
# fn main() {
let string = String::from("abc");
let chars = string.chars(); // Not Mutable!

for c in chars {
    println!("{:?}", c);
}
# }
```

---

# More control flow

All together now:

```rust
# //ignore
# fn main() {
let counts = [1, 2, 3, 4];
let mut counter = counts.iter();

if let Some(n) = counter.next() {
    print!("{}", n);
    while let Some(n) = counter.next() {
        print!(" and {}", n);
    }
    println!();
}
# }
```

---

# More control flow

All together now:

```rust
# fn main() {
let counts = [1, 2, 3, 4];
let mut counter = counts.iter();

if let Some(n) = counter.next() {
    print!("{}", n);
    while let Some(n) = counter.next() {
        print!(" and {}", n);
    }
    println!();
}
# }
```

---

# Pattern Matching

### Guards (допълнителни условия)

```rust
# //ignore
# fn main() {
let pair = (2, -2);

match pair {
    (x, y) if x == y                   => println!("Едно и също"),
    (x, y) if x + y == 0               => println!("Противоположни"),
    (x, y) if x % 2 == 1 && y % 2 == 0 => println!("X е нечетно, Y е четно"),
    (x, _) if x % 2 == 1               => println!("X е нечетно"),
    _                                  => println!("Нищо интересно"),
}
# }
```

---

# Pattern Matching

### Ranges

```rust
# //ignore
# fn main() {
let age: i32 = -5;

match age {
    n if n < 0 => println!("Ще се родя след {} години.", n.abs()),
    0          => println!("Новородено съм."),
    1 ... 12   => println!("Аз съм лапе."),
    13 ... 19  => println!("Аз съм тийн."),
    _          => println!("Аз съм дърт."),
}
# }
```

---

# Pattern Matching

### Bindings

```rust
# //ignore
# fn main() {
let age: i32 = -5;

match age {
    n if n < 0    => println!("Ще се родя след {} години.", n.abs()),
    0             => println!("Новородено съм."),
    n @ 1 ... 12  => println!("Аз съм лапе на {}.", n),
    n @ 13 ... 19 => println!("Аз съм тийн на {}.", n),
    n             => println!("Аз съм дърт, на {} съм вече.", n),
}
# }
```

---

# Pattern Matching

### Multiple patterns

```rust
# //ignore
# fn main() {
let score: u32 = 5;

match score {
    0 | 1 => println!("слабичко :("),
    _     => println!("стаа"),
}
# }
```

---

# Pattern Matching

### Structs

```rust
# //ignore
# fn main() {
struct User {
    name: &'static str,
    age: u8
}

let user = User {
    name: "Пешо",
    age: 12
};

match user {
    User { name: "Пешо", age: _ } => println!("Ко стаа, Пешо"),
    User { name: _, age: 12 }     => println!("Ко стаа, лапе"),
    User { name: x, .. }          => println!("Ко стаа, {}", x),
    _                             => println!("Ко стаа")
}
# }
```

---

# Destructuring

### ref

```rust
#[derive(Debug)]
enum Token { Text(String), Number(f64) }

fn main() {
    let token = Token::Text(String::from("Отговора е 42"));
    match token {
        Token::Text(text) => println!("Токена е текст: '{}'", text),
        Token::Number(n)  => println!("Токена е число: {}", n),
    }

    println!("В крайна сметка, токена е {:?}!", token);
}
```

---

# Destructuring

### ref

Чрез `ref` стойността няма да се премести.

```rust
# #[allow(dead_code)]
#[derive(Debug)]
enum Token { Text(String), Number(f64) }

fn main() {
    let token = Token::Text(String::from("Отговора е 42"));
    match token {
        Token::Text(ref text) => println!("Токена е текст: '{}'", text),
        Token::Number(n)      => println!("Токена е число: {}", n),
    }

    println!("В крайна сметка, токена е {:?}!", token);
}
```

---

# Destructuring

### ref

Какво всъщност прави `ref`? Едно просто обяснение е чрез пример:

```rust
# //ignore
# fn main() {
let x = &1;
let ref y = 1;
# }
```

--
* Двете променливи имат един и същ тип
--
* Първият пример взима референция с `&` в *дясната страна* на твърдението
--
* Вторият пример взима референция с `ref` в *лявата страна* на твърдението
--
* Това е важно, защото в `match` ръкава нямаме достъп до "дясната страна"

---

# Destructuring

### ref mut

Същата идея:

```rust
# //ignore
# fn main() {
let mut token = Token::Text(String::from("Отговора е 42"));

match token {
    Token::Text(ref mut text) => {
        *text = String::from("Може би");
        println!("Токена е Text('{}')", text)
    },
    Token::Number(n) => println!("Токена е Number({})", n),
}
# }
```

---

# Destructuring

### let

```rust
# //ignore
# fn main() {
let (mut a, b) = (1, 2);
let User { name: name, ..} = user;
let User { name, ..} = user;
let Some(val) = Some(5);    // ??
# }
```

---

# Destructuring

### let

```rust
# fn main() {
let (mut a, b) = (1, 2);
// let User { name: name, ..} = user;
// let User { name, ..} = user;
let Some(val) = Some(5);    // ??
# }
```

---

# Refutable/Irrefutable patterns

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

# Refutable/Irrefutable patterns

```rust
# #[allow(unused_variables)]
# fn main() {
if let (a, b) = (1, 2) {
    println!("Nope!");
}

let Some(val) = Some(5);
# }
```
