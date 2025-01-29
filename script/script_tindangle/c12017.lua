-- 차머스의 보석
local s,id=GetID()
function s.initial_effect(c)
	-- 발동
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 묘지 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FLIP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
s.listed_series={0x10b}
s.listed_names={94365540}
-- 코스트: 패와 덱에서 "틴당글" 카드를 각각 1장씩 묘지로 보낸다.
function s.tgfilter(c,tp)
    return c:IsSetCard(0x10b) and not c:IsCode(id) and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- 덱에 남아있는 "틴당글 베이스 가드너"의 수를 확인
        local gardner_count=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_DECK,0,nil,94365540)
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil,tp)
            and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tp)
            and gardner_count>0
    end
    -- 패에서 "틴당글" 카드 1장 묘지로 보내기
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
    Duel.SendtoGrave(g1,REASON_COST)

    -- 덱에 남아있는 "틴당글 베이스 가드너"의 수를 다시 확인
    local gardner_count=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_DECK,0,nil,94365540)

    -- 덱에서 "틴당글" 카드 1장 묘지로 보내기
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=nil
    if gardner_count>1 then
        g2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    else
        g2=Duel.SelectMatchingCard(tp,function(c) return s.tgfilter(c,tp) and c:GetCode()~=94365540 end,tp,LOCATION_DECK,0,1,1,nil,tp)
    end
    Duel.SendtoGrave(g2,REASON_COST)
end

-- 서치할 카드 필터
function s.thfilter1(c)
    return c:IsSetCard(0x10b) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_FLIP) and c:IsAbleToHand()
end

function s.thfilter2(c)
    return c:IsCode(94365540) and c:IsAbleToHand() -- "틴당글 베이스 가드너" 카드 코드
end

-- 효과 발동 조건 설정
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

-- 효과 발동
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- 덱에서 "틴당글" 리버스 몬스터 1장 서치
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g1>0 then
        Duel.SendtoHand(g1,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g1)
    end
    
    -- 덱에서 "틴당글 베이스 가드너" 1장 서치
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g2>0 then
        Duel.SendtoHand(g2,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g2)
    end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
function s.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end