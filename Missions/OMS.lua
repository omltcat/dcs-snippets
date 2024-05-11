oms = {}
oms.players = {}
oms.playerUnitNames = {}
oms.challenger = 'No Unit'
oms.metric = false

function oms.updatePlayerUnits()
	if #oms.players == 0 then
		oms.playerUnitNames = mist.getUnitsByAttribute({skill = 'Client'})
	else
		oms.playerUnitNames = mist.makeUnitTable(oms.players)
	end
	--trigger.action.outText('玩家列表人数  '..#oms.playerUnitNames,1)
end

function oms.getUnitNames(UNT)
	local unitNames
	if UNT then
		unitNames = mist.makeUnitTable(UNT)
	else
		unitNames = oms.playerUnitNames
	end
	return unitNames
end

function oms.getUnitIDs(unitNames, zoneNames)
	local unitIDs = {}
	if zoneNames then
		unitIDs = mist.getUnitsInZones(unitNames, zoneNames)
	else
		for i = 1, #unitNames do
			local u = Unit.getByName(unitNames[i])
			if u then
				unitIDs[i] = u
			end
		end
	end
	return unitIDs
end

function oms.validFlagVal(value, valueType)
	valueType = valueType or 'raw'
	if not oms.metric then
		if valueType == 'alt' then
			value = mist.utils.metersToFeet(value)
		elseif valueType == 'spd' then
			value = mist.utils.mpsToKnots(value)
		elseif valueType == 'vs' then
			value = value * 196.850394
		end
	end
	value = math.floor(value + 0.5)
	if value <= 1 then
		value = 1
	end
	return value
end

function oms.validFlagHdg(hdg)
	hdg = math.floor(hdg + 0.5)
	if hdg < 0 then
		hdg = hdg + 360
	elseif hdg == 0 then
		hdg = 360
	end
	return hdg
end

function oms.setFlag(flag, value)
	flag = flag or 'omsNullFlag'
	value = value or 0
	oms.setFlag(flag, value)
end

function oms.inZone(zoneNames, flag, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local unitsInZone = mist.getUnitsInZones(unitNames, zoneNames)
	oms.setFlag(flag, #unitsInZone)
	return #unitsInZone
end

function oms.inMvZone(zoneUnitNames, zoneRadius, zoneType, flag, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local unitsInZone = mist.getUnitsInMovingZones(unitNames, zoneUnitNames, zoneRadius, zoneType)
	oms.setFlag(flag, #unitsInZone)
	return #unitsInZone
end

function oms.maxASL(flag, zoneNames, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local unitIDs = oms.getUnitIDs(unitNames, zoneNames)
	local maxAlt = 0
	if #unitIDs > 0 then 
		for i = 1, #unitIDs do
			local pos = unitIDs[i]:getPosition().p
			if pos.y > maxAlt then
				maxAlt = pos.y
			end
		end
		maxAlt = oms.validFlagVal(maxAlt, 'alt')
	end
	oms.setFlag(flag, maxAlt)
	return maxAlt
end

function oms.maxAGL(flag, zoneNames, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local unitIDs = oms.getUnitIDs(unitNames, zoneNames)
	local maxAlt = 0
	if #unitIDs > 0 then 
		for i = 1, #unitIDs do
			local pos = unitIDs[i]:getPosition().p
			local AGL = pos.y - land.getHeight({x=pos.x, y=pos.z})
			if AGL > maxAlt then
				maxAlt = AGL
			end
		end
		maxAlt = oms.validFlagVal(maxAlt, 'alt')
	end
	oms.setFlag(flag, maxAlt)
	return maxAlt
end

function oms.minASL(flag, zoneNames, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local unitIDs = oms.getUnitIDs(unitNames, zoneNames)
	--trigger.action.outText(tostring(#unitIDs),1)
	local minAlt = 10000000
	if #unitIDs > 0 then 
		for i = 1, #unitIDs do
			local pos = unitIDs[i]:getPosition().p
			if pos.y < minAlt then
				minAlt = pos.y
			end
		end
		minAlt = oms.validFlagVal(minAlt, 'alt')
	end
	if minAlt == 10000000 then
		minAlt = 0
	end
	oms.setFlag(flag, minAlt)
	return minAlt
end

function oms.minAGL(flag, zoneNames, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local unitIDs = oms.getUnitIDs(unitNames, zoneNames)
	--trigger.action.outText(tostring(#unitIDs),1)
	local minAlt = 10000000
	if #unitIDs > 0 then 
		for i = 1, #unitIDs do
			local pos = unitIDs[i]:getPosition().p
			local AGL = pos.y - land.getHeight({x=pos.x, y=pos.z})
			if AGL < minAlt then
				minAlt = AGL
			end
		end
		minAlt = oms.validFlagVal(minAlt, 'alt')
	end
	if minAlt == 10000000 then
		minAlt = 0
	end
	oms.setFlag(flag, minAlt)
	return minAlt
end

function oms.inAir(flag, zoneNames, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local unitIDs = oms.getUnitIDs(unitNames, zoneNames)
	local n = 0
	if #unitIDs > 0 then
		for i = 1, #unitIDs do
			if unitIDs[i]:inAir() then
				n = n + 1;
			end
		end
	end
	oms.setFlag(flag, n)
	return n
end


function oms.onGnd(flag, zoneNames, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local unitIDs = oms.getUnitIDs(unitNames, zoneNames)
	local n = 0
	if #unitIDs > 0 then
		for i = 1, #unitIDs do
			if not unitIDs[i]:inAir() then
				n = n + 1;
			end
		end
	end
	oms.setFlag(flag, n)
	return n
end

function oms.signUp(zoneNames, flag, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local u
	local name
	local unitsInZone = mist.getUnitsInZones(unitNames, zoneNames)
	if #unitsInZone == 1 then
		oms.setFlag(flag, 1)
		name = Unit.getName(unitsInZone[1])
	elseif #unitsInZone > 1 then
		oms.setFlag(flag, 2)
		name = 'Too Many'
	else
		oms.setFlag(flag, 0)
		name = 'No Unit'
	end
	oms.challenger = name
	return name
end

function oms.signUpMv(zoneUnitNames, zoneRadius, zoneType, flag, UNT)
	local unitNames = oms.getUnitNames(UNT)
	local name
	local unitsInZone = mist.getUnitsInMovingZones(unitNames, zoneUnitNames, zoneRadius, zoneType)
	if #unitsInZone == 1 then
		oms.setFlag(flag, 1)
		name = Unit.getName(unitsInZone[1])
	elseif #unitsInZone > 1 then
		oms.setFlag(flag, 2)
		name = 'Too Many'
	else
		oms.setFlag(flag, 0)
		name = 'No Unit'
	end
	oms.challenger = name
	return name
end

function oms.unitASL(flag, name)
	name = name or oms.challenger
	local unitAlt = 0
	local u = Unit.getByName(name)
	if u then
		local pos = u:getPosition().p
		unitAlt = oms.validFlagVal(pos.y, 'alt')
	end
	oms.setFlag(flag, unitAlt)
	return unitAlt
end

function oms.unitAGL(flag, name)
	name = name or oms.challenger
	local unitAlt = 0
	local u = Unit.getByName(name)
	if u then
		local pos = u:getPosition().p
		local AGL = pos.y - land.getHeight({x=pos.x, y=pos.z})
		unitAlt = oms.validFlagVal(AGL, 'alt')
	end
	oms.setFlag(flag, unitAlt)
	return unitAlt
end

function oms.unitSpeed(flag, name)
	name = name or oms.challenger
	local unitSpeed = 0
	local u = Unit.getByName(name)
	if u then
		local vel = u:getVelocity()
		local spd = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
		unitSpeed = oms.validFlagVal(spd, 'spd')
	end
	oms.setFlag(flag, unitSpeed)
	return unitSpeed
end

function oms.unitGndSpeed(flag, name)
	name = name or oms.challenger
	local unitSpeed = 0
	local u = Unit.getByName(name)
	if u then
		local vel = u:getVelocity()
		local spd = math.sqrt(vel.x^2 + vel.z^2)
		unitSpeed = oms.validFlagVal(spd, 'spd')
	end
	oms.setFlag(flag, unitSpeed)
	return unitSpeed
end

function oms.unitClimbRate(flag, name)
	name = name or oms.challenger
	local unitSpeed = 0
	local u = Unit.getByName(name)
	if u then
		local vel = u:getVelocity()
		local spd = vel.y
		unitSpeed = oms.validFlagVal(spd, 'vs')
	end
	oms.setFlag(flag, unitSpeed)
	return unitSpeed
end

function oms.unitDiveRate(flag, name)
	name = name or oms.challenger
	local unitSpeed = 0
	local u = Unit.getByName(name)
	if u then
		local vel = u:getVelocity()
		local spd = -vel.y
		unitSpeed = oms.validFlagVal(spd , 'vs')
	end
	oms.setFlag(flag, unitSpeed)
	return unitSpeed
end

function oms.unitClimbAngle(flag, name)
	name = name or oms.challenger
	local angle = 0
	local u = Unit.getByName(name)
	if u then
		local vel = u:getVelocity()
		local AbsSpd = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
		local VrtSpd = vel.y
		local angle = math.deg(math.asin(VrtSpd/AbsSpd))
		angle = oms.validFlagVal(angle)
	end
	oms.setFlag(flag, angle)
	return angle
end

function oms.unitDiveAngle(flag, name)
	name = name or oms.challenger
	local angle = 0
	local u = Unit.getByName(name)
	if u then
		local vel = u:getVelocity()
		local AbsSpd = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
		local VrtSpd = -vel.y
		local angle = math.deg(math.asin(VrtSpd/AbsSpd))
		angle = oms.validFlagVal(angle)
	end
	oms.setFlag(flag, angle)
	return angle
end

function oms.unitHeading(flag, name)
	name = name or oms.challenger
	local hdg = 0
	local u = Unit.getByName(name)
	if u then
		hdg = math.deg(mist.getHeading(u))
		hdg = oms.validFlagHdg(hdg)
	end
	oms.setFlag(flag, hdg)
	return hdg
end

function oms.headingDiff(flag, name1, name2)
	flag = flag or 'omsNilFlag'
	local hdgDiff = 0
	local u1 = Unit.getByName(name1)
	local u2 = Unit.getByName(name2)
	local hdgDiffRel = 0
	if u1 and u2 then
		local hdg1 = math.deg(mist.getHeading(u1))
		local hdg2 = math.deg(mist.getHeading(u2))
		hdgDiff = hdg2 - hdg1
		if hdgDiff > 180 then
			hdgDiff = hdgDiff - 360
		elseif hdgDiff < -180 then
			hdgDiff = hdgDiff + 360
		end
		hdgDiff = math.floor(hdgDiff + 0.5)
		hdgDiffRel = hdgDiff
		if hdgDiff == 0 then
			hdgDiff = 1
		end
	end
	oms.setFlag(flag, math.abs(hdgDiff))
	return hdgDiffRel
end

function oms.randFlag(flag, lowerBound, upperBound)
	lowerBound = lowerBound or 1
	upperBound = upperBound or 100
	local num = math.random(lowerBound, upperBound)
	num = oms.validFlagVal(num)
	oms.setFlag(flag, num)
	return num
end

function oms.randTimer(flag, lowerBound, upperBound)
	lowerBound = lowerBound or 1
	upperBound = upperBound or 100
	local dt = math.random(lowerBound, upperBound)
	dt = oms.validFlagVal(dt)
	mist.scheduleFunction(oms.setFlag, {flag, 1}, timer.getTime() + dt)
	return dt
end

mist.scheduleFunction(oms.updatePlayerUnits, {}, timer.getTime() + 1.5, 30)