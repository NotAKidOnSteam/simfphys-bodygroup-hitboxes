local V = {
	Name = "Baggage Box B",
	Model = "models/gtasa/vehicles/bagboxb/bagboxb.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "GTA:SA - Trailers",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = 90,
	NAKGame = "GTA:SA",
	NAKType = "Trailer",
	
	Members = {
		Mass = 1000.0,
		
		GibModels = {
			"models/gtasa/vehicles/bagboxb/chassis.mdl",
			"models/gtasa/vehicles/bagboxb/wheel.mdl",
			"models/gtasa/vehicles/bagboxb/wheel.mdl",
			"models/gtasa/vehicles/bagboxb/wheel.mdl",
			"models/gtasa/vehicles/bagboxb/wheel.mdl",
		},
		
		Trailers = {
			input = Vector(83,0,-20.66),
			output = Vector(-60.60,0,-20.66)
		},
		
		EnginePos = Vector(0,0,0),
		
        OnSpawn = function(ent)
		
			--DK Trailer support
			if (file.Exists( "sound/trailers/trailer_connected.mp3", "GAME" )) then  --checks if sound file exists. will exist if dangerkiddys trailer base is subscribed.
				if ent.GetCenterposition != nil then
					ent:SetSimfIsTrailer(true)
					ent:SetCenterposition(Vector(-60.60,0,-20.66))
					ent:SetTrailerCenterposition(Vector(83,0,-20.66))
				end
			end		
			
			--make the trailer freewheel
			ent:SetActive(true)
			ent.PressedKeys["joystick_throttle"] = 1 -- makes thottle to 1, for remove handbrake
			ent.PressedKeys["joystick_brake"] = 0 -- makes brake to 0, for turn off reverse
			
			ent:NAKSimfGTASA() -- function that does all GTASA changes, like damage sound, explode when upsidedown, ect
			
			--disables Use() function on wheels, makes Use() function call TrailerUse() if it exists
			ent:NAKSimfTrailer() --//in OnSpawn
		end,	
		
		-- TrailerUse = function(ent) 	
			-- do stuff if i need to press E on the trailer
		-- end,
		
		OnTick = function(ent) 	
			--//makes the wheels steer toward the car or trailer connected in front
			if IsValid(ent.TRConnectedInput) then
				local AlignedSteering = math.AngleDifference( ent:EyeAngles().y, ent.TRConnectedInput:EyeAngles().y )
				ent:SteerVehicle( math.Clamp(AlignedSteering, -15, 15) )
			end
        end,
		
		CustomWheels = true,
		CustomSuspensionTravel = 1.5,
			
		CustomWheelModel = "models/gtasa/vehicles/bagboxb/wheel.mdl",
		
		CustomWheelPosFL = Vector(43.81,23.64,-25),
		CustomWheelPosFR = Vector(43.81,-23.64,-25),	
		CustomWheelPosRL = Vector(-36.94,23.64,-25),
		CustomWheelPosRR = Vector(-36.94,-23.64,-25),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,0),		
		
		CustomSteerAngle = 45,
		
		SeatOffset = Vector(-28,-5,35),
		SeatPitch = 15,
		SeatYaw = 90,
		
		FrontHeight = 6,
		FrontConstant = 50000,
		FrontDamping = 1000,
		FrontRelativeDamping = 350,
		
		RearHeight = 6,
		RearConstant = 50000,
		RearDamping = 1000,
		RearRelativeDamping = 800,
		
		FastSteeringAngle = 25,
		SteeringFadeFastSpeed = 200,
		
		TurnSpeed = 2,
		
		MaxGrip = 75,
		Efficiency = 1,
		GripOffset = 0,
		BrakePower = 0,
		BulletProofTires = false,
		
		IdleRPM = 0,
		LimitRPM = 0,
		PeakTorque = 0,
		PowerbandStart = 0,
		PowerbandEnd = 0,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = false,
		
		FuelFillPos = Vector(0,0,0),
		FuelType = FUELTYPE_NONE,
		FuelTankSize = 0,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,

		snd_pitch = 1,
		snd_idle = "common/null.wav",
		
		snd_low = "common/null.wav",
		snd_low_revdown = "common/null.wav",
		snd_low_pitch = 0.95,
		
		snd_mid = "common/null.wav",
		snd_mid_gearup = "common/null.wav",
		snd_mid_pitch = 1.2,
		
		snd_horn = "common/null.wav",
		
		DifferentialGear = 1,
		Gears = {-1,0,1}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_gtasa_bagboxb", V )