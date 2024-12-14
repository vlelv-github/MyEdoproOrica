-- 시계신제 타미온
local s,id=GetID()
function s.initial_effect(c)
	-- 소환 제한
	c:EnableReviveLimit()
	-- 1턴에 1장만 소환 가능
	c:SetSPSummonOnce(id)
	-- 소환 조건
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x4a),1,1)
	-- 1번 효과
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_SUMMON)
	e0:SetCondition(s.dscon)
	e0:SetCost(s.cost)
	e0:SetTarget(s.dstg)
	e0:SetOperation(s.dsop)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e1)
	-- 2번 효과 (전투 파괴 내성)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 2번 효과 (효과 파괴 내성)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 3번 효과
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
	-- 전투를 실행한 자신의 "시계신" 몬스터 수를 카운팅
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetCondition(s.checkcon)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
	-- "시계신"의 테마가 쓰여짐
s.listed_series = {0x4a}
	-- "시계신제 타미온"의 카드명이 쓰여짐
s.listed_names = {id}
	-- 1번 효과
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
	-- 3번 효과
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 파괴할 카드 수 결정 및 파괴 대상 선택
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local count = Duel.GetFlagEffect(0,id)
	if chk == 0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,count,1-tp,LOCATION_HAND)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local count = Duel.GetFlagEffect(0,id)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if count > #g then
		count = #g
	end
    if count>0 then
		local sg = g:Select(tp,1,count,nil)
		Duel.HintSelection(sg,true)
        Duel.Destroy(sg,REASON_EFFECT)
    end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	local at = Duel.GetAttacker()
	if at:IsControler(1-tp) then
		at = Duel.GetAttackTarget()
	end
	return at and at:IsControler(tp) and at:IsSetCard(0x4a) and at:IsFaceup()
end