----------------------------------------------------------------------------------------------------
--- 별도 애드온 설치하기 곤란하여 직접 제작한 애드온
--- 1. 행동단축바의 글씨 크기 변경
--- 2. 화면에 캐릭터의 이동속도 표시
--- 3. 대부분의 UI 요소(대화창, 옵션창, 다이얼로그 버튼, 캐릭터 창 등) 글씨 크기 조정
--- 4. 매크로 편집창(에디트박스) 폰트 크기 변경 기능 추가
----------------------------------------------------------------------------------------------------

-- 1. 행동단축바의 글씨 크기 변경
-- 설정: 원하는 폰트 경로, 크기, 스타일
local FONT_PATH = "Fonts\\FRIZQT__.TTF" -- 기본 와우 폰트, 경로는 Interface\AddOns\ 또는 Fonts\ 기준
local HOTKEY_FONT_SIZE = 16
local MACRO_FONT_SIZE = 14
local FONT_FLAGS = "OUTLINE" -- "OUTLINE", "THICKOUTLINE", "MONOCHROME", 등

-- 행동단축바의 글씨 크기 변경
local function UpdateActionBarFonts()
    for i = 1, 12 do
        for bar = 1, 10 do
            local btn = _G["ActionButton"..i]
            if bar > 1 then
                btn = _G["MultiBarBottomLeftButton"..i]
                if bar == 3 then btn = _G["MultiBarBottomRightButton"..i] end
                if bar == 4 then btn = _G["MultiBarRightButton"..i] end
                if bar == 5 then btn = _G["MultiBarLeftButton"..i] end
                if bar == 6 then btn = _G["MultiBar5Button"..i] end
                if bar == 7 then btn = _G["MultiBar6Button"..i] end
                if bar == 8 then btn = _G["MultiBar7Button"..i] end
                if bar == 9 then btn = _G["MultiBar8Button"..i] end
                if bar == 10 then btn = _G["MultiBar9Button"..i] end
            end
            if btn then
                if btn.HotKey then
                    btn.HotKey:SetFont(FONT_PATH, HOTKEY_FONT_SIZE, FONT_FLAGS)
                end
                if btn.Name then
                    btn.Name:SetFont(FONT_PATH, MACRO_FONT_SIZE, FONT_FLAGS)
                end
            end
        end
    end
end

-- 이벤트에 등록
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
f:SetScript("OnEvent", UpdateActionBarFonts)

----------------------------------------------------------------------------------------------------
-- 2. 화면에 캐릭터의 이동속도 표시

-- SavedVariables로 speedFramePosition 사용 (TOC에 반드시 "## SavedVariables: speedFramePosition" 선언 필요)
if not speedFramePosition then
    speedFramePosition = {}
end

-- 이동속도 표시용 프레임 생성
local speedFrame = CreateFrame("Frame", nil, UIParent)
speedFrame:SetSize(120, 30)

-- 위치 복원 함수
local function RestoreSpeedFramePosition()
    -- SavedVariables는 애드온이 완전히 로드된 후에만 값이 들어옴
    -- 따라서 PLAYER_LOGIN 이벤트에서 복원해야 함
    if speedFramePosition and speedFramePosition.point then
        speedFrame:ClearAllPoints()
        speedFrame:SetPoint(
            speedFramePosition.point,
            UIParent,
            speedFramePosition.relativePoint,
            speedFramePosition.xOfs,
            speedFramePosition.yOfs
        )
    else
        speedFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 500, 400)
    end
end

-- 위치 저장 함수
local function SaveSpeedFramePosition()
    if not speedFramePosition then speedFramePosition = {} end
    local point, _, relativePoint, xOfs, yOfs = speedFrame:GetPoint()
    speedFramePosition.point = point
    speedFramePosition.relativePoint = relativePoint
    speedFramePosition.xOfs = xOfs
    speedFramePosition.yOfs = yOfs
end

-- PLAYER_LOGIN 이벤트에서 위치 복원
local speedFrameEventFrame = CreateFrame("Frame")
speedFrameEventFrame:RegisterEvent("PLAYER_LOGIN")
speedFrameEventFrame:SetScript("OnEvent", function()
    RestoreSpeedFramePosition()
end)

speedFrame.text = speedFrame:CreateFontString(nil, "OVERLAY")
speedFrame.text:SetFont(FONT_PATH, 16, FONT_FLAGS)
speedFrame.text:SetPoint("CENTER", speedFrame, "CENTER", 0, 0)
speedFrame.text:SetText("이동속도: 0%")

-- Shift+클릭 시 프레임 이동 가능
speedFrame:SetMovable(true)
speedFrame:EnableMouse(true)
speedFrame:RegisterForDrag("LeftButton")
speedFrame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        self:StartMoving()
    end
end)
speedFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveSpeedFramePosition()
end)

local function UpdateSpeed()
    local speed = GetUnitSpeed("player") / 7 * 100 -- 7는 기본 걷기 속도
    speedFrame.text:SetText(string.format("이동속도: %.1f%%", speed))
end

speedFrame:SetScript("OnUpdate", function(self, elapsed)
    UpdateSpeed()
end)

----------------------------------------------------------------------------------------------------
--- 3. 대부분의 UI 요소(대화창, 옵션창, 다이얼로그 버튼, 캐릭터 창 등) 글씨 크기 조정
----------------------------------------------------------------------------------------------------

-- 원하는 전체 UI 폰트 크기 및 스타일
local GLOBAL_FONT_SIZE = 16
local GLOBAL_FONT_SIZE_SMALL = 14
local GLOBAL_FONT_FLAGS = "OUTLINE"

-- 주요 폰트 오브젝트 목록
local fontObjects = {
    -- 다이얼로그/버튼
    DialogButtonNormalText,
    DialogButtonHighlightText,
    DialogButtonDisableText,
    -- 탭
    GameFontHighlightSmallLeft,
    GameFontHighlightSmallRight,
    GameFontHighlightSmallCenter,
    GameFontHighlightSmallOutline,
    GameFontNormalLeft,
    GameFontNormalRight,
    GameFontNormalCenter,
    GameFontHighlightLeft,
    GameFontHighlightRight,
    GameFontHighlightCenter,
    GameFontDisableLeft,
    GameFontDisableRight,
    GameFontDisableCenter,
    GameFontNormalLargeLeft,
    GameFontNormalLargeRight,
    GameFontNormalLargeCenter,
    GameFontHighlightLargeLeft,
    GameFontHighlightLargeRight,
    GameFontHighlightLargeCenter,
    GameFontDisableLargeLeft,
    GameFontDisableLargeRight,
    GameFontDisableLargeCenter,
}

local fontObjects_Inner = {
    -- 기본 UI 본문
    GameFontNormal,
    GameFontHighlight,
    GameFontDisable,
    GameFontGreen,
    GameFontRed,
    GameFontWhite,
    GameFontBlack,
    GameFontDarkGray,
    GameFontNormalSmall,
    GameFontHighlightSmall,
    GameFontDisableSmall,
    GameFontNormalLarge,
    GameFontHighlightLarge,
    GameFontDisableLarge,
    GameFontNormalHuge,
    GameFontHighlightHuge,
    GameFontDisableHuge,
    GameFontNormalHugeOutline,
    GameFontNormalHugeOutline2,
    GameFontNormalHugeOutline3,
    GameFontNormalHugeOutline4,
    GameFontNormalMed3,
    GameFontNormalSmall2,
    GameFontNormalLarge2,
    GameFontNormalHuge2,
    GameFontNormalHuge3,
    GameFontNormalHuge4,
    -- 대화창/숫자
    ChatFontNormal,
    NumberFontNormal,
    NumberFontNormalSmall,
    NumberFontNormalLarge,
    NumberFontNormalHuge,
    -- 시스템 폰트
    SystemFont_Shadow_Med1,
    SystemFont_Shadow_Med2,
    SystemFont_Shadow_Med3,
    SystemFont_Shadow_Small,
    SystemFont_Small,
    SystemFont_Tiny,
    SystemFont_Med1,
    SystemFont_Med2,
    SystemFont_Med3,
    SystemFont_Huge1,
    SystemFont_Huge2,
    SystemFont_Huge4,
    SystemFont_Outline_Small,
    SystemFont_Outline,
    SystemFont_OutlineThick_Huge2,
    SystemFont_OutlineThick_Huge4,
    SystemFont_OutlineThick_Mono_Small,
    -- 퀘스트/책
    QuestFont,
    QuestFont_Large,
    QuestFont_Shadow_Huge,
    QuestFont_Shadow_Small,
    QuestFont_Super_Huge,
    QuestFont_Enormous,
    QuestFont_Outline_Huge,
    -- 전문기술
    ProfessionsRecipeNameFont,
    ProfessionsRecipeSubTextFont,
    ProfessionsRecipeTextFont,
    ProfessionsRecipeHighlightFont,
    ProfessionsRecipeErrorTextFont,
    ProfessionsRecipeDescriptionFont,
    ProfessionsRecipeReagentFont,
    ProfessionsRecipeReagentHighlightFont,
    ProfessionsRecipeReagentErrorFont,
    -- 캐릭터창/스탯
    PaperDollTitleFont,
    PaperDollLabelFont,
    PaperDollFontNormalSmall,
    PaperDollFontNormalLarge,
    PaperDollFontHighlightSmall,
    PaperDollFontHighlightLarge,
    -- 기타
    FriendsFont_Normal,
    FriendsFont_Small,
    FriendsFont_Large,
    FriendsFont_UserText,
    InvoiceFont_Small,
    InvoiceFont_Med,
    InvoiceFont_Large,
    MailFont_Large,
    SpellFont_Small,
    SubSpellFont,
    SubSpellFontRight,
    -- PvP/점수
    AchievementFont_Small,
    AchievementFont_SmallBold,
    AchievementFont_SmallItalic,
    AchievementFont_SmallOutline,
    AchievementFont_SmallShadow,
}

-- 폰트 오브젝트의 폰트와 크기 일괄 변경
local function UpdateGlobalUIFont()
    for _, fontObj in ipairs(fontObjects) do
        if fontObj and fontObj.SetFont then
            fontObj:SetFont(FONT_PATH, GLOBAL_FONT_SIZE, GLOBAL_FONT_FLAGS)
        end
    end

    for _, fontObj in ipairs(fontObjects_Inner) do
        if fontObj and fontObj.SetFont then
            fontObj:SetFont(FONT_PATH, GLOBAL_FONT_SIZE_SMALL, GLOBAL_FONT_FLAGS)
        end
    end

    -- 전문기술 창 내부 동적 항목(레시피 리스트 등) 처리
    if ProfessionsFrame and ProfessionsFrame.RecipeList and ProfessionsFrame.RecipeList.ScrollBox then
        local scrollBox = ProfessionsFrame.RecipeList.ScrollBox
        for i = 1, #scrollBox:GetFrames() do
            local button = scrollBox:GetFrames()[i]
            if button and button.Text then
                button.Text:SetFont(FONT_PATH, GLOBAL_FONT_SIZE_SMALL, GLOBAL_FONT_FLAGS)
            end
        end
    end

    -- 캐릭터창 스탯(종합, 방어, 공격력 등) 항목 처리
    if PaperDollFrame then
        for _, region in ipairs({PaperDollFrame:GetRegions()}) do
            if region and region.SetFont then
                region:SetFont(FONT_PATH, GLOBAL_FONT_SIZE_SMALL, GLOBAL_FONT_FLAGS)
            end
        end
    end

    -- 탭 글자(예: CharacterFrameTab1 등)
    for i = 1, 10 do
        local tab = _G["CharacterFrameTab"..i]
        if tab and tab.Text then
            tab.Text:SetFont(FONT_PATH, GLOBAL_FONT_SIZE, GLOBAL_FONT_FLAGS)
        end
        local profTab = _G["ProfessionsFrameTab"..i]
        if profTab and profTab.Text then
            profTab.Text:SetFont(FONT_PATH, GLOBAL_FONT_SIZE, GLOBAL_FONT_FLAGS)
        end
    end
end

-- UI 로딩 후 폰트 적용
local globalFontFrame = CreateFrame("Frame")
globalFontFrame:RegisterEvent("PLAYER_LOGIN")
globalFontFrame:SetScript("OnEvent", function()
    UpdateGlobalUIFont()
end)

----------------------------------------------------------------------------------------------------
-- 매크로 편집창(에디트박스) 폰트 크기 변경 기능 추가
----------------------------------------------------------------------------------------------------

local MACRO_EDITBOX_FONT_SIZE = 14 -- 원하는 크기로 조정
local MACRO_EDITBOX_FONT_FLAGS = "OUTLINE"

local function UpdateMacroEditBoxFont()
    -- 기본 매크로 창
    if MacroFrame and MacroFrameText then
        MacroFrameText:SetFont(FONT_PATH, MACRO_EDITBOX_FONT_SIZE, MACRO_EDITBOX_FONT_FLAGS)
    end
    -- 드래곤플라이트 이후 MacroFrameText가 없을 수 있으니, EditBox를 직접 탐색
    if MacroFrame and MacroFrame:GetChildren() then
        for _, child in ipairs({MacroFrame:GetChildren()}) do
            if child and child:IsObjectType("EditBox") and child.SetFont then
                child:SetFont(FONT_PATH, MACRO_EDITBOX_FONT_SIZE, MACRO_EDITBOX_FONT_FLAGS)
            end
        end
    end
end

-- 매크로 창이 열릴 때마다 폰트 적용
local macroFontFrame = CreateFrame("Frame")
macroFontFrame:RegisterEvent("PLAYER_LOGIN")
macroFontFrame:SetScript("OnEvent", function(_, event, addon)
    if event == "PLAYER_LOGIN" then
        UpdateMacroEditBoxFont()
    end
end)

-- 매크로 창이 열릴 때마다 폰트 재적용(동적 생성 방지)
hooksecurefunc("ShowMacroFrame", UpdateMacroEditBoxFont)