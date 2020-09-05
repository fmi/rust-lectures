---
title: Unsafe Rust and FFI
author: Rust@FMI team
date: 12 декември 2019
speaker: Делян Добрев
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Unsafe Rust

Разглеждали сме малко unsafe Rust в минали лекции за указатели.

---

# Unsafe Rust

Силната страна на Rust са статичните гаранции за поведението на програмата.
--
<br>
Но тези проверки са консервативни и съществуват програми, които са 'safe', но компилатора не може да ги верифицира. За да може да пишем такива програми се налага да кажем на компилатора да смекчи ограниченията си.
--
<br>
За тази цел в Rust има ключовата дума `unsafe`, която премахва някои ограничения на компилатора.

---

# Unsafe Rust

Съществуват 4 контекста в които може да използваме `unsafe`.

---

# Unsafe Rust

Всички функции които използваме през FFI трябва да се маркират като `unsafe`.
Спокойно, ще видим какво точно е FFI по-късно в лекцията.

```rust
# // ignore
unsafe fn danger_will_robinson() {
    // Scary stuff...
}
```

---

# Unsafe Rust

Блокове, маркирани с `unsafe`.

```rust
# // ignore
unsafe {
    // Scary stuff...
}
```

--
Това е може би най-често срещаното използване на `unsafe`.

---

# Unsafe Rust

`unsafe` типажи.

```rust
# // ignore
unsafe trait Scary { ... }
```

---

# Unsafe Rust

Вече сме ги виждали впрочем, най-често използваните са

```rust
# // ignore
pub unsafe auto trait Send { }
pub unsafe auto trait Sync { }
```

---

# Unsafe Rust

Както знаем вече, те се имплементират автоматично върху типове, които компилатора сметне за подходящи.

Но специално `Send` и `Sync` може да ги деимплементираме с `!`, когато не искаме да се имплементират за типа ни.

```rust
# // ignore
impl<T> !Sync for Rc<T> where T: ?Sized
```

---

# Unsafe Rust

Понякога може да имаме обратното - `Send` или `Sync` да *не* са имплементирани за наш тип, но всъщност да е правилно да бъдат имплементирани.

--
<br>
Тогава може да си ги имплементираме сами, но това е `unsafe`, защото има шанс да нарушим гаранциите на компилатора.
В този случай трябва сами да гарантираме, че семантиките, които репрезентират типажите, са спазени.

---

# Unsafe Rust

Тогава може да ги имплементираме по следния начин.

```rust
# // ignore
unsafe impl Scary for i32 { ... }
```

---

# Unsafe Rust

Ако програмата ви segfault-ва, може да сме сигурни, че това се случва в `unsafe` код.

---

# Unsafe Rust

Има неща които не искаме да се случват в програмата ни, но компилаторът не проверява за тях по една или друга причина...

--
* Deadlocks
--
* Leaks of memory or other resources
--
* Exiting without calling destructors
--
* Integer overflow

---

# Unsafe Rust

...има и неща които може да направим в `unsafe` код, но е добре да ги избягваме.

* Data races
* Dereferencing a NULL/dangling raw pointer
* Reads of undef (uninitialized) memory
* Breaking the pointer aliasing rules with raw pointers.
* Mutating an immutable value/reference without `UnsafeCell<U>`
* Invoking undefined behavior via compiler intrinsics
* Invalid values in primitive types, even in private fields/locals
* Unwinding into Rust from foreign code or unwinding from Rust into foreign code.

---

# Unsafe Rust

Чрез `unsafe`, Rust ни предоставя 5 неща които не можем да правим при нормални обстоятелства:

1. Четене и писане в static mutable променливи.
2. Дереференциране на голи указатели.
3. Извикване на `unsafe` функции.
4. Имплементиране на `unsafe` типажи.
5. Достъп до полетата на `union`.

Това е всичко.

--
<br>
Когато използвате `unsafe`, няма да изключите правила на компилатора като borrow checker.

---

# Union

Синтаксисът е сходен с този на структурите, но полетата на union-ите споделят една и съща памет.

```rust
# // no_run
union U {
    a: u32,
    b: bool,
}
# fn main() {}
```

---

# Unsafe Rust

### FFI

Какво означава FFI?

--
<br>
Foreign Function Interface

---

# FFI

За какво се ползва?

--
<br>
За извикване на функции, които не са написани в нашият код.
Това са най-често функции в библиотеки (dll, lib и т.н.), върху които нямаме контрол.

---

# Викане на C функции от Rust

%%
```c
int add_in_c(int a, int b) {
    return a + b;
}
```
%%
```rust
# // ignore
use std::os::raw::c_int;

extern {
    fn add_in_c(a: c_int, b: c_int) -> c_int;
}
```

---

# Викане на C функции от Rust

### extern

--
* extern блок дефинира символи (функции или глобални променливи) към които ще се линква
--
* типа на дефинираните функции е `extern "<abi>" unsafe fn(...) -> ...`
--
* add_in_c: `extern "C" unsafe fn(c_int, c_int) -> c_int`

---

# Викане на C функции от Rust

### extern

Външни функции са unsafe, защото компилаторът не може да гарантира, че работят правилно.

```rust
# // ignore
extern {
    fn add_in_c(a: c_int, b: c_int) -> c_int;
}

fn main() {
    let res = unsafe { add_in_c(1, 2) };
    println!("{}", res);
}
```

---

# Викане на C функции от Rust

### Calling convention

Calling conventions се задават на extern блока. По подразбиране е `"C"`.

```rust
# // ignore
extern "C" {
    fn add_in_c(a: c_int, b: c_int) -> c_int;
}

extern "system" {
    fn SetEnvironmentVariableA(n: *const u8, v: *const u8) -> c_int;
}
```
---

# Викане на C функции от Rust

### Calling convention

За какво служи конвенцията на извикване на функции?

--
<br>
За да уеднакви правилата които трябва да спазват извикващата и извиканата функция, така че да няма разминаване при подаване на параметри и връщане на стойност.

---

# Викане на C функции от Rust

### Calling convention

Ако нямаше конвенция, извикването на функции щеше да е хаос.

Четирите правила които определя са:

--
* как се подават параметрите (в регистри, на стека или и двете)
--
* реда в който се алокират променливите
--
* регистрите, които извиканата функция трябва да запази (callee-saved registers or non-volatile registers)
--
* разпределението на подготовката на стека и зачистването му между извикващата и извиканата функция

---

# Викане на C функции от Rust

### Calling convention

За любопитните, в момента двете най-разпространени конвенции са

* `Microsoft x64 calling convention` - за Windows
* `System V AMD64 ABI` - за Unix и Unix-like операционни системи

---

# Викане на C функции от Rust

### Calling convention

Calling convention-а задължително трябва да съвпада с това как е компилирана функцията в библиотеката.

--
* `"Rust"` - каквото rustc използва за нормалните функции. Не се използва при FFI.
--
* `"C"` - каквото C компилаторът използва по подразбиране. Това почти винаги е правилното, освен ако не е казано друго изрично или библиотеката е компилирана с друг компилатор.
--
* `"system"` - използва се за системни функции (на Windows). Или просто използвайте crate-а winapi.

---

# Викане на C функции от Rust

Нека да пробваме да компилираме

```rust
use std::os::raw::c_int;

extern {
    fn add_in_c(a: c_int, b: c_int) -> c_int;
}

fn main() {
    let res = unsafe {
        add_in_c(1, 2)
    };

    println!("{}", res);
}
```

Очаквано, не сме казали на компилатора къде да намери функцията

---

# Linking

### Ръчният начин

%%
Static linking

компилираме C кода до math.lib / libmath.a

```sh
cargo rustc -- -L . -l math
# или
cargo rustc -- -L . -l static=math
```
%%
Dynamic linking

компилираме C кода до math.dll / libmath.so

```sh
cargo rustc -- -L . -l math
# или
cargo rustc -- -L . -l dylib=math
```
%%

---

# Linking

### Правилният начин

```rust
# // ignore
#[link(name="math")]
extern {
    fn add_in_c(a: c_int, b: c_int) -> c_int;
}
```

--
* `#[link(name="math")]` - линква към динамичната библиотека `math`
--
* `#[link(name="math", kind="static")]` - линква към статичната библиотека `math`
--
* `#[link(name="math", kind="framework")]` - линква към MacOs framework `math`

---

# Linking

### Правилният начин

--
* Обикновено динамичните библиотеки се намират в някоя стандартна директория (в `PATH`)
--
* Тогава `#[link(name="library_name")]` е достатъчно
--
* За статична библиотека все още трябва да кажем на компилатора къде да я намери

```sh
cargo rustc -- -L .
```

---

# Linking

### Странности

Няма значение на кой блок е поставен #[link] атрибута.

```rust
# // ignore
#[link(name="foo")]
#[link(name="bar")]
extern {}

extern {
    fn foo_init();
    fn foo_stuff(x: c_int);
}

extern {
    fn bar_init();
    fn bar_stuff() -> c_int;
}
```

---

# Build scripts

Cargo предоставя възможност за изпълняване на скрипт преди компилиране на crate-a.

Използва се при FFI, ако искаме сами да си компилираме C кода и да укажем как да се линкнем към него.

[http://doc.crates.io/build-script.html](http://doc.crates.io/build-script.html)

---

# Build scripts

```toml
[package]
name = "ffi"
version = "0.1.0"
authors = ["..."]
build = "build.rs"
```

```rust
# // ignore
// build.rs

fn main() {
    ...
}
```

---

# Build scripts

--
* build.rs няма достъп до нормалните dependencies
--
* вместо това използва build-dependencies

```toml
[build-dependencies]
...
```

---

# Build scripts

* cargo прихваща stdout на build скрипта
--
* всеки ред който започва с `cargo:` се разбира като команда
--
* форматът е `cargo:key=value`
--
* `cargo:rustc-link-search=.`

---

# Build scripts

```rust
# // norun
// build.rs

fn main() {
    println!("cargo:rustc-link-search=.");
}
```

---

# Callbacks

```c
// main.c

typedef int (*callback)(int);

int apply(int a, callback op) {
    return op(a);
}
```

```rust
# // ignore
// main.rs
# use std::os::raw::c_int;

#[link(name="math")]
extern "C" {
    fn apply(a: c_int, op: fn(c_int) -> c_int) -> c_int;
}

fn cube(x: i32) -> i32 { x * x * x }

fn main() {
    println!("{}", unsafe { apply(11, cube) });
}
```

---

# Callbacks

```c
// main.c

typedef int (*callback)(int);

int apply(int a, callback op) {
    return op(a);
}
```

```rust
// main.rs
# use std::os::raw::c_int;

#[link(name="math")]
extern "C" {
    fn apply(a: c_int, op: fn(c_int) -> c_int) -> c_int;
}

fn cube(x: i32) -> i32 { x * x * x }

fn main() {
    println!("{}", unsafe { apply(11, cube) });
}
```

---

# Callbacks

Kомпилаторът ни подсказва:

--
* `apply` очаква `int (*callback)(int)`, т.е. `extern "C" fn(c_int) -> c_int`
--
* ние му подаваме `fn(c_int) -> c_int`, т.е. `extern "Rust" fn(c_int) -> c_int`

---

# Callbacks

```rust
# // ignore
// main.rs
# use std::os::raw::c_int;

#[link(name="math")]
extern "C" {
    fn apply(a: c_int, op: extern fn(c_int) -> c_int) -> c_int;
}

extern fn cube(x: i32) -> i32 { x * x * x }

fn main() {
    println!("{}", unsafe { apply(11, cube) });
}
```

---

# Panics

> A panic! across an FFI boundary is undefined behavior.

Когато подаваме или експортираме rust функции трябва да се подсигурим, че те не могат да се панират. В тази ситуация е удобно да се използва `catch_unwind`.

```rust
# // norun
# fn main() {}
use std::panic::catch_unwind;

extern fn oh_no() -> i32 {
    let result = catch_unwind(|| {
        panic!("Oops!");
    });

    match result {
        Ok(_) => 0,
        Err(_) => 1,
    }
}
```

---

# Panics

NB! Не го използвайте за generic try/catch block!!

Не е гарантирано, че ще хване всички паници, защото някои от тях са abort.

---

# Exports

За експортиране на функции към C или друг език се налага да използваме `#[no_mangle]`, за да предотвратим промяна на името в генерираните символи на библиотеката.

```rust
# // no-run
#[no_mangle]
extern fn call_me_from_c() {
}
# fn main() {}
```

---

# Други неща

--
* [Variadic functions](https://doc.rust-lang.org/book/first-edition/ffi.html#variadic-functions)
--
* [Importing global variables](https://doc.rust-lang.org/book/first-edition/ffi.html#accessing-foreign-globals)

---

# Writing wrappers

Много често е удобно да напишем "rusty" интерфейс към библиотеката

```rust
# // ignore
use libc::{c_int, c_size_t};

#[link(name="math")]
extern {
    fn math_array_sum(arr: *const c_int, len: c_size_t) -> c_int;
}

/// Safe wrapper
pub fn array_sum(arr: &[c_int]) -> c_int {
    unsafe { math_array_sum(arr.as_ptr(), arr.len()) }
}
```

---

# Writing wrappers

Други

--
* Конвертиране на кодове за грешки до `Option` или `Result`
--
* Методи
--
* Деструктори

---

# Споделяне на структури

Структурите в rust нямат определено подреждане на полетата.


```c
struct FooBar {
    int foo;
    short bar;
};

void foobar(FooBar x) {
    // ...
}
```

```rust
# // ignore
# use std::os::raw::{c_int, c_short};
# fn main() {}
struct FooBar {
    foo: c_int,
    bar: c_short,
}

extern {
    fn foobar(x: FooBar);
}
```

---

# Споделяне на структури

Структурите в rust нямат определено подреждане на полетата.


```c
struct FooBar {
    int foo;
    short bar;
};

void foobar(FooBar x) {
    // ...
}
```

```rust
# // norun
# use std::os::raw::{c_int, c_short};
# fn main() {}
struct FooBar {
    foo: c_int,
    bar: c_short,
}

extern {
    fn foobar(x: FooBar);
}
```

---

# Споделяне на структури

За да споделим структура между Rust и C трябва да забраним на компилатора да размества полетата с `#[repr(C)]`.

```rust
# // norun
# use std::os::raw::{c_int, c_short};
# fn main() {}
extern {
    fn foobar(x: FooBar);
}

#[repr(C)]
struct FooBar {
    foo: c_int,
    bar: c_short,
}
```

---

# Споделяне на низове

--
* Низовете в Rust са utf-8 encoded, нямат терминираща нула и си пазят размера отделно
--
* Низовете в C могат да имат всякакъв encoding и завършват с терминираща нула
--
* Трябва да конвертираме от единия до другия вид когато изпращаме низове

---

# Споделяне на низове

### CString

* Низ със собственост, съвместим със C.
* Не съдържа нулеви байтове `'\0'` във вътрешността и завършва на терминираща нула.

```rust
# //norun
# use std::os::raw::c_char;
# extern {
#     fn print(s: *const c_char);
# }
use std::ffi::CString;

# fn main() {
// създава се от неща които имплементират Into<Vec<u8>>,
// в това число &str и String
let hello = CString::new("Hello!").unwrap();

unsafe {
    print(hello.as_ptr());
}
# }
```

---

# Споделяне на низове

### CString

Какъв е проблема?

```rust
# //norun
# use std::os::raw::c_char;
# use std::ffi::CString;
extern {
    fn print(s: *const c_char);
}

# fn main () {
unsafe {
    print(CString::new("Hello!").unwrap().as_ptr());
}
# }
```

---

# Споделяне на низове

### CString

Работим с голи указатели, а не с референции. Трябва да се погрижим паметта да живее достатъчно!

```rust
# //norun
# use std::os::raw::c_char;
# use std::ffi::CString;
# extern {
#     fn print(s: *const c_char);
# }
# fn main() {
let hello = CString::new("Hello!").unwrap();
let ptr = hello.as_ptr();                             // `ptr` е валиден докато `hello` е жив
unsafe { print(ptr) };                                // Ок

let ptr = CString::new("Hello!").unwrap().as_ptr();   // временния CString се деалокира
unsafe { print(ptr) };                                // подаваме dangling pointer
# }
```

---

# Споделяне на низове

### CStr

--
* Borrowed CString
--
* удобно ако C код ни даде низ

---

# Option and the "nullable pointer optimization"

```c
typedef int (*callback)(int);

// callback can be a function pointer or NULL
void register(f: callback);
```

```rust
# // ignore
extern "C" {
    /// Registers the callback.
    fn register(cb: Option<extern "C" fn(c_int) -> c_int>);
}
```

---

# Opaque types

Често C код използва opaque types.

```c
struct Foo;

Foo* init();
int stuff(Foo* foo);
```

---

# Opaque types

За да представим такъв тип в rust можем да използваме празен enum

Не можем да създадем променлива от този тип, защото enum-а няма варианти

```rust
# // norun
# use std::os::raw::c_int;
# fn main() {}
enum Foo {}

extern {
    fn init() -> *const Foo;
    fn stuff(foo: *const Foo) -> c_int;
}
```

---

# Компилиране до библиотека

До сега сме правили библиотеки за Rust чрез `cargo new --lib`.
При компилация този вид crate ни дава rlib и има следния Cargo.toml

```toml
[package]
name = "project_name"
version = "0.1.0"
authors = ["..."]

[dependencies]
```

---

# Компилиране до библиотека

Това е достатъчно когато правим crate за Rust екосистемата, но понякога се налага да създадем специфично статична или динамична библиотека.

---

# Компилиране до библиотека

В този случай може да използвате `Cargo.toml`, за да укажете това

```toml
[package]
name = "project_name"
version = "0.1.0"

[lib]
crate-type = ["..."]

[dependencies]
```

---

# Компилиране до библиотека

На мястото на триеточието може да поставим следните типове:

--
* `bin` - binary
--
* `lib` - компилатора избира типа на библиотеката
--
* `rlib` - статична Rust библиотека с метаданни `.rlib`
--
* `dylib` - динамична Rust библиотека `.so`, `.dylib`, `.dll`
--
* `staticlib` - статична native библиотека `.a`, `.lib`
--
* `cdylib` - динамична native библиотека предназначена за използване от други езици `.so`, `.dylib`, `.dll`
--
* `proc-macro` - процедурен макрос

---

# Компилиране до библиотека

При компилация с cargo файловете се намират в `target/${target_type}`

---

# bindgen crate

[Bindgen](https://github.com/rust-lang-nursery/rust-bindgen)

---

# Ресурси

--
* [The Rust Book, First Edition](https://doc.rust-lang.org/book/first-edition/ffi.html)
--
* [Cargo Manifest](http://doc.crates.io/manifest.html)
--
* [Rust Reference Manual](https://doc.rust-lang.org/reference/linkage.html)
