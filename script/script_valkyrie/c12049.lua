-- 왈큐레의 선고
local s,id=GetID()
function s.initial_effect(c)
	-- 발동
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.con)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
	-- 왈큐레 카드군
s.listed_series={SET_VALKYRIE}
	-- 1번 효과
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and (r&REASON_RULE)~=0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_VALKYRIE),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	e:SetLabel(Duel.SelectOption(tp,70,71,72))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local tc=g:GetFirst()
	if g and #g>0 then
		Duel.ConfirmCards(tp,g)
		local opt=e:GetLabel()
		if (opt==0 and tc:IsMonster()) or (opt==1 and tc:IsSpell()) or (opt==2 and tc:IsTrap()) then
			if c:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) then
				Duel.Damage(1-tp,1000,REASON_EFFECT)
			end
		end
	end
end
	-- 2번 효과
function s.cfilter(c,tp)
	return c:IsPreviousControler(1-tp)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and r&REASON_EFFECT==REASON_EFFECT
		and (re:GetHandler():IsSetCard(SET_VALKYRIE) or re:GetHandler():GetType()==TYPE_CONTINUOUS+TYPE_SPELL)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local ct=eg:FilterCount(s.cfilter,nil,tp)
	Duel.Recover(tp,ct*500,REASON_EFFECT)
end