-- 아마조네스 발키리어
local s,id=GetID()
function s.initial_effect(c)
    Fusion.AddProcMix(c,true,true,s.matfilter,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH))
	c:EnableReviveLimit()
	-- 융합 효과
	local params = {fusfilter=s.fusfilter,matfilter=Fusion.OnFieldMat(Card.IsAbleToDeck),extrafil=s.fextra,extraop=Fusion.ShuffleMaterial}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
	--Other "Amazoness" cards cannot be targted by opponent's card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(function(e,c) return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x4) end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Other "Amazoness" cards cannot be destroyed by opponent's card effects
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- Negate effect activation
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)

end
s.listed_series={0x4}
s.listed_name={id}
function s.matfilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:IsSetCard(0x4,fc,sumtype,tp)
end
function s.fusfilter(c)
	return c:IsSetCard(0x4) and not c:IsCode(id)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and ep ~= tp and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, eg, 1, 0, 0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.SendtoDeck(re:GetHandler(), nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end