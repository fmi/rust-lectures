---
title: Здравей, Rust
author: Rust@FMI team
speaker: Андрей Радев
date: 7 октомври 2020
lang: bg
keywords: rust,fmi
description: Въведение
slide-width: 80%
font-size: 20px
font-family: Arial, Helvetica, sans-serif
# code blocks color theme
code-theme: github
---

# Hello, world!

Защото винаги от там се почва:

```rust
# //norun
fn main() {
    println!("Hello, world!");
}
```

---

# Компилация

Можем да използваме компилатора на Rust - `rustc`

--

```sh
$ rustc hello.rs
$ ./hello
Hello, world!
```

---

# Компилация

Но, разбира се, има по-лесен начин

--

```sh
$ cargo new hello
$ cargo run
Hello, world!
```

---

# Cargo

--
* Package manager
--
* Task runner
--
* Подобно на `mix` в elixir, `bundler` в ruby, `npm` в node.js

---

# Инсталация

--
* https://2017.fmi.rust-lang.bg/topics/1
--
* Rustup (https://rustup.rs/)
--
* `$ rustup install stable`
--
* `$ rustup doc`

---

# The Rust Book

https://doc.rust-lang.org/stable/book/

---

# Rust playpen

https://play.rust-lang.org/

---

# Променливи

Променливи се декларират с `let`

`let NAME = VALUE;`
`let NAME: TYPE = VALUE;`

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
let x = 5;
let y: i32 = 3;
# }
```

---

# Променливи

Всяка променлива има тип, но можем да не пишем типа, ако е ясен от контекста

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
let x: i32 = 5;
let y = x;      // типа на `y` е `i32`, защото `x` e `i32`
# }
```

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
let x = 5;      // типа на `x` е `i32`, защото `y` e `i32`
let y: i32 = x;
# }
```

---

# Променливи

### shadowing

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
let x = 10;
let x = x + 10;
let x = x * 3;
# }
```

---

# Променливи

### shadowing

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
let x1 = 10;
let x2 = x1 + 10;
let x3 = x2 * 3;
# }
```

---

# Променливи

### mutability

Променливите са immutable по подразбиране

```rust
# // ignore
let x = 5;
x += 1;
```

---

# Променливи

### mutability

Променливите са immutable по подразбиране

```rust
# // norun
# #[allow(unused_variables)]
# #[allow(unused_assignments)]
# fn main() {
let x = 5;
x += 1;
# }
```

---

# Променливи

### mutability

За да се направи mutable се използва ключовата дума `mut`

```rust
# // norun
# #[allow(unused_variables)]
# #[allow(unused_assignments)]
# fn main() {
let mut x = 5;
x += 1;
# }
```

---

# Основни типове

### Целочислени типове

- `i8`, `i16`, `i32`, `i64`, `i128`, `isize`
- `u8`, `u16`, `u32`, `u64`, `u128`, `usize`
--
- `iN` - цяло (signed) число с размер N бита
- `uN` - неотрицателно (unsigned) число с размер N бита
--
- `isize` и `usize` имат размер колкото машинната дума - 32 бита на 32 битов ОС и 64 бита на 64 битов ОС

---

# Основни типове

### Целочислени типове (литерали)

--
* Цяло число: `42`
* Специфичен тип: `42u32`
--
* Големи числа: `133_587`
* `42_u32`
--
* `1_0_0_0`
--
* `1_____________________________________________________4`

---

# Основни типове

### Целочислени типове (в различни бройни системи)

* Hex: `0xDEADBEEF`
* Octal: `0o77`
* Binary: `0b1010011010`

---

# Основни типове

### Числа с плаваща запетая

- `f32`
- `f64`
- съответно 32 битов и 64 битов float
- `3.14`
- `1.3_f64`

---

# Основни типове

### bool

- `bool`
- стойности `true` и `false`

---

# Основни типове

### unit

- тип `()`
- стойност `()`
--
- тип с една единствена стойност
- големина 0 байта, не носи информация
- използва се за функции които не връщат стойност
- и на други места

--

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let x: () = ();
# }
```

---

# Основни типове

### Низове

- `str`
--
- utf8 низ
- ще му обърнем повече внимание в бъдеща лекция.

--

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let s = "Нещо друго";
# }
```

--

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let s: &str = "Нещо друго";
# }
```

--

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let s: &'static str = "Нещо друго";
# }
```

---

# Основни типове

### Символи

- `char`
--
- unicode code point
- различно е от `u8`
- ще му обърнем внимание заедно с низовете

--
```rust
# fn main() {
let heart1: char = '❤';
let heart2: char = '\u{2764}';
let heart3: &str = "❤";

println!("{:?}", heart1);
println!("{:?}", heart2);
println!("{:?}", heart3);
# }
```

---

# Основни типове

### Масиви

- `[T; n]`

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let arr: [i32; 3] = [1, 2, 3];

let nested: [[i32; 3]; 2] = [
    [1, 2, 3],
    [4, 5, 6],
];
# }
```

---

# Основни типове

### Кортежи (tuples)

- `(A, B, C, ...)`

```rust
# #![allow(unused_variables)]
# fn main() {
let tuple: (i32, u32, bool) = (1, 2, false);
let unit: () = ();

println!("{}", tuple.0);
println!("{}", tuple.1);
println!("{}", tuple.2);
# }
```

---

# Основни типове

### Сравнение със C

@@table
Length Rust   Rust     C/C++  C/C++
Length Signed Unsigned Signed Unsigned
@
8-bit  i8    u8    ci8  cu8
16-bit i16   u16   ci16 cu16
32-bit i32   u32   ci32 cu32
64-bit i64   u64   ci64 cu64
word   isize usize cia  cua
@@
"ci8": "char",
"cu8": "unsigned char",
"ci16": "short",
"cu16": "unsigned short",
"ci32": "int",
"cu32": "unsigned int",
"ci64": "long long",
"cu64": "unsigned long long",
"cia": "long",
"cua": "unsigned long / size_t"
@@end

%%
| Length | Rust | C/C++  |
:-------:|:----:|:------:|
| 32-bit | f32  | float  |
| 64-bit | f64  | double |
%%
| Length | Rust | C++   |
:-------:|:----:|:-----:|
| 8-bit  | bool | bool  |
| -      |  ()  | void  |
%%
---

# Специфики

Няма автоматично конвертиране между различни числови типове

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let x: i32 = 1;
let y: u64 = x;
# }
```

---

# Специфики

Аритметични операции не могат да се прилагат върху различни типове

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let x = 4_u32 - 1_u8;
# }
```

---

# Специфики

Аритметични операции не могат да се прилагат върху различни типове

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let y = 1.2_f64 / 0.8_f32;
# }
```

---

# Специфики

За конвертиране между типове се използва ключовата дума `as`

```rust
# #[allow(unused_variables)]
# fn main() {
let one = true as u8;
let two_hundred = -56_i8 as u8;
let three = 3.14 as u32;

println!("one: {}\ntwo_hundred: {}\nthree: {}", one, two_hundred, three);
# }
```

---

# Специфики

В режим debug, аритметични операции хвърлят грешка при препълванe (integer overflow / underflow)

```rust
# #[allow(unused_variables)]
# fn main() {
let x = 255_u8;
let y = x + 1;                // 💥
println!("{}", y);
# }
```

---

# Специфики

Няма оператори `++` и `--`

```rust
# //ignore
x += 1;
x -= 1;
```

---

# Коментари

Едноредов коментар

```rust
# // ignore
// So we’re doing something complicated here, long enough that we need
// multiple lines of comments to do it! Whew! Hopefully, this comment will
// explain what’s going on.
```

Rust поддържа и блокови коментари

```rust
# // ignore
/*
So we’re doing something complicated here, long enough that we need
multiple lines of comments to do it! Whew! Hopefully, this comment will
explain what’s going on.
*/
```

---

# Control flow

### if-клаузи

Синтаксис на if-клауза

```rust
# //norun
# fn main() {
# let bool_expression = true;
# let another_bool_expression = false;
if bool_expression {
    // ...
} else if another_bool_expression {
    // ...
} else {
    // ...
}
# }
```

Забележете, че няма скоби около условието и скобите за блок `{ }` са задължителни.

---

# Control flow

### Цикли

`for` цикъла работи с итератори, за които ще говорим в бъдеща лекция

```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
# let iterable: &[()] = &[];
for var in iterable {
    // ...
}
# }
```

Отново няма скоби след `for` и скобите за блок `{ }` са задължителни.

---

# Control flow

### Цикли

Също така има и `while` и `loop` цикли.

```rust
# //norun
# fn main() {
# let bool_expression = false;
while bool_expression {
    // ...
}
# }
```

`loop` e същото като `while true`, но по-четимо.

```rust
# //norun
# fn main() {
loop {
    // ...
}
# }
```

---

# Statements & Expressions

### Израз (expression)

--
* нещо което може да се оцени
--
* `1`
--
* `(2 + 3) * 4`
--
* `add(5, 6)`
--
* (`add(5, 6);` също е израз, със стойност `()` -- повече за това по-нататък)

---

# Statements & Expressions

### Твърдение (statement)

--
* казва какво да се направи
--
* `let x = 10;`
--
* `return 25;`
--
* `fn add(a: i32, b: i32) { a + b }`
--
* `израз;`

---

# Statements & Expressions

### Твърдение (statement)

Пример: можем да присвояваме стойността на израз на променлива с `let`, но не и стойността на твърдение (защото няма стойност)

```rust
# #![allow(unused_variables)]
# #![allow(unused_parens)]
# fn main() {
let x = (fn add(a: i32, b: i32) { a + b });
# }
```

---

# Statements & Expressions

Много от конструкциите на езика са изрази.

Блоковете са израз - стойността им е стойността на последния израз в блока

```rust
fn main() {
    let x = {
        let a = 1;
        let b = 2;
        a + b
    };

    println!("x = {}", x);
}
```

---

# Statements & Expressions

if-else конструкцията е израз

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
# let a = 1; let b = 2;
let bigger = if a > b {
    a
} else {
    b
};
# }
```

По тази причина няма тернарен оператор

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
# let a = 1; let b = 2;
let bigger = if a > b { a } else { b };
# }
```

---

# Statements & Expressions

`loop` е израз

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
let x = loop {
    break 5;
};
# }
```

---

# Функции

```rust
fn main() {
    println!("Hello, world!");
    another_function();
}

fn another_function() {
    println!("Another function.");
}
```

---

# Функции

```rust
# //norun
# fn main() {}
# #[allow(dead_code)]
fn add(a: u32, b: u32) -> u32 {
    // note no semicolon
    a + b
}
```

--
* Задаването на типове на параметрите и резултата е задължително
--
* Върнатата стойност е стойността на последния израз в тялото на функцията

---

# Функции

```rust
# //norun
# fn main() {}
# #[allow(dead_code)]
fn print_a(a: u32) {
    println!("{}", a);
}

fn print_b(b: u32) -> () {
    println!("{}", b);
}
```

* Не е нужно да пишем `-> ()` за функции който не връщат резулат

---

# Функции

```rust
# //norun
# fn main() {}
# #[allow(dead_code)]
fn good_a(a: u32, a_is_bad: bool) -> u32 {
    if a_is_bad {
        return 0;
    }

    a
}
```

* Ако искаме да излезем от функцията преди последния ред, може да използваме `return`
* Използване на `return` на последния ред от тялото се счита за лоша практика

---

# Macros

* служат за генериране на код
* различават се от функциите по `!` след името
--
* `println!`
* `print!`
* `dbg!`

---

# println! macro

```rust
# fn main() {
let x = 5;
let y = "десет";
println!("x = {} and y = {}", x, y);
# }
```

--
* Принтиране на конзолата
--
* `{}` placeholders

---

# println! macro

```rust
# fn main() {
let x = 5;
let y = "десет";
println!("x = {:?} and y = {:?}", x, y);
# }
```

* Принтиране на конзолата
* `{:?}` placeholders

---

# dbg! macro

```rust
# fn main() {
let x = 5;
let y = "десет";

dbg!(x);
dbg!(y);
# }
```

---

# Административни неща

- Инсталирайте си Rust: https://2017.fmi.rust-lang.bg/topics/1
--
- Елате в Discord канала: https://discord.gg/r9Wcazk
--
- От другия път -- с парола! Вижте си секция "Табло" в сайта
--
- Първо предизвикателство (не много предизвикателно): https://fmi.rust-lang.bg/challenges/1
