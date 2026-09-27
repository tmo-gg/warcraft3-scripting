# 오버레이 API

[문서 홈](../README.md) · [선택 유닛 HUD 예제](../examples/selected-unit.lua)

`OnDraw`에서 창이나 캔버스를 시작하고 내용을 그린 다음 대응하는 `end`를 호출합니다. 창·캔버스를 중첩하지 않으며, 중간 return으로 end가 생략되지 않게 작성하세요.

```lua
local enabled = true
callbacks.bind("OnDraw", function()
    overlay.beginWindow("settings", "HUD 설정", { width = 320, height = 140 })
    enabled = overlay.toggle("enabled", "HUD 표시", enabled)
    overlay.endWindow()

    overlay.beginCanvas("hud", enabled)
    overlay.drawText(24, 24, "TMO.GG", "accentBright", 22)
    overlay.endCanvas()
end)
```

창은 자동 레이아웃과 입력 컨트롤을 제공합니다. 캔버스는 화면 HUD를 직접 그리는 용도이며 마우스 입력을 가로채는 컨트롤 창이 아닙니다. 캔버스 좌표는 화면 왼쪽 위 기준 픽셀, 창 안의 직접 그리기 좌표는 콘텐츠 시작 위치 기준입니다. 게임 월드 좌표와는 다릅니다.

## 창과 캔버스

| 함수 | 반환 / 설명 |
| --- | --- |
| `overlay.beginWindow(id, title, options?)` | 창 그리기 시작, boolean 반환 |
| `overlay.endWindow()` | 창 완료 |
| `overlay.beginCanvas(id, visible?)` | 캔버스 시작, boolean 반환 |
| `overlay.endCanvas()` | 캔버스 완료 |
| `overlay.setWindowVisible(id, visible)` | 창 표시 상태 설정 |
| `overlay.setCanvasVisible(id, visible)` | 캔버스 표시 상태 설정 |
| `overlay.removeWindow(id)` | 창 제거 |
| `overlay.removeCanvas(id)` | 캔버스 제거 |
| `overlay.clear()` | 현재 스크립트의 오버레이 정리 |
| `overlay.getViewport()` | 화면 `width, height` 반환 |

ID는 스크립트 내부에서 안정적으로 유지되는 문자열을 사용합니다. 매 프레임 새 ID를 만들면 리소스가 누적됩니다. begin의 반환값을 창 닫기 상태로 해석하지 말고 begin/end 쌍을 유지하세요. `clear`와 제거 함수는 콜백 자체를 해제하지 않으므로 다음 OnDraw에서 다시 생성할 수 있습니다.

`beginWindow` 옵션:

| 필드 | 의미 / 범위 |
| --- | --- |
| `width`, `height` | 초기 크기. 폭 160–4096, 높이 80–4096 |
| `minimumWidth`, `minimumHeight` | 최소 크기. 폭 120–4096, 높이 60–4096 |
| `visible` | 표시 여부 |
| `collapsible` | 제목줄에서 접기 허용 |
| `fadeWhenIdle` | 마우스가 벗어나면 배경 투명도 조절 |
| `idleAlpha` | 비활성 배경 투명도, 0.15–1.0 |
| `hoverAlpha` | 마우스가 올라왔을 때 배경 투명도, idleAlpha–1.0 |

닫힌 창을 다시 열 때 `setWindowVisible`을 호출합니다. `visible = true`를 매 프레임 강제하면 사용자가 닫은 상태를 덮어쓸 수 있습니다.

## 레이아웃

다음 함수는 창 안에서 사용합니다.

| 함수 | 설명 |
| --- | --- |
| `overlay.text(text, color?)` | 텍스트 행 |
| `overlay.separator()` | 구분선 |
| `overlay.spacing(height?)` | 세로 여백 |
| `overlay.sameLine(spacing?)` | 다음 항목을 같은 줄에 배치 |
| `overlay.newLine()` | 다음 줄로 이동 |
| `overlay.beginScrollBox(id, height, options?)` | 스크롤 영역 시작. 반환값 없음 |
| `overlay.endScrollBox()` | 스크롤 영역 완료 |

스크롤 영역은 중첩할 수 없습니다. 옵션은 `width`, `padding`(0–64), `alwaysShowScrollbar`입니다. 높이는 60–4096 범위입니다.

## 입력 컨트롤

컨트롤은 창 안에서만 사용합니다. ID는 같은 창 안에서 중복되지 않게 지정합니다. 입력 결과는 다음 OnDraw에서 확인되므로 반환값을 스크립트 상태에 다시 저장합니다.

| 함수 | 반환 |
| --- | --- |
| `overlay.button(id, label, options?)` | `clicked` boolean |
| `overlay.radioButton(id, label, active)` | `clicked` boolean |
| `overlay.checkbox(id, label, value, options?)` | boolean `value, changed` |
| `overlay.toggle(id, label, value, options?)` | boolean `value, changed` |
| `overlay.inputText(id, label, value, options?)` | string `value, changed` |
| `overlay.inputInt(id, label, value, options?)` | integer `value, changed` |
| `overlay.inputFloat(id, label, value, options?)` | number `value, changed` |
| `overlay.sliderInt(id, label, value, minimum, maximum, options?)` | integer `value, changed` |
| `overlay.sliderFloat(id, label, value, minimum, maximum, options?)` | number `value, changed` |
| `overlay.combo(id, label, selectedIndex, items, options?)` | integer `selectedIndex, changed` |
| `overlay.selectable(id, label, selected, options?)` | boolean `selected, changed` |
| `overlay.progressBar(fraction, options?)` | 반환값 없음. fraction은 0–1 |

`changed`는 boolean입니다. `radioButton`은 선택 값을 반환하지 않고 클릭 여부를 반환합니다. `combo`는 비어 있지 않은 문자열 배열(최대 256개)과 **1부터 시작하는** 유효한 선택 인덱스를 받습니다.

| 컨트롤 | 옵션 필드 |
| --- | --- |
| button | `width`, `height`, `disabled` |
| checkbox, toggle | `disabled` |
| inputText | `width`, `height`, `maxLength`, `hint`, `readOnly`, `password`, `multiline`, `disabled` |
| inputInt | `width`, `step`, `stepFast`, `readOnly`, `disabled` |
| inputFloat | `width`, `step`, `stepFast`, `decimals`, `readOnly`, `disabled` |
| sliderInt | `width`, `disabled` |
| sliderFloat | `width`, `disabled`, `decimals` |
| combo | `width`, `disabled` |
| selectable | `width`, `height`, `disabled` |
| progressBar | `width`, `height`, `label` |

`decimals`는 0–6입니다. inputText의 `maxLength`는 기본 1024, 지정 범위 1–4096바이트이며 이미 들어 있는 문자열 길이에 따라 보정됩니다.

```lua
local selected = 1
local items = { "간단히", "자세히" }
callbacks.bind("OnDraw", function()
    overlay.beginWindow("mode", "표시 모드")
    local changed
    selected, changed = overlay.combo("mode", "모드", selected, items)
    if changed then print("선택:", items[selected]) end
    overlay.endWindow()
end)
```

## 직접 그리기

창 또는 캔버스 안에서 사용하며 반환값은 없습니다.

| 함수 | 설명 |
| --- | --- |
| `overlay.drawText(x, y, text, color?, fontSize?)` | 지정 위치 텍스트. 글꼴 크기 6–128 |
| `overlay.line(x1, y1, x2, y2, color?, thickness?)` | 선 |
| `overlay.rect(x, y, width, height, color?, rounding?, thickness?)` | 사각형 테두리 |
| `overlay.rectFilled(x, y, width, height, color?, rounding?)` | 채운 사각형 |
| `overlay.circle(x, y, radius, color?, thickness?, segments?)` | 원 테두리 |
| `overlay.circleFilled(x, y, radius, color?, segments?)` | 채운 원 |
| `overlay.image(path, x, y, width, height, tint?)` | 이미지 |

선 두께는 0.25–64, 원 segments는 0–256 범위이며 0은 자동입니다. 좌표와 크기는 유한한 숫자여야 합니다. 텍스트는 빈 문자열을 받지 않으므로 값이 없으면 대체 문구를 표시하거나 호출을 생략하세요.

이미지 상대 경로는 실행 스크립트의 디렉터리를 기준으로 합니다. `require`한 모듈 파일 자체의 폴더를 기준으로 바뀌지는 않습니다. PNG, JPEG, BMP, GIF 첫 프레임, WebP, SVG를 지원합니다.

## 색상

`overlay.rgba(r, g, b, a?)`는 각 채널 0–255의 정수를 받아 색상 정수를 반환합니다. alpha 기본값은 255입니다. 색상 인수에는 아래 토큰 문자열도 사용할 수 있습니다.

```text
canvas, surface, surfaceRaised, surfaceHover, surfaceActive, sidebar,
border, borderStrong, text, textMuted, textDim,
onSidebar, onSidebarMuted, onSidebarDim,
accent, accentSoft, accentBright, highlight, success, warning, danger
```

## 오류와 리소스

콜백 오류나 닫히지 않은 begin/end가 있으면 이전 완성 상태를 유지합니다. 화면이 멈춘 것처럼 보이면 출력 오류부터 확인하세요.

ID는 최대 128바이트, 제목·레이블은 최대 512바이트, 텍스트는 최대 16 KiB입니다. 창이나 컨트롤을 무한히 생성하지 말고, 사용하지 않는 창은 제거하세요. 많은 이미지나 복잡한 도형을 한꺼번에 그리면 표시 한도에 도달할 수 있습니다.
