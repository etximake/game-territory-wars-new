# Stat Sheet v0.1
> Muc tieu: khoa bo thong so khoi dau de test prototype cho 5 marble + 5 weapon.
> Day la bo so dung cho prototype validation, uu tien territory-centric + readability truoc complexity.

---

# 1. Global Balance Rules

## 1.1. Core Rules
- Khong co marble nao manh toan dien.
- Weapon khong duoc thay the vai tro core cua marble.
- Chiem neutral territory phai nhanh hon cuop enemy territory.
- Territory effect chi nen anh huong ro vao 1 huong chinh.
- Readability quan trong hon complexity.

## 1.2. Prototype Balance Goal
- 5 marble phai tao khac biet role de xem va de test.
- 5 weapon phai tao pairing ro de sinh content moment.
- Territory phai la score source chinh, combat la cong cu shift territory.

---

# 2. Match Baseline

## 2.1. Match Duration
- Target Match Length: 240s
- Overtime Rule: none
- Respawn Delay: 2.8s
- Score Target: 150
- Territory Weight in Final Score: 12.0 / tick
- Kill/Elimination Weight: 8.0
- Objective Bonus Weight: control streak 3.0 | territory steal 10.0

## 2.2. Territory Baseline
- Neutral Capture Time: 1.2s
- Enemy Reclaim Time: 2.4s
- Contested Zone Speed Modifier: 0.35x
- Newly Captured Territory Protection Time: 1.6s
- Territory Decay Rule: none
- Territory Stability Baseline: neutral fast, owned stable, protected anti-recapture short window

## 2.3. Movement Baseline
- Base Move Speed Band: 122 - 155
- Base Acceleration Band: 340 - 470
- Base Friction Band: 240 - 320
- Base Collision Force Band: 0.90 - 1.15
- Base Knockback Resistance Band: 0.88 - 1.45

---

# 3. Marble Table Summary

| Marble | Role | Speed | Durability | Capture | Reclaim | Passive Power | Active Cooldown | Territory Effect | Difficulty | Notes |
|---|---|---:|---:|---:|---:|---:|---:|---|---|---|
| Fire | Attacker / Corruptor | 155 | 92 | 1.25 | 1.08 | burn pressure | 7.0s | fire pressure | Medium | Expand nhanh, giu dat kem |
| Ice | Defender / Controller | 126 | 108 | 0.96 | 1.10 | first hit slow | 7.6s | slow zone | Medium | Giu diem nong, snowball kem |
| Magnet | Utility / Controller | 138 | 96 | 1.08 | 1.04 | pull utility | 6.8s | resource drift | Medium | Contested bias, damage thap |
| Shield | Defender / Anchor | 122 | 116 | 0.90 | 1.16 | guard on impact | 8.2s | anti-recapture | Easy | Giu dat rat tot, mo rong cham |
| Storm | Disruptor / Controller | 148 | 94 | 1.02 | 1.06 | deflect drift | 6.9s | push current | Hard | Tao chaos co kiem soat |

---

# 4. Detailed Marble Notes

## Fire Marble
- Core Fantasy: Expand fast, pressure neutral space, threaten fresh front lines.
- Base Stats: speed 155 | accel 470 | mass 0.95 | collision 1.15 | KB resist 0.90 | HP 92 | defense 0.95
- Territory Stats: neutral 1.25 | reclaim 1.08 | effect radius 132 | effect strength 1.20
- Passive: `passive.fire_burn`
- Active: `active.fire_overheat_burst` | cooldown 7.0s | duration 2.2s
- Pairing Watch: rat hop Cannon de pha cum, hop Shield Device kem hon vi lam giam nhip pressure.
- Readability: do/cam, hot core, trail nong.
- Current Test Note: co nguy co snowball neutral side qua nhanh neu contested thap.

## Ice Marble
- Core Fantasy: Slow pace, lock hot zones, keep territory stable.
- Base Stats: speed 126 | accel 360 | mass 1.05 | collision 0.95 | KB resist 1.18 | HP 108 | defense 1.08
- Territory Stats: neutral 0.96 | reclaim 1.10 | effect radius 140 | effect strength 1.18
- Passive: `passive.ice_first_hit_slow`
- Active: `active.ice_freeze_pulse` | cooldown 7.6s | duration 1.8s
- Pairing Watch: Laser la pairing ro nhat cho lane/choke control.
- Readability: xanh bang, pale core, crisp trail.
- Current Test Note: can watch xem phong thu co bi an hinh boi territory colors hay khong.

## Magnet Marble
- Core Fantasy: Distort nearby space, disrupt routes, bias contested zones.
- Base Stats: speed 138 | accel 410 | mass 1.00 | collision 0.90 | KB resist 0.98 | HP 96 | defense 0.98
- Territory Stats: neutral 1.08 | reclaim 1.04 | effect radius 136 | effect strength 1.16
- Passive: `passive.magnet_pickup_pull`
- Active: `active.magnet_short_pull` | cooldown 6.8s | duration 1.7s
- Pairing Watch: Magnet Device la utility pairing dung fantasy nhat.
- Readability: metallic pale core, orbit trail, pull feedback.
- Current Test Note: damage thap, can watch xem utility co du de dat vao score khong.

## Shield Marble
- Core Fantasy: Hold ground, resist displacement, secure fresh captures.
- Base Stats: speed 122 | accel 340 | mass 1.25 | collision 1.05 | KB resist 1.45 | HP 116 | defense 1.16
- Territory Stats: neutral 0.90 | reclaim 1.16 | effect radius 132 | effect strength 1.24
- Passive: `passive.shield_knockback_guard`
- Active: `active.shield_burst` | cooldown 8.2s | duration 1.9s
- Pairing Watch: Gun va Shield Device deu hop, Gun doc tran tot hon.
- Readability: green shell, hex guard motif, dense hold trail.
- Current Test Note: can watch anti-recapture co bi kho doc trong contested zones hay khong.

## Storm Marble
- Core Fantasy: Create directional chaos, shift fights, open map swings.
- Base Stats: speed 148 | accel 455 | mass 0.92 | collision 1.08 | KB resist 0.88 | HP 94 | defense 0.94
- Territory Stats: neutral 1.02 | reclaim 1.06 | effect radius 140 | effect strength 1.22
- Passive: `passive.storm_deflect`
- Active: `active.storm_wind_surge` | cooldown 6.9s | duration 1.65s
- Pairing Watch: Cannon la pairing content moment manh nhat.
- Readability: wind-bright core, sweeping motion trail.
- Current Test Note: can watch neu chaos day contested nhieu qua, readability se giam.

---

# 5. Weapon Table Summary

| Weapon | Category | Range | Damage | Knockback | Splash | Cooldown | Territory Support | Best Pairing | Notes |
|---|---|---:|---:|---:|---:|---:|---:|---|---|
| Gun | sustain_pressure | 220 | 15 | 120 | 0 | 1.1s | medium | Shield | On dinh, de doc |
| Laser | precision | 300 | 12 | 80 | 0 | 1.55s | high lane control | Ice | Slow ro, lane control tot |
| Cannon | aoe | 255 | 26 | 240 | 118 | 2.7s | break clusters | Fire / Storm | Burst cao, content moment manh |
| Magnet Device | disruption | 235 | 10 | 60 | 92 | 2.1s | contested bias | Magnet | Pull utility ro |
| Shield Device | defensive_utility | 170 | 6 | 40 | 0 | 2.4s | stability support | Shield | Def utility, anti-recapture support |

---

# 6. Build Combination Review

| Marble \ Weapon | Gun | Laser | Cannon | Magnet Device | Shield Device |
|---|---|---|---|---|---|
| Fire | ok pressure | niche | strong | utility off-role | weak fit |
| Ice | stable | strong | ok but noisy | niche | stable |
| Magnet | ok | niche | weak fit | strong | ok |
| Shield | strong | ok | niche | niche | strong |
| Storm | ok | niche | strong | ok | weak fit |

### Key Prototype Pairings
- Fire + Cannon: pha cum manh, nguy co over-snowball neutral side.
- Ice + Laser: ro lane/choke, readability tot cho clip.
- Magnet + Magnet Device: utility/disrupt fantasy ro nhat.
- Shield + Gun: build giu dat on dinh nhat.
- Storm + Cannon: content burst cao, nhung can watch do roi readability.

---

# 7. Phase L Validation Notes

## Required Test Presets
- `res://resources/config/playtests/match_config_1vAI.tres`
- `res://resources/config/playtests/match_config_multi_AI.tres`
- `res://resources/config/playtests/match_config_full_AI_simulation.tres`

## Run Support
- AppRoot co ho tro boot bang cmd arg `--test-preset 1vai|multi_ai|full_ai`.
- Su dung `docs/Phase L Validation Log v0.1.md` de ghi territory / balance / readability issue theo tung session.

## Current Watchouts
- Territory: contested > 6 cell trong thoi gian dai la dau hieu pace reclaim/capture can xem lai.
- Balance: Fire + Cannon va Shield + Gun la 2 pairing can watch nhieu nhat.
- Readability: n?u marble chim vao ownership colors, uu tien giam noise truoc khi them effect moi.
