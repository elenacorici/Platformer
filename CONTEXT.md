# CONTEXT PROIECT — Platformer 2D Folclor Românesc
**Ultima actualizare:** 2026-05-07

---

## DESPRE JOC

Platformer 2D în **GameMaker Studio 2 (GML)**, tema folclor românesc.

**Poveste:** Un băiat intră în joc să-și salveze sora absorbită de calculator. Lumea e un blestem creat de un Solomonar.

**NPC Ghid:** Sfânta Duminică — apare la începutul fiecărui nivel, dă hints despre boss.

**Versiune GameMaker:** 2024.14.3.217

---

## STRUCTURA NIVELURILOR

| Nivel | Locație | Boss | Ce pazește |
|-------|---------|------|-----------|
| 1 | Pădurea Blestemat | Muma Pădurii | Ieșirea din pădure |
| 2 | Satul Blestemat | Strigoi | Cheia satului |
| 3 | Munții Carpați | Zmeul | Sora captivă |
| Final | Turnul Solomonarului | Solomonarul | Blestemul |

**Progresia abilităților:**
- Start: Jump + Melee + Roll + Crouch
- După Boss 1: Double Jump
- După Boss 2: Dash
- După Boss 3: Abilitate nouă (nedecisă)

> ⚠️ Double Jump NU e disponibil de la start — momentan deblocat din Create (`jumps_max = 2`), trebuie gating după Boss 1.

---

## ARHITECTURA TEHNICĂ

### Room Order
`rThree → rMenu → rOne → rTwo → rTunnel → BossRoom`

- Dimensiuni standard: 1024×800
- GUI: 1366×768

---

## OBIECTE — VARIABILE ȘI LOGICĂ

### oPlayer
- **HP:** `hp = 6, max_hp = 6, max_hearts = 3` (3 inimi × 2 HP)
- **Mișcare:** `walksp = 4, grv = 0.1, jump vsp = -3`
- **Roll:** S+A/D, `roll_duration = 60, roll_speed = 5`, invincibil în roll
- **Jump:** `jumps_max = 2, jumps_left = 2` (double jump)
- **State machine:** enum `PLAYERSTATE {FREE, ATTACK_SLASH, ATTACK_COMBO}`
- **Combat:** `hitByAttack` ds_list (prevent double-hit), `combo_window = 20` frames
- **Stun:** `is_stunned, stun_timer` — blocat complet de vine
- **Feedback:** `flash = 3`, `hp_temp` scădere graduală, `heart_shake`
- **Convenție sprite:** față dreapta = `image_xscale = -1`
- **Salvare:** Room Start → scrie progres în `"Save.sav"`

### oEnemy
- **State machine:** enum `ENEMYSTATE {PATROL, CHASE, ATTACK}`
- `move_speed = 2, patrol_move_speed = 0.75, size = 1.3`
- `sight_range = 150, attack_range = 56, check_distance = 25`
- **Idle breaks:** animații random de respire/zgârie la margini platforme
- `hitPlayerThisAttack` ds_list (prevent double-hit)
- **Tranziții:** PATROL ↔ CHASE (vizibilitate + nivel), CHASE → ATTACK (rază)

### oEnemyBig (moștenitor oEnemy)
- `size = 4, walksp = 0.75, check_distance = 60`

### oWolfSmall (moștenitor oEnemyBig)
- `size = 3`

### oBoss1
- **HP:** `hp = 2, max_hp = 2` ← (valoare de test, nu 100!)
- `boss_scale = 2.5, facing = 1, grv = 0.1`
- **Mask:** `mask_index = sBoss1` (separat de sprite vizual)
- **Cooldown-uri:** `attack_cooldown = 120, hop_cooldown, ivy_cooldown, slam_cooldown`
- **State machine (string):** idle, patrol, patrol_idle, attack_hop_windup, attack_hop_air, attack_hop_land, attack_hop_recover, attack_ivy, attack_ivy_wait, attack_ivy_hop, attack_ivy_end, attack_slam, attack_slam_recover, dizzy, dying, grave
- **Death:** hp==1 → dizzy (blochează atacuri) → hp<=0 → dying (sBoss1D) → grave (frozen) → destroy
- **Guard:** `if (instance_exists(oBossTree) && oBossTree.state != "done") exit`
- **Test keys (de șters):** U=patrol, Y=hop, T=ivy
- **HP bar:** desenat în Draw_0 (verde pe roșu)
- **Particule:** `p_sys, p_dirt` (praf maro)

### oBossTree
- `image_xscale/yscale = 2.6`
- `proximity_needed = 180` frames lângă copac înainte de trigger
- `proximity_timer` crește cu player aproape (<250px), scade cu 2 când pleacă
- **State machine:** idle → wake (sBossTreeWake, 0.04 speed) → burst (sBossTreeBurst, 0.1 speed) → spawn oBoss1 + self-destroy
- Camera se blochează pe copac în wake/burst, player pierde controlul

### oCamera
- `follow = oPlayer`, lerp 1/25
- `buff = 32`, clamp la margini room
- `shake_magnitude, shake_remain, shake_length`
- **Letterbox:** în rTunnel, crește progresiv cu avansul player-ului
- **Parallax:** Par1 (x/2), Par2 (x/4), Par3 (x/6)
- Draw GUI: bare negre sus/jos pentru letterbox

### oBranchBase (parent pentru oBranch1-5)
- `y_start, y_risen = y-350, y_tip = y_risen+80`
- `rise_speed=12, settle_speed=2, drop_speed=3`
- `shake_timer, hit_count, hit_cooldown=40, drop_delay, was_triggered`
- **State machine:** idle → rise → settle → up | drop_wait → drop → idle
- **Collision oPlayer:** body = blochează; atac = lovitură 1 shake / lovitură 2 rise

### oBranchDown
- Trigger: când player atinge → crengile din stânga (`x < trigger.x`) care sunt idle/up cad în val
- `drop_delay = _i * 10` (val stânga→dreapta)
- `was_triggered = true` (o singură dată per crenguță)

### oIvy (vine boss)
- `phase: grow → stun → retract`
- La frame 4 din grow: dacă player în rază ≤50px → `player_caught = true`
- Stun: fix player la `(vine.x, vine.y - 75)`, `stun_timer = 90`
- Rendering split depth: `ivy_back` (depth 610) + `ivy_front` (depth 40)

### oTransition
- enum `TRANS_MODE {OFF, NEXT, GOTO, RESTART, INTRO}`
- `percent` smooth 0↔1, bare negre sus/jos pe GUI
- Desenează și **inimi HP** în Draw_64 ← (nu oHUD!)
- R key → restart

### oHUD
- Draw_77 GUI — desenează 3 inimi (bazat pe `hp_temp` al player-ului)
- > ⚠️ Și oTransition desenează inimi în Draw_64 — posibil duplicat, de verificat

### oHole
- Spawnat de boss la aterizare, `timer = 180`, fade out și destroy

### oLevelEnd
- Collision cu player → `SlideTransition(TRANS_MODE.GOTO, target)`

---

## SCRIPTURI

| Script | Funcție |
|--------|---------|
| `PlayerState_Free()` | Mișcare, roll, jump, crouch, coliziuni, animații |
| `PlayerState_Attack_Slash()` | Atac 1: mask sPlayerA1HB, damage hp--, combo window |
| `PlayerState_Attack_Combo()` | Atac 2: mask sPlayerA2HB, damage hp-=2 |
| `Boss1_DecideAction()` | Weighted pick: slam/hop/ivy/patrol cu anti-repeat |
| `Boss1_Phase1_Patrol()` | Patrulare + pauze, particule la pași |
| `Boss1_Phase2_Hop()` | Salt spre player, hitbox sBossL, spawneaza oHole |
| `Boss1_Phase3_Ivy()` | Spawn oIvy, stun player, hop pe player prins |
| `Boss1_Phase4_Slam()` | Frame 6=impact+shake, frames 6-8 hitbox activ |
| `weighted_pick(actions, weights)` | Alegere random ponderată din array |
| `animation_end()` | Helper: `image + speed >= sprite_get_number` |
| `ScreenShake(magnitude, frames)` | Setează shake pe oCamera (nu stivuiește) |
| `SlideTransition(mode, target)` | Setează mode+target pe oTransition |
| `Enemy_VerticalResolve()` | Coliziuni verticale standard pentru inamici |
| `EnemyState_Patrol/Chase/Attack()` | State machine inamici |

---

## DIMENSIUNI BOSS (la runtime)

| Element | Sprite brut | × boss_scale (2.5) |
|---------|------------|-------------------|
| **Vizual (sBoss1I)** | 57×79 px | **142×197 px** |
| **Mask (sBoss1)** | 53×77 px | **132×192 px** |
| **Origine** | x=28, y=39 | center-middle |

---

## IMPLEMENTAT ✅

- Player: movement, roll, double jump, crouch, attack slash+combo
- HP system cu inimi, feedback flash, hp_temp gradual
- Enemy: patrol/chase/attack AI, idle breaks, frică de înălțimi
- Boss 1: toate fazele (patrol, hop, ivy, slam), death sequence
- Boss intro: oBossTree → wake → burst → spawn oBoss1
- Camera: easing, shake, parallax (Par1/2/3), letterbox rTunnel
- rTunnel branch system: blocare, shake, rise, trigger val

---

---

## BOSS 2 — STRIGOI

### Personaj
- Cadavru reanimat monstruos: corp emaciat, piele cenușie, ochi înfundați negri, fără nas, unghii-gheare, membre distorsionate
- Haine tradiționale românești zdrenţuite (cămașă albă brodată, cioareci albi, brâu roșu-negru, opinci)
- **Locul:** Cimitir nocturn, apare lângă un mormânt
- **Mers:** rigid și sacadat, pași lenți și deliberați, se oprește scurt între pași

### Atacuri

| Atac | Distanță | Tip | Obiecte |
|------|----------|-----|---------|
| Scuipat de Venin | < 150px | Proiectil direct | `oStrigoiSpit`, `oStrigoiSpitImpact` |
| Ploaie de Lilieci | 150–300px | Summon hazard | `oBat`, `oBatControl` |
| Transformare în Lup | > 300px | Dash through | `oWolf` |

**Atac 1 — Scuipat:**
- Telegraph: respiră greu 2×, capul se lasă, gâtul se umflă
- Windup: capul se trage înapoi, gura se deschide
- Atac: glob venin negru-roșu spre player în linie dreaptă
- Recovery: cap cade epuizat — window of opportunity

**Atac 2 — Lilieci:**
- Telegraph: ridică brațele ritual spre cer, cap pe spate
- 4-6 lilieci intră din dreapta ecranului, planează haotic
- Player NU îi poate lovi (hazard, nu inamici)
- Dispar după timp fix
- Homing behavior: `direction = point_direction(x, y, oPlayer.x, oPlayer.y)`, `turnSpeed = 2`, `lifetime = room_speed * 5`

**Atac 3 — Transformare Lup:**
- Telegraph: Strigoi se rostogolește rapid (corp blur)
- Când se oprește apare direct lupul
- Lupul aleargă rapid spre dreapta prin player (damage la contact)
- Dispare la marginea ecranului, Strigoi reapare în dreapta

### Faze
- **Phase 1 (100–50% HP):** Scuipat + Lilieci, Lup INACTIV
- **Phase 2 (< 50% HP):** Toate 3 atacurile, viteză mai mare, cooldown mai scurt
- **Phase Finală (< 10% HP):** Stagger + Finishing Move cu țăruș

### Finishing Move
1. Strigoi intră în `"stagger"` — se balansează, nu mai atacă
2. Prompt vizual pe ecran (iconița țărușului pulsează)
3. Player apasă E sau F → animație `sPlayerStake`
4. Strigoi moarte: țăruș înfipt, încearcă să-l scoată, cade pe genunchi, se descompune în praf

### Sprite-uri

| Sprite | Status | Detalii |
|--------|--------|---------|
| `sStrigoi_Idle` | ✅ | 6 frame-uri respirație lentă |
| `sStrigoi_Walk` | ✅ | 6 frame-uri mers rigid |
| `sStrigoi_Spit` | ✅ | 8 frame-uri: respirații → scuipat → recovery |
| `sStrigoi_Summon` | ✅ | 9 frame-uri: ritual chemare lilieci |
| `sStrigoi_Transform` | ✅ | 9 frame-uri: rostogolire → lup |
| `sStrigoi_Stagger` | ✅ | 6 frame-uri: balansare trunchi |
| `sStrigoi_Death` | ✅ | 9 frame-uri: țăruș → descompunere → praf |
| `sStrigoi_Hurt` | ❌ | Reacție la damage |
| `sWolf_Run` | ✅ | 6 frame-uri lup alergând |
| `sBat` | ✅ | 4 frame-uri zbor loop |
| `sStrigoiSpitProjectile` | ✅ | 4 frame-uri venin pulsator |
| `sStrigoiSpitImpact` | ✅ | 6 frame-uri impact pe suprafață |
| `sPlayerStake` | ❌ | Animație player înfige țărușul |
| `sStakeIcon` | ❌ | Iconița țărușului în UI |
| `sStakePrompt` | ❌ | Prompt vizual stagger |

### Obiecte necesare
`oStrigoi`, `oStrigoiControl`, `oStrigoiSpit`, `oStrigoiSpitImpact`, `oBat`, `oBatControl`, `oWolf`

### Scripturi necesare
`Strigoi_DecideAction`, `Strigoi_Phase1_Spit`, `Strigoi_Phase2_Bats`, `Strigoi_Phase3_Wolf`, `Strigoi_Stagger`, `Strigoi_Death`

### Prioritate implementare
`oStrigoi mișcare → oStrigoiSpit → oBat → oWolf → Finishing Move`

---

## DE IMPLEMENTAT ❌

### Prioritate mare
- [ ] **hp boss = 2 (test)** — de setat la valoarea finală
- [ ] **Test keys U/Y/T din oBoss1 Step_0** — de șters înainte de release
- [ ] rTunnel — populare completă cu crengi + triggere poziționate
- [ ] Tranziție rTunnel → BossRoom
- [ ] Boss HP bar finală (există una simplă în Draw_0)
- [ ] Verificat duplicat inimi: oTransition Draw_64 vs oHUD Draw_77

### General
- [ ] NPC Sfânta Duminică + sistem dialog
- [ ] Sprite player stun (când e prins de ivy)
- [ ] Gating Double Jump după Boss 1
- [ ] Boss 2, Boss 3 (neîncepute)
- [ ] Reordonare frame-uri sBoss1Land (5→4→3→2→1)

---

## NOTIȚE DE DESIGN

**Boss 1 — distanțe atacuri:**
- dist < 100px → Slam (weight 4 dacă < 50px)
- 80–350px → Hop
- dist > 250px → Ivy
- fallback → Patrol

**Ivy Attack flow:**
- Boss spawneaza oIvy la poziția player-ului
- Frame 4: verifică dacă player a scăpat (< 50px rază)
- Prins → stun 90 frames, boss sare pe player
- Scăpat → vine se retrage, atac ratat

**Depth system boss room:**
- oIvyBack depth 610 → oIvy (invisible) → oBoss1 depth 50 → oIvyFront depth 40

---

## FIȘIERE RELEVANTE

| Fișier | Rol |
|--------|-----|
| `objects/oPlayer/Create_0.gml` | Toate variabilele player |
| `objects/oPlayer/Step_0.gml` | Input + state machine dispatch |
| `objects/oBoss1/Create_0.gml` | Variabile boss (hp=2 test!) |
| `objects/oBoss1/Step_0.gml` | Guard oBossTree + phase scripts + death |
| `objects/oBoss1/Step_1.gml` | Dizzy/dying transitions |
| `objects/oBossTree/Create_0.gml` | Setup copac intro |
| `objects/oBossTree/Step_0.gml` | State machine intro + spawn boss |
| `objects/oBranchBase/Create_0.gml` | Variabile branch |
| `objects/oBranchBase/Step_0.gml` | State machine branch |
| `objects/oBranchBase/Collision_oPlayer.gml` | Blocare + hit detection |
| `objects/oBranchDown/Step_0.gml` | Trigger drop în val |
| `objects/oCamera/Step_0.gml` | Camera logic + parallax + letterbox |
| `objects/oCamera/Draw_64.gml` | Letterbox GUI bars |
| `objects/oTransition/Draw_64.gml` | Transition bars + inimi HP |
| `scripts/Boss1_DecideAction/` | Weighted pick + helper funcții |
| `scripts/Boss1_Phase2_Hop/` | Faza hop |
| `scripts/Boss1_Phase3_Ivy/` | Faza ivy + stun |
| `scripts/Boss1_Phase4_Slam/` | Faza slam |
| `scripts/weighted_pick/` | Sistem ponderat alegere acțiune |
