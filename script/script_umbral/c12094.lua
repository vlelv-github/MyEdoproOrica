-- RUM(랭크 업 매직)-카오스 드레인 사우전드
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	-- "No.", "CNo.(카오스 넘버즈)" 테마가 쓰여짐
s.listed_series={0x48,0x1048}
function s.filter(c,e,tp)
	local m = c:GetMetatable(true)
	return c:IsSetCard(0x48) and not c:IsSetCard(0x1048) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,m.xyz_number)
end
function s.filter2(c,e,tp,mc,no)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return c:IsSetCard(0x1048) and c.xyz_number==no and mc:IsCanBeXyzMaterial(c,tp)
	and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
	-- 통상 소환 불가
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,4),nil)

	local no = Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local m = no:GetFirst():GetMetatable(true)
	local cno = Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,no:GetFirst(),m.xyz_number)
	
	Duel.ConfirmCards(1-tp,no)
	Duel.ConfirmCards(1-tp,cno)
	no:GetFirst():CreateEffectRelation(e)
	no:AddCard(cno)
	no:KeepAlive()
	e:SetLabelObject(no)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	and	Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsChainDisablable(0) then
		local ex=Duel.GetMatchingGroup(function(c) return c:IsSetCard(0x48) end,tp,0,LOCATION_EXTRA,nil)
		if #ex>=2 and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
			local sg=ex:Select(1-tp,2,2,nil)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			Duel.NegateEffect(0)
			return
		end
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local c=e:GetHandler()
	local g=e:GetLabelObject():Filter(s.filter,nil,e,tp)
	local m = g:GetFirst():GetMetatable(true)
	if g and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then 
		local g2=e:GetLabelObject():Filter(s.filter2,nil,e,tp,g:GetFirst(),m.xyz_number):GetFirst()
		if g2 then 
			g2:SetMaterial(g)
			Duel.Overlay(g2,g)
			Duel.SpecialSummon(g2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			g2:CompleteProcedure()
		end
	end
end