
-- OPTIONS


---  Bone(s) on your model you want for sending or receiving mimic signals.
--- To provide reference points dynamically, use the reference-setting functions
--- like `setReference`.
--- @type ModelPart
local receiverBone = models.avatar.root.Head.Horns
--- @type ModelPart
local senderBone = receiverBone

--- Number of ticks between receiver reference position updates
local updateRate = 2

--- Whether this model is a mimic or not.
--- pretty please only set this to true if you are an actual mimic trust me it'll be a lot more fun this way
--- @type boolean
local isMimic = false

--------------------------- CAREFUL BEARS BELOW -----------------------------------------

-- ʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔʕ•ᴥ•ʔ

local function defaultSender()
    return senderBone:partToWorldMatrix():apply()
end

local function defaultReceiver()
    return receiverBone:partToWorldMatrix():apply()
end

--- @type function
local receiver = defaultReceiver
--- @type function
local sender = defaultSender

--- Sets receiver function, leaving sender untouched.
--- Note that returning `nil` can be used to pause receiving signals,
---   for example if someone is attempting to find you.
---   Mimics have a hard time hiding their horns,
---   so they should do this sparingly if at all.
--- @param receiverFunc function
local function setReceiver(receiverFunc)
    receiver = receiverFunc
end

--- Sets sender function, leaving receiver untouched.
--- @param senderFunc function
local function setSender(senderFunc)
    sender = senderFunc
end

--- Sets reference point function for transmission.
--- if sender is unspecified, sets both to first argument.
--- @param receiverFunc function
--- @param senderFunc function | nil
local function setReference(receiverFunc, senderFunc)
    setReceiver(receiverFunc)
    if senderFunc then
        setSender(senderFunc)
    else
        setSender(receiverFunc)
    end
end

function events.entity_init()
    avatar:store("has_no_soul", isMimic)
end

function events.tick()
    if math.floor(world.getTime()) % updateRate == 0 then
        avatar:store("semaphore_point", receiver())
    end
end

local function fire(pos, time)
    particles:newParticle("minecraft:vibration{destination:{type:'block', pos:[" .. pos.x .. "," .. pos.y .. "," .. pos.z .. "]},arrival_in_ticks:" .. time .."}", sender())
end

--- Sends a signal to all receivers.
--- @param mimicsOnly boolean | nil Declares if the signal is sent to mimics only.
local function semaphore(mimicsOnly)
    if not player:isLoaded() then return end
    --- @type Vector3
    local origin  = sender()
    if origin == nil then return end
    for name, other in pairs(world:getPlayers()) do
        if other:isLoaded() and other:hasAvatar() and name ~= player:getName() then
            local ref = other:getVariable("semaphore_point")
            if ref ~= nil and (not mimicsOnly or other:getVariable("has_no_soul")) then
                local speed = (ref - origin):length() /20 * 20
                fire(ref, math.floor(speed))
            end
        end
    end
end

return {
    setReference = setReference,
    setReceiver = setReceiver,
    setSender = setSender,
    semaphore = semaphore
}
