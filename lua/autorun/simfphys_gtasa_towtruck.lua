local V = {
	Name = "Towtruck",
	Model = "models/gtasa/vehicles/towtruck/towtruck.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "GTA:SA - Public Service",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = 90,
	NAKGame = "GTA:SA",
	NAKType = "Sports",
	
	Members = {
		Mass = 3500,
		
		GibModels = {
			"models/gtasa/vehicles/towtruck/chassis.mdl",
			"models/gtasa/vehicles/towtruck/bonnet_dam.mdl",
			"models/gtasa/vehicles/towtruck/bump_front_dam.mdl",
			"models/gtasa/vehicles/towtruck/door_lf_dam.mdl",
			"models/gtasa/vehicles/towtruck/door_rf_dam.mdl",
			"models/gtasa/vehicles/towtruck/wheel.mdl",
			"models/gtasa/vehicles/towtruck/wheel.mdl",
			"models/gtasa/vehicles/towtruck/wheel.mdl",
			"models/gtasa/vehicles/towtruck/wheel.mdl",
		},
		
		EnginePos = Vector(86.81,0,13.75),
		
		LightsTable = "gtasa_towtruck",
		
		
        OnSpawn = function(ent)
		
			if (file.Exists( "sound/trailers/trailer_connected.mp3", "GAME" )) then  --checks if sound file exists. will exist if dangerkiddys trailer base is subscribed.
				if ent.GetCenterposition != nil then
					ent:SetCenterposition(Vector(-108,0,-12))  -- position of center ballsocket for tow hitch(trailer coupling)
					ent:SetTrailerCenterposition(Vector(0,0,0)) -- position of center ballsocket for trailer hook
				end
			end		
			
			local hitboxes = {}
			hitboxes.hood = {min = Vector(43.36,50,30.54), max = Vector(121,-50,-10), bdgroup = 1, gibmodel = "models/gtasa/vehicles/towtruck/bonnet_dam.mdl", giboffset = Vector(44.6,0,27.3), health=160 }
			hitboxes.bumperf = {min = Vector(95,50,20), max = Vector(121,-50,-15), bdgroup = 2, gibmodel = "models/gtasa/vehicles/towtruck/bump_front_dam.mdl", giboffset = Vector(108.98,-39.17,1.94), health=100 }
			hitboxes.dfdoor = {min = Vector(-9,50,25.74), max = Vector(55,31.67,-12), bdgroup = 3, gibmodel = "models/gtasa/vehicles/towtruck/door_lf_dam.mdl", giboffset = Vector(44.37,44.11,20.34), health=100 }
			hitboxes.pfdoor = {max = Vector(-9,-50,25.74), min = Vector(55,-31.67,-12), bdgroup = 4, gibmodel = "models/gtasa/vehicles/towtruck/door_rf_dam.mdl", giboffset = Vector(44.37,-44.11,20.34), health=100 }
			hitboxes.windowf = {min = Vector(25.68,36.65,49.14), max = Vector(45.68,-36.65,29.14), bdgroup = 5, health=6, glass=true, glasspos=Vector(37.969,0,38.025) }
			
			hitboxes.gastank = {min = Vector(-22.92,50,0.65), max = Vector(-14.69,40,-7.3), explode=true }
			
			ent:NAKAddHitBoxes(hitboxes)
			
			ent:NAKSimfGTASA() -- function that'll do all the GTASA changes for you

			if ( ProxyColor ) then
				local CarCols = {}
				CarCols[1] = {Color(245,245,245),Color(245,245,245),Color(245,245,245)}
				CarCols[2] = {Color(115,14,26),Color(59,78,120),Color(245,245,245)}
				CarCols[3] = {Color(123,10,42),Color(59,78,120),Color(245,245,245)}
				CarCols[4] = {Color(105,30,59),Color(66,31,33),Color(245,245,245)}
				CarCols[5] = {Color(37,37,39),Color(95,10,21),Color(245,245,245)}
				CarCols[6] = {Color(25,56,38),Color(48,79,69),Color(245,245,245)}
				CarCols[7] = {Color(77,98,104),Color(39,47,75),Color(245,245,245)}
				ent:SetProxyColor( CarCols[math.random(1,7)] )
			end
		end,	
		
		OnTick = function(ent)
			local TowPos = ent:GetAttachment( ent:LookupAttachment( "tow_hook" ) ) 
		
			if !ent.TowArmAng then ent.TowArmAng = 0 end
			
			if ent:GetFogLightsEnabled() then
				ent.TowArmAng = math.Clamp(ent.TowArmAng + 2, 0, 27)
			else
				ent.TowArmAng = math.Clamp(ent.TowArmAng - 2, 0, 27)
			end
			ent:SetPoseParameter("vehicle_towarm_move", ent.TowArmAng )
		end,
		
		CustomWheels = true,
		CustomSuspensionTravel = 1.5,
			
		CustomWheelModel = "models/gtasa/vehicles/towtruck/wheel.mdl",
		CustomWheelModel_R = "models/gtasa/vehicles/towtruck/wheel_wide.mdl",
		
		CustomWheelPosFL = Vector(77.08,38.04,-14),
		CustomWheelPosFR = Vector(77.08,-38.04,-14),	
		CustomWheelPosRL = Vector(-77.51,40.82,-14),
		CustomWheelPosRR = Vector(-77.51,-40.82,-14),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,0),		
		
		CustomSteerAngle = 45,
		
		SeatOffset = Vector(5,-18,34),
		SeatPitch = 0,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(15,-20,0),
				ang = Angle(0,-90,10)
			},
		},
		ExhaustPositions = {
			{
				pos = Vector(-104.32,-18.23,-17.41),
				ang = Angle(-90,0,0),
			},
		},
		Attachments = {
			{
				model = "models/gtasa/vehicles/towtruck/steering.mdl",
				color = Color(255,255,255,255),
				pos = Vector(0,0,0),
				ang = Angle(0,0,0)
			},
		},
		
		StrengthenSuspension = true,
		
		FrontHeight = 10,
		FrontConstant = 50000,
		FrontDamping = 1500,
		FrontRelativeDamping = 350,
		
		RearHeight = 10,
		RearConstant = 50000,
		RearDamping = 1500,
		RearRelativeDamping = 800,
		
		FastSteeringAngle = 25,
		SteeringFadeFastSpeed = 350,
		
		TurnSpeed = 4,
		
		MaxGrip = 125,
		Efficiency = 1,
		GripOffset = 0,
		BrakePower = 60,
		BulletProofTires = false,
		
		IdleRPM = 800,
		LimitRPM = 5000,
		PeakTorque = 160,
		PowerbandStart = 2200,
		PowerbandEnd = 4500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = false,
		
		FuelFillPos = Vector(-18.9,51.31,-3.43),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 150,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,

		snd_pitch = 1,
		snd_idle = "gtasa/vehicles/130-131_idle.wav",
		
		snd_low = "gtasa/vehicles/130-131_cruise.wav",
		snd_low_revdown = "gtasa/vehicles/130-131_cruise_loop.wav",
		snd_low_pitch = 0.95,
		
		snd_mid = "gtasa/vehicles/130-131_gear_loop.wav",
		snd_mid_gearup = "gtasa/vehicles/130-131_gear.wav",
		snd_mid_pitch = 1.2,
		
		snd_horn = "gtasa/vehicles/horns/horn_005.wav",
		
		DifferentialGear = 0.18,
		Gears = {-0.13,0,0.15,0.35,0.5,0.65,0.85}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_gtasa_towtruck", V )

local light_table = {
	L_HeadLampPos = Vector(110.8,30.77,13.37),
	L_HeadLampAng = Angle(17,0,0),
	R_HeadLampPos = Vector(110.8,-30.77,13.37),
	R_HeadLampAng = Angle(10,0,0),
	
	L_RearLampPos = Vector(-110.7,34.98,-5.71),
	L_RearLampAng = Angle(25,180,0),
	R_RearLampPos = Vector(-110.7,-34.98,-5.71),
	R_RearLampAng = Angle(25,180,0),
	
	Headlight_sprites = {
		{
			pos = Vector(110.8,30.77,13.37),
			material = "sprites/light_ignorez",
			size = 70,
			color = Color(255,238,200,255),
		},
		{
			pos = Vector(110.8,-30.77,13.37),
			material = "sprites/light_ignorez",
			size = 70,
			color = Color(255,238,200,255),
		},
	},
	
	Headlamp_sprites = {
		{pos = Vector(110.8,30.77,13.37),size = 100,material = "sprites/light_ignorez"},
		{pos = Vector(110.8,-30.77,13.37),size = 100,material = "sprites/light_ignorez"},
	},
	
	Rearlight_sprites = {
		{
			pos = Vector(-110.7,34.98,-5.71),
			material = "sprites/light_ignorez",
			size = 60,
			color = Color(255,0,0,255),
		},
		{
			pos = Vector(-110.7,-34.98,-5.71),
			material = "sprites/light_ignorez",
			size = 60,
			color = Color(255,0,0,255),
		},
	},
	Brakelight_sprites = {
		{
			pos = Vector(-110.7,34.98,-5.71),
			material = "sprites/light_ignorez",
			size = 70,
			color = Color(255,0,0,255),
		},
		{
			pos = Vector(-110.7,-34.98,-5.71),
			material = "sprites/light_ignorez",
			size = 70,
			color = Color(255,0,0,255),
		},
	},
	
	DelayOn = 0,
	DelayOff = 0,
	
	Turnsignal_sprites = {
		Left = {
			{
				pos = Vector(109.22,30.77,5.85),
				material = "sprites/light_ignorez",
				size = 70,
				color = Color(255,135,0,255),
			},
		},
		Right = {
			{
				pos = Vector(109.22,-30.77,5.85),
				material = "sprites/light_ignorez",
				size = 70,
				color = Color(255,135,0,255),
			},
		},
	},
	
	SubMaterials = {
		off = {
			Base = {
				[7] = ""
			},
		},
		on_lowbeam = {
			Base = {
				[7] = "models/gtasa/vehicles/share/vehiclelightson128"
			},
		},
	}
}
list.Set( "simfphys_lights", "gtasa_towtruck", light_table)