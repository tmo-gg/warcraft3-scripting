# 콜백

[문서 홈](../README.md)

## 등록과 해제

| 함수 | 반환 / 설명 |
| --- | --- |
| `callbacks.bind(eventName, callback)` | 공통 콜백을 등록하고 등록 핸들 반환 |
| `callbacks.remove(handle)` | 등록 핸들 해제. 반환값 없음 |

```lua
local handle = callbacks.bind("OnTick", function()
    -- 반복 작업
end)
callbacks.remove(handle)
```

이벤트 이름은 대소문자를 구분합니다. 콜백은 `callbacks.bind`로 등록하고 `callbacks.remove`로 해제합니다. 등록은 게임 실행 전에도 가능합니다.

콜백 안에서 해제하면 이후 호출에 바로 반영됩니다. 콜백 안에서 새로 등록한 함수는 다음 이벤트부터 실행됩니다. 같은 파일 실행 단위를 다시 실행하면 그 파일의 기존 콜백을 교체합니다. 파일 자동 실행과 편집기 테스트는 별도 실행 단위입니다.

## 공통 콜백

| 이름 | 함수 형태 | 설명 |
| --- | --- | --- |
| `OnTick` | `function()` | 지원 게임 연결 중 반복 작업. 고정 주기·delta 인수를 보장하지 않음 |
| `OnDraw` | `function()` | 오버레이 프레임 요청. 짧게 그리기 수행 |
| `OnResponse` | `function()` | 사용자 응답 생성 시 호출. `setCustomResponse`로 정수 필드 설정 |
| `OnUnitBanEvaluate` | `function(unit, info)` | 전달할 유닛 데이터의 차단 목록 설정. true를 반환하면 해당 유닛 유형을 목록에 포함 |

`OnUnitBanEvaluate`의 `unit`은 게임 객체 핸들, `info`는 `getUnit`과 같은 필드의 테이블입니다. 반환값은 전달 데이터의 `banned` 목록을 구성하는 데 사용합니다.

`OnTick`, `OnDraw`, `OnResponse`의 반환값은 사용하지 않습니다. 일반 콜백 오류는 출력에 남습니다.

## 게임 이벤트 콜백

사용자 스크립트는 `war3.bind(eventName, callback)`으로 다음 이벤트를 구독하고, 반환된 등록 핸들을 `war3.remove(handle)`에 전달해 해제합니다. 공통 콜백의 `callbacks.bind`와 이벤트 이름 집합이 다릅니다. 게임 실행 전에도 등록할 수 있습니다.

| 이름 | 함수 형태 | 설명 |
| --- | --- | --- |
| `OnEvent` | `function(event)` | 관측한 게임 명령 이벤트 테이블 |
| `OnEventGap` | `function(gap)` | 수집·전달 중 누락 또는 불연속 알림 |
| `OnEventSession` | `function(session)` | 연결 세션 시작·종료, 수집 세대 변경 |

이 콜백들의 반환값은 사용하지 않습니다. 오류가 발생한 게임 이벤트 콜백은 해제됩니다. 수정 후 스크립트를 다시 실행하면 재등록됩니다. 콜백 중 등록·해제와 파일 재실행의 교체 규칙은 공통 콜백과 같습니다.

### OnEvent 데이터

현재 수집 범위는 정수 이벤트 ID `0xA0010`–`0xA001E`입니다. 공격 적중·스턴 발생을 모두 알려주는 전투 로그가 아닙니다. 아래 이름은 전달되는 Lua 테이블의 필드이며, 생성해야 하는 구조체나 전역 상수가 아닙니다.

| 필드 | 타입 | 의미 |
| --- | --- | --- |
| `type` | string | `"event"` |
| `schemaVersion` | integer | 현재 1 |
| `edition` | string | `"classic"` 또는 `"reforged"` |
| `gameVersion` | string | 게임 버전 |
| `sessionId` | string | 연결 세션 식별자 |
| `stream` | integer | 수집 세대. 완전한 경기 ID가 아님 |
| `sequence` | integer | 관측 순번. 게임 실행 순서를 증명하는 번호는 아님 |
| `qpc`, `qpcFrequency` | integer | 관측 타임스탬프와 초당 카운트. 주파수가 양수일 때 같은 시간 기준의 차이를 초로 변환 가능 |
| `threadId` | integer | 관측 스레드 ID |
| `eventId` | integer | 이벤트 종류의 정수 ID |
| `context` | integer | 명령 문맥 구분값. 게임 turn이 아님 |
| `command` | integer | 원본 명령 코드 |
| `playerId` | integer | 이벤트에 기록된 플레이어 ID |
| `droppedBefore` | integer | 해당 이벤트 이전까지 집계한 누락 수 |
| `payloadDecoded` | boolean | 종류별 추가 데이터를 해석했는지 여부 |
| `readFailed` | boolean | 데이터 읽기 실패 여부 |
| `truncated` | boolean | 전달한 데이터가 잘렸는지 여부 |
| `exceedsSelectionLimit` | boolean | 선택 개수가 판본별 통상 한도를 초과했는지 여부 |

다음 필드는 해당 이벤트에만 있습니다:

| 조건 | 필드 | 타입 / 의미 |
| --- | --- | --- |
| 선택 변경 `eventId == 0xA0016` | `operation` | integer, 원본 선택 연산 코드 |
| 동일 | `unitCount` | integer, 원본 선택 개수 |
| 동일 | `units` | `{id, generation}` 테이블의 1부터 시작하는 배열. 각 필드는 integer이며 최대 64개 |
| 확인된 명령 | `orderId` | integer, 확인된 명령 ID. 현재 클래식 기본 명령 `0xA0010`에 제공 |

`units`의 항목은 불투명 유닛 핸들이 아니며 `war3.getUnit`에 직접 전달할 수 없습니다. `id`를 JASS 핸들 ID나 rawcode로 가정하지 마세요. `readFailed`·`truncated`이면 `unitCount`와 배열 길이가 다를 수 있으므로 완전한 선택 상태로 취급하지 않습니다. `payloadDecoded=false`인 명령의 대상·좌표·명령 ID를 추정하지 마세요.

`qpc`는 관측 시각이지 사람의 입력 시각이 아닙니다. 선택 변경 `0xA0016`과 부대 호출 `0xA0018`은 별개이며 `operation` 한 값으로 행동을 단정할 수 없습니다. 이벤트 ID는 숫자 리터럴로 비교합니다. 이에 대응하는 이름의 전역 Lua 상수는 등록되어 있지 않습니다.

### OnEventGap 데이터

| 필드 | 타입 | 의미 |
| --- | --- | --- |
| `type` | string | `"gap"` |
| `reason` | string | 아래 누락 사유 |
| `sessionId`, `gameVersion` | string | 연결 세션과 게임 버전 |
| `processId`, `stream` | integer | 게임 프로세스와 수집 세대 |
| `droppedTotal` | integer? | `capture_loss`의 누적 누락 수 |
| `count` | integer? | `lua_budget`에서 전달하지 못한 이벤트 수 |
| `vm` | string? | `lua_budget`의 실행 환경 식별값. 사용자 콜백에서는 `"user"` |

`reason`은 `transport`(전달 경로 중단), `sequence_discontinuity`(순번 불연속), `capture_loss`(수집 누락), `lua_budget`(Lua 전달 생략)일 수 있습니다. `lua_budget`은 콜백 오류로 전달이 실패한 경우도 포함할 수 있습니다. 같은 손실이 여러 알림에 겹칠 수 있으므로 수치를 합쳐 정확한 유실 개수로 해석하지 마세요. 누락 알림을 받으면 이전의 부분 관측에 의존하던 상태를 초기화합니다.

### OnEventSession 데이터

| 필드 | 타입 | 의미 |
| --- | --- | --- |
| `type` | string | `"session"` |
| `phase` | string | `"start"`, `"stream"`, `"end"` |
| `sessionId`, `gameVersion` | string | 연결 세션과 게임 버전 |
| `processId` | integer | 게임 프로세스 ID |
| `stream` | integer? | `stream`·`end` 단계에 포함되는 수집 세대 |
| `selectionState` | string? | `start`·`stream` 단계의 `"unknown"` |

세션·수집 세대 경계에서는 기존 선택 상태를 알 수 없습니다. 상태를 누적한다면 `sessionId`, `stream`, `context`, `playerId`를 구분하고 세션 및 누락 알림에 맞춰 초기화하세요.
