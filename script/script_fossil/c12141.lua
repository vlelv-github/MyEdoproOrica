-- 오리하르콘의 눈
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- 2번 효과
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0,1)
    e2:SetCondition(s.condition)
    e2:SetTarget(s.splimit)
    c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,{id,1})
    e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCondition(s.condition2)
    e3:SetTarget(s.target2)
    e3:SetOperation(s.operation2)
    c:RegisterEffect(e3)
end
	-- "화석융합-파슬 퓨전"의 카드명이 쓰여짐
s.listed_names = {CARD_FOSSIL_FUSION}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return (c:IsRace(RACE_ROCK) or c:IsRace(RACE_PYRO)) and c:IsMonster() and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end

function s.condition(e)
    return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, CARD_FOSSIL_FUSION) -- 특정 카드 ID
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return sumtype==SUMMON_TYPE_FUSION-- and c:IsLocation(LOCATION_MZONE) -- 필드의 몬스터를 소재로 사용하려는 경우 제한
end


-- 효과가 발동할 조건 (암석족/화염족 몬스터가 제외되었을 때)
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return #eg:Filter(s.is_rock_or_pyro,nil,tp) > 0
end

-- 암석족 또는 화염족 몬스터 판별 함수
function s.is_rock_or_pyro(c,tp)
    return (c:IsRace(RACE_ROCK) or c:IsRace(RACE_PYRO)) and c:IsControler(tp) and c:IsFaceup()
end

-- 타겟 설정 (대상 몬스터는 제외된 암석족/화염족 몬스터)
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local g=eg:Filter(s.is_rock_or_pyro,nil,tp)
    if chk==0 then return g:GetCount()>0 end
    local tc = Duel.SetTargetCard(g:Select(tp,1,1,nil))
    -- 제외된 몬스터의 종족에 따른 제외된 몬스터 수에 기반한 데미지 계산
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

-- 효과 발동 (데미지 및 파괴 처리)
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

    -- 데미지 입히기
	local g = Duel.GetMatchingGroup(s.damfilter,tp,LOCATION_REMOVED,0,nil,tc:GetRace())
	local gg = Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		-- 데미지가 1000 이상일 경우 상대 필드의 몬스터 파괴
		if Duel.Damage(1-tp,#g*300,REASON_EFFECT) >= 1000 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=gg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
function s.damfilter(c, race)
	return c:IsRace(race) and c:IsFaceup()
end