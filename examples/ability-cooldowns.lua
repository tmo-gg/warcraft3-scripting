if not war3.isRunning() or not war3.hasWorld() then
    print("지원 게임의 월드가 준비되면 다시 실행하세요.")
    return
end

local unit = war3.getSelectedUnit()
if not unit then
    print("유닛을 선택한 뒤 다시 실행하세요.")
    return
end

local abilities = war3.getUnitAbility(unit)
print("능력 수:", #abilities)
for index, id in ipairs(abilities) do
    if index > 12 then
        print("이 예제는 처음 12개 능력까지만 표시합니다.")
        break
    end
    local remaining = war3.getUnitAbilityCooldownRemaining(unit, id)
    local text = remaining == nil and "조회 불가" or string.format("%.1f초", remaining)
    print(id, war3.getObjectName(id), text)
end
