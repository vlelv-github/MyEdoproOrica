local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    -- "아마조네스" 몬스터를 서치
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- "아마조네스" 융합 몬스터 소환 시 필드 카드 1장 제외
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.rmcon)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)

    -- "아마조네스" 지속 함정 카드 1장을 세트
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.sttarget)
    e4:SetOperation(s.stactivate)
    c:RegisterEffect(e4)
end

s.listed_series={0x4}
s.listed_name={id}

function s.filter(c)
    return c:IsSetCard(0x4) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    -- "아마조네스" 융합 몬스터가 소환된 경우만 발동
    return eg:IsExists(function(c) return c:IsSetCard(0x4) and c:IsType(TYPE_FUSION) end, 1, nil)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g:Select(tp,1,1,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end

---------- ㅋㅋㅋㅋ -----------

function s.stfilter(c)
	return c:IsSetCard(0x4) and c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsSSetable()
end
function s.sttarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
        return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
end
function s.stactivate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local c, tc=e:GetHandler(),Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc and tc:IsSSetable() and Duel.SSet(tp,tc)>0 then
		--Can be activated this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4))
        e2:SetValue(s.indct)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
	end
end
function s.indct(e,re,r)
	if (r&REASON_BATTLE)>0 then
		return 1
	else return 0 end
end