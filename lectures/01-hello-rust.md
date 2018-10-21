---
title: Здравей, Rust
author: Rust@FMI team
date: 04 октомври 2018
lang: bg
keywords: rust,fmi
description: Въведение
slide-width: 80%
font-size: 20px
font-family: Arial, Helvetica, sans-serif
# code blocks color theme
code-theme: github
outputDir: output
---

# Административни неща

- Сайт на курса (може би временен): https://fmi.rust-lang.bg/
--
- Лекции: https://fmi.rust-lang.bg/lectures
--
- Discord: https://discord.gg/FCTNfbZ

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

https://doc.rust-lang.org/book/2018-edition/

---

# Rust playpen

https://play.rust-lang.org/

---

# Променливи

Променливи се декларират с `let`

`let NAME = VALUE;`
`let NAME: TYPE = VALUE;`

Типът може се пропусне, ако е ясен от контекста.


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

### shadowing

```rust
# //norun
# #[allow(unused_variables)]
# fn main() {
let x = 10;
let x = x + 10;
let x = x * 3;
// ...
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
// ...
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

{
    let x = x + 10;

    {
        let x = x * 3;
        // ...
    }
}
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
# // ignore
let mut x = 5;
x += 1;
```

---

# Основни типове

### Целочислени типове

--
- `i8`, `i16`, `i32`, `i64`, `i128`, `isize`
- `u8`, `u16`, `u32`, `u64`, `u128`, `usize`
--
- `iN` - цяло (signed) число с размер N бита
--
- `uN` - неотрицателно (unsigned) число с размер N бита
--
- `isize` и `usize` имат размер колкото машинната дума - 32 бита на 32 битов ОС и 64 бита на 64 битов ОС

---

# Основни типове

### Целочислени типове (литерали)

--
* Цяло число: `42`
--
* Специфичен тип: `42u32`
--
* Големи числа: `133_587`
--
* `42_u32`
--
* `1_0_0_0`
--
* `1_____________________________________________________4`

---

# Основни типове

### Целочислени типове (в различни бройни системи)

--
* Hex: `0xDEADBEEF`
--
* Octal: `0o77`
--
* Binary: `0b1010011010`

---

# Основни типове

### Числа с плаваща запетая

--
- `f32`
- `f64`
--
- съответно 32 битов и 64 битов float

---

# Основни типове

### bool

--
- `bool`
--
- стойности `true` и `false`

---

# Основни типове

### unit

--
- `()`
--
- тип с големина 0 байта (zero sized type)
- тип без стойност (но не в смисъла на `null`)
- подобно на `void` в C/C++, но по-полезно
- използва се при generics

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

--
- `str`
--
- utf8 низ
- ще му обърнем повече внимание в бъдеща лекция.

--
```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let s: &str = "Rust рулит!!!";
# }
```

---

# Основни типове

### Символи

--
- `char`
--
- unicode code point
- различно е от `u8`
- ще му обърнем внимание заедно с низовете

--
```rust
# // norun
# #![allow(unused_variables)]
# fn main() {
let love: char = '❤';
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
# // norun
# #![allow(unused_variables)]
# fn main() {
let tuple: (i32, u32, bool) = (1, 2, false);
let unit: () = ();
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

| Length | Rust | C/C++  |
:-------:|:----:|:------:|
| 32-bit | f32  | float  |
| 64-bit | f64  | double |

| Rust | C/C++ |
|:----:|:-----:|
| bool | bool  |
|  ()  | void  |

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
let y = 1.2_f64 / 0.8_f32;
# }
```

---

# Специфики

За конвертиране между типове се използва ключовата дума `as`

```rust
# // norun
# #[allow(unused_variables)]
# fn main() {
let one = true as u8;
let two_hundred = -56_i8 as u8;
let three = 3.14 as u32;
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
# let iterator: &[()] = &[];
for var in iterator {
    // ...
}
# }
```

Отново няма скоби след `for` и скобите за блок `{ }` са задължителни.

---

# Control flow

### Цикли

Също така има и `while` и `loop` цикли.

`loop` e същото като `while true`, но по-четимо.

%%
```rust
# //norun
# fn main() {
# let bool_expression = false;
while bool_expression {
    // ...
}
# }
```
%%
```rust
# //norun
# fn main() {
loop {
    // ...
}
# }
```
%%

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
* Задаването на типове на параметрите и резултата е задължително (няма type inference)
--
* Върнатата стойност е стойността на последния израз в тялото на функцията
--
* Ако искаме да излезем от функцията преди последния ред, може да използваме `return`
--
* Използване на `return` на последния ред от тялото се счита за лоша практика

---

# Statements & Expressions

### Израз (expression)

--
* операция, която връща резултат
--
* `1`
--
* `(2 + 3) * 4`
--
* `add(5, 6)`

---

# Statements & Expressions

### Твърдение (statement)

--
* инструкция, която извършва някакво действие и няма резултат
--
* `let x = 10;`
--
* `return 25;`
--
* `fn add(a: i32, b: i32) { a + b }`
--
* ако добавим `;` след израз го превръщаме в твърдение

---

# Statements & Expressions

### Твърдение (statement)

Пример: можем да присвояваме стойността на израз на променлива с `let`, но не и стойността на твърдение (защото няма стойност)

```rust
# #![allow(unused_variables)]
# fn main() {
let x = (let y = 10);
# }
```

---

# Statements & Expressions

Много от констукциите на езика са изрази.

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

Rust няма тернарен оператор по тази причина

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

# Macros

--
* служат за генериране на код
--
* различават се от функциите по `!` след името
--
* `println!`
--
* `print!`

---

# println! macro

```rust
# fn main() {
let x = 5;
let y = 10;
println!("x = {} and y = {}", x, y);
# }
```

--
* Принтиране на конзолата
--
* `{}` placeholders
