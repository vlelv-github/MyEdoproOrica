-- 바렐 더블액션
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	-- "바렐" 카드군에 속함
s.listed_series={0x10f}
	-- 묘지 특소 필터
function s.spgfilter(c,e,tp)
	return (c:IsSetCard(0x102) or c:IsSetCard(0x10f)) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	-- 엑덱 특소 필터 (필드 대상)
function s.spefilter1(c,e,tp)
	return c:IsSetCard(0x10f) and c:IsLinkMonster() and c:GetLink()==4 and c:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(s.spefilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode()) 
end
	-- 엑덱 특소 필터 (엑덱에서 꺼낼 몬스터 필터)
function s.spefilter2(c,e,tp,code)
	return c:IsSetCard(0x10f) and c:IsLinkMonster() and c:GetLink()==4 and not c:IsCode(code)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spgfilter(chkc,e,tp) end
	local b1=Duel.IsExistingTarget(s.spgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=Duel.IsExistingTarget(s.spefilter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.spefilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (b1 or b2) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetProperty(0)
		local g=Duel.SelectTarget(tp,s.spefilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if op==1 and ft>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 and ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.GetFirstTarget()
		local g=Duel.SelectMatchingCard(tp,s.spefilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetCode())
		if #g>0 then
			Duel.SpecialSummon(g,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
		end
	end
end
