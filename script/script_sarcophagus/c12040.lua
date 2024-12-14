-- 명계의 황금궤
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.discon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
	-- "빛의 황금궤"의 카드명이 쓰여짐
s.listed_names={CARD_SHINING_SARCOPHAGUS}
	-- 1번 효과
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.tffilter(c,tp)
	return c:IsCode(CARD_SHINING_SARCOPHAGUS) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct = Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	if chk==0 then return ct>0
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
	-- 2번 효과
function s.filter(c,code)
	return c:IsFacedown() and c:IsAbleToHand() and c:IsCode(code)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 빛금궤 있어야 함
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SHINING_SARCOPHAGUS),tp,LOCATION_ONFIELD,0,1,nil) then return false end
	-- 빛금궤 관련 몬스터도 있어야 함
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.ListsCode,CARD_SHINING_SARCOPHAGUS),tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 상대가 효과를 발동했을 때
	if not (rp==1-tp) then return false end
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil,tc:GetCode())
    if chk==0 then return #g>0 end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg=g:Select(tp,1,1,nil)
    Duel.ConfirmCards(1-tp,sg) -- 발동 코스트로 카드 공개
    e:SetLabelObject(sg:GetFirst()) -- 선택된 카드를 저장
    
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
    local sc=e:GetLabelObject() -- 타겟이 된 제외 상태의 카드

    if sc and Duel.NegateActivation(ev) and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
        Duel.SendtoHand(sc,tp,REASON_EFFECT) -- 선택된 카드를 패에 추가
    end
end