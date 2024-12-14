-- Evil★Twin(이빌트윈) 해킹
local s,id=GetID()
function s.initial_effect(c)
	-- 발동
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EVIL_TWIN))
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 2번 효과
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end
	-- "키스킬", "리일라", "라이브트윈", "이빌트윈" 테마가 쓰여짐
s.listed_series = {SET_KI_SIKIL,SET_LIL_LA,SET_LIVE_TWIN,SET_EVIL_TWIN}

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end

function s.cfilter(c, e, tp)
    return (c:IsSetCard(SET_LIVE_TWIN) or c:IsSetCard(SET_EVIL_TWIN)) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return (c:IsSetCard(SET_KI_SIKIL) or c:IsSetCard(SET_LIL_LA)) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,e,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.Release(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local code=e:GetLabel()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,code)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- -- 상대 몬스터의 효과가 발동했을 때
-- function s.negcon(e, tp, eg, ep, ev, re, r, rp)
--     return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
-- end

-- -- 자신 필드의 "라이브트윈" 또는 "이빌트윈" 몬스터 1장을 릴리스
-- function s.cfilter(c, e, tp)
--     return (c:IsSetCard(SET_LIVE_TWIN) or c:IsSetCard(SET_EVIL_TWIN)) and c:IsReleasable()
-- end
-- function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
--     if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil, e, tp) end
--     Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
--     local g=Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)
--     local tc=g:GetFirst()
--     e:SetLabel(tc:GetCode())
--     Duel.Release(g, REASON_COST)
-- end

-- -- 효과 무효화 및 파괴 후 묘지에서 특수 소환
-- function s.spfilter(c, code, e, tp)
--     return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and (c:IsSetCard(SET_KI_SKIL) or c:IsSetCard(SET_LIL_LA))
--         and not c:IsCode(code)
-- end
-- function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
-- 	Debug.Message(e:GetLabel())
--     if chk==0 then
--         return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
--             and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e:GetLabel(), e, tp)
--     end
--     Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
--     Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
--     Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
-- end

-- function s.negop(e, tp, eg, ep, ev, re, r, rp)
--     -- 무효화 및 파괴
--     if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
--         Duel.Destroy(eg, REASON_EFFECT)
--     end

--     -- 묘지에서 특수 소환
--     if Duel.GetLocationCount(tp, LOCATION_MZONE)>0 then
--         local g=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_GRAVE, 0, 1, 1, nil, e:GetLabel(), e, tp)
--         if #g>0 then
--             Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
--         end
--     end
-- end