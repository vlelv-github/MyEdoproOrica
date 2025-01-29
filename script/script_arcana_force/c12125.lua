-- 아르카나 라이트
local s,id=GetID()
function s.initial_effect(c)
	-- 발동
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_COIN+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	-- "아르카나 포스" 테마가 쓰여짐
s.listed_series = {SET_ARCANA_FORCE}
	-- "빛의 결계"의 카드명이 쓰여짐
s.listed_names = {73206827}
	-- 코인 토스를 실행하는 효과를 가짐
s.toss_coin=true
function s.cfilter(c)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c)
	return c.toss_coin and not c:IsCode(id) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,g)
		local coin = nil
		Duel.BreakEffect()
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then 
			local dr = Duel.IsPlayerCanDraw(1-tp,1)
			local op=Duel.SelectEffect(tp,
			{true,aux.GetCoinEffectHintString(COIN_HEADS)},
			{dr,aux.GetCoinEffectHintString(COIN_TAILS)})
			if not op then return end
			coin=op==1 and COIN_HEADS or COIN_TAILS
		else 
			coin=Duel.TossCoin(tp,1)
		end
		if coin==COIN_HEADS then
			-- 자신 필드 존의 카드는 효과로는 파괴되지 않음
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetTargetRange(LOCATION_FZONE,0)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		elseif coin==COIN_TAILS then
			-- 상대는 덱에서 1장 드로우
			Duel.Draw(1-tp,1,REASON_EFFECT)
		end
	end
end
