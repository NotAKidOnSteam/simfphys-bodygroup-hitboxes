-- this script is called SEVERSIDE ONLY.
function simfphys.weapon:ValidClasses()
    return {
        "sim_fphys_gtasa_firetruk" -- only one vehicle can/will use it
    }
end

function simfphys.weapon:Initialize(vehicle) -- "vehicle" is the "gmod_sent_vehicle_fphysics_base" entity. 
    -- this function is called once the weapon is initialized
    local pod = vehicle:GetDriverSeat()
    simfphys.RegisterCamera(pod, Vector(0, -10, 6), Vector(22, 60, 40))
    -- print("shit")
end

function simfphys.weapon:AimWeapon(ply, vehicle, pod)
    local Aimang = ply:EyeAngles()
    local AimRate = 300

    local Angles = vehicle:WorldToLocalAngles(Aimang) // -Angle(0, 0, 0)

    vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and
                            math.ApproachAngle(vehicle.sm_pp_yaw, Angles.y,
                                               AimRate * FrameTime()) or 0
    vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and
                              math.ApproachAngle(vehicle.sm_pp_pitch, Angles.p,
                                                 AimRate * FrameTime()) or 0

    local TargetAng = Angle(vehicle.sm_pp_pitch, vehicle.sm_pp_yaw, 0)
    TargetAng:Normalize()

    vehicle:SetPoseParameter("washer_yaw", TargetAng.y)
    vehicle:SetPoseParameter("washer_pitch", -TargetAng.p + 5)
end

function simfphys.weapon:Think(vehicle)
    -- this function is called on tick

    local ply = vehicle:GetDriver()
    if not IsValid(ply) then return end

    local fire = ply:KeyDown(IN_ATTACK)
    local fire2 = ply:KeyDown(IN_ATTACK2)
    local weaponselect = vehicle.SelectedWeapon or 1

    local Angles = self:AimWeapon(ply, vehicle, pod)

    if fire2 then self:SecondaryAttack(vehicle, ply, Angles) end

    if vehicle.OldFire2 ~= fire2 then
        vehicle.OldFire2 = fire2
        if fire2 and weaponselect == 1 then
            self:SetNextSecondaryFire(vehicle, CurTime() + 0.3)
            vehicle.wpn = CreateSound(vehicle, "gtasa/sfx/fire_truck_spray.wav")
            vehicle.wpn2 = CreateSound(vehicle,
                                       "ambient/water/water_in_boat1.wav")
            vehicle.wpn:PlayEx(0, 0)
            vehicle.wpn:ChangePitch(100, 0.2)
            vehicle.wpn:ChangeVolume(0.8, 0.5)
            vehicle.wpn2:PlayEx(0, 0)
            vehicle.wpn2:ChangePitch(100, 0.2)
            vehicle.wpn2:ChangeVolume(0.5, 0.5)
            vehicle:CallOnRemove("stop_fire2_sounds", function(vehicle)
                if vehicle.wpn then
                    vehicle.wpn:Stop()
                    vehicle.wpn2:Stop()
                end
            end)
        else
            if vehicle.wpn then
                vehicle.wpn:Stop()
                vehicle.wpn2:Stop()
                vehicle.wpn = nil
                vehicle.wpn2 = nil
                vehicle:EmitSound("notakid/weapons/shutoff.wav")
                vehicle:EmitSound("weapons/extinguisher/release1.wav")
            end
        end
    end

end

function simfphys.weapon:SecondaryAttack(vehicle, ply)
    -- if not self:CanSecondaryAttack( vehicle ) then return end

    vehicle.wOldPos = vehicle.wOldPos or vehicle:GetPos()
    local deltapos = vehicle:GetPos() - vehicle.wOldPos
    vehicle.wOldPos = vehicle:GetPos()

    local AttachmentID = vehicle:LookupAttachment("washer_muzzle")
    local Attachment = vehicle:GetAttachment(AttachmentID)

    local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
    local shootDirection = Attachment.Ang:Up()

    local effectdata = EffectData()
    effectdata:SetAttachment(AttachmentID)
    effectdata:SetEntity(vehicle)
    effectdata:SetOrigin(shootOrigin)
    effectdata:SetNormal(shootDirection)
    effectdata:SetScale(4)
    util.Effect("gtasafiretruk_hose", effectdata)
    self:SetNextSecondaryFire(vehicle, 0.5)
end
util.AddNetworkString("GTASAFiretrukWaterHit")
net.Receive("GTASAFiretrukWaterHit", function(len, pl)

    local prop = net.ReadEntity()

    if not IsValid(prop) then return end

    if (math.random(0, 1000) > 800) then
        local retval = hook.Call("ExtinguisherDoExtinguish", nil, prop)
        if (retval == false) then return end

        if (prop:IsOnFire()) then prop:Extinguish() end

        local class = prop:GetClass()
        if (string.find(class, "ent_minecraft_torch") and prop:GetWorking()) then
            prop:SetWorking(false)
        elseif (string.find(class, "env_fire")) then -- Gas Can support. Should work in ravenholm too.
            prop:Fire("Extinguish")
        end
    end
end)

function simfphys.weapon:CanPrimaryAttack(vehicle)
    vehicle.NextShoot = vehicle.NextShoot or 0
    return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire(vehicle, time)
    vehicle.NextShoot = time
end

function simfphys.weapon:CanSecondaryAttack(vehicle)
    vehicle.NextShoot2 = vehicle.NextShoot2 or 0
    return vehicle.NextShoot2 < CurTime()
end

function simfphys.weapon:SetNextSecondaryFire(vehicle, time)
    vehicle.NextShoot2 = time
end
