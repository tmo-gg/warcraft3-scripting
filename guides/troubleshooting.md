# 문제 해결

[문서 홈](../README.md)

| 증상 | 확인할 사항 |
| --- | --- |
| 파일이 자동으로 실행되지 않음 | `games/warcraft3/scripts` 바로 아래 `.lua`인지 확인. 하위 폴더는 require 또는 테스트로 실행 |
| 저장했는데 동작이 같음 | 저장과 실행은 별도. 파일은 모두 다시 실행, 편집 내용은 F5로 실행 |
| 출력·동작이 두 번 발생 | 자동 실행 파일과 편집기 테스트의 중복 확인. 테스트 중지 후 저장본을 다시 실행 |
| 문법 검사는 통과하지만 실행 실패 | 문법 검사는 API를 실행하지 않음. 하단 출력의 실행 오류 확인 |
| `Unknown callback event` / `Unknown war3 event` | 공통 이벤트는 callbacks.bind, 게임 이벤트는 war3.bind 사용. 이름 대소문자 확인 |
| `Expected a game object handle` | 주소 숫자·JASS ID·콜백 핸들 혼용 여부 확인. JASS ID는 getRealHandle로 변환 |
| 맵 전환 뒤 유닛 조회가 nil | 이전 월드 핸들 만료. 현재 월드에서 다시 조회 |
| 새 API가 nil이거나 함수 호출 오류 | 사용 중인 Desktop 버전이 해당 API를 제공하는지 `type(war3.getUnitCombatStats)` 또는 `type(overlay.getContentSize)`로 확인 |
| 창을 늘려도 내용이 고정됨 | getViewport 대신 창 안에서 getContentSize를 읽고 컨트롤 너비·목록 높이에 적용 |
| 전투 수치 필드가 nil | 일부 수치만 읽히는 경우가 있음. 없는 필드를 0으로 해석하지 않음 |
| 쿨다운이 nil | 능력이 없거나 타이머 미지원·읽기 실패 가능. 0으로 간주하지 않음 |
| 오버레이가 보이지 않음 | 지원 게임 연결과 OnDraw 등록 확인. 닫은 창은 setWindowVisible로 표시 |
| 오버레이가 갱신되지 않음 | 출력 오류와 begin/end 짝 확인. 긴 Lua 작업 동안 이전 프레임 유지 가능 |
| 컨트롤 값이 돌아감 | 반환된 value를 local 상태에 저장하는지 확인 |
| `module ... not found` | scripts 루트 기준 모듈 경로 확인. `helpers/util.lua`는 `require("helpers.util")` |
| 모듈 수정이 반영되지 않음 | package.loaded 캐시. 모두 다시 실행으로 초기화 |
| 긴 작업 중 앱·오버레이가 멈춘 듯 보임 | 현재 런타임은 고정 실행 시간 제한이 없음. 반복 작업 분할, OnDraw의 전체 유닛·JASS 순회와 블로킹 작업 제거 |
| `Too many callbacks` | OnTick/OnDraw 안에서 계속 bind하지 않는지 확인 |
| 메모리 부족 오류 | 누적 테이블 크기 제한, 오래된 상태 정리. 스크립트 전체 메모리 한도 32 MiB |

테스트 중지는 최근 편집기 테스트의 콜백을 해제합니다. 전역 변수 값까지 초기화하려면 모두 다시 실행을 사용하세요.

오류 제보에는 앱·게임 버전, 실행 방식(자동 시작/F5), 맵 전환 여부, 최소 재현 코드와 출력 메시지를 포함하세요.
