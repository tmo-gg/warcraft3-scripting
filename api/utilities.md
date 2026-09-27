# 유틸리티 API

[문서 홈](../README.md)

다음 함수는 전역 함수이며 네임스페이스를 붙이지 않습니다.

| 함수 | 반환 / 설명 |
| --- | --- |
| `print(...)` | 인수를 탭으로 구분해 출력. 반환값 없음 |
| `getAsyncKeyState(key)` | Windows 가상 키 상태 integer. 0–255 밖의 키는 0 |
| `fileExists(path)` | 일반 파일이면 boolean true |
| `directoryExists(path)` | 디렉터리이면 boolean true |
| `getFiles(path, mask?)` | 파일 경로 string 배열. mask 기본값 `"*"` |
| `setCustomResponse(key, integer)` | OnResponse 응답 필드 지정. 반환값 없음 |

## 파일 조회

위 파일 유틸리티의 상대 경로는 **scripts 루트** 기준입니다. `overlay.image`의 상대 경로 기준과 다릅니다. `getFiles`는 하위 폴더를 재귀 탐색하지 않으며 최대 1024개 일반 파일을 반환합니다. 반환 순서는 보장하지 않습니다.

```lua
for _, path in ipairs(getFiles(".", "*.lua")) do
    print(path)
end
```

Lua 표준 `io.open`은 위 유틸리티와 별도 함수입니다. 그 상대 경로도 자동으로 scripts 루트에 맞춰진다고 가정하지 마세요.

## 키 상태

현재 눌림 상태는 상위 비트로 검사합니다. 매 틱 동작을 반복하지 않으려면 이전 상태를 보관합니다.

```lua
local wasDown = false
callbacks.bind("OnTick", function()
    local down = (getAsyncKeyState(0x77) & 0x8000) ~= 0 -- F8
    if down and not wasDown then print("F8 눌림") end
    wasDown = down
end)
```

이 함수는 Windows 키 상태 조회이며 게임에만 한정된 단축키 등록 API가 아닙니다.

## 사용자 응답

```lua
callbacks.bind("OnResponse", function()
    setCustomResponse("myScriptVersion", 1)
end)
```

응답을 생성할 때 이전 사용자 필드가 비워지고 콜백이 실행됩니다. 키는 최대 128바이트, 응답 필드는 최대 256개이며 값은 정수만 받습니다. `setCustomResponse`는 외부 메시지를 전송하는 함수가 아닙니다.
