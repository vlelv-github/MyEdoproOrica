-- 성마수 밀레니엄 셀케트
local s,id=GetID()
function s.initial_effect(c)
	-- 융합 소재
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,89194033,aux.FilterBoolFunctionEx(Card.IsType,TYPE_NORMAL))
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 2번 효과
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetOperation(s.special_summon_op)
    c:RegisterEffect(e2)
	-- 3번 효과
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end
	-- "왕가의 신전", "신성한 몬스터 셀케트"의 카드명이 쓰여짐
s.listed_names={29762407, 89194033}

function s.thfilter(c)
	return (c:IsCode(29762407) or c:ListsCode(29762407)) and c:IsAbleToHand()
end
	-- 1번 효과
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
	-- 2번 효과
-- "왕가의 신전"의 효과로 특수 소환된 카드를 플래그로 추적
function s.special_summon_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if re and re:GetHandler():IsCode(29762407) then -- "왕가의 신전" 카드 확인
        c:RegisterFlagEffect(29762407,RESET_EVENT+RESETS_STANDARD,0,1)
    end
    -- 상대 묘지에서 몬스터를 특수 소환할 수 없게 하는 효과
    if c:GetFlagEffect(29762407)~=0 then
        s.effect_prevent_special_summon(c)
    end
end

-- 상대가 묘지에서 몬스터를 특수 소환할 수 없게 하는 효과
function s.effect_prevent_special_summon(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,LOCATION_GRAVE)
    e1:SetTarget(s.splimit)
    e1:SetCondition(s.spcon)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    Duel.RegisterEffect(e1,c:GetControler())
end

-- 특수 소환 제한 대상: 상대 묘지의 몬스터
function s.splimit(e,c)
    return c:IsLocation(LOCATION_GRAVE)
end

-- 이 카드가 "왕가의 신전" 효과로 특수 소환된 경우 필드에 있는 동안 적용
function s.spcon(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_MZONE) and c:GetFlagEffect(29762407)~=0
end
	-- 3번 효과
-- 상대의 패에서 몬스터가 있는지 확인하고, 그 중 하나를 제외
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end

-- 상대 패에서 몬스터를 제외하고, 그 몬스터의 공격력만큼 자신의 몬스터 공격력 상승
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #hg>0 then
        Duel.ConfirmCards(tp,hg) -- 상대 패 공개
        local sg=hg:Filter(Card.IsMonster,nil) -- 몬스터 카드 필터링
        if #sg>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local tc=sg:Select(tp,1,1,nil):GetFirst()
            if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
                local atk=tc:GetAttack()
                if atk>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
                    -- 공격력 상승 처리
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_UPDATE_ATTACK)
                    e1:SetValue(atk)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    c:RegisterEffect(e1)
                end
            end
        end
        Duel.ShuffleHand(1-tp) -- 패 섞기
    end
end