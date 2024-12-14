-- 틴당글 타오
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)

	-- 추가 소환 조건
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetTargetRange(1,0)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)

	--  1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tftg)
	e2:SetOperation(s.tfop)
	c:RegisterEffect(e2)
end	
	-- "틴당글" 테마가 쓰여짐
s.listed_series={0x10b}
	-- "틴당글 베이스 가드너", "메일의 계단"의 카드명이 쓰여짐
s.listed_names={94365540,19671102}
	-- 소환 조건
function s.matfilter(c,lc,stype,tp)
	return c:IsSetCard(0x10b) and not c:IsType(TYPE_LINK)
end
	-- 추가 소환 조건
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			return Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
		end
	end
end

	-- 1번 효과
	-- 베이스 가드너를 소재로 링크 소환했을 경우
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and #c:GetMaterial():Filter(Card.IsCode,nil,94365540) > 0
end
	-- 리버스 효과의 발동 조건을 만족하는 리버스 몬스터를 필터링
function s.flip_filter(c,e,tp,eg,ep,ev,re,r,rp)
    return c:IsType(TYPE_FLIP) and s.activable(c,e,tp,eg,ep,ev,re,r,rp)
end
    -- 리버스 효과의 발동 조건을 만족하는지의 여부
function s.activable(c,e,tp,eg,ep,ev,re,r,rp)
    local effs = {c:GetOwnEffects()}
    for k,eff in ipairs(effs) do
        if bit.band(eff:GetType(), EFFECT_TYPE_FLIP) ~= 0 then
            local tg=eff:GetTarget()
            local op=eff:GetOperation()
            if tg then
                if tg(e,tp,eg,ep,ev,re,r,rp,0) then
                    return true
                else
                    return false
                end
            end
        end
    end
    return false
end
	-- 덱에서 리버스 몬스터를 코스트로 묘지로 보냄
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.flip_filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,
        e,tp,eg,ep,ev,re,r,rp) end
    
    local g=Duel.SelectMatchingCard(tp,s.flip_filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,
        e,tp,eg,ep,ev,re,r,rp)
    local tc=g:GetFirst()
		-- 묘지로 보낸 몬스터가 가진 효과를 순회하여
    local effs = {tc:GetOwnEffects()}
    for k,eff in ipairs(effs) do
		-- 효과 타입이 리버스 효과인 경우,
        if bit.band(eff:GetType(), EFFECT_TYPE_FLIP) ~= 0 then
            -- 그 효과를 레이블 오브젝트에 저장
            e:SetLabelObject(eff)
        end
    end
	
    if tc then
        Duel.SendtoGrave(tc,REASON_COST)
    end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local te=e:GetLabelObject()
    local tg=te and te:GetTarget() or nil
    if chkc then return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
    if chk==0 then return true end
    e:SetProperty(te:GetProperty())
    if tg then
        tg(e,tp,eg,ep,ev,re,r,rp,chk)
    end
    e:SetLabelObject(te)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
    if not te then return end
    local op=te:GetOperation()
    if op then
        op(e,tp,eg,ep,ev,re,r,rp)
    end
    e:SetLabel(0)
    e:SetLabelObject(nil)
end
	-- 2번 효과
function s.tffilter(c,tp)
	return c:IsCode(19671102) and not c:IsForbidden() and c:IsSSetable()
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end