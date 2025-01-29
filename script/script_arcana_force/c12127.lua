-- 아르카나 포스 X-휠 오브 포츈
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
	-- "아르카나 포스" 테마가 쓰여짐
s.listed_series = {SET_ARCANA_FORCE}
	-- "빛의 결계"의 카드명이 쓰여짐
s.listed_names = {CARD_LIGHT_BARRIER}
	-- 코인 토스를 실행하는 효과를 가짐
s.toss_coin=true
	-- 1번 효과
function s.spcon(e,c)
	if c==nil then return true end
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
	-- 2번 효과
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,sg,#sg,tp,0)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.setfilter(c)
	return c:IsCanTurnSet() and c:IsFaceup()
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local coin=nil
	if Duel.IsPlayerAffectedByEffect(tp,CARD_LIGHT_BARRIER) then
		local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		local op=Duel.SelectEffect(tp,
			{b1,aux.GetCoinEffectHintString(COIN_HEADS)},
			{b2,aux.GetCoinEffectHintString(COIN_TAILS)})
		if not op then return end
		coin=op==1 and COIN_HEADS or COIN_TAILS
	else
		coin=Duel.TossCoin(tp,1)
	end
	if coin==COIN_HEADS then
		-- 앞
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	elseif coin==COIN_TAILS then
		-- 뒤
		local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end