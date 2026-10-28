local reference = models.avatar.root.XBody.XBodyParts.XHead.Signal

local function defaultReference()
    return reference:partToWorldMatrix():apply()
end

local getReference = defaultReference

local function setReference(fun)
    getReference = fun
end

function events.tick()
    if math.floor(world.getTime()) % 5 == 0 then
        avatar:store("semaphore_point", getReference())
    end
end

local function fire(pos, time)
    particles:newParticle("minecraft:vibration{destination:{type:'block', pos:[" .. pos.x .. "," .. pos.y .. "," .. pos.z .. "]},arrival_in_ticks:" .. time .."}", getReference())
end

local function semaphore()
    local origin  = getReference()
    if origin == nil then return end
    for name, other in pairs(world:getPlayers()) do
        if other:hasAvatar() and other:getName() ~= player:getName() then
            local ref = other:getVariable("semaphore_point")
            if ref ~= nil then
                local speed = (ref - origin):length() /20 * 20
                fire(ref, math.floor(speed))
            end
        end
    end
end

return {
    setReference = setReference,
    semaphore = semaphore
}
