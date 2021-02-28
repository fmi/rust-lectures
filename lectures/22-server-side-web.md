---
title: Server-side Web
author: Rust@FMI team
speaker: Андрей
date: 18 януари 2021
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Административни неща

* Мислете за проекти!
* Пишете домашно!

---

# За боба, 'леба и уеба

* Rust е "използваем" за уеб: https://www.arewewebyet.org/
--
* Фреймуърците са по-скоро "библиотеки". Прости, композируеми. Има какво да се желае от интеграцията между тях.

---

# За боба, 'леба и уеба

Накратко как работи Интернета:

- Една машина стартира безкраен цикъл, който чака за заявки с определен протокол (HTTP) на определен порт. Стандартния порт е 80 за некриптирани, 443 за криптирани връзки. Но може да се използва който и да е.
--
- Някой си отваря браузъра ("клиент") и търси нашия адрес и порт, който се превежда до IP адрес и порт от някакъв DNS (Domain Name Server).
--
- Клиента праща определени параметри, базирано на които програмата-сървър решава какъв низ да върне.
--
- Този низ е във формат HTML, който браузъра знае как да интерпретира като структуриран текст
--
- Или във формат CSS, който казва на браузъра "тази страница има шарени цветове и закръглени ръбчета"
--
- Или във формат Javascript, който инструктира браузъра да кара текста да мига и да копае биткойни.

---

# За боба, 'леба и уеба

Сървъра е просто един цикъл, който чака низова информация в определен формат и връща низова информация в определен формат. Може да го напишем на shellscript, ако искаме (но ще го пишем на Rust).

Разбира се, в реални условия е доста по-сложно да се докарат всички детайли.

(Тия обяснения вероятно не са достатъчни за начинаещ, но поне не са нищо. `¯\_(ツ)_/¯`)

---

# Hello Web

### Demo

https://github.com/AndrewRadev/hello-rusty-web

---

# Hello Web

### Demo

* Съкратено изграждане на маршрут: `web::get()` == `Route::new().guard(guard::Get())`
--
* "Route": Комбинация от функция и някакви "guard"-ове, които описват кога се активира
--
* "Resource": Няколко route-а могат да се накачулят на един път, примерно `web::resource("/posts")` може да му се добавят няколко route-а с различни guard-ове.
--
* "Service": Комбинация от път + route.
--
* "Extractor": Тип, който имплементира `FromRequest` -- може да вадим форми, сесия, параметри от request-а.

---

# Actix-web

Extractor magic: https://github.com/actix/actix-web/blob/0a506bf2e9f0d07c505df725a68808c6343f7a4e/src/handler.rs#L179-L206

---

# Spotiferris

Ще разгледаме (началото на) малък проект за хостинг на музика. Stack-а:

* За сървър: [actix-web](https://actix.rs/)
* За templating: [askama](https://github.com/djc/askama)
* За заявки към базата: [SQLx](https://github.com/launchbadge/sqlx)

Source: https://github.com/AndrewRadev/rust-spotiferris

Стара версия с gotham + diesel: https://github.com/AndrewRadev/rust-spotiferris/releases/tag/gotham-diesel-askama

---

# Database

```
cargo install sqlx-cli --no-default-features --features postgres
```

---

# Gotchas

```
match form.insert(&db) {
    Ok(id) => {
```

Грешка:

```
error[E0308]: mismatched types
  --> src/handlers.rs:86:13
   |
86 |             Ok(id) => {
   |             ^^^^^^ expected opaque type, found enum `std::result::Result`
   |
  ::: src/models.rs:40:48
   |
40 |     pub async fn insert(&self, db: &PgPool) -> Result<i32, sqlx::Error> {
   |                                                ------------------------ the `Output` of this `async fn`'s expected opaque type
   |
   = note: expected opaque type `impl futures::Future`
                     found enum `std::result::Result<_, _>`
```

---

# Gotchas

```
match form.insert(&db).await {
    Ok(id) => {
```

All good!

---

# Auto-reload

```
cargo install cargo-watch
cargo watch -x 'run --bin server'
```

---

# Testing

:/

```
cargo test -- --test-threads=1
```

Luca Palmieri има друго валидно решение -- база данни с ново име за всеки индивидуален тест. Вариант е.

---

# Spotiferris

### Проблеми

* Интеграцията между библиотеките иска работа.
--
* Всичките библиотеки са версия 0.x -- нестабилни са като интерфейс.
--
* Типовата магия може да е трудна за дебъгване.
--
* Тестването е ръбато.
--
* Проекта е далеч от "production-ready"...

---

# Ресурси

* Luca Palmieri има страхотна поредица от blog post-ове, в която задълбава в още доста детайли: https://www.lpalmieri.com/. Компилира ги в книга, ["Zero to Production"](https://www.zero2prod.com/).
--
* Actix си има доста добра документация: https://actix.rs/docs/. Има и [actix-examples](https://github.com/actix/examples) с разнообразни интересни неща.
--
* Diesel е друг фреймуърк за бази данни. Малко по-battery-included, но със собствените си особености: http://diesel.rs/
--
* Askama: https://djc.github.io/askama/askama.html

---

# Проекти?

* Multiplayer snake: https://youtu.be/Yb-QR3Vm3sk
--
* Кръстословици: https://youtu.be/9aHfK8EUIzg
--
* "Тънък" web проект -- web нещата да са само за интерфейс, с интересна логика отвъд това.
--
* Или, "истински" web проект с база данни, формички, CRUD интерфейси и т.н.
--
* Няма да сме много взискателни откъм production-readiness, webscale, etc. Подкарайте го да върви в development mode и да има тестове и ще сме доволни.
