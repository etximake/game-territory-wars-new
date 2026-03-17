# Asset Checklist Production Board
> Mục tiêu: quản lý toàn bộ asset cần chuẩn bị cho prototype và production mở rộng.  
> Tài liệu này phải thống nhất với luật lõi:
> - Territory là trung tâm
> - Marble là entity có bản sắc riêng
> - Weapon là lớp tấn công hỗ trợ
> - Readability phải ưu tiên cao
> - Simulation phải sinh content moment tốt cho YouTube

---

# 1. Asset Production Rules

## 1.1. Core Consistency Rules
- Asset không được làm mờ territory readability.
- Asset không được làm các marble trông quá giống nhau.
- Asset VFX chỉ đẹp là chưa đủ, phải giúp đọc trạng thái.
- UI không được che mất action chính.
- Audio phải giúp nhận biết state quan trọng.
- Content capture asset phải hỗ trợ quay video, không chỉ hỗ trợ chơi.

## 1.2. Priority System
- P0 = bắt buộc để prototype chạy được
- P1 = rất quan trọng để test đúng cảm giác
- P2 = tốt để nâng chất lượng
- P3 = có thể làm sau

## 1.3. Status System
- Backlog
- Planned
- In Progress
- Review
- Done
- Blocked

## 1.4. Ownership Fields
Mỗi asset nên có:
- Owner
- Priority
- Status
- Version
- Dependency
- Notes

---

# 2. Board Overview

| Group | Asset Name | Purpose | Priority | Status | Owner | Dependency | Notes |
|---|---|---|---|---|---|---|---|
| Gameplay |  |  |  |  |  |  |  |
| VFX |  |  |  |  |  |  |  |
| UI |  |  |  |  |  |  |  |
| Audio |  |  |  |  |  |  |  |
| Content Capture |  |  |  |  |  |  |  |

---

# 3. Gameplay Assets

## 3.1. Purpose
Gameplay assets là các asset giúp:
- game chạy được
- luật được test được
- territory được đọc rõ
- marble/weapon có hình hài để chơi thử

## 3.2. Gameplay Checklist

| Asset Name | Description | Used For | Priority | Status | Owner | Dependency | Notes |
|---|---|---|---|---|---|---|---|
| Marble Base Body | thân marble chuẩn dùng chung | mọi marble | P0 |  |  |  |  |
| Fire Core Shell | nhận diện Fire Marble | Fire | P0 |  |  |  |  |
| Ice Core Shell | nhận diện Ice Marble | Ice | P0 |  |  |  |  |
| Magnet Core Shell | nhận diện Magnet Marble | Magnet | P0 |  |  |  |  |
| Shield Core Shell | nhận diện Shield Marble | Shield | P0 |  |  |  |  |
| Storm Core Shell | nhận diện Storm Marble | Storm | P0 |  |  |  |  |
| Gun World Model | nhận diện weapon Gun | weapon system | P0 |  |  |  |  |
| Laser World Model | nhận diện weapon Laser | weapon system | P0 |  |  |  |  |
| Cannon World Model | nhận diện weapon Cannon | weapon system | P0 |  |  |  |  |
| Magnet Device Model | nhận diện Magnet Device | weapon system | P0 |  |  |  |  |
| Shield Device Model | nhận diện Shield Device | weapon system | P0 |  |  |  |  |
| Projectile Placeholder Set | đạn/beam cơ bản | combat readability | P0 |  |  |  |  |
| Arena Blockout Kit | blockout map test | prototype map | P0 |  |  |  |  |
| Territory Neutral Material | vùng neutral | territory system | P0 |  |  |  |  |
| Territory Owned Material | vùng đã chiếm | territory system | P0 |  |  |  |  |
| Territory Contested Material | vùng tranh chấp | territory system | P0 |  |  |  |  |
| Territory Fortified Material | vùng chống tái chiếm | territory system | P1 |  |  |  |  |
| Pickup / Resource Placeholder | vật phẩm/tài nguyên | Magnet / simulation | P1 |  |  |  |  |
| Objective Zone Marker | vùng trọng điểm | scoring/system | P1 |  |  |  |  |
| Hazard Placeholder Set | hazard thử nghiệm | map simulation | P2 |  |  |  |  |
| Spawn Marker | spawn readability | match flow | P0 |  |  |  |  |
| Respawn Indicator | vòng trở lại trận | match flow | P1 |  |  |  |  |

## 3.3. Gameplay Validation
- [ ] 5 marble nhìn khác nhau từ xa
- [ ] 5 weapon nhìn khác nhau khi đang dùng
- [ ] territory neutral/owned/contested dễ phân biệt
- [ ] map blockout hỗ trợ đọc lane/choke/center
- [ ] gameplay asset không cần đẹp hoàn chỉnh nhưng phải rõ

---

# 4. VFX Assets

## 4.1. Purpose
VFX assets giúp:
- đọc active/passive
- đọc territory effect
- thấy rõ combat event
- tăng khả năng tạo highlight video

## 4.2. VFX Checklist

| Asset Name | Description | Used For | Priority | Status | Owner | Dependency | Notes |
|---|---|---|---|---|---|---|---|
| Fire Trail | vệt chuyển động lửa | Fire readability | P0 |  |  |  |  |
| Ice Trail | vệt chuyển động băng | Ice readability | P0 |  |  |  |  |
| Magnet Trail | vệt điện từ | Magnet readability | P0 |  |  |  |  |
| Shield Trail | vệt phòng thủ | Shield readability | P1 |  |  |  |  |
| Storm Trail | vệt lốc xoáy | Storm readability | P0 |  |  |  |  |
| Fire Passive Burn FX | burn status | Fire passive | P0 |  |  |  |  |
| Ice Slow FX | slow/freeze status | Ice passive | P0 |  |  |  |  |
| Magnet Pull FX | hút kéo | Magnet active | P0 |  |  |  |  |
| Shield Activate FX | bật khiên | Shield active | P0 |  |  |  |  |
| Storm Surge FX | sóng đẩy / vortex | Storm active | P0 |  |  |  |  |
| Gun Muzzle FX | bắn gun | Gun | P0 |  |  |  |  |
| Laser Beam FX | beam laser | Laser | P0 |  |  |  |  |
| Cannon Shot FX | pháo bắn | Cannon | P0 |  |  |  |  |
| Magnet Device FX | hiệu ứng hút | Magnet Device | P1 |  |  |  |  |
| Shield Device FX | hiệu ứng chắn | Shield Device | P1 |  |  |  |  |
| Projectile Hit FX Set | trúng mục tiêu | all weapons | P0 |  |  |  |  |
| Explosion FX | AOE impact | Cannon / map events | P1 |  |  |  |  |
| Territory Capture Pulse | vùng vừa chiếm | territory readability | P0 |  |  |  |  |
| Territory Contested FX | vùng đang tranh chấp | territory readability | P0 |  |  |  |  |
| Territory Burn Overlay | burn zone | Fire territory effect | P1 |  |  |  |  |
| Territory Frost Overlay | slow zone | Ice territory effect | P1 |  |  |  |  |
| Territory Pull Overlay | pull zone | Magnet territory effect | P1 |  |  |  |  |
| Territory Shield Overlay | anti-recapture zone | Shield territory effect | P1 |  |  |  |  |
| Territory Wind Overlay | current/push zone | Storm territory effect | P1 |  |  |  |  |
| Score Lead FX | người dẫn đầu | spectator support | P2 |  |  |  |  |
| Comeback FX | lật kèo | content moment | P2 |  |  |  |  |

## 4.3. VFX Validation
- [ ] không che mất territory
- [ ] active quan trọng nhìn phát hiểu ngay
- [ ] 5 marble có silhouette/VFX khác nhau
- [ ] contested zone đọc rõ hơn chứ không rối hơn
- [ ] clip quay lại vẫn nhìn được moment chính

---

# 5. UI Assets

## 5.1. Purpose
UI assets giúp:
- chọn marble/build
- đọc trận đấu
- hiểu điểm số và trạng thái
- hỗ trợ quay clip dễ hiểu

## 5.2. UI Checklist

| Asset Name | Description | Used For | Priority | Status | Owner | Dependency | Notes |
|---|---|---|---|---|---|---|---|
| Marble Icon Set | icon 5 marble | loadout / HUD | P0 |  |  |  |  |
| Weapon Icon Set | icon 5 weapon | loadout / HUD | P0 |  |  |  |  |
| Core Color ID Set | màu nhận diện core | UI readability | P0 |  |  |  |  |
| Match HUD Frame | khung HUD chính | in-match | P0 |  |  |  |  |
| Timer UI | thời gian trận | in-match | P0 |  |  |  |  |
| Score Panel | bảng điểm | in-match | P0 |  |  |  |  |
| Territory Ownership Bar | tỷ lệ territory | in-match | P0 |  |  |  |  |
| Active Skill Cooldown UI | cooldown marble | gameplay | P1 |  |  |  |  |
| Weapon Cooldown/Heat UI | cooldown/heat weapon | gameplay | P1 |  |  |  |  |
| Contested Zone Warning UI | cảnh báo tranh chấp | gameplay | P1 |  |  |  |  |
| Lead Change Banner | đổi người dẫn đầu | content readability | P1 |  |  |  |  |
| Comeback Banner | cảnh báo lật kèo | content readability | P1 |  |  |  |  |
| Dominance Banner | chuỗi kiểm soát mạnh | content readability | P2 |  |  |  |  |
| Loadout Screen | chọn marble + weapon | pre-match | P0 |  |  |  |  |
| Marble Detail Card | thẻ thông tin marble | selection | P1 |  |  |  |  |
| Weapon Detail Card | thẻ thông tin weapon | selection | P1 |  |  |  |  |
| Match Result Screen | kết quả trận | post-match | P0 |  |  |  |  |
| Score Breakdown Panel | breakdown điểm | post-match | P1 |  |  |  |  |
| Build Comparison Card | so sánh build | content/debug | P2 |  |  |  |  |
| Spectator Overlay | overlay khi xem simulation | spectate mode | P2 |  |  |  |  |
| Rarity Frame Set | khung hiếm | production expansion | P3 |  |  |  |  |
| Challenge Badge Set | huy hiệu challenge | creator mode | P2 |  |  |  |  |

## 5.3. UI Validation
- [ ] HUD không che gameplay chính
- [ ] score và territory luôn dễ đọc
- [ ] người xem clip không cần giải thích nhiều vẫn hiểu ai đang thắng
- [ ] loadout screen làm rõ khác biệt giữa marble và weapon
- [ ] các banner event tăng readability chứ không gây spam

---

# 6. Audio Assets

## 6.1. Purpose
Audio assets giúp:
- tăng lực cho gameplay
- báo hiệu event quan trọng
- hỗ trợ viewer hiểu moment ngay cả khi không nhìn toàn màn hình
- làm clip hấp dẫn hơn

## 6.2. Audio Checklist

| Asset Name | Description | Used For | Priority | Status | Owner | Dependency | Notes |
|---|---|---|---|---|---|---|---|
| Base Rolling Loop | tiếng lăn cơ bản | all marble | P0 |  |  |  |  |
| Heavy Collision Hit | va chạm mạnh | collision | P0 |  |  |  |  |
| Light Collision Hit | va chạm nhẹ | collision | P1 |  |  |  |  |
| Fire Passive Burn Audio | tiếng cháy | Fire | P0 |  |  |  |  |
| Ice Slow / Crack Audio | tiếng băng | Ice | P0 |  |  |  |  |
| Magnet Hum Loop | tiếng từ trường | Magnet | P0 |  |  |  |  |
| Shield Activate Sound | bật khiên | Shield | P0 |  |  |  |  |
| Storm Surge Sound | sóng gió/lốc | Storm | P0 |  |  |  |  |
| Gun Fire Sound | súng bắn | Gun | P0 |  |  |  |  |
| Laser Fire Sound | laser bắn | Laser | P0 |  |  |  |  |
| Cannon Fire Sound | pháo bắn | Cannon | P0 |  |  |  |  |
| Magnet Device Sound | hút/kéo | Magnet Device | P1 |  |  |  |  |
| Shield Device Sound | chắn/phản | Shield Device | P1 |  |  |  |  |
| Projectile Impact Set | tiếng trúng mục tiêu | all weapons | P0 |  |  |  |  |
| Explosion Boom | nổ lớn | Cannon / events | P1 |  |  |  |  |
| Territory Capture Cue | chiếm vùng | territory | P0 |  |  |  |  |
| Territory Lost Cue | mất vùng | territory | P1 |  |  |  |  |
| Contested Warning Cue | tranh chấp | territory | P1 |  |  |  |  |
| Lead Change Cue | đổi người dẫn đầu | spectator | P2 |  |  |  |  |
| Comeback Cue | báo lật kèo | spectator | P2 |  |  |  |  |
| Match End Stinger | kết thúc trận | post-match | P1 |  |  |  |  |
| UI Click Set | click UI | menu/UI | P1 |  |  |  |  |
| UI Confirm/Cancel Set | UI feedback | menu/UI | P1 |  |  |  |  |

## 6.3. Audio Validation
- [ ] nghe âm thanh là đoán được sự kiện chính
- [ ] 5 marble có audio identity khác nhau
- [ ] weapon fire không bị giống nhau
- [ ] contested/capture/lead-change có cue rõ
- [ ] audio làm clip “có lực” hơn rõ rệt

---

# 7. Content Capture Assets

## 7.1. Purpose
Content capture assets giúp:
- quay video dễ hơn
- dựng thumbnail/title dễ hơn
- người xem clip hiểu trận nhanh hơn
- game thật sự phục vụ YouTube content loop

## 7.2. Content Capture Checklist

| Asset Name | Description | Used For | Priority | Status | Owner | Dependency | Notes |
|---|---|---|---|---|---|---|---|
| Marble Name Tag Style | tag tên marble rõ ràng | spectate/content | P1 |  |  |  |  |
| Build Label Style | nhãn build Fire + Cannon... | content readability | P1 |  |  |  |  |
| Matchup Intro Card | card giới thiệu matchup | video intro | P2 |  |  |  |  |
| Marble Intro Card | card giới thiệu marble | creator flow | P2 |  |  |  |  |
| Event Banner Pack | stolen territory/comeback/etc. | clip readability | P1 |  |  |  |  |
| Challenge Badge Pack | only Fire/all random/etc. | challenge videos | P2 |  |  |  |  |
| Roster Presentation Frame | khung lineup trước trận | simulation intro | P2 |  |  |  |  |
| No-HUD Overlay Set | mode giảm HUD | clean footage | P2 |  |  |  |  |
| Spectator Label Pack | label cho AI/sim mode | simulation mode | P2 |  |  |  |  |
| Highlight Marker FX/UI | đánh dấu pha highlight | replay/content | P2 |  |  |  |  |
| Thumbnail Background Set | nền thumbnail | marketing/content | P3 |  |  |  |  |
| Result Story Card | card tóm tắt “ai thắng và vì sao” | shorts/videos | P2 |  |  |  |  |
| Comparison Layout Template | before/after, build vs build | creator tools | P3 |  |  |  |  |
| Scenario Title Template | 10 Fire vs 10 Ice... | scenario content | P2 |  |  |  |  |
| Camera Preset Marker Set | đánh dấu góc máy | recording | P2 |  |  |  |  |
| Replay Event Tagging Style | tag event cho replay | highlight curation | P3 |  |  |  |  |

## 7.3. Content Capture Validation
- [ ] có thể quay 1 clip ngắn mà vẫn hiểu match narrative
- [ ] matchup/build được giới thiệu nhanh và rõ
- [ ] event banner hỗ trợ xem video tốt
- [ ] có ít nhất 1 chế độ quay footage sạch
- [ ] content asset hỗ trợ challenge/simulation format

---

# 8. Production Board by Phase

## 8.1. Prototype Phase
### Must Have
- marble body + 5 core shell
- 5 weapon placeholder
- territory material set
- base HUD
- base VFX cho passive/active
- base audio cho collision/weapon/capture
- basic event banner

## 8.2. Playtest Phase
### Must Improve
- readability VFX
- score and territory UI
- territory effect overlays
- marble identity audio
- content readability banners

## 8.3. Creator-Ready Phase
### Additions
- spectator overlay
- no-HUD mode
- matchup intro cards
- challenge badge set
- result story card
- better camera marker support

## 8.4. Production Expansion Phase
### Additions
- rarity frames
- evolved marble presentation assets
- map-specific event assets
- polished content pack
- promotional capture support assets

---

# 9. Asset Dependency Tracking

| Asset | Depends On | Risk | Backup Plan | Notes |
|---|---|---|---|---|
| Fire Core Shell | Marble Base Body |  |  |  |
| Territory Contested FX | Territory Material Set |  |  |  |
| Match HUD | Score Logic |  |  |  |
| Event Banner Pack | Event Definitions |  |  |  |
| Weapon Fire Audio | Weapon Identity Finalization |  |  |  |
| No-HUD Overlay | Camera/Spectator System |  |  |  |

---

# 10. Weekly Review Template

## 10.1. Board Health
- Total Assets Planned:
- Total Assets Done:
- Total Assets Blocked:
- Highest Risk Group:
- Most Missing For Prototype:
- Most Missing For YouTube Content:

## 10.2. Group Review
### Gameplay
- Done:
- Missing:
- Risk:
- Next Action:

### VFX
- Done:
- Missing:
- Risk:
- Next Action:

### UI
- Done:
- Missing:
- Risk:
- Next Action:

### Audio
- Done:
- Missing:
- Risk:
- Next Action:

### Content Capture
- Done:
- Missing:
- Risk:
- Next Action:

---

# 11. Final Validation Checklist

- [ ] Gameplay asset đủ để test đầy đủ 5 marble + 5 weapon
- [ ] VFX giúp đọc trận tốt hơn, không làm rối hơn
- [ ] UI đủ để hiểu score/territory/build
- [ ] Audio đủ để nhận biết event quan trọng
- [ ] Content capture asset đủ để hỗ trợ quay video
- [ ] Tất cả asset vẫn giữ đúng luật lõi territory-centric
- [ ] Không nhóm asset nào làm marble mất identity
- [ ] Asset production ưu tiên đúng thứ tự: readability trước, polish sau