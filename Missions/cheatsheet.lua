local unit = Unit.getByName('SAM-1-1')
-- Returns the unit when alive, can be late activation
-- NIL for non-ooccupied client slot and dead units
-- If unit is saved to a variable, the variable itself continues to exist when unit killed, 
-- isExist() returns FALSE, most other functions won't work anymore

-- Foolproof way to check unit actually exist on current map
if unit and unit:isActive() then
    return true
end

local group = Group.getByName('SAM-1')
-- Returns the group even when all dead or late activation
-- NIL if no one in client group

-- Foolproof way to check group actually exist on current map
if group and group:getSize()>0 and group:getUnit(1):isActive() then
    return true
end

group:destroy()
-- This will cause the above to return nil as any obj is removed from mission entirely
-- destory() even works on already dead group to remove them

group:isExist()
-- TRUE even when late activation
-- TRUE even when all units within are dead
unit:isExist()
-- TRUE even when late activation
-- FALSE if unit dead

group:getSize()
group:getInitialSize()
-- Number of alive or total units
-- Returns the number even when late activation
-- Only killed units make size decrease

group:getUnit(5)
-- Get the nth unit, even when late activation
-- usable index decrease when unit dead
-- returns NIL if all dead or index more than group size

group:getUnits()
-- Get all units, even when late activation
-- dead units not included, returns {} if all dead

unit:isActive()
-- Alive and not in late activation
-- FALSE if in late activation and 'visble before activation' checked
-- FALSE if 'No AI Control' checked
-- Will throw error if used on dead units

unit:inAir()
unit:getPoint()
unit:getPosition()
unit:getVelocity()
unit:getLife()
unit:getLife0()
-- Works as normal for late activation units
-- if no damage taken, getLive() == getLive0()
-- Will throw error if used on dead units
