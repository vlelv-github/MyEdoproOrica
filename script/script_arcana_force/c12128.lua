-- 페이트 오브 아르카나
local s,id=GetID()
function s.initial_effect(c)
	-- 발동
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	-- 2번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY+CATEGORY_COIN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
	-- "아르카나 포스" 테마가 쓰여짐
s.listed_series = {SET_ARCANA_FORCE}
	-- "빛의 결계"의 카드명이 쓰여짐
s.listed_names = {CARD_LIGHT_BARRIER}
	-- 코인 토스를 실행하는 효과를 가짐
s.toss_coin=true
	-- 1번 효과
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.PayLPCost(tp,500)
end
function s.filter(c)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsFaceup() and c:IsMonster() and Arcana.GetCoinResult(c) ~= nil
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and s.filter(tc) then
		local val=Arcana.GetCoinResult(tc)
		if val==COIN_HEADS then
			val = COIN_TAILS
		elseif val==COIN_TAILS then
			val = COIN_HEADS
		end
		Arcana.RegisterCoinResult(tc,val)
		Arcana.SetCoinResult(tc,val)
	end
end
	-- 2번 효과
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local coin=nil
	local at=Duel.GetAttacker()
	if Duel.IsPlayerAffectedByEffect(tp,CARD_LIGHT_BARRIER) then
		local b1 = true
		local b2= at and at:IsFaceup() and at:CanAttack() and at:IsRelateToBattle() and not at:IsStatus(STATUS_ATTACK_CANCELED) 
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
		Duel.NegateAttack()
	elseif coin==COIN_TAILS then
		-- 뒤
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(at:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		at:RegisterEffect(e1)
	end
end