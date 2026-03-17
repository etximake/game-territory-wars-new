# Playable Design Checklist v0.1
> Mục tiêu: chuyển [Playable Design Spec v0.1](./Playable%20Design%20Spec%20v0.1.md) thành checklist triển khai thực tế cho prototype Godot 4.5.  
> Phạm vi: chỉ tập trung vào bản playable prototype, chưa làm production mở rộng.

---

# 1. Cách dùng file này

- Dùng file này làm board triển khai chính cho giai đoạn prototype.
- Chỉ làm những gì phục vụ trực tiếp cho `core loop playable`.
- Nếu có hạng mục không giúp chứng minh `territory-centric + marble identity + content readability`, hoãn lại.

---

# 2. Điều kiện hoàn thành prototype

- [ ] Người mới nhìn vào hiểu đây là game tranh chấp territory.
- [ ] Territory là yếu tố quyết định thắng thua chính.
- [ ] 5 marble tạo cảm giác chơi và cách gây ảnh hưởng khác nhau.
- [ ] 4-5 weapon tạo build khác nhau nhưng không lấn vai trò marble core.
- [ ] Có thể chạy `player + AI` hoặc `full AI simulation`.
- [ ] Có ít nhất 3 loại highlight xảy ra tự nhiên.
- [ ] Quay clip ngắn vẫn đọc được ai mạnh, vùng nào đang tranh chấp, vì sao có highlight.

---

# 3. Checklist triển khai

## Phase A - Foundation

- [ ] Tạo project structure sạch cho prototype.
- [ ] Tạo scene main chạy được.
- [ ] Tạo scene world/arena cơ bản.
- [ ] Tạo config nền cho match prototype.
- [ ] Tạo naming convention thống nhất cho scene, script, resource.
- [ ] Chốt hệ tọa độ, layer, collision layer/mask.
- [ ] Chốt camera prototype cố định hoặc zoom-out đơn giản.

## Phase B - Core Match Loop

- [ ] Tạo match flow: start -> running -> end.
- [ ] Tạo timer trận.
- [ ] Tạo rule thắng cơ bản.
- [ ] Tạo score model cho prototype.
- [ ] Tạo restart match nhanh để playtest liên tục.
- [ ] Tạo seed hoặc reset logic để dễ test lặp.

## Phase C - Territory System

- [ ] Chọn mô hình territory prototype: `cell/grid-based` hoặc `paint mask`.
- [ ] Tạo dữ liệu ownership cho territory.
- [ ] Tạo neutral state.
- [ ] Tạo owned state.
- [ ] Tạo contested state.
- [ ] Tạo capture rule cho neutral territory.
- [ ] Tạo reclaim rule chậm hơn khi cướp đất địch.
- [ ] Tạo short protection/stability cho vùng mới chiếm.
- [ ] Tạo cách đọc % territory đang giữ.
- [ ] Tạo debug view để nhìn logic capture rõ khi test.

## Phase D - Marble Base System

- [ ] Tạo marble actor base.
- [ ] Tạo movement vật lý/di chuyển chuẩn cho marble.
- [ ] Tạo collision cơ bản giữa marble với world.
- [ ] Tạo team/faction ownership cho marble.
- [ ] Tạo stat container cho marble.
- [ ] Tạo passive slot.
- [ ] Tạo active slot.
- [ ] Tạo territory effect slot.
- [ ] Tạo weakness/counter hook.
- [ ] Tạo visual identity hook cho từng marble.

## Phase E - 5 Marble Prototype

### Fire
- [ ] Passive burn nhẹ.
- [ ] Active overheat burst.
- [ ] Territory burn/pressure effect.
- [ ] Readability đỏ/cam + trail cháy.

### Ice
- [ ] Passive slow hit đầu.
- [ ] Active freeze pulse.
- [ ] Territory slow zone.
- [ ] Readability xanh băng + trail băng.

### Magnet
- [ ] Passive hút pickup/resource gần.
- [ ] Active pull ngắn.
- [ ] Territory resource drift/pull effect.
- [ ] Readability điện từ / quỹ đạo lệch.

### Shield
- [ ] Passive giảm knockback hoặc giảm damage ngắn.
- [ ] Active guard/shield burst.
- [ ] Territory anti-recapture effect.
- [ ] Readability shield/lục giác.

### Storm
- [ ] Passive lệch hướng nhẹ khi va chạm.
- [ ] Active wind surge / mini vortex.
- [ ] Territory push/current effect.
- [ ] Readability gió/xoáy/đẩy rõ.

## Phase F - Weapon System

- [ ] Tạo weapon base system.
- [ ] Tạo weapon data container.
- [ ] Tạo equip flow: mỗi marble có 1 weapon slot.
- [ ] Tạo weapon impact lên combat/pressure.
- [ ] Đảm bảo weapon không thay vai trò marble core.

### Weapon Prototype
- [ ] Gun
- [ ] Laser
- [ ] Cannon
- [ ] Magnet Device
- [ ] Shield Device

### Build Validation
- [ ] Fire + Cannon tạo cảm giác phá cụm mạnh.
- [ ] Ice + Laser tạo cảm giác giữ lane/choke.
- [ ] Magnet + Magnet Device tạo cảm giác utility/disrupt.
- [ ] Shield + Gun tạo cảm giác giữ đất ổn định.
- [ ] Storm + Cannon tạo cảm giác chaos burst.

## Phase G - Combat Rules

- [ ] Chốt va chạm có gây damage hay không.
- [ ] Chốt va chạm có gây knockback hay không.
- [ ] Chốt attack có tương tác với territory thế nào.
- [ ] Chốt elimination model:
- [ ] `No death, only disruption` hoặc
- [ ] `Temporary out + short respawn`
- [ ] Nếu có respawn, tạo respawn delay ngắn.
- [ ] Đảm bảo combat luôn phục vụ đổi quyền territory.

## Phase H - AI / Simulation

- [ ] Tạo AI cơ bản đủ để tự tranh chấp territory.
- [ ] AI biết ưu tiên vùng giá trị cao.
- [ ] AI biết mở rộng vào vùng dễ chiếm.
- [ ] AI biết dùng active ở điểm nóng.
- [ ] AI có behavior khác nhau theo role marble.
- [ ] AI không quá random, có pattern đọc được.
- [ ] Tạo mode full AI simulation.

## Phase I - Readability / Spectatorship

- [ ] Người xem hiểu trong 5 giây ai đang mạnh.
- [ ] Người xem nhìn ra marble nào là gì.
- [ ] Người xem nhìn ra vùng nào đang contested.
- [ ] Active skill state hiển thị rõ.
- [ ] Territory ownership luôn rõ hơn effect.
- [ ] Hạn chế particle che map.
- [ ] Hạn chế effect trùng màu gây rối.

## Phase J - UI Prototype

- [ ] Match HUD cơ bản.
- [ ] Timer UI.
- [ ] Score panel.
- [ ] Territory ownership indicator.
- [ ] Marble identity icon/tag.
- [ ] Build select UI đơn giản.
- [ ] Match result screen đơn giản.

## Phase K - Content Capture Support

- [ ] Camera preset chơi thường.
- [ ] Camera preset zoom-out để xem simulation.
- [ ] Name tag hoặc icon tag rõ.
- [ ] Event banner đơn giản:
- [ ] territory stolen
- [ ] domination
- [ ] comeback
- [ ] streak

## Phase L - Playtest / Validation

- [ ] Test 1vAI.
- [ ] Test nhiều AI cùng lúc.
- [ ] Test full AI simulation.
- [ ] Test khả năng đọc trận ở tốc độ bình thường.
- [ ] Test quay clip ngắn.
- [ ] Ghi log vấn đề territory.
- [ ] Ghi log vấn đề balance.
- [ ] Ghi log vấn đề readability.
- [ ] Cập nhật `Stat Sheet v0.1`.

---

# 4. Assets phải chuẩn bị cho prototype

## P0 - Bắt buộc

- [ ] 1 marble base body dùng chung.
- [ ] 5 core shell/visual nhận diện cho Fire, Ice, Magnet, Shield, Storm.
- [ ] 5 weapon placeholder visuals.
- [ ] 1 test arena map blockout.
- [ ] Territory materials/states:
- [ ] neutral
- [ ] owned
- [ ] contested
- [ ] fortified
- [ ] Projectile/effect primitives cơ bản.
- [ ] Match HUD khung đơn giản.
- [ ] Timer UI.
- [ ] Score panel.
- [ ] Territory indicator.
- [ ] Marble icon set cơ bản.
- [ ] Weapon icon set cơ bản.
- [ ] Âm thanh va chạm cơ bản.
- [ ] Âm thanh capture territory.
- [ ] Âm thanh contested warning.

## P1 - Rất nên có

- [ ] Fire trail / burn FX.
- [ ] Ice trail / slow FX.
- [ ] Magnet pull FX.
- [ ] Shield activate FX.
- [ ] Storm surge FX.
- [ ] Gun muzzle / hit FX.
- [ ] Laser beam FX.
- [ ] Cannon impact FX.
- [ ] Territory effect overlays cho 5 marble.
- [ ] Active skill sound cho từng marble.
- [ ] Weapon fire sound riêng cho từng weapon.
- [ ] Event banner pack đơn giản.
- [ ] Camera zoom presets.

## P2 - Làm sau nếu còn thời gian

- [ ] Highlight marker.
- [ ] Replay đơn giản.
- [ ] Build comparison card.
- [ ] Matchup intro card.
- [ ] No-HUD mode.

---

# 5. Phân công: việc bạn làm / việc mình làm

## Việc bạn làm

- Chốt quyết định thiết kế khi có nhiều hướng triển khai.
- Chọn ưu tiên prototype nào làm trước nếu cần cắt scope.
- Chuẩn bị hoặc chọn asset art/audio placeholder khi cần nhìn đúng cảm giác.
- Playtest trực tiếp và phản hồi cảm giác chơi.
- Quyết định stat/fantasy cuối cùng cho từng marble và weapon.
- Xác nhận mức độ đúng với vision YouTube/content.

## Việc mình làm

- Chuyển spec thành kiến trúc scene/script/resource trong Godot 4.5.
- Viết code cho core systems: match flow, territory, marble, weapon, AI, HUD prototype.
- Tạo data structure cho marble/weapon/stat để dễ tuning.
- Tạo checklist, roadmap và chia phase triển khai.
- Đề xuất scope cut khi thấy rủi ro quá tải.
- Hỗ trợ điền stat test đầu tiên từ `Stat Sheet v0.1`.
- Rà soát xem implementation có còn bám đúng spec hay bị lệch.

## Cách phối hợp khuyến nghị

- Bạn chốt `design intent`.
- Mình dựng `technical implementation`.
- Bạn test và phản hồi.
- Mình sửa loop, tuning và readability.

---

# 6. Thứ tự triển khai khuyến nghị

1. Foundation
2. Core Match Loop
3. Territory System
4. Marble Base System
5. 2 marble đầu tiên để validate loop
6. Weapon Base System
7. 5 marble + 5 weapon đầy đủ
8. AI / Simulation
9. UI + readability
10. Playtest + Stat Sheet tuning

---

# 7. Scope cut nếu thiếu thời gian

- Cắt replay.
- Cắt progression.
- Cắt nhiều map.
- Cắt polish VFX cao cấp.
- Giữ đúng 1 map test.
- Ưu tiên 2 marble đầu tiên để kiểm chứng loop trước khi làm đủ 5 marble.
- Chỉ làm UI đủ đọc, chưa cần đẹp.

---

# 8. Bước tiếp theo ngay bây giờ

- [ ] Chốt kiến trúc project prototype mới.
- [ ] Tạo task breakdown cho `Foundation + Core Match Loop + Territory System`.
- [ ] Tạo skeleton scene/script đầu tiên trong Godot 4.5.

