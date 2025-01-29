-- 뱀파이어 데이라이트
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	-- "뱀파이어" 테마가 쓰여짐
s.listed_series = {0x8e}
function s.filter1(c,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(5)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.filter2(c,tp)
	local atk = c:GetAttack()
	return c:IsSetCard(0x8e) and c:IsMonster() 
	and Duel.IsExistingTarget(s.filter3, tp,0,LOCATION_MZONE,1,nil,atk) 
end
function s.filter3(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter2(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local tg=Duel.GetMatchingGroup(s.filter3,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	local ct = Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct < #tg then 
		tg = tg:Select(tp,ct,ct,nil)
	end
	if #tg>0 then 
		for sc in aux.Next(tg) do
			Duel.GetControl(sc,tp)

			

			-- 언데드족 취급
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_ZOMBIE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
		-- 다음 턴의 엔드 페이즈에 묘지로 보내짐
		local turn_ct=Duel.GetTurnCount()
		aux.DelayedOperation(tg,PHASE_END,id,e,tp,
			function(ag)
				Duel.SendtoGrave(ag,REASON_EFFECT)
			end,
			function()
				return Duel.GetTurnCount()==turn_ct+1
			end,
			nil,2
		)
	end

end