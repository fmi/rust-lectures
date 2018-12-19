---
title: Правене на игри с GGEZ
author: Rust@FMI team
date: 04 декември 2018
lang: bg
keywords: rust,fmi
# description:
slide-width: 80%
font-size: 20px
font-family: Arial, Helvetica, sans-serif
# code blocks color theme
code-theme: github
---

# Административни неща

* Лекции от миналия път -- скоро

---

# Rust-shooter

Пълен код: https://github.com/AndrewRadev/rust-shooter

<img src="images/shooter.png" height="500px" />

---

# Инсталация на ggez

### SDL2

Инсталацията на ggez включва инсталиране на необходимите SDL2 библиотеки. Това може да е сравнително досадно, понеже включва копиране на разни dll-и, поне на Windows.

Инструкции: [Rust-SDL2](https://github.com/Rust-SDL2/rust-sdl2#user-content-requirements)

---

# Инсталация на ggez

### SDL2

Как да дистрибутираме после играта? Exe-то ще бъде компилирано с нужните неща, стига да минем през някой от комплектите инструкции. Под windows, трябва да пакетираме exe-то редом със `SDL2.dll` и така ще можем да го пратим на другарче да го пробва.

---

# Инсталация на ggez

Библиотеката има текуща версия 0.4.4. Добре е обаче да знаете как се инсталират неща през git, в случай, че master версията има някой bugfix, който още не е release-нат.

Имайте предвид че в <code>Cargo.lock</code> ще се запази *конкретна* версия на библиотеката, така че всеки следващ download ще е на същия код. Няма как да ви се счупи кода без да сте го докосвали, освен ако ръчно не ъпдейтнете версията.

```
[dependencies]
ggez = { git = "https://github.com/ggez/ggez" }
```

---

# Скелет на играта

Фреймуърка очаква да дефинирате ваш тип, който да имплементира трейта `ggez::event::EventHandler`:

```rust
# //ignore
struct MainState { /* ... */ }

impl event::EventHandler for MainState {
    fn update(&mut self, ctx: &mut Context) -> GameResult<()> {
        // Променяме състоянието на играта
        Ok(())
    }

    fn draw(&mut self, ctx: &mut Context) -> GameResult<()> {
        graphics::clear(ctx);
        // Рисуваме неща
        graphics::present(ctx);
        Ok(())
    }
}
```

---

# Скелет на играта

В `main` функцията, създаваме инстанция на нашия тип, и "контекст" (за рисуване/звуци) с конфигурация, и стартираме event loop-а:

```rust
# //ignore
pub fn main() {
    let ctx = &mut ContextBuilder::new("shooter", "fmi").
        window_mode(WindowMode {
            min_width: 1024,
            min_height: 768,
            ..Default::default()
        }).
        build().unwrap();
    let state = &mut MainState::new(ctx).unwrap();

    if let Err(e) = event::run(ctx, state) {
        println!("Error encountered: {}", e);
    } else {
        println!("Game exited cleanly.");
    }
}
```

---

# Зареждане на ресурси

За да може библиотеката да си намери картинки и звуци при компилация, добре е да добавим локалната директория "resources" (или както искаме да я наречем). Когато разпространяваме играта, тя ще търси по default папка до exe-то, която се казва "resources", но подкарвайки я с <code>cargo run</code>, е по-удобно да използваме друга:

```rust
# //ignore
// ...
// let ctx = &mut Context::load_from_conf("shooter", "ggez", conf).unwrap();

if let Ok(manifest_dir) = env::var("CARGO_MANIFEST_DIR") {
    let mut path = path::PathBuf::from(manifest_dir);
    path.push("resources");
    ctx.filesystem.mount(&path, true);
}

// if let Err(e) = event::run(ctx, state) {
// ...
```

---

# Update

```rust
# //ignore
fn update(&mut self, ctx: &mut Context) -> GameResult<()> {
    if self.game_over { return Ok(()); }
    const DESIRED_FPS: u32 = 60;

    while timer::check_update_time(ctx, DESIRED_FPS) {
        let seconds = 1.0 / (DESIRED_FPS as f32);

        self.time_until_next_enemy -= seconds;
        if self.time_until_next_enemy <= 0.0 {
            // Създаваме следващия противник
            // self.time_until_next_enemy = ...;
        }

        // Обновяваме позиция на играча, на изстрелите, ...
    }
}
```

---

# Update

--
* Метода връща `GameResult<()>`, така че успешен край ще е `Ok(())`, е неуспешен край вероятно ще дойде от грешка в някоя от функциите за чертане, звуци, и т.н.
--
* Всичко се случва в цикъл, който ще се викне 60 пъти (или колкото искаме) в секунда, плавно (надяваме се).
--
* Затова имаме нужда от `seconds`, или `time_delta`, или както го наречете -- изминалото време в този цикъл, като части от секундата. Умножаваме тази стойност по всякакво движение, за получим равномерна промяна.
--
* Състоянието става на тези квантове време, така че няма как да правим продължителна промяна на състоянието -- анимации няма как да станат с "линеен" код. Променяме състоянието (играча е в състояние "стреляне", "движение", и т.н.), и движим позицията му както подобава.

---

# Update

Най-простата форма на `update` би могла да изглежда така:

```rust
# //ignore
self.position += self.velocity * seconds;
```

Променяме `velocity` в зависимост от, например, задържан клавиш-стрелкичка, или в зависимост от AI-а на противниците, или както си пожелаем. Имаме пълната мощ на библиотеката [nalgebra](http://nalgebra.org/), която вероятно няма да ни трябва за много сложни неща:

```rust
# //ignore
#[derive(Debug)]
pub struct Enemy {
    position: Point2,
    velocity: Vector2,
    // ... и каквото още ни трябва ...
}
```

Точки и вектори могат да се събират с вектори, вектори могат да се умножават с числа. И други работи, но вижте документацията.

---

# Input

Има още два метода, които могат да се имплементират за `event::EventHandler`:

```rust
# //ignore
fn key_down_event(&mut self,
                  _ctx: &mut Context,
                  keycode: event::Keycode,
                  _keymod: event::Mod,
                  _repeat: bool) {
    match keycode {
        event::Keycode::Space => self.input.fire = true,
        // ... Други клавиши ...
        _ => (), // Do nothing
    }
}
```

И еквивалентния за key up ...

---

# Input

Има още два метода, които могат да се имплементират за `event::EventHandler`:

```rust
# //ignore
fn key_up_event(&mut self,
                _ctx: &mut Context,
                keycode: event::Keycode,
                _keymod: event::Mod,
                _repeat: bool) {
    match keycode {
        event::Keycode::Space => self.input.fire = false,
        // ... Други клавиши ...
        _ => (), // Do nothing
    }
}
```

---

# Drawing

```rust
# //ignore
fn draw(&mut self, ctx: &mut Context) -> GameResult<()> {
    graphics::clear(ctx);
    if self.game_over {
        let font = graphics::Font::new(ctx, "/DejaVuSerif.ttf", 24)?;
        let text = graphics::Text::new(ctx, "Game Over!", &font)?;
        let center = Point2::new(self.screen_width as f32 / 2.0, self.screen_height as f32 / 2.0);
        graphics::draw_ex(ctx, &text, graphics::DrawParam {
            dest: center,
            offset: Point2::new(0.5, 0.5),
            .. Default::default()
        })?;
        graphics::present(ctx);
        return Ok(())
    }

    // ...

    graphics::present(ctx);
    Ok(())
}
```

---

# Drawing

Просто викане на методи в модула <code>graphics::</code> Когато имаме координатите и състоянието на противници, играч, изстрели, сцена, фон, и прочее, всичко се свежда до това да извикаме методи, които казват на графичната система какво да нарисува и къде.

---

# Collision detection

Не ни трябва нищо сложно за тази конкретна игра. За всеки противник и всеки изстрел, проверяваме дали изстрела е в противника:

```rust
# //ignore
for enemy in &mut self.enemies {
    for shot in &mut self.shots {
        if enemy.bounding_rect().contains(shot.pos) {
            shot.is_alive = false;
            enemy.is_alive = false;
            self.score += 1;
            let _ = self.assets.boom_sound.play();
        }
    }
}
```

---

# Тестване

Инициализиране на контекст може да се направи само веднъж, което може да затрудни тестването. Решението е decoupling -- вместо конкретен тип, използваме trait, който можем да варираме:

```rust
# //ignore
pub trait Sprite: Debug {
    fn draw(&mut self, center: graphics::Point2, ctx: &mut Context) -> GameResult<()>;
    fn width(&self) -> u32;
    fn height(&self) -> u32;
}
```

---

# Тестване

В истинския код, имаме нещо истински използваемо, което използва assets, fonts, drawing:

```rust
# //ignore
#[derive(Debug)]
pub struct TextSprite {
    text: graphics::Text,
}

impl TextSprite {
    pub fn new(label: &str, ctx: &mut Context) -> GameResult<TextSprite> {
        let font = graphics::Font::new(ctx, "/DejaVuSerif.ttf", 16)?;
        let text = graphics::Text::new(ctx, label, &font)?;
        Ok(TextSprite { text })
    }
}

impl Sprite for TextSprite {
    fn draw(&mut self, center: graphics::Point2, ctx: &mut Context) -> GameResult<()> {
        // ...
    }

    fn width(&self) -> u32 { self.text.width() }
    fn height(&self) -> u32 { self.text.height() }
}
```

---

# Тестване

В тестовете, спокойно можем да си сложим един "фалшив" sprite:

```rust
# //ignore
#[derive(Debug)]
struct MockSprite {
    width: u32,
    height: u32,
}

impl Sprite for MockSprite {
    fn draw(&mut self, _center: Point2, _ctx: &mut Context) -> GameResult<()> { Ok(()) }

    fn width(&self) -> u32 { self.width }
    fn height(&self) -> u32 { self.height }
}
```

---

# Съвети

--
* Карайте стъпка по стъпка и няма да имате проблеми. Правете "актьорите" един по един, движете ги, проверявайте дали всичко е наред.
--
* Пишете си функции за дебъгване -- за чертаене на кутийка около противника, например, да видите дали collision-а работи като хората.
--
* Извличайте константи с добри имена: <code>PLAYER_MOVE_SPEED</code>, <code>GRAVITY_ACCELERATION</code> са добри константи, които може лесно да промените за дебъгване и натаманяване. <code>THIRTY_TWO</code> и <code>FIVE_HUNDRED</code> не са.

---

# Ресурси

--
* Тази игра: [rust-shooter](https://github.com/AndrewRadev/rust-shooter)
--
* Звукови ефекти: [Freesound](https://freesound.org/)
--
* Инсталиране на SDL2: [Rust-SDL2](https://github.com/Rust-SDL2/rust-sdl2#user-content-requirements)
--
* Най-простия пример: [Super Simple](https://github.com/ggez/ggez/blob/master/examples/super_simple.rs)
--
* Най-интересния пример: [Astroblasto](https://github.com/ggez/ggez/blob/master/examples/astroblasto.rs)
--
* Лекция от RustFest Zurich: [Beyonce Brawles](https://youtu.be/str_mex__0M)
--
* По-генерална помощ за gamedev (множко за простичък проект, но интересно четиво in general): [Game Programming Patterns](http://gameprogrammingpatterns.com/)
