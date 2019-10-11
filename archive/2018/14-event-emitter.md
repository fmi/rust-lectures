---
title: Анонимни функции II
author: Rust@FMI team
date: 22 ноември 2018
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Преговор

### Fn traits

* `Fn`
* `FnMut`
* `FnOnce`

---

# Преговор

move премества стойността, независимо как се използва

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

# Moving closure captures

Няколко трика ако искаме да преместим някоя стойност, но да прихванем друга по референция

```rust
# fn main() {
let nums = vec![0, 1, 2, 3];
let s = String::from("cookies");

let f = || {
    let nums = nums;         // move `nums`

    println!("{:?}", nums);
    println!("{:?}", s);
};

// println!("{:?}", nums);   // комп. грешка
println!("{:?}", s);
# }
```

---

# Moving closure captures

```rust
# fn main() {
let nums = vec![0, 1, 2, 3];
let s = String::from("cookies");

{
    let s = &s;             // move `s: &String`

    let f = move || {
        println!("{:?}", nums);
        println!("{:?}", s);
    };
}

// println!("{:?}", nums);   // комп. грешка
println!("{:?}", s);
# }
```

---

# Saving closures

Да си направим адаптер за итератор, който работи подобно на
адаптера връщан от `Iterator::map()`

```rust
# // norun
# fn main() {}
struct Map<I, F, B> where
    I: Iterator,
    F: FnMut(I::Item) -> B
{
    iter: I,
    f: F,
}
```

---

# Saving closures

Имплементираме `Iterator`

```rust
# // norun
# struct Map<I, F, B> where I: Iterator, F: FnMut(I::Item) -> B {
#     iter: I,
#     f: F,
# }
# fn main() {}
impl<I, F, B> Iterator for Map<I, F, B> where
    I: Iterator,
    F: FnMut(I::Item) -> B
{
    type Item = B;

    fn next(&mut self) -> Option<Self::Item> {
        match self.iter.next() {
            Some(item) => Some((self.f)(item)),
            None => None,
        }
    }
}
```

---

# Saving closures

Малко улеснение

```rust
# // norun
# struct Map<I, F, B> where I: Iterator, F: FnMut(I::Item) -> B {
#     iter: I,
#     f: F,
# }
# fn main() {}
impl<I, F, B> Iterator for Map<I, F, B> where
    I: Iterator,
    F: FnMut(I::Item) -> B
{
    type Item = B;

    fn next(&mut self) -> Option<Self::Item> {
        self.iter.next().map(|x| (self.f)(x))
    }
}
```

---

# Saving closures

```rust
# struct Map<I, F, B> where I: Iterator, F: FnMut(I::Item) -> B {
#     iter: I,
#     f: F,
# }
# impl<I, F, B> Iterator for Map<I, F, B> where
#     I: Iterator,
#     F: FnMut(I::Item) -> B
# {
#     type Item = B;
#     fn next(&mut self) -> Option<Self::Item> {
#         self.iter.next().map(|x| (self.f)(x))
#     }
# }
# fn main() {
// vec![1, 2, 3].into_iter().map(|x| x * 3)

let map = Map {
    iter: vec![1, 2, 3].into_iter(),
    f: |x| x * 3,
};

let v = map.collect::<Vec<_>>();
println!("{:?}", v);
# }
```

---

# Returning closures

```rust
# // ignore
fn get_incrementer() -> ??? {
    |x| x + 1
}
```

---

# Returning closures

Да проверим какъв е типът на closure-а

```rust
# // ignore
let _: () = |x| x + 1;
```

---

# Returning closures

Да проверим какъв е типът на closure-а

```rust
# fn main() {
let _: () = |x| x + 1;
# }
```

Тип генериран от компилатора, това не ни е полезно

---

# Returning closures

### Вариант 1

Ако closure не прихваща променливи, той може автоматично да се сведе до указател към функция

```rust
# // norun
# fn main() {}
fn get_incrementer() -> fn(i32) -> i32 {
    |x| x + 1
}
```

---

# Returning closures

### Вариант 2

Често се налага да прихванем променливи

```rust
# // ignore
fn curry(a: u32) -> ??? {
    |b| a + b
}
```

---

# Returning closures

### Вариант 2

Можем да използваме Trait objects

%%
```rust
# // norun
# fn main() {}
struct F<'a> {
    closure: &'a Fn()
}
```
%%
```rust
# // norun
# fn main() {}
struct F {
    closure: Box<Fn()>
}
```
%%

---

# Returning closures

### Вариант 2

Така дали ще е добре?

```rust
# // ignore
fn curry(a: u32) -> Box<Fn(u32) -> u32> {
    Box::new(|b| a + b)
}
```

---

# Returning closures

### Вариант 2

Така дали ще е добре?

```rust
# // norun
# fn main() {}
fn curry(a: u32) -> Box<Fn(u32) -> u32> {
    Box::new(|b| a + b)
}
```

---

# Returning closures

### Вариант 2

move

```rust
fn curry(a: u32) -> Box<Fn(u32) -> u32> {
    Box::new(move |b| a + b)
}
# fn main() {
assert_eq!(curry(1)(2), 3);
# }
```

---

# Closures & lifetimes

```rust
# fn main() {}
fn curry<'a>(a: &'a u32) -> Box<Fn(&u32) -> u32> {
    Box::new(move |b| a + b)
}
```

---

# Closures & lifetimes

```rust
# // ignore
struct State<'b> {
    a: &'b u32
}

// impl Fn, FnMut, FnOnce for State

fn curry<'a>(a: &'a u32) -> Box<State<'a>> {
    let state = State { a };    // State<'a>
    Box::new(state)             // очаква 'static
}
```

---

# Closures & lifetimes

### Lifetime на структура

Какво означава обект (който не е референция) да има 'static lifetime

Lifetime-а показва максимално ограничение до което може да живее някаква стойност

```rust
# fn main() {
struct Foo<'a> { a: &'a i32 }

{
    let a = 10;                     // ---+- 'a
                                    //    |
    let foo = Foo { a: &a };        // ---+- foo: 'a
                                    //    |
}                                   // <--+
# }
```

---

# Closures & lifetimes

### Lifetime на структура

Когато обект не държи референции няма такова ограничение

Затова се приема че обекта има 'static lifetime

```rust
# fn main() {
struct Foo { a: i32 }

{
    let a = 10;

    let foo = Foo { a: a };         // foo: 'static
}
# }
```

---

# Closures & lifetimes

По подразбиране се очаква trait object-а да няма такова ограничение

`Box<Fn(&u32) -> u32> -> Box<Fn(&u32) -> u32 + 'static>`;

Ако имаме ограничение трябва да го укажем изрично

```rust
fn curry<'a>(a: &'a u32) -> Box<Fn(&u32) -> u32 + 'a> {
    Box::new(move |b| a + b)
}
# fn main() {
assert_eq!(curry(&1)(&2), 3);
# }
```

---

# Returning closures

### Вариант 3 (impl Trait)

```rust
fn curry(a: u32) -> impl Fn(u32) -> u32 {
    move |b| a + b
}
# fn main() {
assert_eq!(curry(1)(2), 3);
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

---

# EventEmitter

### layout

Нека опитаме да напишем прост event emitter със следните изисквания:

--
* Generic по типа на съобщенията и типа на данните които се излъчват
--
* `on` - регистрира слушател
--
* `off` - премахва слушател
--
* `emit` - излъчва съобщение с данни

---

# EventEmitter

Пълният код може да се разгледа в Github - [https://github.com/d3lio/simple-event-emitter](https://github.com/d3lio/simple-event-emitter)

---

# EventEmitter

### usage

```rust
# // ignore
let mut emitter = EventEmitter::new();

let _  = emitter.on("woot", |p: String| println!("{}", p));
let id = emitter.on("woot", |_| println!("hi"));

emitter.off(id);

emitter.emit("woot", "boot".to_string());
```

---

# EventEmitter

### structures

Ето как би изглеждала структурата

```rust
# // ignore
struct EventEmitter<E, P> {
    map: HashMap<E, Vec<Box<Fn(P)>>>
}
```

---

# EventEmitter

### structures

Изглежда лесно...

---

# EventEmitter

### structures

Но нещата не са толкова прости

```rust
# // norun
# fn main() {}
# use std::collections::HashMap;
struct EventEmitter<E, P> {
    map: HashMap<E, Vec<Box<Fn(P)>>>
}
```

---

# EventEmitter

### structures

```rust
# // norun
# fn main() {}
# use std::collections::HashMap;
# use std::hash::Hash;
type Id = u64;

struct Listener<P> {
    id: Id,
    closure: Box<Fn(P)>
}

struct EventEmitter<E, P> where E: Eq + Hash, P: Clone {
    next_id: Id,
    map: HashMap<E, Vec<Listener<P>>>
}
```

---

# EventEmitter

### constructors

```rust
# // norun
# use std::collections::HashMap;
# use std::hash::Hash;
# fn main() {}
# type Id = u64;
# struct Listener<P> {
#     id: Id,
#     closure: Box<Fn(P)>
# }
# struct EventEmitter<E, P> where E: Eq + Hash, P: Clone {
#     next_id: Id,
#     map: HashMap<E, Vec<Listener<P>>>
# }
impl<P> Listener<P> {
    fn new<F>(id: Id, f: F) -> Self where F: Fn(P) + 'static {
        Self {
            id,
            closure: Box::new(f)
        }
    }
}

impl<E, P> EventEmitter<E, P> where E: Eq + Hash, P: Clone {
    fn new() -> Self {
        Self {
            next_id: Id::default(),
            map: HashMap::new()
        }
    }
}
```

---

# EventEmitter

### on

Място, където map::Entry ще ни улесни

```rust
# // norun
# use std::collections::HashMap;
# use std::hash::Hash;
# fn main() {}
# type Id = u64;
# struct Listener<P> {
#     id: Id,
#     closure: Box<Fn(P)>
# }
# struct EventEmitter<E, P> where E: Eq + Hash, P: Clone {
#     next_id: Id,
#     map: HashMap<E, Vec<Listener<P>>>
# }
# impl<P> Listener<P> {
#     fn new<F>(id: Id, f: F) -> Self where F: Fn(P) + 'static {
#         Self {
#             id,
#             closure: Box::new(f)
#         }
#     }
# }
impl<E, P> EventEmitter<E, P> where E: Eq + Hash, P: Clone {
    fn on<F>(&mut self, event: E, listener: F) -> Id where F: Fn(P) + 'static {
        let id = self.next_id;
        let listeners = self.map.entry(event).or_insert(Vec::new());

        listeners.push(Listener::new(self.next_id, listener));

        self.next_id += 1;
        id
    }
}
```

---

# EventEmitter

### off

```rust
# // norun
# fn main() {}
# use std::collections::HashMap;
# use std::hash::Hash;
# type Id = u64;
# struct Listener<P> {
#     id: Id,
#     closure: Box<Fn(P)>
# }
# struct EventEmitter<E, P> where E: Eq + Hash, P: Clone {
#     next_id: Id,
#     map: HashMap<E, Vec<Listener<P>>>
# }
impl<E, P> EventEmitter<E, P> where E: Eq + Hash, P: Clone {
    fn off(&mut self, id: Id) -> bool {
        for (_, listeners) in self.map.iter_mut() {
            let position = listeners.iter().position(|x| x.id == id);

            if let Some(idx) = position {
                listeners.remove(idx);
                return true;
            }
        }

        false
    }
}
```

---

# EventEmitter

### emit

Ето една възможност да използваме `Borrow`

```rust
# // norun
# fn main() {}
# use std::collections::HashMap;
# use std::hash::Hash;
# use std::borrow::Borrow;
# type Id = u64;
# struct Listener<P> {
#     id: Id,
#     closure: Box<Fn(P)>
# }
# struct EventEmitter<E, P> where E: Eq + Hash, P: Clone {
#     next_id: Id,
#     map: HashMap<E, Vec<Listener<P>>>
# }
impl<E, P> EventEmitter<E, P> where E: Eq + Hash, P: Clone {
    fn emit<B>(&self, event: &B, payload: P) -> bool
    where E: Borrow<B>, B: ?Sized + Hash + Eq {
        match self.map.get(event) {
            Some(listeners) => {
                // Клонираме данните, за да може да ги подадем на всички слушатели
                listeners.iter().for_each(|f| (f.closure)(payload.clone()));
                true
            },
            None => false
        }
    }
}
```

---

# Borrow

Какво точно прави този типаж?

---

# Borrow

```rust
# // norun
# fn main() {}
pub trait Borrow<Borrowed> where Borrowed: ?Sized {
    fn borrow(&self) -> &Borrowed;
}
```

---

# Borrow

Позволява ни да абстрахираме даден тип и да кажем, че искаме да получаваме всеки тип, който се конвертира до желания тип. В случая на този пример искаме да приемаме всичко, което може да се заеме като `str`.

```rust
use std::borrow::Borrow;

fn check<T: Borrow<str>>(s: T) {
    println!("{}", s.borrow());
}

# fn main() {
// В стандартната библиотека има impl Borrow<str> for String
let s = "Hello".to_string();

check(s);

let s = "Hello";

check(s);
# }
```

---

# Event emitter

До тук какво имаме

---

# Event emitter

```rust
# // ignore
struct EventEmitter<E, P> where E: Eq + Hash, P: Clone {
    next_id: Id,
    map: HashMap<E, Vec<Listener<P>>>
}

impl<E, P> EventEmitter<E, P> where E: Eq + Hash, P: Clone {
    fn new() -> Self { ... }

    /// Регистрира слушател
    fn on<F>(&mut self, event: E, listener: F) -> Id
    where F: Fn(P) + 'static { ... }

    /// Премахва слушател
    fn off(&mut self, id: Id) -> bool { ... }

    /// Излъчва съобщение с данни
    fn emit<B>(&self, event: &B, payload: P) -> bool
    where E: Borrow<B>, B: ?Sized + Hash + Eq { ... }
}
```

---

# Event emitter

Тази имплементация има един проблем - какво става, ако излъчваме големи данни? Ще ги копираме всеки път като ги подаваме на event handler. Тогава бихме искали да подадем данните чрез референция.

```rust
# // ignore
# fn main() {
let mut emitter = EventEmitter::new();
emitter.on("woot", |p: &str| println!("{}", p));

let data = "boot".to_string();
emitter.emit("woot", &data);
# }
```

---

# Event emitter

```rust
# use std::collections::HashMap;
# use std::hash::Hash;
# use std::borrow::Borrow;
# type Id = u64;
# struct Listener<P> {
#     id: Id,
#     closure: Box<Fn(P)>
# }
# struct EventEmitter<E, P> where E: Eq + Hash, P: Clone {
#     next_id: Id,
#     map: HashMap<E, Vec<Listener<P>>>
# }
# impl<P> Listener<P> {
#     fn new<F>(id: Id, f: F) -> Self where F: Fn(P) + 'static {
#         Self {
#             id,
#             closure: Box::new(f)
#         }
#     }
# }
# impl<E, P> EventEmitter<E, P> where E: Eq + Hash, P: Clone {
#     fn new() -> Self {
#         Self {
#             next_id: Id::default(),
#             map: HashMap::new()
#         }
#     }
#     fn on<F>(&mut self, event: E, listener: F) -> Id where F: Fn(P) + 'static {
#         let id = self.next_id;
#         let listeners = self.map.entry(event).or_insert(Vec::new());
#         listeners.push(Listener::new(self.next_id, listener));
#         self.next_id += 1;
#         id
#     }
#     fn emit<B>(&self, event: &B, payload: P) -> bool
#     where E: Borrow<B>, B: ?Sized + Hash + Eq {
#         match self.map.get(event) {
#             Some(listeners) => {
#                 listeners.iter().for_each(|f| (f.closure)(payload.clone()));
#                 true
#             },
#             None => false
#         }
#     }
# }
# fn main() {
let mut emitter = EventEmitter::new();
emitter.on("woot", |p: &str| println!("{}", p));

let data = "boot".to_string();
emitter.emit("woot", &data);
# }
```

Защо?

---

# Event emitter

Още по-странно, ако преместим data над emitter, всичко работи

```rust
# use std::collections::HashMap;
# use std::hash::Hash;
# use std::borrow::Borrow;
# type Id = u64;
# struct Listener<P> {
#     id: Id,
#     closure: Box<Fn(P)>
# }
# struct EventEmitter<E, P> where E: Eq + Hash, P: Clone {
#     next_id: Id,
#     map: HashMap<E, Vec<Listener<P>>>
# }
# impl<P> Listener<P> {
#     fn new<F>(id: Id, f: F) -> Self where F: Fn(P) + 'static {
#         Self {
#             id,
#             closure: Box::new(f)
#         }
#     }
# }
# impl<E, P> EventEmitter<E, P> where E: Eq + Hash, P: Clone {
#     fn new() -> Self {
#         Self {
#             next_id: Id::default(),
#             map: HashMap::new()
#         }
#     }
#     fn on<F>(&mut self, event: E, listener: F) -> Id where F: Fn(P) + 'static {
#         let id = self.next_id;
#         let listeners = self.map.entry(event).or_insert(Vec::new());
#         listeners.push(Listener::new(self.next_id, listener));
#         self.next_id += 1;
#         id
#     }
#     fn off(&mut self, id: Id) -> bool {
#         for (_, listeners) in self.map.iter_mut() {
#             let position = listeners.iter().position(|x| x.id == id);
#             if let Some(idx) = position {
#                 listeners.remove(idx);
#                 return true;
#             }
#         }
#         false
#     }
#     fn emit<B>(&self, event: &B, payload: P) -> bool
#     where E: Borrow<B>, B: ?Sized + Hash + Eq {
#         match self.map.get(event) {
#             Some(listeners) => {
#                 listeners.iter().for_each(|f| (f.closure)(payload.clone()));
#                 true
#             },
#             None => false
#         }
#     }
# }
# fn main() {
let data = "boot".to_string();

let mut emitter = EventEmitter::new();
emitter.on("woot", |p: &str| println!("{}", p));

emitter.emit("woot", &data);
# }
```

---

# Event emitter

emitter няма lifetime, но иска да живее повече от data...

... а дали е така?

---

# Event emitter

```rust
# // ignore
emitter.emit("boot", &data);

fn emit<B>(&self, event: B, payload: P) -> bool where B: Borrow<E> { ... }

// => P = &'a str
```

---

# Event emitter

```rust
# // ignore
let mut emitter = EventEmitter::new();            // EventEmitter<E = ?, P = ?>
emitter.on("woot", |p: &str| println!("{}", p));  // EventEmitter<&'static str, &'??? str>

let data = "boot".to_string();
emitter.emit("woot", &data);                      // EventEmitter<&'static str, &'a str>
```

P ограничава колко може да живее emitter

---

# Event emitter

Решението: `P -> &P`

```rust
# // ignore
fn emit<B>(&self, event: &B, payload: &P) -> bool
where E: Borrow<B>, B: ?Sized + Hash + Eq { ... }

struct Listener<P> {
    id: Id,
    closure: Box<Fn(&P)>
}
```

---

# Event emitter

```rust
# use std::collections::HashMap;
# use std::hash::Hash;
# use std::borrow::Borrow;
# type Id = u64;
# struct Listener<P> {
#     id: Id,
#     closure: Box<Fn(&P)>
# }
# struct EventEmitter<E, P> where E: Eq + Hash {
#     next_id: Id,
#     map: HashMap<E, Vec<Listener<P>>>
# }
# impl<P> Listener<P> {
#     fn new<F>(id: Id, f: F) -> Self where F: Fn(&P) + 'static {
#         Self {
#             id,
#             closure: Box::new(f)
#         }
#     }
# }
# impl<E, P> EventEmitter<E, P> where E: Eq + Hash {
#     fn new() -> Self {
#         Self {
#             next_id: Id::default(),
#             map: HashMap::new()
#         }
#     }
#     fn on<F>(&mut self, event: E, listener: F) -> Id where F: Fn(&P) + 'static {
#         let id = self.next_id;
#         let listeners = self.map.entry(event).or_insert(Vec::new());
#
#         listeners.push(Listener::new(self.next_id, listener));
#
#         self.next_id += 1;
#         id
#     }
#     fn off(&mut self, id: Id) -> bool {
#         for (_, listeners) in self.map.iter_mut() {
#             let position = listeners.iter().position(|x| x.id == id);
#
#             if let Some(idx) = position {
#                 listeners.remove(idx);
#                 return true;
#             }
#         }
#         false
#     }
#     fn emit<B>(&self, event: &B, payload: &P) -> bool
#     where E: Borrow<B>, B: ?Sized + Hash + Eq {
#
#         match self.map.get(event) {
#             Some(listeners) => {
#                 listeners.iter().for_each(|f| (f.closure)(payload.clone()));
#                 true
#             },
#             None => false
#         }
#     }
# }
# fn main() {
let mut emitter = EventEmitter::new();
emitter.on("woot", |p: &str| println!("{}", p));

let data = "boot".to_string();
emitter.emit("woot", &data);
# }
```

---

# Event emitter

Добре, тъй като си избрахме като тип `&str` имаме да решим допълнителен проблем.

P се опитва да бъде `str`, който не е Sized и на компилатора не му харесва,
защото по подразбиране всеки тип трябва да е Sized.

---

# Event emitter

С подсказките от компилатора и това че използваме P само зад референция (&P) можем спокойно да добавим "ограничение" `?Sized`

```rust
# use std::collections::HashMap;
# use std::hash::Hash;
# use std::borrow::Borrow;
# type Id = u64;
struct Listener<P> where P: ?Sized {
    // ...
#     id: Id,
#     closure: Box<Fn(&P)>
}

impl<P> Listener<P> where P: ?Sized {
    // ...
#     fn new<F>(id: Id, f: F) -> Self
#     where F: Fn(&P) + 'static {
#         Self { id, closure: Box::new(f) }
#     }
}

struct EventEmitter<E, P> where E: Eq + Hash, P: ?Sized {
    // ...
#     next_id: Id,
#     map: HashMap<E, Vec<Listener<P>>>
}

impl<E, P> EventEmitter<E, P> where E: Eq + Hash, P: ?Sized {
    // ...
#     fn new() -> Self {
#         Self {
#             next_id: Id::default(),
#             map: HashMap::new()
#         }
#     }
#     fn on<F>(&mut self, event: E, listener: F) -> Id
#     where F: Fn(&P) + 'static {
#         let id = self.next_id;
#         let listeners = self.map.entry(event).or_insert(Vec::new());
#         listeners.push(Listener::new(self.next_id, listener));
#         self.next_id += 1;
#         id
#     }
#     fn off(&mut self, id: Id) -> bool {
#         for (_, listeners) in self.map.iter_mut() {
#             let position = listeners.iter().position(|x| x.id == id);
#
#             if let Some(idx) = position {
#                 listeners.remove(idx);
#                 return true;
#             }
#         }
#         false
#     }
#     fn emit<B>(&self, event: &B, payload: &P) -> bool
#     where E: Borrow<B>, B: ?Sized + Hash + Eq {
#         match self.map.get(event) {
#             Some(listeners) => {
#                 listeners.iter().for_each(|f| (f.closure)(payload.clone()));
#                 true
#             },
#             None => false
#         }
#     }
}

fn main() {
    let mut emitter = EventEmitter::new();
    emitter.on("woot", |p: &str| println!("{}", p));

    let data = "boot".to_string();
    emitter.emit("woot", &data);
}
```

---

# Networking

Стандартната библиотека имплементира networking примитиви в модула std::net

---

# UDP

### UdpSocket

```rust
# // norun
use std::net::UdpSocket;

// сокета се затваря на края на scope-a
fn main() {
    let mut socket = UdpSocket::bind("127.0.0.1:34254").unwrap();

    // Получава една дейтаграма от сокета. Ако буфера е прекалено малък за съобщението,
    // то ще бъде орязано.
    let mut buf = [0; 10];
    let (amt, src) = socket.recv_from(&mut buf).unwrap();

    // Редекларира `buf` като слайс от получените данни и ги праща в обратен ред.
    let buf = &mut buf[..amt];
    buf.reverse();
    socket.send_to(buf, &src).unwrap();
}
```

---

# TCP

### TcpStream

```rust
# // norun
use std::io::prelude::*;
use std::net::TcpStream;

// стриймът се затваря на края на scope-a
fn main() {
    let mut stream = TcpStream::connect("127.0.0.1:34254").unwrap();

    let _ = stream.write(&[1]);
    let _ = stream.read(&mut [0; 128]);
}
```

---

# TCP

### TcpListener

```rust
# // norun
use std::net::{TcpListener, TcpStream};

fn handle_client(stream: TcpStream) {
    // ...
}

fn main() {
    let listener = TcpListener::bind("127.0.0.1:80").unwrap();

    // примера конекции и ги обработва
    for stream in listener.incoming() {
        handle_client(stream.unwrap());
    }
}
```

---

# TCP

### Simple chat

Ще разгледаме проста чат система за демонстрация на нишки, канали и TCP

Пълният код може да се разгледа в Github - [https://github.com/d3lio/simple-chat](https://github.com/d3lio/simple-chat)

---

# TCP

### Simple chat

Какво няма да обхванем:


--
* Няма да се занимаваме със целия error handling
--
* Няма да използваме най-оптималните подходи, все пак е проста система

---

# Simple chat

### Server

```rust
# // norun
use std::net::{TcpListener, TcpStream};
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

const LOCALHOST: &str = "127.0.0.1:1234";
const MESSAGE_SIZE: usize = 32;

fn main() {
    let server = TcpListener::bind(LOCALHOST).expect("Listener failed to bind");
    server.set_nonblocking(true).expect("Failed to initialize nonblocking");

    // Stores client sockets
    let mut clients = Vec::<TcpStream>::new();
    let (sx, rx) = mpsc::channel::<String>();

    loop {
        /* accept */
        /* broadcast */
        thread::sleep(Duration::from_millis(100));
    }
}
```

---

# Server

```rust
# // norun
use std::io::{ErrorKind, Read, Write};
use std::net::TcpListener;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn sleep() {
    thread::sleep(Duration::from_millis(100));
}

const LOCALHOST: &str = "127.0.0.1:1234";
const MESSAGE_SIZE: usize = 32;

fn main() {
    let server = TcpListener::bind(LOCALHOST).expect("Listener failed to bind");
    server.set_nonblocking(true).expect("Failed to initialize nonblocking");

    let mut clients = Vec::new();
    let (sx, rx) = mpsc::channel::<String>();

    loop {
        // Try to accept a client
        if let Ok((mut socket, addr)) = server.accept() {
            println!("Client {} connected", addr);

            let sx = sx.clone();

            clients.push(socket.try_clone().expect("Failed to clone client"));

            thread::spawn(move || loop {
                let mut buf = vec![0; MESSAGE_SIZE];

                // Try to receive message from client
                match socket.read_exact(&mut buf) {
                    Ok(_) => {
                        let msg = buf.into_iter().take_while(|&x| x != 0).collect::<Vec<_>>();
                        let msg = String::from_utf8(msg).expect("Invalid utf8 message");

                        println!("{}: {:?}", addr, msg);
                        sx.send(msg).expect("Send to master channel failed");
                    },
                    Err(ref err) if err.kind() == ErrorKind::WouldBlock => (),
                    Err(_) => {
                        println!("Closing connection with: {}", addr);
                        break;
                    }
                }

                sleep();
            });
        }

        if let Ok(msg) = rx.try_recv() {
            // Try to send message from master channel
            clients = clients.into_iter().filter_map(|mut client| {
                let mut buf = msg.clone().into_bytes();
                buf.resize(MESSAGE_SIZE, 0);

                client.write_all(&buf).map(|_| client).ok()
            }).collect::<Vec<_>>();
        }

        sleep();
    }
}
```

---

# Simple chat

### Client

```rust
# // norun
use std::net::TcpStream;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

const LOCALHOST: &str = "127.0.0.1:1234";
const MESSAGE_SIZE: usize = 32;

fn main() {
    let mut client = TcpStream::connect(LOCALHOST).expect("Stream failed to connect");
    client.set_nonblocking(true).expect("Failed to initialize nonblocking");

    let (sx, rx) = mpsc::channel::<String>();

    thread::spawn(move || loop {
        /* try recv */
        /* try send */
        thread::sleep(Duration::from_millis(100));
    });

    /* repl */
}
```

---

# Client

```rust
# // norun
use std::io::{self, ErrorKind, Read, Write};
use std::net::TcpStream;
use std::sync::mpsc::{self, TryRecvError};
use std::thread;
use std::time::Duration;

const LOCALHOST: &str = "127.0.0.1:1234";
const MESSAGE_SIZE: usize = 32;

fn main() {
    let mut client = TcpStream::connect(LOCALHOST).expect("Stream failed to connect");
    client.set_nonblocking(true).expect("Failed to initialize nonblocking");

    let (sx, rx) = mpsc::channel::<String>();

    thread::spawn(move || loop {
        let mut buf = vec![0; MESSAGE_SIZE];

        // Try to receive message from server
        match client.read_exact(&mut buf) {
            Ok(_) => {
                let msg = buf.into_iter().take_while(|&x| x != 0).collect::<Vec<_>>();
                let msg = String::from_utf8(msg).expect("Invalid utf8 message");
                println!("message recv {:?}", msg);
            },
            Err(ref err) if err.kind() == ErrorKind::WouldBlock => (),
            Err(_) => {
                println!("Connection with the server closed");
                break;
            }
        }

        // Try to send message from repl
        match rx.try_recv() {
            Ok(msg) => {
                let mut buf = msg.clone().into_bytes();
                buf.resize(MESSAGE_SIZE, 0);
                client.write_all(&buf).expect("Writing to socket failed");
                println!("message sent {:?}", msg);
            },
            Err(TryRecvError::Empty) => (),
            Err(TryRecvError::Disconnected) => break
        }

        thread::sleep(Duration::from_millis(100));
    });

    println!("repl");
    loop {
        let mut buf = String::new();
        io::stdin().read_line(&mut buf).expect("Reading form stdin failed");
        let msg = buf.trim().to_string();

        if msg == ":q" || sx.send(msg).is_err() { break }
    }
    println!("bye!");
}
```
