# Foundation Naming Convention

## Muc tieu
- Giu ten scene, script va resource nhat quan ngay tu Phase A.
- Giu cau truc de mo rong sang match flow, territory, marble va weapon ma khong phai doi ten lon.

## Thu muc nen
- `scenes/app`: scene vao game va cac scene cap dieu phoi.
- `scenes/world`: world, arena va cac scene cap tran dau.
- `scenes/ui`: overlay debug va HUD prototype.
- `scenes/camera`: danh cho scene camera neu ve sau can tach rieng.
- `scripts/autoload`: hang so va singleton dung chung toan project.
- `scripts/app`: logic cap app va bootstrap.
- `scripts/world`: logic cap world, arena va match scene.
- `scripts/match`: flow tran dau, score model va ket qua.
- `scripts/territory`: grid ownership, territory agents va debug view cho territory.
- `scripts/ui`: logic overlay debug va HUD prototype.
- `scripts/resources`: resource script cho config va du lieu tuning.
- `resources/config`: cac file `.tres` cau hinh cho prototype va production.

## Quy uoc dat ten
- Scene file: `snake_case.tscn`
- Script file: `snake_case.gd`
- Resource file: `snake_case.tres`
- Class name Godot: `PascalCase`
- Node trong scene: `PascalCase` cho node chinh, ro vai tro theo nghia gameplay.

## Quy uoc scope
- `AppRoot`: diem vao duy nhat cua playable prototype.
- `PrototypeWorld`: sandbox tran dau de noi cac system phase sau.
- `MatchController`: owner cua flow `start -> running -> end`, timer, score va restart.
- `TerritoryController`: owner cua territory grid, ownership, contested state, capture va territory scoring.
- `MatchConfig`: noi luu thong so match nen, khong hard-code trong scene.
- Hang so physics, group va duong dan dung chung: dat trong `GameConstants`.

## Layer 2D hien tai
1. `world`
2. `marble`
3. `projectile`
4. `territory_sensor`
5. `pickup`
6. `camera_blocker`
