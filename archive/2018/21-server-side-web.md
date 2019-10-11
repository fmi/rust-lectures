---
title: Server-side Web
author: Rust@FMI team
date: 03 януари 2019
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Административни неща

* Мислете за проекти!

---

# За боба, леба, и уеба

--
* Rust все още му е малко рано за сериозен web. Но е използваем! https://www.arewewebyet.org/
--
* Доста работа се влага в client-side неща, но има и доста server-side
--
* Фреймуърците са по-скоро "библиотеки". Прости, композируеми
--
* Не подценявайте стойността на добре организиран фреймуърк. Уеба е "лесен" в такъв смисъл, че индивидуалните проблеми са сравнително лесни, но са много и обикновено трябва да се решават бързо. Организиран, подреден codebase означава удобен flow, лесно намиране на бъгове, лесна работа с други хора.
* Фреймуърк, който ви дава адекватна структура, ви позволява да се концентрирате върху бизнес логиката, вместо върху организационни глупости.
--
* (Уви, рядко се стига до 100% подреденост. Но спокойно може да е "good enough")

---

# За боба, леба, и уеба

--
* Threaded vs event-based сървъри (preemptive vs cooperative multitasking)
--
* Threaded: удобен за работа, неоптимален
--
* Event-based: ако не е написан като хората, може да се забатачи здраво :). Но потенциално се изстисква максимален performance.
--
* За Rust, проекти като [tokio](https://github.com/tokio-rs/tokio) и [hyper](https://github.com/hyperium/hyper) предоставят базата за event-based неща.

---

# За боба, леба, и уеба

В node.js (server-side javascript) най-много си личи кооперативния multitasking:

```javascript
function some_endpoint() {
    var userId = request['id'];

    return database.fetchUser(userId).then(function(err, user) {
        // ...
    });
}
```

Резултата, който се връща от handler-а на някакъв request, е Promise. Той се връща веднага, а функцията-callback се слага на някакъв worker thread. Когато той приключи, се връща крайния резултат, без да се блокира клиента.

---

# Spotiferris

Ще разгледаме (началото на) малък проект за хостинг на музика. Stack-а:

* За сървър: [gotham](https://github.com/gotham-rs/gotham)
* За templating: [askama](https://github.com/djc/askama)
* За заявки към базата: [diesel](http://diesel.rs/)

Source: https://github.com/AndrewRadev/rust-spotiferris

---

# Документация

* От документацията има какво да се желае. Иска се експериментиране и ровене из examples.
* За препоръчване е, ако искате да правите уеб проект, да минете през всички достъпни guides, и всички examples, и на gotham, и на diesel.
* Не игнорирайте и API документацията. Rust е език, в който import-ите могат да се проследяват, и можете да се ориентирате успешно във, примерно, http://docs.diesel.rs/diesel/index.html

---

# Spotiferris

### Demo

---

# Spotiferris

### Проблеми

--
* Бавно :/. Автоматично компилиране и рестартиране би помогнало.
--
* Няма удобен test setup. Има [TestServer](https://docs.rs/gotham/0.3.0/gotham/test/struct.TestServer.html) за gotham, и [test_transaction](https://docs.rs/diesel/1.3.3/diesel/connection/trait.Connection.html#method.test_transaction) за diesel, но няма как да "интегрирате" двете.
--
* Интеграцията между библиотеките иска работа.
--
* Всичките библиотеки са версия 0.x -- нестабилни са като интерфейс.
