# 게임 API

[문서 홈](../README.md) · [핸들과 수명](../guides/runtime.md)

모든 함수는 `war3.` 네임스페이스에 있습니다. 조회 전에 `isRunning()`과 `hasWorld()`로 연결·월드 상태를 확인하세요. 실패값 `0`, `false`, 빈 문자열은 유효한 게임 값과 구별되지 않을 수 있습니다.

## 게임과 입력

| 함수 | 반환 / 설명 |
| --- | --- |
| `war3.isRunning()` | 지원 게임이 실행 중이면 boolean `true` |
| `war3.isReforged()` | 리포지드 `true`, 클래식 `false`, 미연결·지원하지 않는 연결은 `nil` |
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
| `war3.getPlayerTechCount(player, techId)` | 해당 연구 rawcode의 완료 단계. 미연구는 0, 월드 없음·읽기 실패는 nil |
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
| `war3.getUnitCombatStats(unit, weaponIndex?)` | HP/MP·최대치·초당 자연 재생·공속 보정 공격 간격 table 또는 nil. 무기는 0(기본)/1 |
| `war3.getRealHandle(handleId)` | JASS 정수 핸들 ID에 대응하는 게임 객체 핸들 또는 `nil` |
| `war3.getUnitHasInventory(unit)` | 인벤토리 유무 boolean |
| `war3.getUnitInventorySize(unit)` | 실제 슬롯 수 또는 nil, 성공 여부, 상태. 빈 슬롯 포함, 인벤토리 없음은 0 |
| `war3.getUnitItem(unit, slot)` | 슬롯 **0–슬롯 수-1**의 아이템 rawcode string 또는 `nil` |
| `war3.getUnitItemInfo(unit, slot)` | 슬롯 **0–슬롯 수-1**의 `{typeId, charges}` 또는 nil, 성공 여부, 상태 |
| `war3.getItemInfo(item)` | 불투명 아이템 핸들의 `{typeId, charges}` 또는 nil, 성공 여부, 상태 |
| `war3.getUnitAbility(unit)` | 능력 rawcode 문자열 배열 |
| `war3.getUnitAbilityLevel(unit, abilityId)` | 능력 레벨 integer. 조회 불가 시 0 |
| `war3.getUnitAbilityCooldownRemaining(unit, abilityId)` | 남은 쿨다운 초 number 또는 `nil` |
| `war3.getUnitStockCooldownRemaining(shop, unitId)` | 유닛 재고 보충까지 남은 초 number 또는 `nil` |
| `war3.getTimerRemaining(timer)` | 타이머 객체 핸들의 남은 초 number. 조회 불가 시 0 가능 |

`getUnit`은 다음 필드를 가진 Lua 테이블을 반환합니다. 별도 구조체 생성자는 없습니다:

| 필드 | 타입 | 의미 |
| --- | --- | --- |
| `typeId` | string | 유닛 유형 rawcode |
| `owner` | integer | 소유 플레이어 ID |
| `vertexColor` | integer | 유닛 색상 원시 값 |
| `x`, `y`, `z` | number | 게임 월드 좌표 |

아이템 상세 정보의 `typeId`는 기존 `getUnitItem`과 같은 종류 문자열이며, `charges`는 부호 있는 32비트 정수 충전 수입니다. 충전 수가 성장 스택인지 소비 수량인지는 맵이 결정합니다. `getItemInfo`에는 JASS item ID를 `war3.getRealHandle`로 변환한 핸들을 전달합니다. 객체 소멸·세대 변경·주소 재사용으로 만료된 핸들에서는 새 아이템의 정보를 반환하지 않습니다. 게임 메모리 주소는 노출하지 않습니다.

`war3.getUnitInventorySize(unit)`는 클래식·리포지드 공통으로 유닛에 실제 설정된 인벤토리 용량을 반환합니다. 현재 들어 있는 아이템 수가 아니라 빈 슬롯을 포함한 전체 슬롯 수입니다. 클래식에서 3칸이면 3, 리포지드에서 9칸이면 9입니다. 인벤토리가 없거나 용량이 0이면 `0, true, "ok"`이며, 읽기 실패는 nil/false로 구분합니다.

현재 능력 레벨과 개체별 설정을 반영하고 저장 공간보다 큰 값은 반환하지 않습니다. 슬롯 용량은 일시적인 아이템 사용 가능 여부와 별개입니다. 리포지드의 판독 한도는 8192슬롯으로, 게임 자체의 상한을 뜻하지 않습니다.

```lua
local count, ok, status = war3.getUnitInventorySize(unit)
if ok then
    for slot = 0, count - 1 do
        local item, found, itemStatus = war3.getUnitItemInfo(unit, slot)
        if found then print(slot, item.typeId, item.charges) end
    end
end
```

슬롯은 **0부터 count-1까지**이며, count 자체는 인덱스가 아닙니다. 개수 조회 후 인벤토리가 바뀔 수 있으므로 개별 조회의 상태도 확인하세요. 두 아이템 조회와 슬롯 수 조회는 아래의 **조회 상태** 규약을 사용합니다. 기존 `getUnitItem`의 반환값은 바뀌지 않습니다.

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


## 전투 수치와 연구 단계

`war3.getUnitCombatStats(unit, weaponIndex?)`는 유효한 유닛의 **현재 능력치**를 Lua 테이블로 반환합니다. `weaponIndex`는 생략하면 0(첫 번째 무기)이며, 두 번째 무기는 1입니다. 0·1 이외의 값은 오류입니다.

| 필드 | 타입 / 단위 | 의미 |
| --- | --- | --- |
| `hp` | number | 현재 체력 |
| `maxHp` | number | 최대 체력 |
| `hpRegen` | number / 초 | 엔진에 반영된 현재 체력 재생량 |
| `mana` | number | 현재 마나 |
| `maxMana` | number | 최대 마나 |
| `manaRegen` | number / 초 | 엔진에 반영된 현재 마나 재생량 |
| `attackInterval` | number / 초 | 지정 무기의 공격속도 보정 후 공격 간격 |
| `attackSpeedMultiplier` | number / 배율 | 엔진의 예외·상하한을 적용한 공격속도 배율 |
| `userData` | integer / 부호 있는 32비트 | 맵의 `GetUnitUserData` 값 |

유닛을 확인할 수 없으면 전체 반환값이 `nil`입니다. 유효한 유닛이어도 특정 값을 읽지 못하면 해당 필드는 생략됩니다. 체력 세 필드와 마나 세 필드는 각각 묶음으로 읽으며, 공격 관련 값과 `userData`도 없는 경우가 있습니다. 없는 필드를 0으로 대체하면 실제 0과 조회 실패를 구별할 수 없습니다. 다른 게임·스크립트 실행에서 얻은 핸들 등 잘못된 핸들 타입은 오류가 될 수 있습니다.

재생량에는 엔진에 적용된 보정이 들어가지만, 공격할 때 맵 스크립트가 직접 지급하는 체력·마나까지 합산하지 않습니다. 현재 체력·마나는 게임 시간에 따른 지연 재생을 반영합니다. 공격 간격은 실제 공격 중인지, 대상 변경이나 시전 지연이 얼마나 있는지 알려주는 값이 아닙니다. 조회 결과는 게임을 정지시켜 얻는 원자적 스냅샷이 아닙니다.

`userData`의 의미는 맵이 정하므로 소유 플레이어 ID로 가정하지 마세요. 소유자는 `war3.getUnit(unit).owner`로 조회합니다.

`war3.getPlayerTechCount(player, techId)`는 **완료된 연구 단계**를 integer로 반환합니다. `techId`는 정확히 4바이트인 rawcode 문자열이어야 하며 길이가 다르면 오류입니다. 확인한 미연구 항목은 `0`, 월드 없음·읽기 실패·범위 밖 플레이어 ID는 `nil`입니다. `player`의 API 허용 범위는 0–31이며 실제 맵에 존재하는 플레이어를 사용하세요.

연구 API는 유닛 생산 수량이나 대체 유닛 의존성을 합산하지 않습니다. 맵의 초기 연구 설정 때문에 화면의 “0업”과 엔진 단계 0이 다를 수 있습니다. 판본이 필요한 계산은 `war3.isReforged()`의 `nil`, `false`, `true`를 구별하세요. 현재 공격 간격에는 이미 적용된 연구 효과가 포함되므로 같은 효과를 다시 가산하지 않습니다.

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
| `war3.jass.getArray(name, index)` | 배열 원소 하나의 값 또는 nil, 성공 여부, 상태. **JASS 0 기반 인덱스** |
| `war3.jass.loadBoolean(tableId, parent, child)` | JASS 해시테이블 boolean 값. 실패도 `false` |
| `war3.jass.tryLoadBoolean(tableId, parent, child)` | boolean 또는 nil, 성공 여부, 상태. false와 조회 실패 구분 |
| `war3.jass.loadInteger(tableId, parent, child)` | integer 또는 nil, 성공 여부, 상태 |
| `war3.jass.loadReal(tableId, parent, child)` | number 또는 nil, 성공 여부, 상태 |

`loadBoolean`의 `tableId`는 JASS 정수 핸들 ID입니다. `parent`, `child`는 정수 또는 rawcode 문자열입니다.

`war3.jass.variables()`의 각 항목도 Lua 테이블입니다:

| 필드 | 타입 | 의미 |
| --- | --- | --- |
| `name` | string | 변수 이름. `war3.jass.get(name)`에 전달 가능 |
| `type` | string | JASS 타입 이름 |
| `value` | 타입별 값 또는 nil | 현재 값. 읽을 수 없으면 필드가 없을 수 있음 |

`type`은 `nothing`, `unknown`, `null`, `code`, `integer`, `real`, `string`, `handle`, `boolean`, `integerArray`, `realArray`, `stringArray`, `handleArray`, `booleanArray` 중 하나입니다. 타입 이름이 있다고 해서 값을 조회할 수 있다는 뜻은 아닙니다.

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


## 조회 상태

`getUnitInventorySize`, `getUnitItemInfo`, `getItemInfo`, `jass.getArray`, `jass.loadInteger`, `jass.loadReal`, `jass.tryLoadBoolean`은 **`value, ok, status` 세 값**을 반환합니다. 기존 조회 함수의 반환 형식은 유지합니다.

`ok == true`이면 `status == "ok"`이며 실제 0·false·빈 문자열도 유효한 값입니다. `ok == false`이면 값은 nil이고 다음 상태를 확인합니다. `empty`·`missing`도 값이 없는 결과이므로 ok는 false입니다.

| status | 의미 |
| --- | --- |
| `ok` | 조회 성공 |
| `empty` | 인벤토리가 없거나 슬롯이 비어 있음 |
| `missing` | 확인한 해시테이블에 해당 타입의 키가 없음 |
| `unavailable` | 연결·월드가 없거나 필요한 데이터를 읽지 못함. 배열 변수 조회 실패도 포함 |
| `invalid_object` | 잘못된 종류·만료·소멸한 객체 |
| `out_of_range` | 슬롯 또는 배열 인덱스 범위 밖 |
| `type_mismatch` | 조회한 변수가 지원하는 배열 타입이 아님 |
| `invalid_data` | 비정상 구조·순환·과도한 탐색 또는 NaN/Infinity |
| `changed` | 조회 도중 객체·슬롯·배열·테이블 연결이 바뀜 |

상태 이름은 문자열이며 전역 Lua 상수가 아닙니다. 인수 타입 오류, 위조·외부 핸들, 32비트 범위를 넘는 해시 키 등 잘못된 호출은 Lua 오류가 될 수 있습니다. 한 번의 조회가 게임 전체의 원자적 스냅샷을 보장하지는 않습니다.

### 배열 원소 조회

`jass.getArray(name, index)`는 integer/real/string/handle/boolean 배열을 지원합니다. 전체 배열을 복사하지 않고 요청한 원소 하나만 읽습니다. 숫자 원소는 4바이트만 읽고 문자열은 최대 4096바이트에서 종료 문자를 확인합니다. 인덱스는 0–65535 중 실제 배열 범위 안이어야 합니다.

**이 함수의 0 기반 인덱스는 `jass.get(name)`이 반환하는 Lua 배열의 1 기반 인덱스와 다릅니다.** 플레이어별 배열에서는 맵이 플레이어 ID를 어떤 인덱스로 사용하는지 확인하세요. handle 원소는 JASS 정수 ID이므로 필요할 때 `getRealHandle`로 변환합니다.

### 타입별 해시테이블 조회

세 새 해시테이블 조회 함수의 `tableId`는 JASS hashtable 정수 핸들 ID입니다. `parent`, `child`는 -2147483648–4294967295 범위의 정수 또는 정확히 4바이트인 rawcode 문자열입니다. 정수의 상위 비트는 같은 32비트 키로 해석하며, 문자열은 기존 `loadBoolean`과 같은 rawcode 바이트 순서를 사용합니다.

integer, real, boolean 저장 공간은 독립적입니다. 다른 타입으로 저장된 값을 변환해서 반환하지 않습니다. 저장된 0/false와 키가 없는 상태를 구분하며, 조회 실패를 기본값으로 대체하지 않습니다. 기존 `loadBoolean`은 계속 boolean 한 값을 반환하고 실패도 false이므로 상태가 필요하면 `tryLoadBoolean`을 사용하세요.

새 함수는 해당 기능을 포함한 Desktop 런타임이 필요합니다. `type(war3.jass.getArray) == "function"`처럼 제공 여부를 확인할 수 있습니다.
