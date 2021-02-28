---
title: Правене на игри II
description: Amethyst, ECS
author: Rust@FMI team
date: 07 януари 2020
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
cargo-deps:
    - specs = { version = "0.15", features = ["specs-derive"] }
---

# Административни неща

- Домашно 3: https://fmi.rust-lang.bg/tasks/3
- Предизвикателство 2: https://fmi.rust-lang.bg/challenges/2

---

# Административни неща

### Изберете си проекти

- трябва да си изберете тема за финален проект и ние да ви я одобрим
--
- можете да ни пишете
--
    - в дискорд в `#projects` - https://discord.gg/FCTNfbZ
--
    - на [fmi@rust-lang.bg](mailto:fmi@rust-lang.bg)

---

# Архитектура на игрови двигатели

--
Има много различни начини да се структурира логиката на игра. Някои от тях включват:

--
- ad-hoc - особено ако е по-малък проект
--
- ООП - update на всичко
--
- Component based / EC
--
- ECS - Entity Component System

--
Ще се фокусираме върху ECS, но е добре да видим как се различава от други алтернативи

---

# ООП метода

```rust
# // ignore
loop {
    player.update();
    shots.update();
    enemies.update();

    player.draw();
    shots.draw();
    enemies.draw();
}
```

---

# ООП метода

- всеки обект има виртуален `update` метод
--
- обикновено се реализира чрез наследяване с цел преизползване на логика
--
- напр `Оrc` -> `MeleeUnit` -> `Unit` -> `PositionEntity` -> `BaseEntity`

---

# ООП метода

Недостатъци (в сравнение с ECS)

- веригите от наследяване създават някакви ограничения (всяко X е Y)
--
- и не са лесни за рефакториране
--
- има случаи в които логиката зависи от няколко entity-та и е трудно да се набута в една `update` функция
--
- паралелизъм?

---

# ООП метода

Една интересно сравнение на ООП с ECS:

- RustConf 2018 - Closing Keynote - Using Rust For Game Development by Catherine West
- https://www.youtube.com/watch?v=aKLntZcp27M

---

# Component based

Идеята на компонентната архитектура е да се използва принципа за композиция вместо наследяване.
--
Вместо да се използва наследяване с цел преизползване на код, логиката се разделя на множество независими компоненти.
--
Тези компоненти се закачат към обектите за да им добавят определено поведение.
--
При някои имплементации това добавяне и премахване на поведени може да стане динамично по време на изпълнение на програмата.

---

# Component based / EC

### Entity-Component

- еntity е обект в света
--
- към него се закачат компоненти
--
- компонентът отговаря за определено поведение
--

Забележка: Тука е малко мъгляво дали EC е правилният термин, аз ще го използвам за архитектурата която съм описал по-горе.
--
Много ресурси представят EC и ECS като различни начини да се имплементира архитектура базирана на компоненти, но имплементацията и поведението им е доста различно затова аз ще ги разграничавам.

---

# EC - Entity

```rust
# // ignore
struct Ferris {
    rendering: RenderingComponent,
    position: PositionComponent,
    shooting: ShootingComponent,
}

// или

struct Entity {
    components: Vec<Box<dyn Component>>,
}
```

---

# EC - Component

```rust
# // ignore
struct PositionComponent {
    pos: Vector2<f32>,
    vel: Vector2<f32>,
}

impl Component for PositionComponent {
    fn update(&mut self) {
        self.pos += self.vel * delta_time();
    }
}
```

---

# EC

```rust
# // ignore
for c in components {
    c.update();
}

// или

for e in entities {
    for c in e.components() {
        c.update();
    }
}
```

---

# ECS

### Entity-Component-System

- **еntity** е обект в играта
--
- **компонента** е съвкупност от данни които определят един аспект
--
- компонентите се закачат за entity-та
--
- **системите** са логиката на играта
--
- всяка система обработва entity-та с определени компоненти

---

# ECS - Entity

- entity-то е просто таг
--
- ако два компонента имат един и същ таг, те принадлежат на едно и също entity

---

# ECS - Component

При ECS данните се съдържат в структура наподобяваща релационна база даани.

```rust
# // ignore
// например
let components = Components {
    position: vec![
        (EntityId(0), PositionComponent { pos: .., vel: .. }),
        (EntityId(1), PositionComponent { pos: .., vel: .. }),
        (EntityId(4), PositionComponent { pos: .., vel: .. }),
    ],
    rendering: vec![
        (EntityId(0), RenderingComponent::Sprite("ferris_shooting.png")),
        (EntityId(1), RenderingComponent::Text("Undefined behaviour")),
        (EntityId(4), RenderingComponent::Sprite("pew.png")),
    ],
    shooting: vec![
        (EntityId(0), ShootingComponent { cooldown_remaining: 0.0, cooldown_rate: 1.0 }),
    ],
    enemies: vec![
        (EntityId(1), Enemy {}),
    ],
}
```

---

# ECS - Component

- компонентът е просто някакви данни асоциирани с entity таг
--
- различните типове данни задават различни компоненти
--
- всяко entity може да има най-много един компонент от даден тип
--
- и всеки компонент принадлежи на едно entity
--
- обикновено се държат в линейна сортирана структура от данни
--
- така позволяват бърза итерация и бърз join по entity id

---

# ECS - System

- системите съдържат логиката която се изпълнява върху данните
--
- системата декларира от кои компоненти се интересува и се изпълнява за entity-тата които съдържат тези компоненти

---

# Specs

> Specs Parallel ECS

ECS библиотека създадена като част от [Amethyst](https://github.com/amethyst/amethyst) game engine-а.
Но може да се използва и самостоятелно.

- https://github.com/amethyst/specs
- https://docs.rs/specs

---

# Specs - Component

Деклариране на компонент

```rust
# fn main() {}
# extern crate specs;
use specs::{prelude::*};

struct Pos([f32; 2]);

impl Component for Pos {
    // В каква структура ще се пазят стойностите на компонента.
    // Може да се променя като оптимизация.
    type Storage = VecStorage<Self>;
}
```

---

# Specs - Component

Използвайки `features = ["specs-derive"]`

```rust
# fn main() {}
# extern crate specs;
use specs::{prelude::*, Component};

#[derive(Component)]
#[storage(VecStorage)]  // default is `DenseVecStorage`
struct Pos([f32; 2]);
```

---

# Specs - Resource

Ресурсите в specs са подобни на компоненти с разликата че не са свързани с entity и може да съществува само една стойност от този тип. С други думи са като singleton стойност която се управлява от specs.

Ресурс може да е всеки тип `T: 'static + Send + Sync + Any`

Примери:
    - активна камера
    - часовник
    - ...

---

# Specs - System

```rust
# fn main() {}
# extern crate specs;
# use specs::{prelude::*, Component};
#[derive(Component)] struct Pos(f32);
#[derive(Component)] struct Vel(f32);
struct DeltaTime(f32);

struct MovementSys;

impl<'a> System<'a> for MovementSys {
    // Данните, които тази система използва
    type SystemData = (
        WriteStorage<'a, Pos>,      // компонент `Pos`
        ReadStorage<'a, Vel>,       // компонент `Vel`
        ReadExpect<'a, DeltaTime>,  // ресурс `DeltaTime`
    );

    fn run(&mut self, data: Self::SystemData) {
        let (mut pos, vel, dt) = data;
        let DeltaTime(dt) = *dt;

        // Използваме `.join()` за да изберем само тези ентитита,
        // които имат и двата компонента.
        for (pos, vel) in (&mut pos, &vel).join() {
            pos.0 += vel.0 * dt;
        }
    }
}
```

---

# Specs - System

- системите декларират експлицитно кои компоненти и ресурси четат и кои пишат
--
- това позволява на specs автоматично да паралелизира изпълнението им
--
- освен това самата система може да се изпълнява паралелно - например използвайки `par_join` вместо `join`
--
- за целта се използва библиотеката [rayon](https://docs.rs/rayon)

---

# Specs - Dispatcher

- класа, който изпълнява системите
--
- към него се регистрират системите
--
- по извор със зависимости коя преди коя трябва да се изпълни
--
- `dispatcher.dispatch` е update функцията

---

# Specs - Demo

https://github.com/sunjay/rust-simple-game-dev-tutorial

---

# Библиотеки и игрови двигатели

### Amethyst

- https://github.com/amethyst/amethyst
--
- game engine в пълния смисъл на думата
--
- построен около библиотеката `specs`
--
- много feature-и...
--
- и discord сървър за помощ или споделяне на яки проекти
--

*Забележка*: Аметист е мощен, но като всеки голям проект изисква време докато човек научи концепциите му. Не си избирайте да правите краен проект на аметист защото ще си загубите времето в учене на API.

---

# Библиотеки и игрови двигатели

### Kiss3d

- Keep It Simple, Stupid 3d graphics engine
--
- https://github.com/sebcrozet/kiss3d
--
- проста графична библиотека за създаване на прости 3d сцени
--
- предоставя наготово повече неща които са нужни ако искаме визуализираме нещо
--
    - създаване на прозорец
--
    - камера, която се контролира с мишката
--
    - светлини, цветове, текстури
--
    - базови геометрични фигури, трансформации
