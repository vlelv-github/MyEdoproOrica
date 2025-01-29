-- 앤틱 기어 트리거
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
    -- 2번 효과
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,2})
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end
	-- "앤틱 기어" 카드군임
s.listed_series={SET_ANCIENT_GEAR}
    -- 1번 효과
function s.costfilter(c)
    return c:IsSetCard(0x7) and c:IsAbleToGraveAsCost()
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and re:IsMonsterEffect()
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
    Duel.SendtoGrave(g+e:GetHandler(),REASON_COST)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.spfilter(c,e,tp)
    return c:IsLevelBelow(4) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local cl=e:GetHandler():GetControler()
	Duel.Hint(HINT_SELECTMSG,cl,HINTMSG_SPSUMMON)
    local g1=Duel.SelectMatchingCard(cl,s.spfilter,cl,LOCATION_GRAVE,0,1,1,nil,e,cl)
    if #g1>0 then
        Duel.SpecialSummon(g1,0,cl,cl,false,false,POS_FACEUP)
    end

    Duel.Hint(HINT_SELECTMSG,1-cl,HINTMSG_SPSUMMON)
    local g2=Duel.SelectMatchingCard(1-cl,s.spfilter,1-cl,LOCATION_GRAVE,0,1,1,nil,e,cl)
    if #g2>0 then
        Duel.SpecialSummon(g2,0,1-cl,1-cl,false,false,POS_FACEUP)
    end
end
    -- 2번 효과
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x7) and not c:IsCode(id) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
    end
end