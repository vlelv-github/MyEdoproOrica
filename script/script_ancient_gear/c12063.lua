-- 앤틱 기어 오퍼레이션
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
    -- 2번 효과
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- 3번 효과
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end
	-- "앤틱 기어" 카드군임
s.listed_series={SET_ANCIENT_GEAR}
    -- 1번 효과
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44052075,0x7,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44052075,0x7,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44052075,0x7,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44052075,0x7,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,1-tp) then
		local tk1=Duel.CreateToken(tp,44052075)
		local tk2=Duel.CreateToken(tp,44052075)
		Duel.SpecialSummonStep(tk1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(tk2,0,tp,1-tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end
    -- 2번 효과
-- 상대 필드에 몬스터가 존재할 경우 발동 조건
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
end

-- "앤틱 기어" 몬스터를 특수 소환하는 대상 설정
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- "앤틱 기어" 몬스터를 소환 조건을 무시하고 특수 소환
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
end

-- "앤틱 기어" 몬스터 필터 (0x7은 "앤틱 기어"의 코드)
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x7) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

-- 마법 & 함정 존에서 파괴되었을 때 발동하는 조건
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end

-- 특수 소환 대상 설정
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    if chk==0 then
        return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
end

-- 특수 소환 처리
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE,nil)
    local mz=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if mz<ct then
        ct=mz
    end
    if ct>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,ct,nil,e,tp)
        if #g>0 then
            for tc in aux.Next(g) do
                Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
            end
        end
    end
end