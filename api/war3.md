# 게임 API

[문서 홈](../README.md) · [핸들과 수명](../guides/runtime.md)

모든 함수는 `war3.` 네임스페이스에 있습니다. 조회 전에 `isRunning()`과 `hasWorld()`로 연결·월드 상태를 확인하세요. 실패값 `0`, `false`, 빈 문자열은 유효한 게임 값과 구별되지 않을 수 있습니다.

## 게임과 입력

| 함수 | 반환 / 설명 |
| --- | --- |
| `war3.isRunning()` | 지원 게임이 실행 중이면 boolean `true` |
| `war3.hasWorld()` | 게임 월드 UI가 준비되어 있으면 `true` |
| `war3.getMapName()` | 맵 이름 string |
| `war3.getMapFileName()` | 맵 경로 string |
| `war3.isChatAvailable()` | 현재 채팅 전송 가능 여부 boolean |
| `war3.sendChat(message)` | 문자열 채팅 전송. 반환값 없음 |
| `war3.sendInput(key)` | 정수 키 코드 전달. 반환값 없음 |
| `war3.getObjectName(id, index?)` | 오브젝트 표시 이름. `id`는 rawcode 문자열 또는 정수, `index` 기본값 0 |

`sendChat`과 `sendInput`에는 성공 여부 반환값이 없습니다. 조회 함수의 결과나 전송 요청만으로 실제 입력 처리가 완료됐다고 판단하지 마세요.

## 플레이어

`player`는 0부터 시작하는 게임 플레이어 ID입니다. Lua 배열 인덱스와 혼동하지 마세요.

| 함수 | 반환 / 설명 |
| --- | --- |
| `war3.getLocalPlayer()` | 로컬 플레이어 ID integer. 미연결이면 -1 |
| `war3.getPlayerName(player)` | 이름 string |
| `war3.getPlayerTeam(player)` | 팀 번호 integer |
| `war3.getPlayerRace(player)` | 종족 integer. `RACE_*`와 비교 |
| `war3.getPlayerSlotState(player)` | 슬롯 상태 integer. `PLAYER_SLOT_STATE_*`와 비교 |
| `war3.getPlayerState(player, field)` | 정수 상태 값. `PLAYER_STATE_*` 사용 |
| `war3.getPlayerStartLocation(player)` | `x, y` 두 number |
| `war3.getPlayerAbilityAvailable(player, abilityId)` | 능력 사용 가능 여부 boolean. `abilityId`는 rawcode string |

```lua
if war3.hasWorld() then
    local player = war3.getLocalPlayer()
    if player >= 0 then
        print("금:", war3.getPlayerState(player, PLAYER_STATE_RESOURCE_GOLD))
    end
end
```

## 유닛과 능력

`unit`과 `shop`은 게임 객체 핸들입니다. rawcode는 `"hfoo"` 같은 4바이트 오브젝트 식별 문자열이며 표시 이름과 다릅니다. 맵이 정의한 능력·유닛 ID를 사용하세요.

| 함수 | 반환 / 설명 |
| --- | --- |
| `war3.getSelectedUnit()` | 선택 유닛 핸들 또는 `nil` |
| `war3.getUnitHandle()` | 현재 월드 유닛 핸들의 Lua 배열. 미연결이면 `nil` 가능 |
| `war3.getUnit(unit)` | 아래 유닛 정보 table 또는 `nil` |
| `war3.getRealHandle(handleId)` | JASS 정수 핸들 ID에 대응하는 게임 객체 핸들 또는 `nil` |
| `war3.getUnitHasInventory(unit)` | 인벤토리 유무 boolean |
| `war3.getUnitItem(unit, slot)` | 슬롯 **0–5**의 아이템 rawcode string 또는 `nil` |
| `war3.getUnitAbility(unit)` | 능력 rawcode 문자열 배열 |
| `war3.getUnitAbilityLevel(unit, abilityId)` | 능력 레벨 integer. 조회 불가 시 0 |
| `war3.getUnitAbilityCooldownRemaining(unit, abilityId)` | 남은 쿨다운 초 number 또는 `nil` |
| `war3.getUnitStockCooldownRemaining(shop, unitId)` | 유닛 재고 보충까지 남은 초 number 또는 `nil` |
| `war3.getTimerRemaining(timer)` | 타이머 객체 핸들의 남은 초 number. 조회 불가 시 0 가능 |

`getUnit`의 반환 필드:

| 필드 | 타입 | 의미 |
| --- | --- | --- |
| `typeId` | string | 유닛 유형 rawcode |
| `owner` | integer | 소유 플레이어 ID |
| `vertexColor` | integer | 유닛 색상 원시 값 |
| `x`, `y`, `z` | number | 게임 월드 좌표 |

쿨다운의 **0은 완료**, **nil은 확인 불가**입니다. 없는 능력, 지원하지 않는 타이머, 읽기 실패를 임의로 0으로 바꾸지 마세요. 재고 API는 재고가 있으면 0, 항목이 없거나 보충 타이머를 확인할 수 없으면 nil을 반환합니다.

```lua
local unit = war3.getSelectedUnit()
if unit then
    for _, id in ipairs(war3.getUnitAbility(unit)) do
        local seconds = war3.getUnitAbilityCooldownRemaining(unit, id)
        print(id, seconds == nil and "조회 불가" or string.format("%.1f초", seconds))
    end
end
```

전체 유닛 순회는 `ipairs(war3.getUnitHandle() or {})`처럼 미연결을 처리합니다. 큰 월드의 전체 순회를 매 OnDraw마다 수행하지 마세요.

## 카메라 정보

| 함수 | 반환 / 설명 |
| --- | --- |
| `war3.getCameraPosition()` | `x, y` 두 number |
| `war3.getCameraField(field)` | 필드 값 number |

`field`는 [CAMERA_FIELD 상수](constants.md)를 사용합니다. 좌표는 화면 픽셀이 아닌 게임 좌표이며, 각 필드 값은 게임의 필드 단위를 따릅니다.

## JASS 데이터

| 함수 | 반환 / 설명 |
| --- | --- |
| `war3.jass.variables()` | `{name, type, value}` 항목 배열. 미연결이면 `nil` 가능 |
| `war3.jass.get(name)` | 변수 값. 없거나 읽을 수 없으면 `nil` |
| `war3.jass.loadBoolean(tableId, parent, child)` | JASS 해시테이블 boolean 값. 실패도 `false` |

`loadBoolean`의 `tableId`는 JASS 정수 핸들 ID입니다. `parent`, `child`는 정수 또는 rawcode 문자열입니다.

지원 값은 integer, real, string, handle, boolean 및 해당 배열입니다. handle 값은 정수 ID로 반환합니다. 배열은 Lua의 **1부터 시작하는 배열**로 변환하므로 JASS의 인덱스 0은 Lua 인덱스 1에 대응합니다. 읽기 불가 항목은 nil이 될 수 있어 `#`나 `ipairs`로 원본 배열 길이를 보장할 수 없습니다.

```lua
-- udg_MyUnit은 설명용 이름입니다. 실제 맵의 변수명으로 바꾸세요.
local id = war3.jass.get("udg_MyUnit")
if type(id) == "number" then
    local unit = war3.getRealHandle(id)
    local info = unit and war3.getUnit(unit)
    if info then print(info.typeId) end
end
```

반복 조회에서는 전체 `variables()` 대신 필요한 이름을 `get()`으로 조회하세요. 이 API는 임의 JASS 함수를 호출하거나 변수를 쓰는 API가 아닙니다.
