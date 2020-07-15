-- //Creates the sounds used by the addon.
sound.Add({
    name = "NAKGTASAFire",
    channel = CHAN_STATIC,
    volume = 0.8,
    level = 70,
    pitch = {95, 110},
    sound = "gtasa/sfx/fire_loop.wav"
})
sound.Add({
    name = "NAKGTASAFireEng",
    channel = CHAN_STATIC,
    volume = 0.4,
    level = 72,
    pitch = {95, 110},
    sound = "gtasa/sfx/engine_damaged_loop.wav"
})

-- //Creates the config menu in the simfphys tab
--[[
	This part of the code is adapted from Neptune QTG's BTTF system vehicle addon.
	https://steamcommunity.com/sharedfiles/filedetails/?id=2135782690
--]]

local function createslider(x, y, sizex, sizey, label, command, parent, min,
                            max, default)
    local slider = vgui.Create("DNumSlider", parent)
    slider:SetPos(x, y)
    slider:SetSize(sizex, sizey)
    slider:SetText(label)
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetDecimals(2)
    slider:SetConVar(command)
    slider:SetValue(default)
    return slider
end

local function addhook(a, b, c) hook.Add(a, c or 'nak_gtasa_config', b) end

local function buildthemenu(self)

    local Background = vgui.Create('DShape', self.PropPanel)
    Background:SetType('Rect')
    Background:SetPos(20, 20)
    Background:SetColor(Color(0, 0, 0, 200))
    local y = 0

    if LocalPlayer():IsSuperAdmin() then

        y = y + 25
        local CheckBoxDamage = vgui.Create("DCheckBoxLabel", self.PropPanel)
        CheckBoxDamage:SetPos(25, y)
        CheckBoxDamage:SetText("Enable Damage")
        CheckBoxDamage:SetValue(GetConVar("sv_simfphys_enabledamage"):GetInt())
        CheckBoxDamage:SizeToContents()

        y = y + 18
        local DamageMul = vgui.Create("DNumSlider", self.PropPanel)
        DamageMul:SetPos(30, y)
        DamageMul:SetSize(345, 30)
        DamageMul:SetText("Physical Damage Multiplier")
        DamageMul:SetMin(0)
        DamageMul:SetMax(10)
        DamageMul:SetDecimals(3)
        DamageMul:SetValue(GetConVar("gtasa_physicdamagemultiplier"):GetFloat())

        y = y + 32
        local DamageMul = vgui.Create("DNumSlider", self.PropPanel)
        DamageMul:SetPos(30, y)
        DamageMul:SetSize(345, 30)
        DamageMul:SetText("Bullet Damage Multiplier")
        DamageMul:SetMin(0)
        DamageMul:SetMax(10)
        DamageMul:SetDecimals(3)
        DamageMul:SetValue(GetConVar("gtasa_takedamagemultiplier"):GetFloat())

        y = y + 18
    else
        y = y + 25
        local Label = vgui.Create('DLabel', self.PropPanel)
        Label:SetPos(30, y)
        Label:SetText("Admin-Only Settings!")
        Label:SizeToContents()
    end

    Background:SetSize(350, y)
end

addhook('SimfphysPopulateVehicles', function(pc, t, n)

    local node = t:AddNode('GTA:SA Config', 'icon16/wrench_orange.png')

    node.DoPopulate = function(self)
        if self.PropPanel then return end

        self.PropPanel = vgui.Create('ContentContainer', pc)
        self.PropPanel:SetVisible(false)
        self.PropPanel:SetTriggerSpawnlistChange(false)

        buildthemenu(self)
    end

    node.DoClick = function(self)
        self:DoPopulate()
        pc:SwitchPanel(self.PropPanel)
    end
end)

-- //Client stuff
if CLIENT then
    net.Receive("nak_hitbox_cashed", function()
        local ent = net.ReadEntity()
        if IsValid(ent) then ent.NAKHitboxes = net.ReadTable() end
    end)
    local function initializeHitboxesRenderer()
        local nak_simf_hitboxes = CreateConVar("nak_simf_hitboxes", 0, {
            FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX
        }, "Debug Simfphys hitboxes for supported vehicles", 0, 1)
        local nak_simf_hitboxes_filled =
            CreateConVar("nak_simf_hitbox_filled", 1,
                         {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX},
                         "Filled boxes?\nrequires nak_simf_hitbox_reload",
                         0, 1):GetBool()
        local nak_simf_hitboxes_wireframe =
                         CreateConVar("nak_simf_hitbox_wireframe", 1,
                                      {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX},
                                      "Wireframe boxes?\nrequires nak_simf_hitbox_reload",
                                      0, 1):GetBool()
        local veccolor = util.StringToType(
                             CreateConVar("nak_simf_hitbox_color",
                                          "255 255 255",
                                          {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX},
                                          "Set a color for the box AS A STRING '255,255,255'\nrequires nak_simf_hitbox_reload"):GetString(),
                             "Vector")
        local alpha = CreateConVar("nak_simf_hitbox_alpha", 100,
                                   {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX},
                                   "Set the alpha of the hitbox\nrequires nak_simf_hitbox_reload",
                                   0, 255):GetFloat()
        hook.Remove("PostDrawTranslucentRenderables", "nak_simf_hitboxes")
        hook.Remove("PostDrawOpaqueRenderables", "nak_simf_hitboxes")
        local color = Color(veccolor.x, veccolor.y, veccolor.z, alpha)
        if nak_simf_hitboxes_filled then
            hook.Add("PostDrawTranslucentRenderables", "nak_simf_hitboxes",
                     function()
                if nak_simf_hitboxes:GetBool() then
                    render.SetColorMaterial()
                    for k, ent in pairs(ents.FindByClass(
                                            "gmod_sent_vehicle_fphysics_base")) do -- WIKI: Gets all entities with the given class, supports wildcards. This works internally by iterating over ents.GetAll. Even if internally ents.GetAll is used, It is faster to use ents.FindByClass than ents.GetAll with a single class comparison.
                        local HBInfo = ent.NAKHitboxes
                        if HBInfo then
                            local entPos = ent:GetPos()
                            local entAngles = ent:GetAngles()
                            local key = nil
                            while true do
                                key = next(HBInfo, key)
                                if key == nil then
                                    break
                                end
                                render.DrawBox(entPos, entAngles,
                                               HBInfo[key].OBBMin,
                                               HBInfo[key].OBBMax, color, true)
                            end
                        end
                    end
                end
            end)
        end
        if nak_simf_hitboxes_wireframe then
            hook.Add("PostDrawOpaqueRenderables", "nak_simf_hitboxes",
                     function()
                if nak_simf_hitboxes:GetBool() then
                    render.SetColorMaterial()
                    for k, ent in pairs(ents.FindByClass(
                                            "gmod_sent_vehicle_fphysics_base")) do -- WIKI: Gets all entities with the given class, supports wildcards. This works internally by iterating over ents.GetAll. Even if internally ents.GetAll is used, It is faster to use ents.FindByClass than ents.GetAll with a single class comparison.
                        local HBInfo = ent.NAKHitboxes
                        if HBInfo then
                            local entPos = ent:GetPos()
                            local entAngles = ent:GetAngles()
                            local key = nil
                            while true do
                                key = next(HBInfo, key)
                                if key == nil then
                                    break
                                end
                                render.DrawWireframeBox(entPos, entAngles,
                                                        HBInfo[key].OBBMin,
                                                        HBInfo[key].OBBMax,
                                                        color, true)
                            end
                        end
                    end
                end
            end)
        end
    end
    initializeHitboxesRenderer()
    concommand.Add("nak_simf_hitbox_reload", initializeHitboxesRenderer, nil,
                   "updates settings for hitbox renderer")
    net.Receive("simf_dmgengine_sound", function()
        local ent = net.ReadEntity()
        local snd = net.ReadString()
        if IsValid(ent) then ent.DamageSnd = CreateSound(ent, snd) end
    end)

    net.Receive("nakkillveh_fire", function()
        local ent = net.ReadEntity()
        if IsValid(ent) then
            local delay = 0.1
            local nextOccurance = 0

            hook.Add("Think", "nakkillveh_fire_" .. ent:EntIndex(), function()
                local timeLeft = nextOccurance - CurTime()
                if timeLeft > 0 then return end
                if IsValid(ent) then
                    local effectdata = EffectData()
                    effectdata:SetOrigin(ent:GetEnginePos() + Vector(0, 0, 25))
                    effectdata:SetEntity(ent)
                    util.Effect("simf_gtasa_fire", effectdata)
                    nextOccurance = CurTime() + delay
                else
                    hook.Remove("Think", "nakkillveh_fire_" .. ent:EntIndex())
                end
            end)
        end
    end)
else -- //server code
    util.AddNetworkString("simf_dmgengine_sound")
    util.AddNetworkString("nakkillveh_fire")
end

--[[
	FUNCTIONS AND STUFF OH OH OH OH OH OH OH OH OH OH OH OH OH O im bored

	meow

	spacing things out
--]]

local Entity = FindMetaTable("Entity")

function Entity:NAKDmgEngineSnd(snd) -- //custom damaged engine sound needs to be networked to the client as its clientsided
    net.Start("simf_dmgengine_sound")
    net.WriteEntity(self)
    net.WriteString(snd)
    net.Broadcast()
end

function Entity:NAKSimfEngineStart(snd)
    self.StartEngine = function(self)
        if not self:CanStart() then return end
        if not self:EngineActive() then
            if not bIgnoreSettings then self.CurrentGear = 2 end
            if not self.IsInWater then
                self:EmitSound(snd)
                self.EngineRPM = self:GetEngineData().IdleRPM
                self.EngineIsOn = 1
            else
                if self:GetDoNotStall() then
                    self.EngineRPM = self:GetEngineData().IdleRPM
                    self.EngineIsOn = 1
                    self:EmitSound(snd)
                end
            end
        end
    end
end

function Entity:NAKSimfSkidSounds(wheelsnds)

    if wheelsnds == nil then
        wheelsnds = {}
        wheelsnds.snd_skid = "gtasa/sfx/tireskid.wav"
        wheelsnds.snd_skid_dirt = "gtasa/sfx/tire_dirt.wav"
        wheelsnds.snd_skid_grass = "gtasa/sfx/tire_grass.wav"
    end

    for i = 1, table.Count(self.Wheels) do
        local Wheel = self.Wheels[i]
        Wheel.snd_skid = wheelsnds.snd_skid
        Wheel.snd_skid_dirt = wheelsnds.snd_skid_dirt
        Wheel.snd_skid_grass = wheelsnds.snd_skid_grass
    end
end

-- //prolly not good upsidedown damage timer thing stuffs
function Entity:NAKKillVehicle()
    net.Start("nakkillveh_fire")
    net.WriteEntity(self)
    net.Broadcast()

    self:EmitSound("NAKGTASAFire")
    if self:EngineActive() then self:EmitSound("NAKGTASAFireEng") end
    self:CallOnRemove("NAKGTASAFireSoundRemove", function()
        self:StopSound("NAKGTASAFire")
        self:StopSound("NAKGTASAFireEng")
    end)

    timer.Create("GTASAKillVeh_" .. self:EntIndex(), math.random(4, 5), 1,
                 function()
        if not IsValid(self) then return end
        self:ExplodeVehicle()
    end)
end
function Entity:NAKSimfFireTime(Danger)
    if Danger then
        if not self.NAKUpsideDownDanger then
            self.NAKUpsideDownDanger = true
            timer.Create("GTASADanger_" .. self:EntIndex(),
                         math.random(3.5, 4.5), 1, function()
                if not IsValid(self) then return end
                if not self.NAKUpsideDownDanger then return end
                self:NAKKillVehicle()
            end)
        end
    else
        self.NAKUpsideDownDanger = false
    end
end

function Entity:NAKSimfTickStuff()

    self.OnTick_UDF = self.OnTick -- //store the old built in simfphys function

    self.OnTick =
        function(self) -- //override the old function to call our code first, then call the old stored one

            if self:GetAngles():Up().z < -0.7 then
                self:NAKSimfFireTime(true)
            else
                self:NAKSimfFireTime(false)
            end

            if self.NAKGTASAFireDamage == 1000 then
                self:NAKKillVehicle()
            end

            if self:GetGear() == 1 then
                self.ReverseSound:ChangeVolume(1, 0.2)
                self.ReverseSound:ChangePitch(
                    math.Clamp(self:GetRPM() / 50, 0, 100), 0.4)
            elseif self.ReverseSound then
                self.ReverseSound:ChangePitch(0, 0.8)
                self.ReverseSound:ChangeVolume(0, 0.4)
            end

            self:OnTick_UDF()
        end

end

local function NAKPlayEMSRadio(self)

    if not IsValid(self) then return end

    local filter = RecipientFilter()

    if IsValid(self:GetDriver()) then filter:AddPlayer(self:GetDriver()) end
    if self.PassengerSeats then
        for i = 1, table.Count(self.PassengerSeats) do
            local Passenger = self.pSeat[i]:GetDriver()
            if IsValid(Passenger) then filter:AddPlayer(Passenger) end
        end
    end

    self.NAKEMSRadio = CreateSound(self,
                                   "gtasa/sfx/police_radio/police_radio" ..
                                       math.random(1, 53) .. ".wav", filter)
    self.NAKEMSRadio:SetSoundLevel(100)
    self.NAKEMSRadio:PlayEx(2, 100)
    timer.Create("NAKGTASA_EMSRadio_" .. self:EntIndex(), math.random(20, 45),
                 1, function() NAKPlayEMSRadio(self) end)
end

function Entity:NAKSimfEMSRadio()
    timer.Create("NAKGTASA_EMSRadio_" .. self:EntIndex(), 1, 1,
                 function() NAKPlayEMSRadio(self) end)
end

function Entity:NAKSimfTrailer()
    for i = 1, table.Count(self.Wheels) do self.Wheels[i].Use = nil end

    if self.TrailerUse then
        self.Use = nil
        self.Use = function() self:TrailerUse() end
    else
        self.Use = nil
    end
end

-- MAIN GLOBAL FUNCTION TO APPLY MOST IF NOT ALL OF THESE TO ALL VEHICLES
-- (i can update this function to apply to all vehicles using it)

function Entity:NAKSimfGTASA()

    if not self.ReverseSound then
        self.ReverseSound = CreateSound(self, "gtasa/vehicles/reverse_gear.wav")
        self.ReverseSound:PlayEx(0, 0)
        self:CallOnRemove("GTASARevSound", function()
            if self.ReverseSound then self.ReverseSound:Stop() end
        end)
    end

    self:NAKSimfSkidSounds() -- replaces the wheel skid sounds
    self:NAKSimfEngineStart("gtasa/sfx/engine_start.wav")
    -- self:NAKSimfCustomExplode()
    self:NAKDmgEngineSnd("gtasa/sfx/engine_damaged_loop.wav")
    self:NAKSimfTickStuff()
end

-- //All done!
print("loaded")
