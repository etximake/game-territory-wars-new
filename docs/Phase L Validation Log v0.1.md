# Phase L Validation Log v0.1

> Muc tieu: chot quy trinh playtest cho prototype Godot 4.5 va ghi log theo 3 mode bat buoc.
> Cach chay preset:
> - `-- --test-preset 1vai`
> - `-- --test-preset multi_ai`
> - `-- --test-preset full_ai`
>
> Vi du:
> `Godot_v4.5-stable_win64_console.exe --path <project> -- --test-preset full_ai`

---

## Validation Matrix

| Test ID | Preset | Goal | Pass Condition | Log Focus |
|---|---|---|---|---|
| L-01 | `1vai` | Test 1vAI | Player va 1 AI tranh chap territory ro, khong bi nghen loop | readability, lane pressure, duel pacing |
| L-02 | `multi_ai` | Test nhieu AI cung luc | 6 actor tao tranh chap map nhung van doc duoc ai dang dan | territory spread, score gap, hotspot clarity |
| L-03 | `full_ai` | Test full AI simulation | Tran tu chay, co event banner, camera simulation doc duoc | spectatorship, content moments, macro ownership |
| L-04 | `multi_ai` | Test doc tran o toc do binh thuong | Nguoi xem nhin 5 giay biet lead/hot zone/build | readability, UI noise, active state |
| L-05 | `full_ai` | Test quay clip ngan | 20-30 giay clip van thay duoc lead swing va contested zone | capture support, highlight density |

---

## Session Template

### Test ID
- Date:
- Preset:
- Seed:
- Camera preset used:
- Test goal:

### Result Summary
- Match winner:
- Reason:
- Most controlled competitor:
- Strongest build impression:
- Weakest build impression:

### Territory Issues
- Neutral capture pace:
- Enemy reclaim pace:
- Contested zone clarity:
- Domination snowball note:

### Balance Issues
- Overperforming marble/build:
- Underperforming marble/build:
- Weapon pairing issue:
- Score source skew:

### Readability Issues
- 5-second read result:
- Marble identity clarity:
- Active state clarity:
- HUD noise:
- Clip readability:

### Next Action
- Immediate fix:
- Tuning candidate:
- Needs more human playtest:

---

## Baseline Notes - Current Prototype

- `1vai`: dung de test lane duel, contested timing va active clarity.
- `multi_ai`: dung de test overlap giua score panel, event banner va ownership indicator.
- `full_ai`: dung de test camera preset `Simulation`, event banner `territory stolen`, `domination`, `comeback`, `streak`.
- Territory can watch:
  - neu contested cell > 6 qua lau, xem lai reclaim/capture pacing.
  - neu 1 build snowball map qua som, xem lai `territory_score_weight`, `control_streak_bonus`, hoac pairing.
- Readability can watch:
  - neu marble van chim vao ownership colors, uu tien tiep tuc giam alpha territory truoc khi them effect moi.

---

## Exit Signal for Phase L

Danh dau Phase L dat yeu cau khi:
- Da chay du 3 preset `1vai`, `multi_ai`, `full_ai`.
- Da co it nhat 1 log cho territory, 1 log cho balance, 1 log cho readability.
- `Stat Sheet v0.1` da cap nhat thanh gia tri hien tai cua prototype.
- Da co danh sach 3-5 thay doi tuning uu tien cho vong tiep theo.
