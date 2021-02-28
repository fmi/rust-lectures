---
title: Процедурни макроси
author: Rust@FMI team
speaker: Делян Добрев
date: 13 януари 2021
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github

---

# Административни неща

Домашно №4 - https://fmi.rust-lang.bg/tasks/4

---

# Процедурни макроси

Предоставят ни възможността да пишем синтактични разширения под формата на функции

---

# Процедурни макроси

* Работят директо с TokenStream - приемат и връщат TokenStream
* Всеки процедурен макрос е отделна Rust библиотека (нормалните макроси си имат собствен синтаксис чрез `macro_rules!`)
* Не са хигиенични - за разлика от нормалните макроси се повлияват от кода около тях

---

# Фази на компилация

За да разберем какво точно правят процедурните макроси, трябва да знаем фазите на компилация

---

# Фази на компилация

Всеки код минава през няколко фази при компилация/интерпретация в зависимост от компилатора

Стандартно първите две са Lexer и Parser

---

# Фази на компилация
### Lexer

Целта на Lexer-a е да разбие кода, който е под формата на низ или поток от символи на значещи за езика Token-и
Примери за Token са ключови думи, литерали, оператори, имена на променливи и др.
Крайният резултат е поток от Token-и

---

# Фази на компилация
### Parser

Parser-ът приема поток от Token-и и им придава значение като крайният резултат е дърво
Всеки възел от дървото е синтактична конструкция на езика
Примери за такъв възел са `if`, block, variable, expression и др.

---

# Фази на компилация

Процедурните макроси се вмъкват между лексъра и парсъра и работят с поток от опростени Token-и

---

# Процедурни макроси
### Особености

* Макросът споделя ресурсите на компилатора като stdin, stdout, stderr
* Ако макросът panic-не, компилаторът го прихваща и изкарва compiler error
* Това може да се постигне и чрез `compile_error!`
* Ако макросът влезе в безкраен цикъл, целият компилатор зависва

---

# Процедурни макроси

За да създадем такъв макрос ни трябва нов проект, в чиито манифест да се съдържа

```toml
[lib]
proc-macro = true
```

---

# Процедурни макроси
### Видове

* Function-like macros - `sql!(SELECT * FROM posts WHERE id=1)`
* Derive macros - `#[derive(CustomDerive)]`
* Attribute macros - `#[CustomAttribute]`

---

# Function-like procedural macros

Изглеждат като нормални макроси, но зад тях стои Rust код вместо синтаксиса на `macro_rules!`
Не могат да се ползват като statement, expression или pattern, но са позволени на всички останали места

---

# Function-like procedural macros

```rust
# // ignore
/// Macro

extern crate proc_macro;

use proc_macro::TokenStream;

#[proc_macro]
pub fn make_answer(_item: TokenStream) -> TokenStream {
    "fn answer() -> u32 { 42 }".parse().unwrap()
}
```

```rust
# // ignore
/// Usage

use proc_macro_examples::make_answer;

make_answer!();

fn main() {
    println!("{}", answer());
}
```

---

# Derive macros

Анотират структури или енумерации, като добавят код към модула или блока на анотирания item без да променят item-a

---

# Derive macros

```rust
# // ignore
/// Macro

extern crate proc_macro;

use proc_macro::TokenStream;

#[proc_macro_derive(AnswerFn)]
pub fn derive_answer_fn(_item: TokenStream) -> TokenStream {
    "fn answer() -> u32 { 42 }".parse().unwrap()
}
```

```rust
# // ignore
/// Usage

use proc_macro_examples::AnswerFn;

#[derive(AnswerFn)]
struct Struct;

fn main() {
    assert_eq!(42, answer());
}
```

---

# Derive macro helper attributes

Може да дефинираме и помощни атрибути, които служат само за ориентация на макроса

---

# Derive macro helper attributes

```rust
# // ignore
/// Macro

#[proc_macro_derive(HelperAttr, attributes(helper))]
pub fn derive_helper_attr(_item: TokenStream) -> TokenStream {
    TokenStream::new()
}

```

```rust
# // ignore
/// Usage

#[derive(HelperAttr)]
struct Struct {
    #[helper] field: ()
}
```

---

# Attribute macros

Дефинират произволен атрибут
За разлика от Derive макросите, заместват кода който анотират
Също така са по-гъвкави от Derive макросите като могат да анотират повече конструкции например функции

---

# Attribute macros

```rust
# // ignore
/// Macro

/// Noop with prints
#[proc_macro_attribute]
pub fn show_streams(attr: TokenStream, item: TokenStream) -> TokenStream {
    println!("attr: \"{}\"", attr.to_string());
    println!("item: \"{}\"", item.to_string());
    item
}

```

```rust
# // ignore
/// Usage

use my_macro::show_streams;

// Example: Basic function
#[show_streams]
fn invoke1() {} // attr: ""   item: "fn invoke1() { }"

// Example: Attribute with input
#[show_streams(bar)]
fn invoke2() {} // attr: "bar"   item: "fn invoke2() {}"

// Example: Multiple tokens in the input
#[show_streams(multiple => tokens)]
fn invoke3() {} // attr: "multiple => tokens"   item: "fn invoke3() {}"

#[show_streams { delimiters }]
fn invoke4() {} // attr: "delimiters"   item: "fn invoke4() {}"
```

---

# Обработка на входните данни

`TokenStream` имплементира `IntoIterator`, което ни позволява да превърнем потока в итератор

```rust
# // ignore
#[proc_macro]
pub fn exmaple(input: TokenStream) -> TokenStream {
    for token in input.into_iter() {
        println!("{}", token);
    }

    // ...
}
```

---

# Обработка на входните данни

Може да си направим собствен парсър на итератор от `TokenTree`, но това обикновено е трудоемка и времеемка задача

Ще видим как може да улесним задачата малко по-късно

---

# Обработка на изходните данни

Дали построяването на изходния поток е по-лесно?

---

# Обработка на изходните данни

Както видяхме в един от предните примери, може да използваме `.parse()`, тъй като `TokenStream` имплементира `FromStr`

```rust
# // ignore
#[proc_macro]
pub fn exmaple(input: TokenStream) -> TokenStream {
    "fn f() {}".parse().unwrap()
}
```

---

# Обработка на изходните данни

Комбинирайки `.parse()` с `format!()`, може да постигнем гъвкаво конструиране на крайния резултат

```rust
# // ignore
#[proc_macro]
pub fn exmaple(input: TokenStream) -> TokenStream {
    format!(r#"fn f() {{ println!("{{}}", {}); }}"#, 42).parse().unwrap()
}
```

---

# Обработка на изходните данни

Недостатъците на подхода с `format!` са
* special character escaping
* едитори обикновено не оцветяват код в низове, което прави сложни примери трудни за поддръжка

---

# syn and quote

Освен вградения `proc_macro` пакет съществуват два, които се използват най-често при работа с процедурни макроси
* [syn](https://crates.io/crates/syn)
* [quote](https://crates.io/crates/quote)

--

Базирани са на [proc_macro2](https://crates.io/crates/proc-macro2)

---

# syn

`syn` пакетът предоставя парсър, който превръща TokenStream в синтактично дърво AST (Abstract syntax tree)

```rust
# // ignore
#[proc_macro_derive(HelloMacro)]
pub fn hello_macro_derive(input: TokenStream) -> TokenStream {
    // Construct a representation of Rust code as a syntax tree
    // that we can manipulate
    let ast: syn::DeriveInput = syn::parse(input).unwrap();

    // Build the trait implementation
    impl_hello_macro(&ast)
}
```

---

# AST (Abstract syntax tree)

Нарича се абстрактно дърво, защото не описва всяка подробност от реалния синтаксис, а само структурата на кода
Например скобите не присъстват в дървото, те само насочват парсъра

---

# quote

`quote` пакетът предоставя начин да превърнем синтактичното дърво обратно в TokenStream, който да върнем на компилатора

```rust
# // ignore
fn impl_hello_macro(ast: &syn::DeriveInput) -> TokenStream {
    // Извлича името на структурата която сме анотирали
    let name = &ast.ident;
    let gen = quote! {
        impl HelloMacro for #name {
            fn hello_macro() {
                println!("Hello, Macro! My name is {}", stringify!(#name));
            }
        }
    };
    gen.into()
}
```

---

# quote

`#var` интерполира стойността на променливи в token-и

---

# Библиотеки с интересни процедурни маркоси

* https://crates.io/crates/serde
* https://crates.io/crates/rocket
* https://crates.io/crates/fehler
* https://github.com/colin-kiegel/rust-derive-builder
* https://crates.io/crates/derive_more
* https://crates.io/crates/educe

---

# Ресурси

* https://doc.rust-lang.org/reference/procedural-macros.html#procedural-macros
* https://doc.rust-lang.org/stable/book/ch19-06-macros.html#procedural-macros-for-generating-code-from-attributes
