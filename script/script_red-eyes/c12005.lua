-- 집결한 우정
local s,id=GetID()
function s.initial_effect(c)
	-- 룰 상, "붉은 눈" 취급
    c:AddSetcodesRule(id,true,0x3b)
	-- 특소 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1, id) -- 1턴에 1번 발동 가능
	c:RegisterEffect(e1)
	-- check
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	-- search
	local e3 = Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1, {id, 1})
	e3:SetCondition(s.cond)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
s.listed_series={0x3b}
s.listed_name={id}
function s.valcheck(e, c)
	if not c:IsSummonPlayer(e:GetHandlerPlayer()) then return end --자신이 소환했을 때에만 유효
	local g = c:GetMaterial() --소재 정보 가져옴
	if not g or #g == 0 then return end --소재 정보가 있을 때에만 유효
	if g:IsExists(Card.IsType, 1, nil, TYPE_NORMAL) then
		c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
	end
end
function s.cfilter(c)
	return c:GetFlagEffect(id)>0 and (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_XYZ))
end
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c) return c:IsSummonPlayer(tp) and s.cfilter(c) end, 1, nil)
end
function s.ft(c, e, tp)
	return (c:IsSetCard(0x3b) and c:IsSpellTrap() and not c:IsCode(id))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ft,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ft,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end






function s.filter(c,e,tp)
	return ((c:IsLevel(7) and c:IsType(TYPE_NORMAL)) or (c:IsLevelBelow(7) and c:IsSetCard(0x3b))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetOperation(s.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		tc:RegisterEffect(e1,true)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
