Config = {}
Config.LicensePlate = "Welder"

Config.Zones = {

	WelderJob = {
		Pos     = {x = 1383.7, y = -2079.3, z = 52.0},
		Size    = {x = 2.0, y = 2.0, z = 2.0},
		Color   = {r = 255, g = 165, b = 0},
		Type    = -1, Rotate = true,
	},
}

Config.Device = {

	{ [ 'x' ] =     2666.03   , [ 'y' ] =   2771.74  , [ 'z' ] =     36.94    },
	{ [ 'x' ] =     2754.6   , [ 'y' ] =   2801.41  , [ 'z' ] =     33.97    },
	{ [ 'x' ] =     2789.52   , [ 'y' ] =   2835.49  , [ 'z' ] =     36.17    },
	{ [ 'x' ] =     2639.25   , [ 'y' ] =   2932.11  , [ 'z' ] =     36.88    },
	{ [ 'x' ] =     2673.16   , [ 'y' ] =   2796.82  , [ 'z' ] =     32.81    },

}

for i=1, #Config.Device, 1 do

	Config.Zones['Device' .. i] = {
		Pos   = Config.Device[i],
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Color = {r = 255, g = 165, b = 0},
		Type  = -1
	}

end