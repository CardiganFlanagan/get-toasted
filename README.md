# Get Toasted

A survivors-like game made in Godot 4.7. You play as a slice of toast on a kitchen counter, shoot crumbs at bugs, buy ingredients and cook dishes that become new weapons. A shift lasts until the timer runs out.

Course project for Game Development Fundamentals, Narxoz University.

## Audio

### Mixer (Project → Audio tab)

| Bus | What goes there | Effects |
|---|---|---|
| Master | everything | none |
| Music | menu and level music (the `Music` autoload) | LowPassFilter and Amplify, used for the pause |
| SFX | every other sound | none |

Every `AudioStreamPlayer` in the project has its bus set to Music or SFX.

- **Volume.** The music and sound glasses in Settings set the Music and SFX buses. There are three glasses plus mute, and the level becomes decibels with `linear_to_db(level / 3)`, which is 20 × log10: S = −9.5 dB, M = −3.5 dB, L = 0 dB. The levels are saved in `user://save.json` (`Game.set_volume`).
- **Music.** The `Music` autoload (`scenes/music.tscn`, `scripts/music.gd`) has two players, A and B. `Music.play(stream)` fades the new track in and the old one out over 1 s. If that track is already playing it does nothing, so restarting a level does not restart the music.
- **Pause.** While the game is paused (pause menu or end receipt), `Music` lowers the LowPass cutoff on the Music bus to 700 Hz and the Amplify effect to −8 dB. Both slide back when the game continues.
- **Variation.** Repeated sounds use `AudioStreamRandomizer` resources in `sfxs/random/`, with a random pitch from 0.93 to 1.08. The toast hit also switches between two clips.
- **Wind-up.** The beetle beeps at the start of its 0.6 s wind-up, and the bee plays a rising tone at the start of its 0.7 s aim. Both are `AudioStreamPlayer2D`, so you can hear them from off screen and tell which side they come from.

### Sound events

| Event | Where in the game | File | Node |
|---|---|---|---|
| Main move: toast shoots | every weapon shot | `sfxs/ninja/shot.wav` via `sfxs/random/shot.tres` | `weapon.tscn` → ShotSound |
| Hit | toast takes damage | `sfxs/ninja/hit.wav`, `hit2.wav` via `sfxs/random/hit.tres` | `character.tscn` → HurtSound |
| Pickup | crumbs reach the plate | `sfxs/ninja/coin.wav` via `sfxs/random/coin.tres` | `level.tscn` → toast/Plate/PickupSound |
| Enemy wind-up | beetle wind-up | `sfxs/ninja/beetle_windup.wav` | `charger.tscn` → WindupSound |
| Enemy wind-up | bee aims | `sfxs/ninja/bee_aim.wav` | `bee.tscn` → AimSound |
| Death | winged bug dies | `sfxs/ninja/bug_death.wav` via `sfxs/random/bug_death.tres` | `bug_death.tscn` |
| Death | bee dies | `sfxs/ninja/bee_death.wav` via `sfxs/random/bee_death.tres` | `bee_death.tscn` |
| Death | beetle dies | `sfxs/ninja/poof.wav` | `poof.tscn` |
| UI click | shift buttons, reset, exit, receipt buttons | `sfxs/ui/button_pressed.wav` | `Main_menu.tscn`, `end_screen.tscn` → Click |
| Win | shift closed | `sfxs/ninja/win.wav` | `end_screen.tscn` → WinJingle |
| Lose | toast burnt | `sfxs/ninja/lose.wav` | `end_screen.tscn` → LoseJingle |
| Explosion | omelette bomb | `sfxs/ninja/explosion.wav` via `sfxs/random/explosion.tres` | `boom.tscn` |
| Buy | ingredient bought | `sfxs/ui/purchase.wav` | `shop_panel.tscn` → BuySound |
| Cook | dish ready / burnt | `sfxs/ui/success.wav`, `sfxs/ui/failure.wav` | `cooking_panel.tscn` |
| Pause | pause opens | `sfxs/ui/pause.wav` | `pause_menu.tscn` → PauseSound |
| Resume | service bell | `sfxs/ui/bell_ding.wav` | `pause_menu.tscn` → DingSound |
| Volume | glass clink | `sfxs/ui/glass_clink.wav` | `volume_row.tscn` → Clink |
| Play | ice cubes in the juice | `sfxs/527322__clearwavsound__ice-cubes-poured-into-drink.wav` | `Main_menu.tscn` → SFX |

### Sources and licenses

| Files | Source | Author | License |
|---|---|---|---|
| `sfxs/ninja/*.wav` | [Ninja Adventure Asset Pack](https://pixel-boy.itch.io/ninja-adventure-asset-pack) (Audio/Sounds and Audio/Jingles) | Pixel-boy and AAA | CC0 1.0 |
| `sfxs/ui/button_pressed.wav`, `purchase.wav`, `success.wav`, `failure.wav`, `pause.wav` | [Cute & Cozy UI Audio, free sample](https://caseportman.itch.io/cute-cozy-ui-sfx) | Case Portman Audio | Royalty-free, credit required |
| `sfxs/ui/bell_ding.wav`, `sfxs/ui/glass_clink.wav` | Made for this game: synthesized with a Python script, no samples | Get Toasted team | Our own |
| `sfxs/527322__clearwavsound__ice-cubes-poured-into-drink.wav` | [Freesound #527322](https://freesound.org/s/527322/) | clearwavsound | [fill in: license shown on the Freesound page] |
| Menu music: `sfxs/Audio/ogg/Pineapple Under The Sea.ogg` | [Cozy Tunes](https://pizzadoggy.itch.io/cozy-tunes) | Pizza Doggy | CC0 1.0 (the pack page asks not to resell the tracks as an asset pack) |
| Level music: `sfxs/poopie pack/start.wav` | [cute & silly rpg music pack](https://chajamakesmusic.itch.io/cute-and-silly-rpg-music-pack) | chajamakesmusic | CC BY 4.0, credit required |

The other tracks in `sfxs/Audio/ogg/` and `sfxs/poopie pack/` come from the same two packs and are not used yet.

Art, code and font credits are in [CREDITS.md](CREDITS.md).
