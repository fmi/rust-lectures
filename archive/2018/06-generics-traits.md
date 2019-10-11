---
title: Шаблонни типове, типажи
author: Rust@FMI team
date: 23 октомври 2018
lang: bg
keywords: rust,fmi
# description:
slide-width: 80%
font-size: 20px
font-family: Arial, Helvetica, sans-serif
# code blocks color theme
code-theme: github
# Speaker notes
# cargo +nightly rustc -- -Z ast-json
---

# Административни неща

Една лоша и една добра новина

--
* Наближава края на домашното!
--
* Rust 1.30.0 излиза след два дни!

---

# Административни неща

За домашното:

--
* Ако не сте почнали, започнете *веднага след лекцията*
--
* Ако не сте се регистирали в сайтa, OMG, регистрирайте се *веднага след лекцията*
--
* Ако сте го пуснали вече, прегледате го пак, може да се сетите за някой edge case

---

# Преговор

### Документация

```rust
# // norun
/// Add 2 to a number
///
/// # Example
///
/// \`\`\`
/// # use playground::add_two;
/// assert_eq!(add_two(5), 7);
/// \`\`\`
pub fn add_two(n: u32) -> u32 {
    n + 2
}
# fn main() {}
```

---

# Преговор

### Тестове

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
fn add_two(n: u32) -> u32 {
    n + 2
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(add_two(2), 4);
    }
}
```

---

# Преговор

### Атрибути

* `#[cfg(test)]`
* `#[test]`

---

# Атрибути

### Документация

```rust
# // norun
/// Add 2 to a number
///
/// # Example
pub fn add_two(n: u32) -> u32 {
    n + 2
}
# fn main() {}
```

---

# Атрибути

### Документация

```rust
# // norun
#[doc="Add 2 to a number"]
#[doc=""]
#[doc="# Example"]
pub fn add_two(n: u32) -> u32 {
    n + 2
}
# fn main() {}
```

---

# Generic Types (Generics)

![](images/generics.jpeg)

---

# Generic Types (Generics)

### Oбобщени типове

--
Вече сме ги виждали

--
* `Option<T>`
--
* `Vec<T>`

---

# Oбобщени типове

--
* Позволяват да пишем код, валиден за различни ситуации
--
* Поддържат само типове за разлика от C++ templates
--
* Мономорфизация на кода, т.е няма runtime overhead

---

# Oбобщени типове

### функции

Със знанията събрани до сега

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
fn add_i32(a: i32, b: i32) -> i32 {
    a + b
}

fn add_u8(a: u8, b: u8) -> u8 {
    a + b
}
```

---

# Oбобщени типове

### функции

С обобщени типове

```rust
# // ignore
fn add<T>(a: T, b: T) -> T {
    a + b
}
```

---

# Oбобщени типове

### функции

С обобщени типове

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
fn add<T>(a: T, b: T) -> T {
    a + b
}
```

--
Ще видим как да оправим грешката малко по-късно в презентацията

---

# Oбобщени типове

### структури

Нека разгледаме структурата

```rust
# // norun
# #![allow(dead_code, unused_variables)]
struct Point<T> {
    x: T,
    y: T,
}

fn main() {
    let integer = Point { x: 5, y: 10 };
    let float = Point { x: 1.0, y: 4.0 };
}
```

---

# Oбобщени типове

### структури

А какво ще стане, ако опитаме да я създадем по този начин?

```rust
# // ignore
fn main() {
    let what_about_this = Point { x: 5, y: 4.0 }; // ??
}
```

---

# Oбобщени типове

### структури

А какво ще стане, ако опитаме да я създадем по този начин?

```rust
# // norun
# #![allow(dead_code)]
# struct Point<T> { x: T, y: T }
fn main() {
    let what_about_this = Point { x: 5, y: 4.0 };
}
```

---

# Oбобщени типове

### структури

Ако искаме да позволим двете координати да са различни типове

```rust
# // norun
# #![allow(dead_code, unused_variables)]
struct Point<T, U> {
    x: T,
    y: U,
}

fn main() {
    let both_integer = Point { x: 5, y: 10 };
    let both_float = Point { x: 1.0, y: 4.0 };
    let integer_and_float = Point { x: 5, y: 4.0 };
}
```

---

# Oбобщени типове

### енумерации

Ето как се дефинира `Option`:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
enum Option<T> {
    Some(T),
    None,
}
```

---

# Oбобщени типове

### енумерации

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
enum Message<T, A> {
    Text(T),
    Action(A),
}
```

---

# Oбобщени типове

### методи

```rust
# // norun
# #![allow(dead_code)]
struct Point<T> { x: T, y: T }

// Забележете impl<T>
impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

fn main() {
    let p = Point { x: 5, y: 10 };

    println!("p.x   = {}", p.x);    // ??
    println!("p.x() = {}", p.x());  // ??
}
```

---

# Oбобщени типове

### методи

```rust
# #![allow(dead_code)]
struct Point<T> { x: T, y: T }

// Забележете impl<T>

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

fn main() {
    let p = Point { x: 5, y: 10 };

    println!("p.x   = {}", p.x);
    println!("p.x() = {}", p.x());
}
```

---

# Oбобщени типове

### специализирани имплементации

В този пример само `Point<f32>` ще притежава този метод

```rust
# // norun
# #![allow(dead_code)]
# struct Point<T> { x: T, y: T }
# fn main() {}
// Този път няма impl<T>
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

---

# Oбобщени типове

```rust
# #![allow(dead_code)]
struct Point<T, U> {
    x: T,
    y: U,
}

impl<T, U> Point<T, U> {
    fn mixup<V, W>(self, other: Point<V, W>) -> Point<T, W> {
        Point { x: self.x, y: other.y }
    }
}

fn main() {
    let p1 = Point { x: 5, y: 10.4 };
    let p2 = Point { x: "Hello", y: 'c'};
    let p3 = p1.mixup(p2);
    println!("p3.x = {}", p3.x);
    println!("p3.y = {}", p3.y);
}
```

---

# Упражнение

### The JSON encoder

* Искаме да си направим логика, която да преобразува Rust данни в JSON.
* Да речем низа `"stuff"` трябва да се преобразува до `"\"stuff\""`.
* Числото `5` трябва да се преобразува в `"5"`.
* Ако си дефинираме функция, тя ще изглежда така:

```rust
# // ignore
fn to_json<T>(val: T) -> String {
    ...
}
```

---

# Упражнение

### The JSON encoder

--
Но как да я имплементираме?
--
Какъв тип да е T? Може да е всичко? Ще правиме проверки дали получаваме число или низ?
--
А ако е наш собствен тип?

---

# Типажи

### Traits

* Споделенo поведение.
* Подобни на интерфейси от други езици.
* И почти същите като type class-овете в един определен език!

---

# Типажи

### Traits

* Всъщност ние сме виждали вече trait-ове.
--
* Помните ли `{:?}`, когато отпечатваме на екрана?
--
* Това има значение за данни от тип, който имплементира trait-а `Debug`.
--
* Но нека се върнем на нашия пример с JSON encoder-a.

---

# Упражнение

### The JSON encoder

Нека си дефинираме trait:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
trait ToJson {
    fn to_json(&self) -> String;
}
```

---

# Упражнение

### The JSON encoder

Сега можем да го имплементираме за някои вградени типове данни:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
# trait ToJson { fn to_json(&self) -> String; }
impl ToJson for String {
    fn to_json(&self) -> String {
        format!("\"{}\"", self)
    }
}
```

---

# Упражнение

### The JSON encoder

Сега можем да го имплементираме за някои вградени типове данни:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
# trait ToJson { fn to_json(&self) -> String; }
impl ToJson for i32 {
    fn to_json(&self) -> String {
        format!("{}", self)
    }
}

impl ToJson for f32 {
    fn to_json(&self) -> String {
        format!("{}", self)
    }
}
```

---

# Упражнение

### The JSON encoder

```rust
# trait ToJson {
#     fn to_json(&self) -> String;
# }
# impl ToJson for String {
#     fn to_json(&self) -> String {
#         format!("\"{}\"", self)
#     }
# }
# impl ToJson for i32 {
#     fn to_json(&self) -> String {
#         format!("{}", self)
#     }
# }
# fn main() {
println!("String as json: {}", String::from("mamal").to_json());

println!("Number as json: {}", 3.to_json());
# }
```

---

# Упражнение

### The JSON encoder

Можем да имаме имплементация по подразбиране:

```rust
trait ToJson {
    fn to_json(&self) -> String {
        String::from("null")
    }
}

impl ToJson for () {}

fn main() {
    println!("Unit as json: {}", ().to_json());
}
```

---

# Упражнение

### The JSON encoder

Още малко - за `Option`!

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
# trait ToJson { fn to_json(&self) -> String; }
impl<T> ToJson for Option<T> where T: ToJson {
    fn to_json(&self) -> String {
        match self {
            &Some(ref val) => val.to_json(),
            &None => String::from("null"),
        }
    }
}
```

---

# Упражнение

### The JSON encoder

В JSON има списъци, нека да пробваме да го направим за вектор:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
# trait ToJson { fn to_json(&self) -> String; }
# impl<T> ToJson for Option<T> where T: ToJson {
#     fn to_json(&self) -> String {
#         match self {
#             &Some(ref val) => val.to_json(),
#             &None => String::from("null"),
#         }
#     }
# }
# impl<'a, T> ToJson for &'a T where T: ToJson {
#     fn to_json(&self) -> String {
#         (*self).to_json()
#     }
# }
impl <T> ToJson for Vec<T> where T: ToJson {
    fn to_json(&self) -> String {
        let mut iter = self.iter();
        let first = iter.next();
        let mut result: String = first.to_json();

        for e in iter {
            result.push_str(", ");
            result.push_str(&e.to_json());
        }

        format!("[{}]", result)
    }
}
```

---

# Упражнение

### The JSON encoder

В JSON има списъци, нека да пробваме да го направим за вектор:

```rust
# trait ToJson { fn to_json(&self) -> String; }
# impl ToJson for f32 {
#     fn to_json(&self) -> String {
#         format!("{}", self)
#     }
# }
# impl<T> ToJson for Option<T> where T: ToJson {
#     fn to_json(&self) -> String {
#         match self {
#             &Some(ref val) => val.to_json(),
#             &None => String::from("null"),
#         }
#     }
# }
# impl<'a, T> ToJson for &'a T where T: ToJson {
#     fn to_json(&self) -> String {
#         (*self).to_json()
#     }
# }
# impl <T> ToJson for Vec<T> where T: ToJson {
#     fn to_json(&self) -> String {
#         let mut iter = self.iter();
#         let first = iter.next();
#         let mut result: String = first.to_json();
#         for e in iter {
#             result.push_str(", ");
#             result.push_str(&e.to_json());
#         }
#         format!("[{}]", result)
#     }
# }
fn main() {
    let arr = vec![Some(1.1), Some(2.2), None].to_json();
    println!("Vector as json: {}", arr);
}
```

---

# Упражнение

### The JSON encoder

А сега и за наш си тип:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
struct Student {
    age: i32,
    full_name: String,
    number: i32,
    hobby: Option<String>
}
```

---

# Упражнение

### The JSON encoder

```rust
# // norun
# #![allow(dead_code)]
# trait ToJson { fn to_json(&self) -> String; }
# struct Student {
#     age: i32,
#     full_name: String,
#     number: i32,
#     hobby: Option<String>
# }
# impl ToJson for i32 {
#     fn to_json(&self) -> String {
#         format!("{}", self)
#     }
# }
# impl<T> ToJson for Option<T> where T: ToJson {
#     fn to_json(&self) -> String {
#         match self {
#             &Some(ref val) => val.to_json(),
#             &None => String::from("null"),
#         }
#     }
# }
# impl ToJson for String {
#     fn to_json(&self) -> String {
#         format!("\"{}\"", self)
#     }
# }
# fn main() {}
impl ToJson for Student {
    fn to_json(&self) -> String {
        format!(
r#"{{
    "age": {},
    "full_name": {},
    "number": {},
    "hobby": {}
}}"#,
            self.age.to_json(), self.full_name.to_json(),
            self.number.to_json(), self.hobby.to_json()
        )
    }
}
```

---

# Упражнение

### The JSON encoder

```rust
# trait ToJson { fn to_json(&self) -> String; }
# struct Student {
#     age: i32,
#     full_name: String,
#     number: i32,
#     hobby: Option<String>
# }
# impl ToJson for i32 {
#     fn to_json(&self) -> String {
#         format!("{}", self)
#     }
# }
# impl<T> ToJson for Option<T> where T: ToJson {
#     fn to_json(&self) -> String {
#         match self {
#             &Some(ref val) => val.to_json(),
#             &None => String::from("null"),
#         }
#     }
# }
# impl ToJson for String {
#     fn to_json(&self) -> String {
#         format!("\"{}\"", self)
#     }
# }
# impl ToJson for Student {
#     fn to_json(&self) -> String {
#         format!(
# r#"{{
#     "age": {},
#     "full_name": {},
#     "number": {},
#     "hobby": {}
# }}"#,
#             self.age.to_json(), self.full_name.to_json(),
#             self.number.to_json(), self.hobby.to_json()
#         )
#     }
# }
fn main() {
    let student = Student {
        age: 16,
        full_name: "Jane Doe".to_owned(),
        number: 5,
        hobby: Some("Tennis".to_string())
    };

    println!("{}", student.to_json());
}
```

---

# Упражнение

### The JSON encoder

Сега можем да си дефинираме функцията, от която почна всичко:

```rust
# // norun
# #![allow(dead_code)]
# trait ToJson { fn to_json(&self) -> String; }
# fn main() {}
fn to_json<T: ToJson>(value: T) -> String {
    value.to_json()
}
```

---

# Типажи

### Traits

А ако искаме дадена стойност да имплементира повече от един trait?

```rust
# // norun
# #![allow(dead_code)]
# use std::fmt::Debug;
# trait ToJson { fn to_json(&self) -> String; }
# fn main() {}
fn log_json_transformation<T: ToJson + Debug>(value: T) {
    println!("{:?} -> {}", value, value.to_json());
}
```

---

# Traits

### Кога можем да имлементираме trait?

* За определена структура може да има само една имплементация на определен trait.
* За да няма грешки поради имплементации в други библиотеки, има създадени правила.

--

Можем да имплементираме trait `T` за тип `S` ако:

* trait-a `T` е дефиниран в нашия crate, или
* типа `S` е дефиниран в нашия crate

---

# Traits

### static dispatch

--
* Компилатора генерира отделна версия на `to_json` за всяка нейна имплементация.
--
* При компилиране се избира правилният вариант на функцията за дадения случай.
--
* Това изпълва executable-а с тези дефиниции.
--
* Този вид генериране на код се нарича мономорфизация.

---

# Traits

### static dispatch

![](images/static_dispatch.png)

---

# Trait Objects

### dynamic dispatch

Има начин да се използва една версия на функцията и те да се избира at runtime.
--
Това става с trait objects.

---

# Trait Objects

### dynamic dispatch

Ако имаме trait `Stuff`, `&dyn Stuff` да представлява какъвто и да е обект имплементиращ trait-а.

```rust
# trait ToJson { fn to_json(&self) -> String; }
# impl ToJson for i32 {
#     fn to_json(&self) -> String {
#         format!("{}", self)
#     }
# }
fn to_json(value: &dyn ToJson) -> String {
    value.to_json()
}

fn main() {
    let trait_object: &dyn ToJson = &5;

    println!("{}", to_json(trait_object));
    println!("{}", to_json(&5));
    println!("{}", to_json(&5 as &dyn ToJson));
}
```

---

# Trait Objects

### dynamic dispatch

--
* Сега не изпълваме binary-то с много дефиниции.
--
* Runtime нещата са малко по-сложни.
--
* Имплементирано е с vtable създаден при компилация.
--
* Не от всеки trait може да се направи trait обект.

---

# Trait Objects
Можем да използваме trait обекти да си направим не-хомогенен вектор, който може да се принтира.

```rust
# fn main() {
use std::fmt::Debug;

println!("{:?}", vec![
    &1.1 as &dyn Debug,
    &Some(String::from("Stuff")),
    &3
]);
# }
```

---

# Trait Objects

Големината на един trait object е два указателя - един към самата стойност и един към vtable-a.

Може да ги срещнете още като "fat pointer".

```rust
# use std::fmt::Debug;
# use std::mem;
# fn main() {
println!("{}", mem::size_of::<&u32>());
println!("{}", mem::size_of::<&dyn Debug>());
# }
```

---

# Turbofish!

![](images/turbofish.jpg)

---

# Generic Traits

Нека разгледаме как бихме имплементирали `Graph` trait

```rust
# // norun
# #![allow(dead_code)]
# fn main () {}
trait Graph<N, E> {
    fn has_edge(&self, &N, &N) -> bool;
    fn edges(&self, &N) -> Vec<E>;
    // ...
}
```

---

# Generic Traits

Ако се опитаме да направим функция

```rust
# // norun
# #![allow(dead_code, unused_variables)]
# fn main () {}
# trait Graph<N, E> {
#     fn has_edge(&self, &N, &N) -> bool;
#     fn edges(&self, &N) -> Vec<E>;
# }
fn distance<N, E, G: Graph<N, E>>(graph: &G, start: &N, end: &N) -> u32 {
    // ...
# 0
}
```

--
Тук дефиницията на типа `E` за ребрата на графа няма пряко отношение към сигнатурата на функцията.

---

# Traits

### Асоциирани типове

Нека пробваме отново..

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
trait Graph {
    type N;
    type E;

    fn has_edge(&self, &Self::N, &Self::N) -> bool;
    fn edges(&self, &Self::N) -> Vec<Self::E>;
}
```

--
Асоциираните типове служат за, един вид, групиране на типове.

---

# Traits

### Асоциирани типове

```rust
# // norun
# #![allow(dead_code, unused_variables)]
# fn main() {}
# trait Graph {
#     type N;
#     type E;
#     fn has_edge(&self, &Self::N, &Self::N) -> bool;
#     fn edges(&self, &Self::N) -> Vec<Self::E>;
# }
struct Node;
struct Edge;
struct MyGraph;

impl Graph for MyGraph {
    type N = Node;
    type E = Edge;

    fn has_edge(&self, n1: &Node, n2: &Node) -> bool {
        true
    }

    fn edges(&self, n: &Node) -> Vec<Edge> {
        Vec::new()
    }
}
```

---

# Generic Traits

И сега ако се опитаме да направим функцията отново

```rust
# // norun
# #![allow(dead_code, unused_variables)]
# fn main() {}
# trait Graph {
#     type N;
#     type E;
#     fn has_edge(&self, &Self::N, &Self::N) -> bool;
#     fn edges(&self, &Self::N) -> Vec<Self::E>;
# }
# struct Node;
# struct Edge;
# struct MyGraph;
# impl Graph for MyGraph {
#     type N = Node;
#     type E = Edge;
#     fn has_edge(&self, n1: &Node, n2: &Node) -> bool {
#         true
#     }
#     fn edges(&self, n: &Node) -> Vec<Edge> {
#         Vec::new()
#     }
# }
fn distance<G: Graph<N=Node, E=Edge>>(graph: &G, start: &G::N, end: &G::N) -> u32 {
    // ...
# 0
}
```

---

# Traits

### Асоциирани типове

Може да си дефинираме trait за събиране като комбинираме Generic Traits и Associated Types:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
trait Add<RHS=Self> {
    type Output;

    fn add(self, rhs: RHS) -> Self::Output;
}
```

---

# Traits

### Асоциирани типове

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
# trait Add<RHS=Self> {
#     type Output;
#     fn add(self, rhs: RHS) -> Self::Output;
# }
impl Add for i32 {
    type Output = i32;

    fn add(self, rhs: i32) -> i32 {
        self + rhs
    }
}

impl Add for String {
    type Output = String;

    fn add(self, rhs: String) -> String {
        format!("{} {}", self, rhs)
    }
}
```

---

# Traits

### Асоциирани типове

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
# trait Add<RHS=Self> {
#     type Output;
#     fn add(self, rhs: RHS) -> Self::Output;
# }
struct Student;
struct StudentGroup {
    members: Vec<Student>
}

impl Add for Student {
    type Output = StudentGroup;

    fn add(self, rhs: Student) -> StudentGroup {
        StudentGroup { members: vec![self, rhs] }
    }
}
```

---

# Traits

### Каква е разликата между "асоцииран тип" и "generic тип"?

Да речем, че имаме `Add` trait дефиниран така:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
trait Add {
    fn add(self, rhs: Self) -> Self;
}
```

Това ще работи само за един и същ тип отляво, отдясно и като резултат:

```rust
# //ignore
i32.add(i32) -> i32             // Self=i32
f64.add(f64) -> f64             // Self=f64
Student.add(Student) -> Student // Self=Student
```

---

# Traits

### Каква е разликата между "асоцииран тип" и "generic тип"?

За да варираме дясната страна:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
trait Add<RHS> {
    fn add(self, rhs: RHS) -> Self;
}
```

Това ще позволи различни типове отляво и отдясно, но резултата задължително трябва да е левия:

```rust
# //ignore
i32.add(i8) -> i32                        // Self=i32, RHS=i8
f64.add(f32) -> f64                       // Self=f64, RHS=f32
StudentGroup.add(Student) -> StudentGroup // Self=StudentGroup, RHS=Student
```

(Или може да върнем `-> RHS` вместо `-> Self`, за да върнем задължително десния тип.)

```rust
# //ignore
fn add(self, rhs: RHS) -> Self;
```

---

# Traits

### Каква е разликата между "асоцииран тип" и "generic тип"?

За да сме напълно свободни:

```rust
# // norun
# #![allow(dead_code)]
# fn main() {}
trait Add<RHS, OUTPUT> {
    fn add(self, rhs: RHS) -> OUTPUT;
}
```

Проблема е, че това позволява:

```rust
# //ignore
i32.add(i8) -> i64 // Self=i32, RHS=i8, OUTPUT=i64
i32.add(i8) -> i32 // Self=i32, RHS=i8, OUTPUT=i32
```

Компилатора сега няма как да знае със сигурност какъв е типа на `i32.add(i8)`. Може да е което и да е от двете. Налага се експлицитно да го укажем, или със `::<>`, или със `let result: i32 = ...`

---

# Traits

### Каква е разликата между "асоцииран тип" и "generic тип"?

Асоциирания тип е компромисен вариант -- можем да изберем какъв е типа на output-а, но този тип е винаги един и същ за всяка двойка ляв+десен тип:

```rust
# //ignore
trait Add<RHS> {
    type Output;
    fn add(self, rhs: RHS) -> Self::Output;
}
```

Така можем да кажем:

```rust
# //ignore
impl Add<i8> for i32 {  // Имплементирай ми "добавяне на i8 към i32"
    type Output = i64;  // Като резултата ще е винаги i64
    fn add(self, rhs: i8) -> i64 { ... }
}
```

---

# Заключение

* Generic Traits се използват когато искаме да имаме множество имплементации с различен тип върху една и съща структура.
* Associated Type се използва когато искаме да има точно един тип на имплементацията.
