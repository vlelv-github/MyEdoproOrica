-- 진화융합-에볼루션 퓨전
local s,id=GetID()
function s.initial_effect(c)
	--발동
	local params={
		--fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x14c),
		fusfilter=s.filter,
		matfilter=aux.FALSE,
		extrafil=s.fextra,
		extraop=Fusion.BanishMaterial,
		extratg=s.extratarget,
		chkf=FUSPROC_NOLIMIT
	}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(params),Fusion.SummonEffOP(params)))
	c:RegisterEffect(e1)
end
	-- "화석융합-파슬 퓨전"의 카드명이 쓰여짐
s.listed_names = {CARD_FOSSIL_FUSION}
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	else
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_ONFIELD,0,nil)
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end

function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end

function s.filter(c)
	return c:IsRace(RACE_ROCK) or c:IsRace(RACE_DINOSAUR)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 
		and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>4 end
end
function s.operation(oldtg,oldop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if not (Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 
			and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>4) then return end
		Duel.ConfirmDecktop(tp,5)
		Duel.ConfirmDecktop(1-tp,5)
		local g1=Duel.GetDecktopGroup(tp,5):Select(tp,1,1,nil)
		local g2=Duel.GetDecktopGroup(1-tp,5):Select(tp,1,1,nil)
		g1:Merge(g2)
		Duel.SendtoGrave(g1,REASON_EFFECT|REASON_EXCAVATE)
		if oldtg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			oldop(e,tp,eg,ep,ev,re,r,rp)
		else
			local tc=g1:Filter(Card.IsControler,nil,tp):GetFirst()
			if tc and tc:IsLocation(LOCATION_GRAVE) then
				--융합 효과 적용 안하면 디메리트 부여
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetCode(EFFECT_CANNOT_ACTIVATE)
				e1:SetTargetRange(1,0)
				e1:SetValue(s.aclimit)
				e1:SetLabelObject(tc)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CANNOT_TRIGGER)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
end
function s.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
function s.aclimit(e,re,tp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(tc:GetCode())
end