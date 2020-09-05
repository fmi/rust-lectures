---
title: Web assembly
author: Rust@FMI team
speaker: Никола Стоянов
date: 16 януари 2020
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Web assembly

> WebAssembly (abbreviated Wasm) is a binary instruction format for a stack-based virtual machine. Wasm is designed as a portable target for compilation of high-level languages like C/C++/Rust, enabling deployment on the web for client and server applications.

Източник: https://webassembly.org

---

# Компилация на rust до wasm

- преди да разгледаме някакви помощни инструменти
--
- ще видим как можем да компилираме до wasm използвайки `cargo` и `rustc`
--
- `rustc` може да генерира web assembly код ако използваме `--target` атрибута

---

# Компилация на rust до wasm

### Крос компилация

- най-често от компилаторите се очаква да генерират код за същата платформа върху която се изпълняват
--
- но понякога искаме компилираната програма или библиотека да се изпълнява на друга платформа
--
- например пишем код за микро контролер
--
- това се нарича cross compilation

---

# Компилация на rust до wasm

### Крос компилация

- rustc използва llvm като backend за генериране на крайния код
--
- llvm поддържа задаване на платформата за която да генерира код чрез target tuple
--
- target tuple-а оказва
--
    - архитектурата на процесора (набор от процесорни инструкции)
--
    - операционната система (ако има такава)
--
    - и понякога допълнително детайли за средата в която ще се изпълнява
--
- примери
--
    - x86_64-unknown-linux-gnu
    - x86_64-pc-windows-msvc

---

# Компилация на rust до wasm

### Крос компилация

- web assembly се поддържа като вид "процесорна архитектура"
--
- ще използваме target-а `wasm32-unknown-unknown`
--
- `rustup target add wasm32-unknown-unknown`
--
- това ще ни инсталира прекомпилира версия на стандартната rust библиотека към която ще се линква

---

# Пример 1

### Rust до Wasm

Cargo.toml
```toml
[lib]
crate-type = ["cdylib"]
```

---

# Пример 1

### Rust до Wasm

src/lib.rs
```rust
# // ignore
#[no_mangle]
pub fn add(a: u32, b: u32) -> u32 {
    a + b
}
```

---

# Пример 1

### Rust до Wasm

```sh
cargo build --release --target wasm32-unknown-unknown
```

Това ше генерира `target/wasm32-unknown-unknown/release/example_01.wasm`

---

# Пример 1

### Изпълняване в уеб браузър

- ще ни е нужен статичен file server
--
- причината е че .wasm (все още) не може да се импортира от html файл
--
- и трябва да използваме javascript функцията `fetch`
--
- ако имате python може да ползвате `python3 -m http.server` [обяснение](https://pythonbasics.org/webserver/)

---

# Пример 1

### Изпълняване в уеб браузър

Сървъра ще връща следните файлове:
- index.html
- index.js
- pkg/wasm_lib.wasm

```sh
cp target/wasm32-unknown-unknown/release/example_01.wasm \
    pkg/wasm_lib.wasm
```

---

# Пример 1

### Изпълняване в уеб браузър

index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Hello wasm!</title>
  </head>
  <body>
    <script src="./index.js" type="module"></script>
  </body>
</html>
```

---

# Пример 1

### Изпълняване в уеб браузър

index.js

```js
const response = fetch('./pkg/wasm_lib.wasm')

response
    .then(r => r.arrayBuffer())
    .then(bytes => WebAssembly.instantiate(bytes, {}))
    .then(({instance, module}) => {
        return instance.exports;
    })
    .then(wasm => {
        // През `wasm` можем да достъпваме функциите които
        // сме дефинирали в нашата библиотека.
        //
        // Но не знаем каква е "calling конвенцията" затова
        // не знаем как правилно да ги извикаме.
        //
        // Единствено функции които приемат и връшат само
        // числа ще работят *почти* както очакваме.
        console.log(wasm.add(1, 2))

        // Това няма да работи както очакваме - ще получим
        // `-3` вместо `-3 as u32`
        console.log(wasm.add(-1, -2))
    })
```

---

# Wasm-bindgen

- web assembly разбира само от няколко числови типа - u32, u64, i32, i64, f32, f64
--
- и гола памет - масив от байтове
--
- `wasm-bindgen` е библиотека която опакова голите функции от wasm модула
--
- генерира wrapper-и и от rust и от js страната

---

# Пример 2

### Wasm-bindgen

Cargo.toml
```toml
[lib]
crate-type = ["cdylib"]

[dependencies]
wasm-bindgen = "*"
```

---

# Пример 2

### Wasm-bindgen

src/lib.rs
```rust
# // ignore
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn add(a: u32, b: u32) -> u32 {
    a + b
}

// повече примери на демото
```

---

# Пример 2

### Wasm-bindgen

```sh
cargo build --release --target wasm32-unknown-unknown

wasm-bindgen target/wasm32-unknown-unknown/release/wasm_lib.wasm \
    --out-dir pkg \
    --target web
```

- копира wasm файла в `pkg/wasm_lib_bg.wasm`
- генерира wrapper `pkg/wasm_lib.js`
- и typescript дефиниции

---

# Пример 2

### Wasm-bindgen

index.js
```js
import init from './pkg/wasm_lib.js'
import { add } from './pkg/wasm_lib.js'

init('pkg/wasm_lib_bg.wasm')
    .then(wasm => {
        console.log(add(1, 2));
    })
```

---

# Пример 2

### Примери от демото

src/lib.rs

```rust
# // ignore
use serde_derive::{Deserialize, Serialize};
use wasm_bindgen::prelude::*;

/// Връща поздрав.
///
/// Този коментар се вижда в генерирания js wrapper.
#[wasm_bindgen]
pub fn greet() -> String {
    "hello wasm".to_string()
}

#[wasm_bindgen]
pub fn add(a: u32, b: u32) -> u32 {
    a + b
}

#[wasm_bindgen]
pub fn sub(a: i32, b: i32) -> i32 {
    a - b
}

#[wasm_bindgen]
pub fn len_64(s: String) -> u64 {
    s.len() as u64
}

// `wasm_bindgen` атрибута позволява да подаваме структурата
// на JS код като opaque тип, т.е. указател
//
// `Serialize, Deserialize` идват от библиотеката `serde`
#[wasm_bindgen]
#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    name: String,
    age: u32,
}

// В този случай `User` е opaque type
#[wasm_bindgen]
pub fn user_info(user: User) -> String {
    format!("{:?}", user)
}

// В този случай `User` е opaque type
#[wasm_bindgen]
pub fn gosho() -> User {
    User {
        name: "Гошо".to_string(),
        age: 11,
    }
}

// в този случай се използва `#[derive(Deserialize)]`
#[wasm_bindgen]
pub fn js_user_info(user: JsValue) -> String {
    // Извиква `JSON.stringify` върху `user` и след това
    // го десериализира до структура
    user_info(user.into_serde().unwrap())
}

// в този случай се използва `#[derive(Serialize)]`
#[wasm_bindgen]
pub fn js_gosho() -> JsValue
{
    // Сериализира структурата до JSON и я подава на JS,
    // където ще се десериализира до JS обект
    JsValue::from_serde(&gosho()).unwrap()
}
```

---

# Пример 2

### Примери от демото

index.js

```js
import init from './pkg/wasm_lib.js'
import { add, greet, len_64, user_info, gosho, js_user_info, js_gosho, User } from './pkg/wasm_lib.js'

function try_catch(id, fn) {
    try {
        fn()
    } catch (e) {
        console.log(id, e);
    }
}

init('pkg/wasm_lib_bg.wasm')
    .then(_ => {
        console.log("greet", greet());

        // 4294967293
        console.log("add0", add(-1, -2));
        // 12
        console.log("add1", add(12));
        // 0
        console.log("add2", add("still", "php?"));

        // 3n
        console.log("len_64", len_64("asd"));

        // { ptr: 1114136 }
        console.log("gosho0", gosho());
        // "User { name: \"Гошо\", age: 11 }"
        console.log("gosho1", user_info(gosho()));
        // Error: "expected instance of User"
        try_catch("gosho2", () => user_info({ name: "Гошо", age: "11" }))
        // Error: "expected instance of User"
        try_catch("gosho3", () => user_info({ ptr: 123456 }))
        // User { name: "", age: 0 }    // Undefined behaviour i guess
        console.log("gosho4", user_info(User.__wrap(123456)))

        // "User { name: \"Гошо\", age: 11 }"
        console.log("js_gosho0", js_user_info({ name: "Гошо", age: 11 }));
        // "User { name: \"Гошо\", age: 11 }"  // the power of serde
        console.log("js_gosho1", js_user_info(["Гошо", 11]));
        // RuntimeError: "unreachable executed"
        try_catch("js_gosho2", () => js_user_info({ name: "Гошо", age: "11" }))
        // RuntimeError: "unreachable executed"
        try_catch("js_gosho3", () => js_user_info('{name: "Гошо", age: "11"}'))
        // { name: "Гошо", age: 11 }
        console.log("js_gosho4", js_gosho());
    });
```

---


# Wasm pack

- автоматизира това което правихме досега ръчно
--
- инсталира target `wasm32-unknown-unknown` с `rustup`
--
- използва `cargo` за да компилира Rust до `.wasm`
--
- използва `wasm-bindgen` за да генерира JavaScript binding-и за rust-кия ни код

---

# Wasm pack

- помага за интеграция с javascript света - npm, bundler-и, ...
- https://rustwasm.github.io/wasm-pack/installer/
- или `cargo install wasm-pack`

---

# Оптимизиране за малък размер

- ако ще добавяме wasm към web страница обикновено размера на модула е по-важен критерий от скоростта му
- можем да използваме различни похвати
- оптимизиране за по-малък размер, вместо за най-голяма скорост (opt-level = "z")
- премахване на ненужни символи с [wasm-opt](https://github.com/WebAssembly/binaryen)
- смяна на глобалния алокатор с такъв оптимизиран за малък размер ([wee_alloc](https://docs.rs/wee_alloc))
- [линк1](https://rustwasm.github.io/book/reference/code-size.html#optimizing-builds-for-code-size) [линк2](https://rustwasm.github.io/book/game-of-life/code-size.html)
- пълен списък с инструменти - https://rustwasm.github.io/book/reference/tools.html

---

# Web assembly извън браузъра

Въпреки, че wasm е създаден с идеята да се използва за уеб намира и други приложения.

--
Web assembly като формат притежава някои много удобни свойства:
--
- сравнително прост bytecode формат
--
- поддръжка на компилация до wasm от много езици
--
- сигурен - всички инструкции и достъпи до памет се валидират
--
- sandbox-нат - няма достъп до външния свят

---

# Web assembly извън браузъра

С две думи е подходящ ако имаме някаква система върху която искаме да позволим на потребители да изпълняват произволен код.

![If WASM+WASI existed in 2008...](images/wasm_docker_tweet.png)

---

# Web assembly извън браузъра

### Няколко презентации

Rust, WebAssembly, and the future of Serverless by Steve Klabnik
https://www.youtube.com/watch?v=CMB6AlE1QuI

Bringing WebAssembly outside the web with WASI by Lin Clark
https://www.youtube.com/watch?v=fh9WXPu0hw8

---

# Watt

- https://github.com/dtolnay/watt
--
- процедурни макроси, компилирани до wasm
--

![WAT](images/wat_duck.jpg)
