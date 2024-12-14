-- 프레데터 플랜츠 바실리캔토스
local s,id=GetID()
function s.initial_effect(c)
	-- 펜듈럼 소환
	Pendulum.AddProcedure(c)
	-- 1번 펜듈럼 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pccon)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	-- 1번 몬스터 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
	-- 2번 몬스터 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.recon)
	e3:SetTarget(s.retg)
	e3:SetOperation(s.reop)
	c:RegisterEffect(e3)
end
	-- "프레데터 플랜츠" 카드군이 쓰여짐
s.listed_series={0x10f3}
	-- 1번 펜듈럼 효과
function s.pcfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and c:IsType(TYPE_PENDULUM) and not c:IsCode(id)
	and Duel.IsExistingMatchingCard(s.pcfilter2,tp,LOCATION_DECK,0,1,c,e,tp,c:GetLeftScale())
end
function s.pcfilter2(c,e,tp,scale)
	return c:IsSetCard(0x10f3) and c:IsType(TYPE_PENDULUM) and not c:IsCode(id) 
	and c:GetLeftScale() ~= scale
end
function s.pccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0) == 1
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0) == 1 then return end
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g1=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g1==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g2=Duel.SelectMatchingCard(tp,s.pcfilter2,tp,LOCATION_DECK,0,1,1,g1,e,tp,g1:GetFirst():GetLeftScale())
		if #g2==0 then return end
		Duel.MoveToField(g1:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		Duel.MoveToField(g2:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
	-- 1번 몬스터 효과
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:GetCounter(COUNTER_PREDATOR)>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
	-- 2번 몬스터 효과
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_FUSION)==REASON_FUSION and c:IsFaceup()
		and c:IsLocation(LOCATION_GRAVE+LOCATION_EXTRA) 
end
function s.refilter(c,e,tp)
	return (c:IsSetCard(0x10f3) or (c:IsLevelAbove(8) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_FUSION)))
		and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.refilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end