# 시작 가이드

[문서 홈](../README.md)

## 파일 위치

자동 실행할 `.lua` 파일은 TMO.GG Desktop 설치 폴더 기준 `games/warcraft3/scripts` 바로 아래에 둡니다.

```text
TMO.GG Desktop.exe
games/
  warcraft3/
    scripts/
      main.lua
      helpers/
        labels.lua
```

`main.lua`는 자동 실행 대상이고 `helpers/labels.lua`는 자동 실행 대상이 아닙니다. 하위 폴더 코드는 `require("helpers.labels")`로 불러오거나 편집기에서 테스트합니다.

## 첫 스크립트

TMO.GG Desktop에서 워크래프트 III의 스크립트 관리를 열고 `hello.lua`를 만든 뒤 아래 코드를 입력합니다.

```lua
print("Hello, TMO.GG!")

if war3.isRunning() and war3.hasWorld() then
    print("현재 맵:", war3.getMapName())
    local player = war3.getLocalPlayer()
    if player >= 0 then
        print("내 이름:", war3.getPlayerName(player))
    end
else
    print("지원 게임의 월드가 준비되면 다시 실행하세요.")
end
```

**문법 검사**는 코드를 컴파일만 합니다. **F5 / 테스트**는 저장하지 않은 편집 내용도 실제 환경에서 실행합니다. 등록한 콜백이 동작하고 변수 값도 바뀌므로 문법 검사와 실행을 구분하세요.

**Ctrl+S**로 저장합니다. 파일 저장 자체는 실행을 뜻하지 않습니다. 저장된 시작 스크립트들을 다시 불러오려면 **모두 다시 실행**을 사용합니다.

## 계속 갱신되는 화면 만들기

한 번 실행한 코드는 끝나면 종료됩니다. 지속적인 동작은 콜백으로 등록합니다.

```lua
local status = "게임 연결 대기"

callbacks.bind("OnTick", function()
    status = war3.hasWorld() and war3.getMapName() or "월드 준비 대기"
end)

callbacks.bind("OnDraw", function()
    overlay.beginWindow("hello", "내 첫 오버레이", { width = 320, height = 120 })
    overlay.text(status ~= "" and status or "맵 이름 없음")
    overlay.endWindow()
end)
```

지원 게임에 연결하면 오버레이가 자동으로 동작합니다. `OnTick`은 게임 연결 상태에서 호출되며, `OnDraw`는 오버레이 프레임 요청에 따라 호출됩니다. 창을 닫았다면 `overlay.setWindowVisible("hello", true)`로 다시 표시할 수 있습니다.

## 편집기 조작

| 동작 | 단축키 또는 버튼 |
| --- | --- |
| 저장 / 다른 이름으로 저장 | Ctrl+S / Ctrl+Shift+S |
| 테스트 | F5 |
| 최근 편집기 테스트의 콜백 해제 | 테스트 중지 |
| 저장된 파일과 활성 테스트 다시 시작 | 모두 다시 실행 |
| 찾기 / 바꾸기 | Ctrl+F / Ctrl+H |
| 자동완성 | Ctrl+Space |

반복 테스트는 이전 편집기 테스트 콜백을 교체합니다. 다만 자동 실행된 파일과 편집기 테스트는 별도 실행 단위이므로 같은 코드가 양쪽에 있으면 중복 동작할 수 있습니다. 테스트 중지로 편집기 콜백을 정리하고, 저장된 파일은 모두 다시 실행으로 갱신하세요.

창을 닫는 동작은 편집기 창을 숨깁니다. 스크립트 정지 명령이 아니며, 저장하지 않은 내용은 앱 종료 전에 저장해야 합니다.

다음: [실행 환경과 수명](runtime.md) · [실행 예제](../examples/README.md)
