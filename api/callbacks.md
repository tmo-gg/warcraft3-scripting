# 콜백

[문서 홈](../README.md)

## 등록과 해제

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
