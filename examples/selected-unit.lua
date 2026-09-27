local title = "월드 준비 대기"
local details = "유닛을 선택하세요."

callbacks.bind("OnTick", function()
    if not war3.hasWorld() then
        title, details = "월드 준비 대기", "유닛을 선택하세요."
        return
    end
    local unit = war3.getSelectedUnit()
    local info = unit and war3.getUnit(unit)
    if not info then
        title, details = "선택 유닛 없음", "유닛을 선택하세요."
        return
    end
    local name = war3.getObjectName(info.typeId)
    title = name ~= "" and name or info.typeId
    details = string.format("소유자 %d | 위치 %.0f, %.0f", info.owner, info.x, info.y)
end)

callbacks.bind("OnDraw", function()
    overlay.beginWindow("selected-unit", "선택 유닛", {
        width = 360, height = 140, collapsible = true
    })
    overlay.text(title, "accentBright")
    overlay.text(details, "textMuted")
    overlay.endWindow()
end)
