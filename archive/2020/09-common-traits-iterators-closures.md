---
title: Често срещани типажи, итератори и анонимни функции
author: Rust@FMI team
speaker: Делян Добрев
date: 9 ноември 2020
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Често използвани типажи

--
Стандартната библиотека дефинира често използвани типажи
--
Голяма част от Rust екосистемата разчита на тях
--
Само ние можем да имплементираме стандартните trait-ове за наши типове
--
Затова, ако пишем библиотека, е добре да имплементираме всички стандартни trait-ове, които можем

---

# Често използвани типажи

### Списък

* Copy
* Clone
* Eq
* PartialEq
* Ord
* PartialOrd
* Hash
* Debug
* Display
* Default

---

# Clone

```rust
# // ignore
trait Clone {
    fn clone(&self) -> Self;

    fn clone_from(&mut self, source: &Self) { ... }
}
```

--
* Създава копие на обекта
--
* Позволява да си дефинираме собствена логика за копирането
--
* Поддържа `#[derive(Clone)]`, ако всички полета имплементират `Clone`
--
* Имплементацията от derive извиква `clone` на всички полета рекурсивно
--
* Рядко ще се налага да правим ръчна имплементация на `Clone`, защото не работим с гола памет!

---

# Copy

```rust
# // ignore
trait Copy: Clone { }
```

--
* Marker trait
--
* Показва, че стойността може да се копира чрез копиране на паметта байт по байт т.е. `memcopy`
--
* Променя се семантиката за присвояване на стойност от преместване (move) на копиране (copy)
--
* Изисква `Clone` да е имплементиран за съответния тип.
--
* Може да се добави с `#[derive(Copy)]`
--
* Или като цяло с `Clone` - `#[derive(Copy, Clone)]`, поредността няма значение

--

Можем да имплементираме Copy само ако:

--
* всички полета са `Copy`
--
* типа няма дефиниран деструктор (т.е. не е `Drop`)

---

# Drop

```rust
# // ignore
pub trait Drop {
    fn drop(&mut self);
}

```

--
* Позволява да дефинираме деструктори
--
* Метода се извиква автоматично, когато обекта излезе от scope
--
* Не може да се извика ръчно
--
* Вика се `drop` на всяко поле рекурсивно, ако имплементира `Drop`
--
* Можем да използваме `std::mem::drop` за да "накараме" drop-ване (просто move-ва стойността в себе си и приключва)

---

# Default

```rust
# // ignore
trait Default {
    fn default() -> Self;
}
```

--
* Позволява създаване на обект със стойност по подразбиране
--
* Може да се добави с `#[derive(Default)]`, ако всички полета имплементират `Default`
--
* Q: `Default` или `fn new() -> Self`
--
* A: и двете

---

# Hash

--
* Използва се от типове и функции, които използват хеширане
--
* Например ключовете на `HashMap` и `HashSet`
--
* Може да се добави с `#[derive(Hash)]`, ако всички полета имплементират `Hash`
--
* Няма да показваме ръчна имплементация

---

# Display & Debug

Вече сме виждали `#[derive(Debug)]`, сега ще разгледаме как да си имлементираме собствени `Display` и `Debug`
Те ни позволяват `format!`, `println!` и подобни макроси да работят за наш тип

```rust
# use std::fmt::{self, Display, Formatter};
# impl Display for MagicTrick {
#     fn fmt(&self, f: &mut Formatter) -> fmt::Result {
#         write!(f, "Магически трик {:?}", self.description)
#     }
# }
# #[derive(Debug)]
struct MagicTrick {
    description: String,
    secrets: Vec<String>,
    skills: Vec<String>,
}

# fn main() {
let trick = MagicTrick {
    description: String::from("Изчезваща монета"),
    secrets: vec![String::from("Монетата се прибира в ръкава")],
    skills: vec![String::from("Бързи ръце"), String::from("Заблуда")],
};

println!("{}", trick);
println!("===");
println!("{:?}", trick);
# }
```

---

# Display

--
* Използва се от placeholder-a `{}` за форматиране на стойност, която ще се показва на потребителя
--
* Не може да се derive-не за разлика от `Debug`

---

# Display

```rust
# #![allow(dead_code)]
# struct MagicTrick { description: String }
# fn main() {}
use std::fmt::{self, Display, Formatter};

impl Display for MagicTrick {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        write!(f, "Магически трик {:?}", self.description)
    }
}
```

---

# Display

Нека да разбием примера и да видим какво oзначават новите неща

---

# Макрос write

```rust
# #![allow(dead_code)]
# // ignore
write!(f, "Магически трик {:?}", self.description)
```
--
* Подобно на `print!` и `format!`
--
* Записва форматиран текст в структура, която имплементира `std::fmt::Write` или `std::io::Write`

---

# Formatter структура

* Записваме форматирания текст в нея
--
* Съдържа набор от полезни функции за форматира като `pad`, `precision`, `width`, `debug_struct` и други
--
* Не можем да я конструираме, стандартната библиотека ни я подава като извиква форматъра

---

# Display

```rust
# #![allow(dead_code)]
# use std::fmt::{self, Display, Formatter};
# impl Display for MagicTrick {
#     fn fmt(&self, f: &mut Formatter) -> fmt::Result {
#         write!(f, "Магически трик {:?}", self.description)
#     }
# }
struct MagicTrick {
    description: String,
    secrets: Vec<String>,
    skills: Vec<String>,
}

# fn main() {
let trick = MagicTrick {
    description: String::from("Изчезваща монета"),
    secrets: vec![String::from("Монетата се прибира в ръкава")],
    skills: vec![String::from("Бързи ръце"), String::from("Заблуда")],
};

println!("{}", trick);
# }
```

---

# Debug

--
* Използва се от placeholder-a `{:?}` за форматиране на стойност, която ще се показва само с цел debug
--
* Както знаете `#[derive(Debug)]` имплементира версия по подразбиране

---

# Debug

Може да напишем и собствена имплементация

```rust
# #![allow(dead_code)]
# fn main() {}
# struct MagicTrick {
#     description: String,
#     secrets: Vec<String>,
#     skills: Vec<String>
# }
use std::fmt::{self, Debug, Formatter};

impl Debug for MagicTrick {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        write! {
            f,
r#"Трик
Описание: {:?}
Тайни: {:?}
Умения: {:?}"#,
            self.description,
            self.secrets,
            self.skills
        }
    }
}
```

---

# Display & Debug

```rust
# #![allow(dead_code)]
# use std::fmt::{self, Display, Debug, Formatter};
# impl Display for MagicTrick {
#     fn fmt(&self, f: &mut Formatter) -> fmt::Result {
#         write!(f, "Магически трик {:?}", self.description)
#     }
# }
# impl Debug for MagicTrick {
#     fn fmt(&self, f: &mut Formatter) -> fmt::Result {
#         write! { f,
# r#"Трик
# Описание: {:?}
# Тайни: {:?}
# Умения: {:?}"#,
#             self.description, self.secrets, self.skills
#         }
#     }
# }
struct MagicTrick {
    description: String,
    secrets: Vec<String>,
    skills: Vec<String>,
}

# fn main() {
let trick = MagicTrick {
    description: String::from("Изчезваща монета"),
    secrets: vec![String::from("Монетата се прибира в ръкава")],
    skills: vec![String::from("Бързи ръце"), String::from("Заблуда")],
};

println!("{}", trick);
println!("===");
println!("{:?}", trick);
# }
```

---

# Предефиниране на оператори

Операторите се дефинират с trait-ове

Видяхме trait-а Add, с който дефинираме оператора +

```rust
# // ignore
trait Add<RHS = Self> {
    type Output;

    fn add(self, rhs: RHS) -> Self::Output;
}
```

---

# Предефиниране на оператори

### Примери

* `Add`, `Sub`, `Mul`, `Div`, `Rem`
* `BitAnd`, `BitOr`, `BitXor`, `Shl`, `Shr`
* `*Assign` (`AddAssign`, `SubAssign`, и т.н.)
* `Neg`, `Not`
* `Index`
* `IndexMut`

---

# Предефиниране на оператори

### PartialEq

```rust
# // ignore
trait PartialEq<Rhs = Self> where Rhs: ?Sized {
    fn eq(&self, other: &Rhs) -> bool;

    fn ne(&self, other: &Rhs) -> bool { ... }
}

```

--
* Дефинира операторите `==` и `!=`
--
* Не е задължително `a == a` да върне `true`
--
* `assert_eq!(::std::f64::NAN == ::std::f64::NAN, false);`

---

# Предефиниране на оператори

### Eq

```rust
# // ignore
trait Eq: PartialEq<Self> { }
```

--
* Marker trait
--
* Задължава `a == a` да е `true`

---

# Предефиниране на оператори

### PartialOrd

```rust
# // ignore
trait PartialOrd<Rhs = Self>: PartialEq<Rhs> where Rhs: ?Sized {
    fn partial_cmp(&self, other: &Rhs) -> Option<Ordering>;

    fn lt(&self, other: &Rhs) -> bool { ... }
    fn le(&self, other: &Rhs) -> bool { ... }
    fn gt(&self, other: &Rhs) -> bool { ... }
    fn ge(&self, other: &Rhs) -> bool { ... }
}

enum Ordering {
    Less,
    Equal,
    Greater,
}
```

---

# Предефиниране на оператори

### PartialOrd

Дефинира операторите `< <= > >=`

PartialOrd дефинира частична наредба

```rust
# fn main() {
assert_eq!(::std::f64::NAN < 0.0, false);
assert_eq!(::std::f64::NAN >= 0.0, false);
# }
```

---

# Предефиниране на оператори

### Ord

```rust
# // ignore
trait Ord: Eq + PartialOrd<Self> {
    fn cmp(&self, other: &Self) -> Ordering;

    fn max(self, other: Self) -> Self { ... }
    fn min(self, other: Self) -> Self { ... }
}
```

Дефинира тотална наредба т.е само едно от `a < b`, `a == b`, `a > b` е изпълнено.

---

# Итератори

![](images/iterator.jpeg)

---

# Итератори

Итераторите имплементират trait, който изглежда така:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // ... predefined iterator methods ...
}
```

---

# Итератори

Ето и как може да си имплементиране собствен итератор

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
struct OneTwoThree {
    state: u32,
}

impl OneTwoThree {
    fn new() -> Self {
        Self { state: 0 }
    }
}

impl Iterator for OneTwoThree {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.state < 3 {
            self.state += 1;
            Some(self.state)
        } else {
            None
        }
    }
}
```

---

# Итератори

```rust
# #![allow(dead_code)]
# struct OneTwoThree {
#     state: u32,
# }
# impl Iterator for OneTwoThree {
#     type Item = u32;
#     fn next(&mut self) -> Option<Self::Item> {
#         if self.state < 3 { self.state += 1 ; Some(self.state) } else { None }
#     }
# }
# impl OneTwoThree {
#     fn new() -> Self {
#         Self { state: 0 }
#     }
# }
fn main() {
    let mut iter = OneTwoThree::new();

    println!("{:?}", iter.next());
    println!("{:?}", iter.next());
    println!("{:?}", iter.next());
    println!("{:?}", iter.next());
    println!("{:?}", iter.next());
    // ...
}
```

---

# Итератори

### IntoIterator

Указва как може един тип да се конвертира до итератор.

```rust
# // ignore
trait IntoIterator
{
    type Item;
    type IntoIter: Iterator<Item=Self::Item>;
    fn into_iter(self) -> Self::IntoIter;
}
```

---

# Итератори

### IntoIterator

```rust
# #![allow(dead_code)]
# fn main() {
let v = vec![1, 2, 3];
let mut iter = v.into_iter();

while let Some(i) = iter.next() {
    println!("{}", i);
}
# }
```

---

# Итератори

### IntoIterator

Също така получаваме и благото да използваме типа директно във `for-in` цикли

Тъй като векторите имплементират този типаж, следните два примера са еднакви

%%
```rust
# #![allow(dead_code)]
# fn main() {
let v = vec![1, 2, 3];

for i in v.into_iter() {
    println!("{}", i);
}
# }
```
%%
```rust
# #![allow(dead_code)]
# fn main() {
let v = vec![1, 2, 3];

for i in v {
    println!("{}", i);
}
# }
```
%%

---

# Итератори

### for-in цикъл

Нека отбележим и доста важен факт, че всеки итератор има имплементиран `IntoIterator`

```rust
# // ignore
impl<I: Iterator> IntoIterator for I {
    type Item = I::Item;
    type IntoIter = I;

    fn into_iter(self) -> I {
        self
    }
}
```

---

# Итератори

### for-in цикъл

```rust
# #![allow(dead_code)]
# fn main() {
let values = vec![1, 2, 3];

for x in values {
    println!("{}", x);
}
# }
```

Rust генерира следният код зад всеки `for-in` цикъл:

```rust
# #![allow(dead_code)]
# fn main() {
let values = vec![1, 2, 3];
{
    let result = match IntoIterator::into_iter(values) {
        mut iter => loop {
            let next;
            match iter.next() {
                Some(val) => next = val,
                None => break,
            };
            let x = next;
            let () = { println!("{}", x); };
        },
    };
    result
}
# }
```

---

# Итератори

### FromIterator

Обратно на `IntoIterator`, `FromIterator` се използва за да укаже как един итератор да се конвертира до тип, най-често структура от данни.

```rust
# // ignore
trait FromIterator<A>: Sized {
    fn from_iter<T: IntoIterator<Item=A>>(iter: T) -> Self;
}
```

--
Ще видим как това е полезно при итератор адаптeрите.

---

# Итератори

### Vec

Има две интересни имплементации на `Iterator` за `Vec`, освен стандартната

```rust
# // ignore
impl<T> IntoIterator for Vec<T>

impl<'a, T> IntoIterator for &'a mut Vec<T>
impl<'a, T> IntoIterator for &'a Vec<T>
```

---

# Итератори

### Vec

които позволяват взаимно заменяемия код

%%
```rust
# fn main() {
let v = vec![1, 2, 3];
for i in v.iter() {
    println!("{}", i);
}
# }
```
%%
```rust
# fn main() {
let v = vec![1, 2, 3];
for i in &v {
    println!("{}", i);
}
# }
```
%%

---

# Итератори

### Vec

както и mutable версията

%%
```rust
# fn main() {
let mut v = vec![1, 2, 3];
for i in v.iter_mut() {
    *i += 1;
}
println!("{:?}", v);
# }
```
%%
```rust
# fn main() {
let mut v = vec![1, 2, 3];
for i in &mut v {
    *i += 1;
}
println!("{:?}", v);
# }
```
%%

---

# Итератори

### Адаптери

![](images/adapters.jpeg)

---

# Итератори

### Адаптери

```rust
# fn main() {
let v = vec![1, 2, 3];
let iter = v.into_iter().map(|x| x + 1).filter(|&x| x < 4);
for i in iter {
    println!("{}", i);
}
# }
```

--
* Това са функции които взимат итератор и връщат нов итератор.
--
* Най-често правят трансформации на данните.

---

# Итератори

### Адаптери

```rust
# fn main() {
let v = vec![1, 2, 3];
let v = v
    .into_iter()
    .map(|x| x + 1)
    .filter(|&x| x < 4)
    .collect::<Vec<_>>();

println!("{:?}", v);
# }
```

--
Това е възможно защото `collect` извиква вътрешно `FromIterator::from_iter`.

---

# Итератори

### Адаптери

Преди да правите някакви странни цикли за трансформация, разгледайте какви адаптери има за `Iterator`.

---

# Closures

![](images/closure.jpg)

---

# Closures

### syntax

```rust
# // ignore
|x: u32| -> u32 { x + 1 }
|x| { x + 1 }
|x| x + 1
```

---

# Closure vs fn

Каква е разликата между функция и closure?

Closures могат да използват променливи дефинирани по-горе в scope-a.

```rust
# // norun
fn main() {
    let other = String::from("foo");               // <-+
                                                   //   |
    Some("bar").map(|s| s.len() + other.len());    // --+
}
```

---

# Вътрешна имплементация

Зад кулисите компилаторът създава една структура и една функция

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
/// Структура в която запомняме променливите, които сме прихванали
struct State {
    other: String,
}

impl State {
    /// Функция която съдържа логиката
    fn call(&self, s: &str) -> usize {
        s.len() + self.other.len()
    }
}
```

---

# Вътрешна имплементация

```rust
# #![allow(dead_code)]
# struct State {
#     other: String,
# }
# impl State {
#     fn call(&self, s: &str) -> usize {
#         s.len() + self.other.len()
#     }
# }
fn map_option(opt: Option<&str>, f: State) -> Option<usize> {
    match opt {
        Some(s) => Some(f.call(s)),
        None => None,
    }
}

fn main() {
    let other = String::from("foo");

    map_option(Some("bar"), State { other });
}
```

---

# Move closure

Closure-ите, за разлика от нашата имплементация, не консумират прихванатите променливи по подразбиране

```rust
# #![allow(dead_code)]
# struct State {
#     other: String,
# }
# impl State {
#     fn call(&self, s: &str) -> usize {
#         s.len() + self.other.len()
#     }
# }
# fn map_option(opt: Option<&str>, f: State) -> Option<usize> {
#     match opt {
#         Some(s) => Some(f.call(s)),
#         None => None,
#     }
# }
# fn main() {
let other = String::from("foo");

println!("{:?}", Some("bar").map(|s| s.len() + other.len()));
println!("{:?}", other);       // Ок

println!("{:?}", map_option(Some("bar"), State { other }));
// println!("{:?}", other);    // комп. грешка - use of moved value `other`
# }
```

---

# Move closure

Можем да променим семантиката с ключовата дума move

%%
```rust
# // ignore
|s| s.len() + other.len();

// генерира
struct State<'a> {
    other: &'a String
}
```
%%
```rust
# // ignore
move |s| s.len() + other.len();

// генерира
struct State {
    other: String
}
```
%%

---

# Move closure

`move` премества стойността, независимо как се използва

```rust
# fn main() {
let nums = vec![0, 1, 2, 3];

// прихваща `nums` като `Vec<i32>`
let f = move || {
    for n in &nums {
        println!("{}", n);
    }
};
# }
```

---

# Move closure

Ако искаме да преместим някоя стойност, но да прихванем друга по референция:

%%
```rust
# fn main() {
let nums = vec![0, 1, 2, 3];
let s = String::from("cookies");

let f = || {
    // move `nums`
    let nums = nums;

    println!("{:?}", nums);
    println!("{:?}", s);
};

println!("{:?}", s);
# }
```
%%
```rust
# fn main() {
let nums = vec![0, 1, 2, 3];
let s = String::from("cookies");

let f = || {
    // move `nums`
    let nums = nums;

    println!("{:?}", nums);
    println!("{:?}", s);
};

println!("{:?}", nums);
# }
```
%%

---

# Move closure

Или с move closure:

%%
```rust
# fn main() {
let nums = vec![0, 1, 2, 3];
let s = &String::from("cookies");

let f = move || {
    println!("{:?}", nums);
    println!("{:?}", s);
};

println!("{:?}", s);
# }
```
%%
```rust
# fn main() {
let nums = vec![0, 1, 2, 3];
let s = &String::from("cookies");

let f = move || {
    println!("{:?}", nums);
    println!("{:?}", s);
};

println!("{:?}", nums);
# }
```
%%

---

# Fn traits

* `Fn`
* `FnMut`
* `FnOnce`

--

Имат специален синтаксис, например

* `Fn()`
* `FnMut(u32, u32) -> bool`
* `FnOnce() -> String`

---

# Fn traits

### FnOnce

```rust
# // ignore
// опростено
trait FnOnce<Args> {
    type Output;
    fn call_once(self, args: Args) -> Self::Output;
}

```

--
* `self`
--
* може да се извика само веднъж
--
* в комбинация с move closure може да се използва за прехвърляне на собственост

---

# Fn traits

### FnMut

```rust
# // ignore
// опростено
trait FnMut<Args>: FnOnce<Args> {
    fn call_mut(&mut self, args: Args) -> Self::Output;
}

```

--
* `&mut self`
--
* може да се вика множество пъти и да се променят прихванатите стойност

---

# Fn traits

### Fn

```rust
# // ignore
// опростено
trait Fn<Args>: FnMut<Args> {
    fn call(&self, args: Args) -> Self::Output;
}

```

--
* `&self`
--
* може да се вика множество пъти, но не могат да се променят прихванатите стойност

---

# Fn traits

Когато създадем closure, компилатора имплементира всички trait-ове, които може

--
* (`&`): `FnOnce` + `FnMut` + `Fn`
--
* (`&mut`): `FnOnce` + `FnMut`
--
* (ownership): `FnOnce`
--
* Не можем да имаме само `Fn` или `FnMut` заради ограниченията на трейтовете
--
* Ако това ви се струва странно, може да го мислите като ограниченията при взимане на референция `let x = ...` → `&mut x` → `&x`

---

# Taking closures

По-популярния начин за взимане на closure е чрез static dispatch

```rust
# // ignore
fn eval_and_increment<F>(f: F) -> usize where F: Fn???() -> usize {
    f() + 1
}

println!("{}", eval_and_increment(|| 1));
```

---

# Taking closures

Кой Fn trait да сложим за ограничение?

| Тип      | Прихващане на стойности                     | Брой викания   | Кога?                                          |
|----------|---------------------------------------------|----------------|------------------------------------------------|
| `FnOnce` | може да местим, променяме и четем стойности | веднъж         | move closures                                  |
| `FnMut`  | може да променяме и четем стойности         | множество пъти | викане множество пъти                          |
| `Fn`     | може да четем стойности                     | множество пъти | когато не можем да прихванем `&mut` референция |

--

или пробваме в този ред докато компилаторът ни разреши 😉

---

# Taking closures

```rust
fn eval_and_increment<F>(f: F) -> usize where F: FnOnce() -> usize {
    f() + 1
}

# fn main() {
println!("{}", eval_and_increment(|| 1));
# }
```

---

# Returning closures

### impl Trait

Не знаем типа на closure-a тъй като се генерира при компилиране, съответно това е един начин за връщане на closure

```rust
fn curry(a: u32) -> impl Fn(u32) -> u32 {
    move |b| a + b
}

# fn main() {
println!("{}", curry(1)(2));
# }
```

---

# impl Trait

Може да стои на мястото на типа на аргумент или return типа

```rust
use std::fmt::Debug;

fn id(arg: impl Debug) -> impl Debug {
    arg
}
# fn main() {
println!("{:?}", id(1));
println!("{:?}", id("foo"));
# }
```

---

# impl Trait

Не може да правите нищо друго с него освен това което имплементира

```rust
use std::fmt::Debug;

fn id(arg: impl Debug) -> impl Debug {
    arg
}
# fn main() {
println!("{}", id(1));
# }
```

---

# impl Trait

Разликата между `generics` и `impl Trait`

* generics поддържа turbofish синтаксис и изисква да се пише задължително при функция като `f<T>() -> T`
* impl Trait оставя компилатора да оправи типа включително и като return тип, но не може да използваме turbofish при извикване на функцията
