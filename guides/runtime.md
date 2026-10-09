# 실행 환경과 수명

[문서 홈](../README.md)

## 사용자 환경

파일 스크립트와 편집기 테스트는 전역 변수와 불러온 모듈을 공유합니다. 스크립트끼리 이름이 충돌하지 않도록 변수는 `local`로 선언하는 것을 권장합니다.

맵을 바꿔도 변수, 콜백, 오버레이 창은 유지됩니다. **모두 다시 실행**을 누르면 스크립트 상태를 초기화하고 저장된 시작 파일과 마지막으로 테스트에 성공한 활성 편집기 코드를 실행합니다. 테스트하지 않은 수정은 복원하지 않으며, 테스트 중지·실패한 코드는 복원 대상에서 제외됩니다.

## 세 가지 식별자

| 종류 | 예 | 용도 |
| --- | --- | --- |
| 게임 객체 핸들 | `war3.getSelectedUnit()` 결과 | 유닛·타이머 조회에 전달하는 불투명 userdata |
| JASS 핸들 ID | JASS handle 변수에서 읽은 정수 | `war3.getRealHandle(id)`로 게임 객체 핸들로 변환 |
| 콜백 핸들 | `callbacks.bind(...)` 결과 | 대응하는 `remove` 함수로 등록 해제 |

게임 객체 핸들은 메모리 주소가 아닙니다. 숫자 변환이나 주소 계산을 하지 마세요. 출력의 `war3.handle:번호`도 JASS ID가 아닙니다.

같은 연결·월드의 같은 객체 핸들은 비교하거나 테이블 키로 사용할 수 있습니다. 연결 변경, 월드 변경, 모두 다시 실행 시 만료됩니다. 유닛·아이템 소멸이나 객체 재사용으로도 기존 핸들이 더 이상 유효하지 않을 수 있습니다. 캐시한 핸들은 사용 전에 조회 결과를 확인하거나 현재 선택 유닛을 다시 가져오세요.

```lua
local unit = war3.getSelectedUnit()
local info = unit and war3.getUnit(unit)
if info then
    print(info.typeId, info.owner, info.x, info.y)
end
```

`getUnit(nil)`과 `getUnitCombatStats(nil)`은 `nil`을 반환합니다. 다른 유닛 API에 `nil`을 전달해도 된다는 뜻은 아닙니다.

## 모듈 분리

`require`는 scripts 루트의 `?.lua`와 `?/init.lua`를 검색합니다. 호출 파일의 하위 폴더를 기준으로 검색하는 방식이 아닙니다.

```lua
-- helpers/labels.lua
local M = {}
function M.cooldown(seconds)
    if seconds == nil then return "조회 불가" end
    return string.format("%.1f초", seconds)
end
return M
```

```lua
-- main.lua
local labels = require("helpers.labels")
print(labels.cooldown(nil))
```

모듈은 `package.loaded`에 캐시됩니다. 수정한 모듈을 다시 불러오려면 모두 다시 실행을 사용합니다. 시작 파일 사이의 실행 순서에 의존하기보다 진입 파일 하나에서 모듈을 불러오는 구성을 권장합니다.

## 실행 한도

| 항목 | 한도 |
| --- | --- |
| Lua 메모리 | 실행 중인 스크립트 전체가 32 MiB를 공유 |
| 콜백 등록 | 스크립트 전체 합계 256개 |
| 편집기 파일 | UTF-8, 최대 256 KiB |
| 파일 탐색 | 최대 512개 항목, 하위 폴더 8단계 |
| 자동 실행 파일 | scripts 바로 아래 `.lua`, 최대 128개 |
| 코드·콜백 실행 시간 | 현재 런타임은 고정 시간 제한을 적용하지 않음 |
| 출력 보관 | 최근 64개 레코드, print 한 번 최대 2,048바이트 |

현재 런타임은 편집기 테스트와 OnDraw를 포함해 Lua 실행 시간 제한을 적용하지 않습니다. 무한 반복이나 블로킹 작업이 자동으로 중단된다고 가정하지 마세요. 콜백에서 대기 루프나 큰 파일 읽기를 하지 말고, 여러 틱에 작업을 나누세요. `OnDraw`는 캐시된 값을 그리는 용도로 짧게 유지합니다.

Lua 표준 라이브러리(`io`, `os`, `package` 등)를 사용할 수 있습니다. 스크립트는 컴퓨터의 파일에 접근할 수 있으므로 출처와 내용을 확인한 뒤 실행하세요.
