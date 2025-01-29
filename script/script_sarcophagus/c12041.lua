-- 결투왕의 문
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetValue(CARD_SHINING_SARCOPHAGUS)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.ListsCode,CARD_SHINING_SARCOPHAGUS))
	c:RegisterEffect(e2)
	-- 3번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end
	-- "빛의 황금궤"의 카드명이 쓰여짐
s.listed_names={CARD_SHINING_SARCOPHAGUS}
	-- 3번 효과
function s.filter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove(tp,POS_FACEDOWN)
	and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,c:GetRace(),c:GetAttribute(),c:GetCode())
end

function s.filter2(c,race,attribute,code)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() 
		and (c:IsRace(race) or c:IsAttribute(attribute))
		and not c:IsCode(code) and c:ListsCode(CARD_SHINING_SARCOPHAGUS) -- "빛의 황금궤" 세트 카드 필터
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp) end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.ConfirmCards(1-tp,tc)
		if Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			local race=tc:GetRace()
			local attribute=tc:GetAttribute()
			local code=tc:GetCode()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,race,attribute,code)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end