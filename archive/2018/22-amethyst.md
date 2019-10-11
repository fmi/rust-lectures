---
title: Правене на игри с Amethyst
author: Rust@FMI team
date: 08 януари 2019
lang: bg
keywords: rust,fmi
slide-width: 80%
font-size: 24px
font-family: Arial, Helvetica, sans-serif
code-theme: github
---

# Какво е Amethyst?

What sort of graphics do you need?

- 2D only. All you need is...
    - Love: [ggez](https://github.com/ggez/ggez)
    - Not sure: [piston](https://github.com/PistonDevelopers/piston)
- 3D for sure. Do you like making your hands dirty?
    - Yes, give me some! What graphics APIs do you need supported?
        - GL only: [glium](https://github.com/glium/glium), [gl-rs](https://github.com/brendanzab/gl-rs)
        - Vulkan only: [vulkano](https://github.com/vulkano-rs/vulkano), [ash](https://github.com/MaikKlein/ash)
        - Many/Other: [gfx-rs](https://github.com/gfx-rs/gfx)
    - Sometimes: [amethyst](https://github.com/amethyst/amethyst)
    - Not at all. Do you fancy experimental/hot/web stuff?
        - Yes: [three.rs](https://github.com/three-rs/three)
        - Nope: [kiss3d](https://github.com/sebcrozet/kiss3d)


<small>Source: [https://gist.github.com/kvark/840c8cadf755b0d822b331222b0c3095](https://gist.github.com/kvark/840c8cadf755b0d822b331222b0c3095)</small>

---

# Подходи

--
- Amethyst използва ECS - Entity Component System
--
- ще го сравним с някои често използвани подходи

---

# Подходи

Една интересна презентация по темата:

- RustConf 2018 - Closing Keynote - Using Rust For Game Development by Catherine West
- https://www.youtube.com/watch?v=aKLntZcp27M

---

# "Update" pattern

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

# EC

### Модел Entity-Component

- еntity е някакъв обект в света
--
- към него се закачат компоненти
--
- компонента отговаря за определено поведение

---

# EC - Entity

```rust
# // ignore
struct Ferris {
    rendering: RenderingComponent,
    position: PositionComponent
    shooting: ShootingComponent
}

struct Enemy {
    rendering: RenderingComponent,
    position: PositionComponent,
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

// or

for e in entities {
    for c in e.components() {
        c.update();
    }
}
```

---

# ECS

### Модел Entity-Component-System

- еntity е обект в играта
--
- компонента е съвкупност от данни
--
- компонентите се закачат за entity-та
--
- системите са логиката на играта
--
- всяка система обработва entity-та с определени компоненти

---

# ECS - Entity

<table>
    <tr>
        <td style="background: #1a334d;">
            <img src="images/ferris-shooting.png">
        </td>
        <td>
            <span style="border: 1px solid #333; background: #d9d2e9; padding: 4px; display: inline-block; border-radius: 4px;">EntityId(0)</span>
        </td>
    </tr>
    <tr>
        <td style="background: #1a334d;">
            <span style="color: #fff; border: 1px solid #fff; font-size: 1.17em; font-weight: bold; padding: 10px; margin: auto">Undefined behaviour</span>
        </td>
        <td>
            <span style="border: 1px solid #333; background: #d9d2e9; padding: 4px; display: inline-block; border-radius: 4px;">EntityId(1)</span>
        </td>
    </tr>
    <tr>
        <td style="background: #1a334d;">
            <img src="images/shot.png">
        </td>
        <td>
            <span style="border: 1px solid #333; background: #d9d2e9; padding: 4px; display: inline-block; border-radius: 4px;">EntityId(4)</span>
        </td>
    </tr>
</table>

---

# ECS - Component

```rust
# // ignore
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
        (EntityId(0), ShootingComponent { cooldown: 0.0, cooldown_rate: 1.0 }),
    ]
}
```

---

# ECS - System

```sql
SELECT (t, mesh, mat)
FROM TransformComponent, MeshComponent, MaterialComponent
WHERE t.entity_id == mesh.entity_id == mat.entity_id
```

---

# ECS - System

```rust
# // ignore
for (t, mesh, mat) in (&transforms, &meshes, &materials).join() {
    ...
}
```

---

# Amethyst

%%
![Old amethyst logo](images/amethyst_logo_old.png)
%%
![New amethyst logo](images/amethyst_logo.png)
%%

---

# Amethyst

- https://www.amethyst.rs/
- може да прочетете [книгата](https://www.amethyst.rs/book/latest/)

---

# API документация

--
- [docs.rs](https://docs.rs) не предоставя документация за подбиблиотеки
--
- много от големите проекти (включително amethyst) съдържат множество малки библиотеки, които се пакетират в един
--
- най-добре е да си генерирате API документация локално с `cargo doc`

---

# Оптимизации

Могат да се включат оптимизации в debug режим, без да се изключват останалите полезни проверки и опции

Това става като се добави в `Cargo.toml`

```toml
[profile.dev]
opt-level = 3
```

За повече информация: https://doc.rust-lang.org/cargo/reference/manifest.html#the-profile-sections

---

# Amethyst

### Simple towers

- кодът на проекта се намира в [github](https://github.com/nikolads/simple-towers)
