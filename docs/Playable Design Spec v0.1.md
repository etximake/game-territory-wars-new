# Playable Design Spec v0.1
> Dành cho prototype có thể chơi/test được.  
> Mục tiêu: biến định hướng Level 1 thành bộ luật gameplay cụ thể, có thể triển khai prototype mà không phá vỡ luật lõi.  
> Định hướng bắt buộc: simulation game + territory control + content YouTube.

---

# 1. Product Intent

## 1.1. Core Product Statement
Game là một **simulation arena territory game**, nơi các marble có core riêng, weapon riêng và tác động riêng lên bản đồ để tạo ra:
- tranh chấp lãnh thổ
- phản công/lật kèo
- tình huống hỗn loạn dễ đọc
- clip highlight phù hợp làm content YouTube

## 1.2. Prototype Goal
Bản playable đầu tiên phải chứng minh được 5 điều:
1. người xem nhìn vào hiểu được trận đấu
2. territory là trung tâm của trận
3. marble khác nhau tạo cảm giác khác nhau
4. weapon + marble core tạo build khác nhau
5. simulation sinh ra khoảnh khắc thú vị để quay video

## 1.3. Non-Goals của bản prototype
Prototype chưa cần:
- progression sâu
- economy hoàn chỉnh
- live ops
- social features phức tạp
- balance tuyệt đối
- quá nhiều marble/map/weapon

---

# 2. Design Pillars

## 2.1. Readability First
Mọi thứ phải dễ đọc khi:
- trực tiếp chơi
- đứng ngoài xem
- xem clip ngắn không có giải thích

## 2.2. Territory is the Main Layer
Combat chỉ có ý nghĩa khi tác động tới:
- chiếm đất
- giữ đất
- phá đất
- mở đường chiếm đất
- khóa đường phản công

## 2.3. Simulation Generates Content
Game phải sinh ra:
- va chạm bất ngờ
- combo emergent
- đảo chiều lãnh thổ
- tranh chấp choke point
- build thắng theo phong cách riêng

## 2.4. Controlled Chaos
Hỗn loạn là tốt cho content, nhưng phải:
- có nguyên nhân rõ
- người xem vẫn đọc được
- không biến thành random vô nghĩa

---

# 3. Core Match Structure

## 3.1. Match Format
### Khuyến nghị prototype:
- 1 trận: 3–6 marble AI + 1 player hoặc full AI simulation mode
- thời lượng: 3–6 phút
- chế độ chính: Free-for-all territory battle

## 3.2. Start of Match
Mỗi marble bắt đầu với:
- vị trí spawn riêng
- 1 weapon đã gắn
- 1 marble core đã chọn
- màu đội/định danh riêng
- điểm năng lượng/kỹ năng cơ bản

## 3.3. Main Objective
Mục tiêu thắng là đạt điểm tổng cao nhất khi hết thời gian hoặc đạt ngưỡng thắng sớm.

## 3.4. Score Sources
Điểm trong trận đến từ:
- % territory đang giữ
- số territory cướp được từ đối thủ
- kill/elimination nếu có
- giữ vùng trọng điểm
- chuỗi kiểm soát liên tục
- action highlight bonus (tùy prototype có bật hay không)

## 3.5. End Conditions
Một trận kết thúc khi:
- hết thời gian
- một marble/team đạt ngưỡng điểm
- một marble/team thống trị map theo điều kiện xác định trước

---

# 4. Territory Rules

## 4.1. Territory Model
Map được chia thành các vùng có thể bị tô màu/chiếm.
Prototype nên chọn 1 trong 2 cách:
- **cell/grid-based**
- **paint mask / influence field**

### Khuyến nghị prototype:
Dùng model đơn giản nhất mà dễ test và dễ nhìn.

## 4.2. Neutral Territory
Vùng trung lập:
- chưa thuộc ai
- có thể bị chiếm bằng tiếp xúc/ảnh hưởng
- không có bonus phòng thủ

## 4.3. Owned Territory
Vùng đã sở hữu:
- mang màu của chủ sở hữu
- có thể bị cướp lại
- có thể nhận hiệu ứng từ marble core

## 4.4. Capture Rule
Một vùng được chiếm khi marble:
- tiếp xúc đủ thời lượng
- hoặc để lại influence đủ ngưỡng
- hoặc kích hoạt skill ảnh hưởng vùng

## 4.5. Reclaim Rule
Vùng của đối thủ bị cướp lại chậm hơn vùng trung lập.
Khuyến nghị:
- chiếm neutral nhanh hơn
- chiếm enemy slower
- vùng vừa chiếm có thời gian ổn định ngắn

## 4.6. Contested Territory
Khi 2 hoặc nhiều marble cùng tác động vào vùng:
- vùng chuyển sang trạng thái tranh chấp
- tốc độ đổi quyền bị giảm
- hiệu ứng territory có thể bị triệt tiêu một phần

## 4.7. Territory Stability
Mỗi vùng nên có chỉ số ổn định tạm:
- neutral stability thấp
- owned stability trung bình
- fortified territory stability cao hơn

## 4.8. Territory Effects
Territory có thể chịu ảnh hưởng từ marble core:
- slow zone
- burn zone
- pull zone
- anti-recapture zone
- push/current zone

### Quy tắc:
Mỗi marble chỉ nên tác động rõ vào 1 kiểu territory effect chính.

---

# 5. Marble System

## 5.1. Marble Definition
Mỗi marble là một gameplay entity với:
- Role
- Core Fantasy
- Passive
- Active
- Territory Effect
- Weakness
- Readability Profile

## 5.2. Marble Archetypes trong prototype
Bản đầu chỉ dùng 5 marble:
- Fire
- Ice
- Magnet
- Shield
- Storm

## 5.3. Shared Rules cho mọi marble
Tất cả marble đều có:
- di chuyển vật lý
- va chạm
- khả năng chiếm đất
- 1 passive chính
- 1 active chính
- 1 territory effect chính
- 1 weapon slot

## 5.4. Fire Marble
### Role
Attacker / Corruptor

### Gameplay Intent
Mở rộng territory nhanh, ép nhịp, phá vùng địch

### Passive
Va chạm hoặc attack gây burn nhẹ

### Active
Overheat burst:
- tăng tốc ngắn
- tăng pressure lên vùng vừa chạm

### Territory Effect
Vùng vừa chiếm gây damage/pressure nhẹ lên địch đi qua

### Weakness
Giữ đất kém, thủ lâu không tốt

### Viewer Readability
- lõi đỏ/cam
- trail cháy
- hiệu ứng bốc nhiệt

## 5.5. Ice Marble
### Role
Defender / Controller

### Gameplay Intent
Khóa nhịp đối thủ, giữ điểm nóng

### Passive
Hit đầu làm chậm

### Active
Freeze pulse cục bộ

### Territory Effect
Vùng của mình làm giảm tốc địch

### Weakness
Damage thấp, tốc độ snowball kém

### Viewer Readability
- lõi xanh băng
- trail băng
- hit effect giòn

## 5.6. Magnet Marble
### Role
Utility / Controller

### Gameplay Intent
Điều hướng tình huống, hút tài nguyên, phá nhịp đội hình

### Passive
Hút pickups hoặc resource lân cận

### Active
Magnetic pull ngắn

### Territory Effect
Tài nguyên gần vùng sẽ trôi về phía mình

### Weakness
Áp lực damage thấp

### Viewer Readability
- vòng từ trường
- hiệu ứng rung lệch quỹ đạo
- trail điện từ

## 5.7. Shield Marble
### Role
Defender / Anchor

### Gameplay Intent
Cắm trụ, giữ territory, chống phản công

### Passive
Giảm knockback hoặc giảm damage ngắn

### Active
Shield burst / guard window

### Territory Effect
Vùng mới chiếm khó bị cướp trong thời gian ngắn

### Weakness
Đẩy map chậm, khó tạo snowball

### Viewer Readability
- lớp lục giác
- shimmer shield
- hit feedback chắc, nặng

## 5.8. Storm Marble
### Role
Disruptor / Controller

### Gameplay Intent
Tạo hỗn loạn có kiểm soát, đẩy lệch giao tranh, lật kèo

### Passive
Va chạm gây lệch hướng nhẹ

### Active
Wind surge / mini vortex

### Territory Effect
Tạo dòng đẩy hoặc lệch hướng quanh vùng

### Weakness
Thiếu ổn định, yêu cầu đọc tình huống tốt

### Viewer Readability
- trail xoáy
- vòng khí
- hiệu ứng đẩy rõ

---

# 6. Weapon System

## 6.1. Weapon Layer Role
Weapon quyết định cách gây áp lực, không thay vai trò core của marble.

## 6.2. Prototype Weapon Set
Bản đầu nên giới hạn 4–5 weapon:
- Gun
- Laser
- Cannon
- Magnet Device
- Shield Device

## 6.3. Weapon Design Rule
Mỗi weapon phải rõ:
- range profile
- pressure profile
- territory interaction support
- clarity in spectatorship

## 6.4. Weapon + Core Rule
Build phải tạo khác biệt, nhưng không được làm core mất bản sắc.

Ví dụ:
- Fire + Cannon = phá cụm mạnh
- Ice + Laser = giữ lane/choke
- Shield + Gun = giữ đất ổn định
- Magnet + utility pull = disrupt/tài nguyên
- Storm + Cannon = chaos burst

---

# 7. Combat Rules

## 7.1. Combat Exists to Shift Territory
Damage, knockback, disable chỉ có ý nghĩa khi:
- đẩy đối thủ ra khỏi vùng
- mở khoảng trống chiếm đất
- cản đường phản công
- phá nhịp build đối phương

## 7.2. Collision
Va chạm vật lý là một phần quan trọng của readability.
Cần xác định:
- va chạm có gây damage không
- va chạm có gây knockback không
- va chạm có kích hoạt passive không

## 7.3. Elimination / Downed Rule
Prototype cần quyết định 1 trong 2:
- marble không chết, chỉ mất nhịp/choáng/đẩy lùi
- marble có thể bị out tạm thời rồi respawn

### Khuyến nghị:
Cho respawn ngắn để tăng nhịp content.

## 7.4. Respawn Rule
Nếu dùng respawn:
- respawn delay ngắn
- respawn không reset toàn bộ match state
- respawn phải tạo cơ hội comeback, không làm trận chết nhịp

---

# 8. Simulation Rules

## 8.1. AI / Autonomy Goal
Nếu game hướng content YouTube, AI/simulation phải đủ tốt để:
- tự va chạm
- tự tranh chấp
- tạo narrative
- tạo tình huống bất ngờ

## 8.2. Simulation Priorities
AI marble nên có mục tiêu ưu tiên:
1. giữ an toàn khi yếu
2. tranh chấp vùng giá trị cao
3. mở rộng vào vùng dễ chiếm
4. dùng active ở điểm nóng
5. săn/né theo role

## 8.3. Simulation Readability
Dù AI thông minh hay đơn giản, hành động phải:
- đọc được
- có pattern hợp lý
- không quá random

---

# 9. Content Readability Rules

## 9.1. 5-Second Read Rule
Người xem phải hiểu trong 5 giây:
- ai đang mạnh
- marble nào là gì
- vùng nào đang tranh chấp
- vì sao có highlight

## 9.2. Visual Priority
Ưu tiên hiển thị:
1. territory ownership
2. active skill state
3. marble identity
4. damage/status
5. secondary UI

## 9.3. Do Not Overload
Không để:
- quá nhiều particle che territory
- quá nhiều status icon
- quá nhiều hiệu ứng cùng màu

---

# 10. Prototype Scope Lock

## 10.1. Must Have
- 1 mode playable
- 1 map đơn giản
- 5 marble core
- 4–5 weapon
- territory scoring
- contested zone rule
- match timer
- basic AI hoặc simulation mode
- basic spectator readability

## 10.2. Nice to Have
- highlight replay
- quick stat overlay
- kill feed
- event callout

## 10.3. Not in Prototype
- battle pass
- skins quy mô lớn
- marketplace
- social guild
- dozens of maps
- too many rarity tiers

---

# 11. Asset Requirements for Prototype

## 11.1. Gameplay Assets
- 5 marble core visual variants
- 4–5 weapon visual indicators
- 1 test arena map
- territory visual state set:
  - neutral
  - owned
  - contested
  - fortified
- VFX cho passive/active mỗi marble
- projectile/effect primitives

## 11.2. UI Assets
- match HUD
- score panel
- timer
- marble identity icons
- simple build select UI
- territory status indicator

## 11.3. Audio Assets
- impact sounds
- territory capture sound
- contested warning
- active skill sounds per marble
- weapon fire sounds
- score lead / momentum cues

## 11.4. Content Capture Support Assets
- clear nameplates hoặc icon tags
- camera zoom presets
- simple event banner:
  - territory stolen
  - domination
  - comeback
  - streak

---

# 12. Validation Checklist

Prototype đạt yêu cầu khi:
- người mới xem hiểu được core match
- 5 marble nhìn ra khác nhau
- build tạo cảm giác khác nhau
- territory ảnh hưởng quyết định thắng thua
- ít nhất 3 loại highlight xảy ra tự nhiên
- có thể quay ra clip ngắn mà vẫn hiểu được

---

# 13. Prototype Exit Criteria

Chỉ chuyển sang Production Content Spec khi:
1. loop trận đấu đã vui
2. territory đủ rõ
3. 5 marble khác biệt thật
4. simulation tạo narrative
5. viewer readability đạt ngưỡng tốt
6. không có cơ chế nào phá luật lõi Level 1