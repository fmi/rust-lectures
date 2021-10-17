---
title: Запазване на анонимни функции, Read, Write, Networking
author: Rust@FMI team
date: 2 декември 2020
speaker: Делян Добрев
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Административни неща

Разглеждане на второто домашно с примерна имплементация: https://youtu.be/HtyMM_RGexU

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

--
Забележете скобите около `self.f`

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
    closure: &'a dyn Fn()
}
```
%%
```rust
# // norun
# fn main() {}
struct F {
    closure: Box<dyn Fn()>
}
```
%%

---

# Returning closures

### Вариант 2

Така дали ще е добре?

```rust
# // ignore
fn curry(a: u32) -> Box<dyn Fn(u32) -> u32> {
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
fn curry(a: u32) -> Box<dyn Fn(u32) -> u32> {
    Box::new(|b| a + b)
}
```

---

# Returning closures

### Вариант 2

move

```rust
fn curry(a: u32) -> Box<dyn Fn(u32) -> u32> {
    Box::new(move |b| a + b)
}

# fn main() {
println!("{}", curry(1)(2));
# }
```

---

# Closures & lifetimes

А какво става, ако искаме да прихванем референция?

```rust
# fn main() {}
fn curry<'a>(a: &'a u32) -> Box<dyn Fn(&u32) -> u32> {
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

Какво означава обект (който не е референция) да има 'static lifetime?

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

По подразбиране се очаква trait object-а да няма lifetime ограничение, т.е да е 'static

`Box<dyn Fn(&u32) -> u32>` <-> `Box<dyn Fn(&u32) -> u32 + 'static>`;

Ако имаме ограничение трябва да го укажем изрично

```rust
fn curry<'a>(a: &'a u32) -> Box<dyn Fn(&u32) -> u32 + 'a> {
    Box::new(move |b| a + b)
}

# fn main() {
println!("{}", curry(&1)(&2));
# }
```

---

# Promise Demo

Ще опитаме да си имплементираме Promise в Rust

---

# Promise Demo

--

JavaScript API

```js
const promise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve('foo');
    }, 300);
});

promise.then(value => console.log(value));
promise.catch(error => console.log(error));
```

--

![](./images/event-loop.png)

---

# Promise Demo

Ако искате да си разгледате сорса: https://github.com/d3lio/simple-promise

---

# Read & Write

Има стандартни типажи, които ни помагат за четене и писане

---

# Read & Write

### `std::io::Read`

Един от тях е <code>Read</code>

```rust
# //ignore
# fn main() {
pub trait Read {
    // Required:
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize>;

    // Provided:
    fn read_to_end(&mut self, buf: &mut Vec<u8>) -> io::Result<usize> { ... }
    fn read_to_string(&mut self, buf: &mut String) -> io::Result<usize> { ... }
    fn read_exact(&mut self, buf: &mut [u8]) -> io::Result<()> { ... }
    fn by_ref(&mut self) -> &mut Self where Self: Sized { ... }
    fn bytes(self) -> Bytes<Self> where Self: Sized { ... }
    fn chain<R: Read>(self, next: R) -> Chain<Self, R> where Self: Sized { ... }
    fn take(self, limit: u64) -> Take<Self> where Self: Sized { ... }
}
# }
```

---

# Read & Write

### Бележка:

В модула `std::io` има следната дефиниция:

```rust
# //ignore
type Result<T> = Result<T, Error>;
```

Този синтаксис дефинира type alias ("тип-синоним"). Типа `std::io::Result<T>` е еквивалентен на `Result<T, std::io::Error>`.

Това се използва за улеснение, и спокойно може да use-нем `std::io` и да адресираме `io::Result<usize>` без да указваме типа за грешка -- той вече е конкретизиран в alias-а.

---

# Read

Имплементира се за някои очаквани структури и слайсове от байтове

```rust
# //ignore
# fn main() {
impl Read for File
impl Read for Stdin
impl Read for TcpStream
impl<'_> Read for &'_ [u8]
# }
```

---

# Read

Четене от `File`

```rs
use std::io;
use std::io::prelude::*;
use std::fs::File;

fn main() -> io::Result<()> {
    let mut f = File::open("foo.txt")?;
    let mut buffer = [0; 10];

    // Може да прочетем само 10 байта
    f.read(&mut buffer)?;

    let mut buffer = Vec::new();
    // Може да прочетем целия файл
    f.read_to_end(&mut buffer)?;

    // Или директно да четем в String
    let mut buffer = String::new();
    f.read_to_string(&mut buffer)?;

    Ok(())
}
```

---

# Read

Четене от `Stdin`

```rust
# //ignore
# fn main() {
use std::io::{self, Read};

let mut buffer = String::new();
io::stdin().read_to_string(&mut buffer)?;
# }
```

---

# Read & Write

### `std::io::Write`

За писане се използва <code>Write</code>

```rust
# //ignore
# fn main() {
pub trait Write {
    // Required:
    fn write(&mut self, buf: &[u8]) -> io::Result<usize>;
    fn flush(&mut self) -> io::Result<()>;

    // Provided:
    fn write_all(&mut self, buf: &[u8]) -> io::Result<()> { ... }
    fn write_fmt(&mut self, fmt: Arguments) -> io::Result<()> { ... }
    fn by_ref(&mut self) -> &mut Self where Self: Sized { ... }
}
# }
```

---

# Write

Както <code>Read</code>,  се имплементира за очаквани структури, но и за вектор

```rust
# //ignore
# fn main() {
impl Write for File
impl Write for Stdout
impl Write for Stderr
impl Write for TcpStream
impl Write for Vec<u8>
# }
```

---

# Write

```rust
# //ignore
# fn main() {
use std::fs::File;
use std::io::Write;

let mut f = File::create("foo.txt")?;
f.write_all(b"Hello, world!")?;
# }
```

---

# Read & Write

Като цяло са интуитивни, но не винаги ефективни когато правим много, но малки операции

---

# BufReader & BufWriter

--
* Затова са създадени <code>BufReader</code> и <code>BufWriter</code>
--
* Използват се да буферират операциите, както се досещате от имената им

---

# BufReader & BufWriter

### `std::io::BufReader`

<code>BufReader</code> е wrapper за структури, които имплементират <code>Read</code>

```rust
use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn main() -> Result<(), std::io::Error> {
# std::fs::write("log.txt", b"Some stuff").unwrap();
    let f = File::open("log.txt")?;
    let mut reader = BufReader::new(f);

    let mut line = String::new();
    let len = reader.read_line(&mut line)?;
    println!("First line is {} bytes long", len);
    Ok(())
}
```

---

# BufReader & BufWriter

### std::io::BufRead

Тук се появява нов метод <code>read_line</code>:

```rust
# //ignore
# fn main() {
pub trait BufRead: Read {
    // Required:
    fn fill_buf(&mut self) -> io::Result<&[u8]>;
    fn consume(&mut self, amt: usize);

    // Provided:
    fn read_until(&mut self, byte: u8, buf: &mut Vec<u8>) -> io::Result<usize> { ... }
    fn read_line(&mut self, buf: &mut String) -> io::Result<usize> { ... }
    fn split(self, byte: u8) -> Split<Self> where Self: Sized { ... }
    fn lines(self) -> Lines<Self> where Self: Sized { ... }
}
# }
```

---

# BufReader & BufWriter

### BufWriter

Подобно, <code>BufWriter</code> е wrapper за структури, които имплементират <code>Write</code>

```rust
# //ignore
# fn main() {
use std::io::prelude::*;
use std::io::BufWriter;
use std::net::TcpStream;

let mut stream = BufWriter::new(TcpStream::connect("127.0.0.1:34254").unwrap());

for i in 1..10 {
    stream.write(&[i]).unwrap();
}
# }
```

В този пример чрез <code>BufWriter</code> превръщаме 10 system calls в 1

---

# BufReader & BufWriter

### BufWrite

Няма <code>BufWrite</code> :(

---

# BufReader & BufWriter

* `Read`: Trait, който е имплементиран за файлове, сокети, и т.н., за четене на брой байтове.
* `BufReader`: Структура, която обвива нещо, което е `Read`, която **също e** `Read` и която имплементира `BufRead`.
* `BufRead`: Trait за структури като `BufReader`, които четат чрез буфер.
--
<hr>
* `Write`: Trait, който е имплементиран за файлове, сокети, и т.н., за писане на брой байтове.
* `BufWriter`: Структура, която обвива нещо, което е `Write`, която **също e** `Write` и която позволява буферирано писане
* `BufWrite`: Не съществува :/.

---

# Read & Write

<code>Write</code> може да се използва и за тестване чрез <code>mock</code>

```rust
# //ignore
# fn main() {
fn write_u8<W>(writer: &mut W, data: u8) -> io::Result<usize>
where W: Write {
    // Do cool stuff with `writer`
}

#[test]
fn test_write_u8() {
    let mut mock: Vec<u8> = Vec::new();

    write_u8(&mut mock, 42).unwrap();

    assert_eq!(mock.len(), 1);
    assert_eq!(mock[0], 42);
}
# }
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

    // приема конекции и ги обработва
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

                match client.write_all(&buf) {
                    Ok(_) => Some(client),
                    _ => None,
                }
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
        io::stdin().read_line(&mut buf).expect("Reading from stdin failed");
        let msg = buf.trim().to_string();

        if msg == ":q" || sx.send(msg).is_err() { break }
    }
    println!("bye!");
}
```
