-- 프레데터 플레이
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
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.atttg)
	c:RegisterEffect(e2)
	-- 2번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	-- 필드의 카드가 벗어날 때 포식 카운터를 저장
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_LEAVE_FIELD_P)
    e6:SetRange(LOCATION_SZONE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e6:SetOperation(s.pre_grave)
    c:RegisterEffect(e6)
	-- 3번 효과
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2)) -- 효과 설명
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.condition)
    e4:SetTarget(s.target)
    e4:SetOperation(s.operation)
	e4:SetLabelObject(e6)
    c:RegisterEffect(e4)
end
	-- "융합", "퓨전" 테마가 쓰여짐
s.listed_series={0x46}
	-- 포식 카운터를 놓음
s.counter_place_list={COUNTER_PREDATOR}
	-- 1번 효과
function s.atttg(e,c)
	return c:GetCounter(COUNTER_PREDATOR)>0 
end
	-- 2번 효과
function s.lvcon(e)
	return e:GetHandler():GetCounter(COUNTER_PREDATOR)>0
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsCanAddCounter(COUNTER_PREDATOR,1) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,COUNTER_PREDATOR,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,COUNTER_PREDATOR,1)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(COUNTER_PREDATOR,1) and tc:GetLevel()>1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
	-- 3번 효과
function s.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSummonPlayer(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and e:GetLabelObject():GetLabel()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.filter(c)
    return c:IsType(TYPE_SPELL) and c:IsSetCard(0x46) and c:IsSSetable() -- "융합" 또는 "퓨전" 필터
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SSet(tp,tc)
        if tc:IsType(TYPE_QUICKPLAY) then
            -- 세트한 턴에 발동 가능하게 설정
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT) -- 1장 드로우
    end
end
	-- 포식 카운터 기록
function s.pre_grave(e,tp,eg,ep,ev,re,r,rp)
	local tc = eg:GetFirst()
	while tc do
		if tc:GetCounter(COUNTER_PREDATOR) > 0 then
			e:SetLabel(tc:GetCounter(COUNTER_PREDATOR))
		end
		tc = eg:GetNext()
	end

end