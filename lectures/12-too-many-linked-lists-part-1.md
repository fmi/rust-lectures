---
title: Свързани списъци, част 1
author: Rust@FMI team
speaker: Андрей Радев
date: 19 ноември 2019
lang: bg
keywords: rust,fmi
# description:
slide-width: 80%
font-size: 20px
font-family: Arial, Helvetica, sans-serif
# code blocks color theme
code-theme: github
---

# Learning Rust With Entirely Too Many Linked Lists

Оригиналния източник: https://rust-unofficial.github.io/too-many-lists/

Пълния код: https://github.com/rust-unofficial/too-many-lists/tree/master/lists

Тези слайдове ще съдържат само кратки обобщения на интересни части от кода.

---

# `std::mem::replace`

Удобна функция, която ни позволява да разменим две стойности:

```rust
# //ignore
use std::mem;

let head = mem::replace(&mut self.head, None)
```

- Първия аргумент е mutable reference, той се променя.
- Втория аргумент е стойността, която записваме в него. Тя се move-ва.
- Резултата е старата стойност на първия аргумент.
- По този начин, нищо не се деинициализира, "вземаме" стойността на `self.head`, като слагаме някаква "празна" стойност като заместител.

---

# `Option::take`

По-четим и удобен за използване вариант на предната функция за `Option`

```rust
# //ignore
let head = self.head.take();

// Превежда се отдолу до:
let head = Option::take(&mut self.head);
let head = std::mem::replace(&mut self.head, None);
```

Трябва `self` да е взето или като `mut self`, или `&mut self`

---

# `map` & `as_ref`

Метода `map` се използва често когато имаме `Option`:

- Ако стойността е `None`, просто не вика функцията/closure-а.
- Ако стойността е `Some(val)`, вика функцията върху `val` и я пакетира отново в `Some`.

```rust
# //ignore
pub fn peek(&self) -> Option<&T> {
    self.head.as_ref().map(|node| &node.elem)
}
```

Map обаче взема ownership! Метода `as_ref` Конвертира `Option<T>` в `Option<&T>`, което ни позволява да достъпим вътрешната стойност по reference (ако изобщо има такава).

---

# Итерация по reference

Итерирането по този начин включва вземане на вътрешния `&Node` изпод Box-а. Това може да изглежда объркващо...

```rust
# //ignore
pub fn iter(&self) -> Iter<T> {
    Iter {
        current: self.head.as_ref().map(|node| &**node),
    }
}
```

Винаги трябва да мислим за типовете! В случая имаме:

```rust
# //ignore
Option<Box<Node<T>>> // в списъка.
Option<&Node<T>>     // в итератора. Не искаме Box, защото не искаме ownership
```

---

# Итерация по reference

```rust
# //ignore
// self.head: Option<Box<Node<T>>>
// current:   Option<&Node<T>>
let current = self.head.as_ref().map(|node| &**node);

//    node: &Box<Node<T>>
//   *node: *&Box<Node<T>> -> Box<Node<T>>
//  **node: *Box<Node<T>> -> *&Node<T> -> Node<T>
// &**node: &Node<T>
```

Алтернативно, функцията `Box::as_ref` ни дава същия процес с по-малко perl-like код:

```rust
# //ignore
let mut current = self.head.as_ref().map(|node| Box::as_ref(node));

// Или, за по-кратко:
let mut current = self.head.as_ref().map(Box::as_ref);
```

---

# Итерация по mutable reference

```rust
# //ignore
let mut current = self.head.as_mut().map(|node| &mut **node);
// Или
let mut current = self.head.as_mut().map(Box::as_mut);
```

Благодарение на всичките safety check-ове, спокойно можем и да си вземем mutable reference, с почти същия код.

---

# Итерация по mutable reference

Ключова разлика между итерирането по immutable vs mutable reference:

```rust
impl<'a, T> Iterator for Iter<'a, T> {
    type Item = &'a T;
    fn next(&mut self) -> Option<Self::Item> {
        self.next.map(|node| {
            self.next = node.next.as_ref().map(|node| &**node);
            &node.elem
        })
    }
}

impl<'a, T> Iterator for IterMut<'a, T> {
    type Item = &'a mut T;
    fn next(&mut self) -> Option<Self::Item> {
        self.next.take().map(|node| {
            self.next = node.next.as_mut().map(|node| &mut **node);
            &mut node.elem
        })
    }
}
```

---

# Итерация по mutable reference

Разликата е в тези два реда:

```rust
# //ignore
// immutable:
self.next.map(|node| {
// mutable:
self.next.take().map(|node| {
```

Защо е нужно да викнем `take`? В първия случай, `self.next` е от тип `Option<&Node>`, докато във втория e `Option<&mut Node>`.

---

# Итерация по mutable reference

Викането на `self.next.map` в първия случай прави **копие** на този option, понеже типа `&T`, за което и да е `T`, е `Copy`. Това е смислено, понеже можем да имаме колкото си искаме immutable references към нещо.

Типа `&mut T` не е `Copy`, обаче. Това не се компилира, защото mutable reference-а има move semantics:

```rust
fn main() {
    let mut source = String::from("foo");

    let first_ref = &mut source;
    let second_ref = first_ref;

    first_ref.push_str(" bar");
    println!("{}", second_ref);
}
```

---

# Итерация по mutable reference

Това, от друга страна, се компилира без проблеми, защото immutable references се копират:

```rust
fn main() {
    let source = String::from("foo");

    let first_ref = &source;
    let second_ref = first_ref;

    println!("{}", first_ref);
    println!("{}", second_ref);
}
```

Тук не става въпрос за преместване или копиране на `source`, а за *references* към `source`! И references са някакви конкретни типове, алокирани на стека, и за тях може да се мисли дали ще се копират или ще се преместват.

---

# Не е нужно да се ползва map

Тези три имплементации на `peek` са еквивалентни:

```rust
# //ignore
pub fn peek(&self) -> Option<&T> {
    self.head.as_ref().map(|node| &node.elem)
}

pub fn peek(&self) -> Option<&T> {
    match self.head {
        None => None,
        Some(ref node) => Some(&node.elem)
    }
}

pub fn peek(&self) -> Option<&T> {
    let node = self.head.as_ref()?;
    Some(&node.elem)
}
```

---

# Не е нужно да се ползва map

Дали ще ползвате map, експлицитен pattern-matching, или `?` оператора е предимно въпрос на предпочитание. Не всички варианти са използваеми на всички места, разбира се.

Напълно е възможно да започнете с експлицитен pattern-matching, и да видите, че можете да си опростите кода значително с един map. Или да "извадите" стойност от option рано в метода и оттам нататък да работите безопасно с нея.

Експериментирайте, за да откриете с какво се чувствате най-комфортни. Правете го редовно -- силно е вероятно предпочитанията ви да се променят с времето.
