---
title: Макроси
author: Rust@FMI team
date: 10 декември 2019
speaker: Делян Добрев
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Административни неща

* Първото предизвикателство е пуснато - https://fmi.rust-lang.bg/challenges/1

---

# Макроси

--
* Първо: Прости макроси, the basics, лесна работа, практически полезни неща
--
* После: Как *всъщност* работят нещата. Edge cases. Сложност. Неприятност.

---

# try!

Това вече сме го виждали

```rust
# // ignore
# #![allow(unused_macros)]
# fn main () {}
macro_rules! try {
    ($expr:expr) => {
        match $expr {
            Ok(value) => value,
            Err(e) => return Err(e.into()),
        }
    }
}
```

---

# add!

Общата схема

```rust
macro_rules! add {
    ($var1:expr, $var2:expr) => {
        $var1 + $var2;
    }
}

fn main() {
    println!("{}", add!(1, 1));
    println!("{}", add!("foo".to_string(), "bar"));
}
```

---

# add!

Общата схема


--
* `macro_rules!` всъщност не е макро, а е "syntax extension", имплементирано на ниво компилатор
--
* Името на макроса следвано от чифт скоби за тялото на макроса: `macro_rules! add { ... }`
--
* Аргументи в скоби, последвани от стрелкичка и още един чифт скоби: `(...) => { ... }`
--
* Всички тези скоби са взаимозаменяеми измежду кръгли, квадратни и къдрави скоби
--
* "Променливите" `$var1`, `$var2` се наричат метапроменливи и в случая са от "тип" expression - цялостен израз

---

# add!

Защо не "променливи"? Защото в кръглите скоби се прави pattern-matching на ниво token-и:

```rust
macro_rules! add {
    (Чш, я събери ($var1:expr) и ($var2:expr)) => {
        $var1 + $var2;
    }
}

fn main() {
    println!("{}", add!(Чш, я събери (1) и (1)));
    println!("{}", add!(Чш, я събери ("foo".to_string()) и ("bar")));
}
```

---

# add!

Защо има скоби? За да се знае къде свършва expression/израз.

```rust
# // norun
# #![allow(unused_macros)]
# fn main () {}
macro_rules! add {
    (Чш, я събери $var1:expr и $var2:expr) => {
        $var1 + $var2;
    }
}
```

---

# add!

Непосредствено след expr са позволени само (`=>`), (`,`) и  (`;`), ако expr не е в скоби

```rust
macro_rules! add {
    (Чш, я събери $var1:expr, $var2:expr) => {
        $var1 + $var2;
    }
}

fn main() {
    println!("{}", add!(Чш, я събери 1, 1));
    println!("{}", add!(Чш, я събери "foo".to_string(), "bar"));
}
```

---

# map!

Нещо малко по-практично

```rust
# // ignore
macro_rules! map {
    {
        $( $key: expr => $value: expr ),*
    } => {
        // Забележете блока
        {
            let mut map = ::std::collections::HashMap::new();
            $( map.insert($key, $value); )*
            map
        }
    }
}
```

---

# map!

Какво прави `$( ... ),*` ?

--
* Това е repetition operator
--
* Винаги се състои от `$( ... )` и едно от трите:
--
* `*` - 0 или повече повторения
--
* `+` - 1 или повече повторения
--
* `?` - 0 или 1 повторения
--
* Може да сложим разделител веднага след затварящата скоба например `,`
--
* `$( ... ),*` търси нещо от вида `... , ... , ...`
--
* Операторът не поддържа optional trailing разделител

---

# map!

Ок, нека да компилираме

```rust
# // ignore
macro_rules! map {
    {
        $( $key: expr : $value: expr ),*
    } => {
        {
            let mut map = ::std::collections::HashMap::new();
            $( map.insert($key, $value); )*
            map
        }
    }
}
```

---

# map!

Ок, нека да компилираме

```rust
# //norun
# #![allow(unused_macros)]
# fn main() {}
macro_rules! map {
    {
        $( $key: expr : $value: expr ),*
    } => {
        {
            let mut map = ::std::collections::HashMap::new();
            $( map.insert($key, $value); )*
            map
        }
    }
}
```

---

# map!

Правилата са си правила... Ще ги разгледаме подробно по-късно

```rust
# //norun
# #![allow(unused_macros)]
# fn main() {}
macro_rules! map {
    {
        $( $key: expr => $value: expr ),*
    } => {
        {
            let mut map = ::std::collections::HashMap::new();
            $( map.insert($key, $value); )*
            map
        }
    }
}
```

---

# map!

```rust
# macro_rules! map {
#     {
#         $( $key: expr => $value: expr ),*
#     } => {
#         {
#             let mut map = ::std::collections::HashMap::new();
#             $( map.insert($key, $value); )*
#             map
#         }
#     }
# }
# fn main() {
let m = map! {
    "a" => 1,
    "b" => 2
};

println!("{:?}", m);
# }
```

---

# map!

А какво става, ако искаме да поддържаме trailing comma 🤔

```rust
# // ignore
# fn main() {
let m = map! {
    "a" => 1,
    "b" => 2,
};

println!("{:?}", m);
# }
```

---

# map!

А какво става, ако искаме да поддържаме trailing comma 🤔

```rust
# macro_rules! map {
#     {
#         $( $key: expr => $value: expr ),*
#     } => {
#         {
#             let mut map = ::std::collections::HashMap::new();
#             $( map.insert($key, $value); )*
#             map
#         }
#     }
# }
# fn main() {
let m = map! {
    "a" => 1,
    "b" => 2,
};

println!("{:?}", m);
# }
```

---

# map!

Не точно каквото очаквахме..

---

# map!

Може би така?

```rust
# // ignore
macro_rules! map {
    {
        $( $key: expr => $value: expr ),*,
    } => {
        /* ... */
    }
}

# fn main() {
let m = map! {
    "a" => 1,
    "b" => 2
};
# }
```

---

# map!

Може би така?

```rust
macro_rules! map {
    {
        $( $key: expr => $value: expr ),*,
    } => {
        /* ... */
#         {
#             let mut map = ::std::collections::HashMap::new();
#             $( map.insert($key, $value); )*
#             map
#         }
    }
}

# fn main() {
let m = map! {
    "a" => 1,
    "b" => 2
};
# }
```

---

# map!

Не..

---

# map!

Не бойте се, има си трик за това

До тази година се налагаше да правим следното

```rust
# // ignore
macro_rules! map {
    {
        $( $key: expr => $value: expr ),* $(,)*
    } => {
        /* ... */
    }
}
```

---

# map!

Недостатъка е, че може да match-нем нещо такова

```rust
# macro_rules! map {
#     {
#         $( $key: expr => $value: expr ),* $(,)*
#     } => {
#         {
#             let mut map = ::std::collections::HashMap::new();
#             $( map.insert($key, $value); )*
#             map
#         }
#     }
# }
# fn main() {
let m = map! {
    "a" => 1,
    "b" => 2,,,,,,,,,,,,
};
# }
```

---

# map!

Но както казахме има оператор `?`

```rust
# // ignore
macro_rules! map {
    {
        $( $key: expr => $value: expr ),* $(,)?
    } => {
        /* ... */
    }
}
```

---

# map!

```rust
macro_rules! map {
    {
        $( $key: expr => $value: expr ),* $(,)?
    } => {
        /* ... */
#         {
#             let mut map = ::std::collections::HashMap::new();
#             $( map.insert($key, $value); )*
#             map
#         }
    }
}

# fn main() {
map! {
    "a" => 1,
    "b" => 2
};

map! {
    "a" => 1,
    "b" => 2,
};
# }
```

---

# Хигиена

Макросите в Rust са хигиенични

```rust
# // ignore
macro_rules! five_times {
    ($x:expr) => (5 * $x);
}

# fn main() {
println!("{}", five_times!(2 + 3));
# }
```

---

# Хигиена

Макросите в Rust са хигиенични

```rust
macro_rules! five_times {
    ($x:expr) => (5 * $x);
}

# fn main() {
println!("{}", five_times!(2 + 3));
# }
```

--
Нещо подобно в C/C++ би изчислило 13

---

# Хигиена

В този пример отново заради хигиена двата state-а не се shadow-ват взаимно

```rust
# fn get_log_state() -> i32 { 1 }
macro_rules! log {
    ($msg:expr) => {{
        let state: i32 = get_log_state();
        if state > 0 {
            println!("log({}): {}", state, $msg);
        }
    }};
}

# fn main() {
let state: &str = "reticulating splines";
log!(state);
# }
```

---

# Хигиена

Всяко разгъване на макрос се случва в различен синтактичен контекст.
В този случай може да го мислите все едно двете променливи имат различен цвят който ги разграничава.

---

# Хигиена

По тази причина не може да представяме нови променливи чрез макрос по следния начин

```rust
macro_rules! foo {
    () => (let x = 3;);
}

# fn main() {
foo!();
println!("{}", x);
# }
```

---

# Хигиена

Ще трябва да подадем името на променлива на макроса за да се получи

```rust
macro_rules! foo {
    ($v:ident) => (let $v = 3;);
}

# fn main() {
foo!(x);
println!("{}", x);
# }
```

---

# Хигиена

Правило важи за `let` и цикли като `loop while for`, но не и за [item](https://doc.rust-lang.org/reference/items.html)-и, което значи, че следното ще се компилира

```rust
macro_rules! foo {
    () => (fn x() { println!("macros!") });
}

# fn main() {
foo!();
x();
# }
```

---

# Синтаксис

### Извикване на макроси

Макросите следват същите правила както останалата част от синтаксиса на Rust


--
* `foo!( ... );`
--
* `foo![ ... ];`
--
* `foo! { ... }`

---

# Синтаксис


--
* Макросите трябва да съдържат само валидни Rust token-и
--
* Скобите в макросите трябва да са балансирани т.е. `foo!([)` е невалидно
--
* Без това ограничение, Rust няма как да знае къде свършва извикването на макроса

---

# Синтаксис

Формално извикването на макрос се състои от поредица от token trees които са


--
* произволна поредица от token trees обградена от `()`, `[]` или `{}`
--
* всеки друг единичен token

---

# Синтаксис

Затова Rust макросите винаги приоритизират затварянето на скобите пред match-ването, което е полезно при някои подходи за match-ване

---

# Синтаксис

### Metavariables & Fragment specifiers

Tиповете на метапроменливите са

* `ident`: an identifier. `x`; `foo`
* `path`: a qualified name. `T::SpecialA`
* `expr`: an expression. `2 + 2`; `if true { 1 } else { 2 }`; `f(42)`
* `ty`: a type. `i32`; `Vec<(char, String)>`; `&T`
* `pat`: a pattern. `Some(t)`; `(17, 'a')`; `_`
* `stmt`: a single statement. `let x = 3`
* `block`: a brace-delimited sequence of statements and optionally an expression. `{ log(error, "hi"); return 12; }`
* `item`: an item. `fn foo() { }`; `struct Bar;`
* `meta`: a "meta item", as found in attributes. `cfg(target_os = "windows")`
* `tt`: a single token tree.
* `lifetime`: a lifetime `'a`.
---

# Синтаксис

### Metavariables & Fragment specifiers

Ограниченията за типовете са

* `expr` and `stmt` variables may only be followed by one of: `=> , ;`
* `ty` and `path` variables may only be followed by one of: `=> , = | ; : > [ { as where`
* `pat` variables may only be followed by one of: `=> , = | if in`
* Other variables may be followed by any token.

---

# Ръкави

Макросите могат да имат повече от един ръкав за matching разделени с ;

```rust
# // ignore
macro_rules! my_macro {
    ($e: expr) => (...);
    ($i: ident) => (...);
    (for $i: ident in $e: expr) => (...);
}
```

---

# Ръкави

Има и конвенция за private ръкави `@text`, които да се викат чрез рекурсия

```rust
# // ignore
macro_rules! my_macro {
    (for $i: ident in $e: expr) => (...);
    (@private1 $e: expr) => (...);
    (@private2 $i: ident) => (...);
}
```

---

# Рекурсия

Макросите могат да извикват други макроси и дори себе си както този прост HTML shorthand

```rust
# // norun
# #![allow(unused_macros)]
# fn main() {}
macro_rules! write_html {
    ($w: expr, ) => (());

    ($w: expr, $e: tt) => (write!($w, "{}", $e)?);

    ($w: expr, $tag: ident [ $( $inner: tt )* ] $( $rest: tt )*) => {{
        write!($w, "<{}>", stringify!($tag))?;
        write_html!($w, $($inner)*);
        write!($w, "</{}>", stringify!($tag))?;
        write_html!($w, $($rest)*);
    }};
}
```

---

# Рекурсия

```rust
# macro_rules! write_html {
#     ($w: expr, ) => (());
#
#     ($w: expr, $e: tt) => (write!($w, "{}", $e)?);
#
#     ($w: expr, $tag: ident [ $( $inner: tt )* ] $( $rest: tt )*) => {{
#         write!($w, "<{}>", stringify!($tag))?;
#         write_html!($w, $($inner)*);
#         write!($w, "</{}>", stringify!($tag))?;
#         write_html!($w, $($rest)*);
#     }};
# }
# fn main() -> Result<(), ::std::fmt::Error> {
use std::fmt::Write;

let mut out = String::new();

write_html! {
    &mut out,
    html[
        head[title["Macros guide"]]
        body[h1["Macros are the best!"]]
    ]
}

println!("{}", out);
# Ok(())
# }
```

---

# Рекурсия

Нека да разгледаме и една алтернатива на `?`, която може да видите като legacy код

```rust
# // norun
# #![allow(unused_macros)]
# fn main() {}
macro_rules! map {
    { $( $key: expr => $value: expr ),*, } => {
        map!( $( $key => $value ),* );
    };

    { $( $key: expr => $value: expr ),* } => {
        {
            let mut map = ::std::collections::HashMap::new();
            $( map.insert($key, $value); )*
            map
        }
    };
}
```

---

# Scoping

Компилатора разгъва макросите в ранна фаза на компилация, затова имат специфична видимост

--
* Дефинициите и разгръщанията се случват в едно depth-first lexical-order обхождане на crate-a
--
* Затова видимостта на макрос е *след* дефиницията му - в същия scope и в child mods
--
* Използването на макрос от друг модул става чрез `#[macro_use]` преди мястото, където го ползвате

---

# Scoping

Имаме макроси дефинирани в macros и ще ги използваме в client

%%
```rust
# // ignore
#[macro_use]
mod macros;
mod client; // ок
```
%%
```rust
# // ignore
mod client; // компилационна грешка
#[macro_use]
mod macros;
```
%%

---

# Scoping

Имаме макроси дефинирани в macros и ще ги използваме в client

```rust
# // ignore
// crate macros

mod some_module {
    #[macro_export]
    macro_rules! hello {
        () => (println!("Hello!"))
    }
}
```

```rust
# // ignore
// crate client

#[macro_use]
extern crate macros;

fn main() {
    hello!();
}
```

---

# Scoping

От Rust 1.30 може и ето така

```rust
# // ignore
// crate macros

mod some_module {
    #[macro_export]
    macro_rules! hello {
        () => (println!("Hello!"))
    }
}
```

```rust
# // ignore
// crate client

// notice top-level use
use macros::hello;

fn main() {
    hello!();
}
```

---

# Scoping

Макроси дефинирани в блокове, функции или други подобни конструкции са видими само там

```rust
# // ignore
fn main() {
    macro_rules! map { ... }
}
```

---

# Scoping

При работа на ниво crate


--
* се използва `#[macro_use]` за импортиране на всичко или `#[macro_use(my_macro, other_macro)]`
--
* за да направите макросите достъпни за други crate-ове се използва `#[macro_export]`
--
* може да видите всички вградени атрибути [тук](https://doc.rust-lang.org/stable/reference/attributes.html#macro-related-attributes)

---

# Debugging

Дебъгването на макроси е сложно, но има някои полезни команди

--
* `rustc --pretty expanded`
--
* `--pretty expanded,hygiene` за да се запазят syntax scope-овете
--
* `cargo +nightly rustc -- -Z unstable-options --pretty=expanded`

---

# Debugging

Има и удобни, но нестабилни макроси, които се ползват през feature gate на nightly

--
* `log_syntax!(...)` - принтира аргументите си при компилация на stdout и се разгръща до нищо
--
* `trace_macros!(true)` - включва компилаторни съобщения при разгръщане на макрос
--
* `trace_macros!(false)` - изключва съобщенията

---

# Стандартни макроси

--
* `panic!` - панира програмата
--
* `vec!` - създава вектор от елементи
--
* `assert!` & `assert_eq!` - използват се при тестове за проверка на данните
--
* https://doc.rust-lang.org/stable/std/#macros

---

# Advanced

### TT Muncher (Token Muncher)

```rust
# // norun
# #![allow(unused_macros)]
# fn main() {}
macro_rules! write_html {
    ($w: expr, ) => (());

    ($w: expr, $e: tt) => (write!($w, "{}", $e)?);

    ($w: expr, $tag: ident [ $( $inner: tt )* ] $( $rest: tt )*) => {{
        write!($w, "<{}>", stringify!($tag))?;
        write_html!($w, $($inner)*);
        write!($w, "</{}>", stringify!($tag))?;
        write_html!($w, $($rest)*);
    }};
}
```

---

# Advanced

### TT Muncher

```rust
# // ignore
write_html! {
    &mut out,
    html[
        head[title["Macros guide"]]
        body[h1["Macros are the best!"]]
    ]
}
```

---

# Advanced

### Push-Down Accumulation

Макрос, който инизиализира масив до 3 елемента

```rust
macro_rules! init_array {
    [$e:expr; $n:tt] => {{
        let e = $e;
        init_array!(@accum ($n, e.clone()) -> ())
    }};
    (@accum (3, $e:expr) -> ($($body:tt)*)) => { init_array!(@accum (2, $e) -> ($($body)* $e,)) };
    (@accum (2, $e:expr) -> ($($body:tt)*)) => { init_array!(@accum (1, $e) -> ($($body)* $e,)) };
    (@accum (1, $e:expr) -> ($($body:tt)*)) => { init_array!(@accum (0, $e) -> ($($body)* $e,)) };
    (@accum (0, $_e:expr) -> ($($body:tt)*)) => { init_array!(@as_expr [$($body)*]) };
    (@as_expr $e:expr) => { $e };
}

# fn main() {
let strings: [String; 3] = init_array![String::from("hi!"); 3];
println!("{:?}", strings);
# }
```

---

# Advanced

### Push-Down Accumulation

А не може ли да опростим нещата до това?

```rust
# // ignore
macro_rules! init_array {
    (@accum 0, $_e:expr) => {/* empty */};
    (@accum 1, $e:expr) => {$e};
    (@accum 2, $e:expr) => {$e, init_array!(@accum 1, $e)};
    (@accum 3, $e:expr) => {$e, init_array!(@accum 2, $e)};
    [$e:expr; $n:tt] => {
        {
            let e = $e;
            [ init_array!(@accum $n, e) ]
        }
    };
}
```

---

# Advanced

### Push-Down Accumulation

Не...

```rust
macro_rules! init_array {
    (@accum 0, $_e:expr) => {/* empty */};
    (@accum 1, $e:expr) => {$e};
    (@accum 2, $e:expr) => {$e, init_array!(@accum 1, $e)};
    (@accum 3, $e:expr) => {$e, init_array!(@accum 2, $e)};
    [$e:expr; $n:tt] => {
        {
            let e = $e;
            [ init_array!(@accum $n, e) ]
        }
    };
}

# fn main() {
let strings: [String; 3] = init_array![String::from("hi!"); 3];
# }
```

---

# Advanced

### Push-Down Accumulation

...защото това би довело до следното разгъване

```rust
# // ignore
init_array!(@accum 3, e)
e, init_array!(@accum 2, e)
e, e, init_array!(@accum 1, e)
e, e, e
[e, e, e]
```

Тук всяка помощна стъпка ще е невалиден Rust синтаксис и това не е позволено независимо от стъпките

---

# Advanced

### Push-Down Accumulation

Push-Down ни позволява да правим подобни конструкции чрез акумулиране на токени, без да се налага да имаме валиден синтаксис през цялото време.

---

# Advanced

### Push-Down Accumulation

Разгъвка на първия пример изглежда така

```rust
# // ignore
init_array! { String:: from ( "hi!" ) ; 3 }
init_array! { @ accum ( 3 , e . clone (  ) ) -> (  ) }
init_array! { @ accum ( 2 , e.clone() ) -> ( e.clone() , ) }
init_array! { @ accum ( 1 , e.clone() ) -> ( e.clone() , e.clone() , ) }
init_array! { @ accum ( 0 , e.clone() ) -> ( e.clone() , e.clone() , e.clone() , ) }
init_array! { @ as_expr [ e.clone() , e.clone() , e.clone() , ] }
```

---

# Advanced

Push-Down Accumulation се използва в комбинация с TT Muncher, за да се парсват произволно сложни граматики

---

# Материали

* [First edition book](https://doc.rust-lang.org/stable/book/first-edition/macros.html) (Missing new features)
* [The Little Book of Rust Macros](https://danielkeep.github.io/tlborm/book/README.html)
