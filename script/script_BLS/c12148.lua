-- 혼돈의 주술사-블랙 카오스 소서러
local s,id=GetID()
function s.initial_effect(c)
    -- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Ritual.CreateProc({
		handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0xcf),desc=aux.Stringid(id,1),
		extrafil=s.extrafil,extratg=s.extratg,matfilter=s.matfilter,location=LOCATION_HAND+LOCATION_GRAVE})
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsRitualSummoned() end)
	c:RegisterEffect(e2)

end
    -- "카오스 폼" "카오스 솔저"의 카드명이 쓰여짐
s.listed_names = {21082832, 5405694}
	-- "카오스 솔저", "카오스"의 테마명이 쓰여짐
s.listed_series = {SET_BLACK_LUSTER_SOLDIER, 0xcf}

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
	return c:ListsArchetype(SET_BLACK_LUSTER_SOLDIER) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.cfilter(c)
	return c:IsAbleToRemove() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsMonster()
end
function s.extrafil(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_GRAVE)
end