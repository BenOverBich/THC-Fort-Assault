Config = {}

-- Time players must defend the fort in seconds
Config.RobTime = 300

-- Zone size used when checking player position near the fort
Config.ZoneSize = 2.0

-- Prompt text shown when player can start the assault
-- Text shown to players when prompting them to start
Config.RobPrompt = 'Start the assault'

-- Control key used for the start prompt (E by default)
Config.StartKey = 0xC7B5340A

-- World coordinates for the fort assault event
Config.AssaultLocation = vector3(-4207.02, -3582.37, 49.43)

-- Distance after which the event is cancelled
Config.CancelDistance = 2000.0

-- Reward money granted to the player after success
Config.RewardMoney = 100

-- NPC model used for defenders
Config.NPCModel = 'G_M_O_UniExConfeds_01'

-- Locations where defending NPCs are spawned
Config.NPCSpawns = {
    {x = -4205.81, y = -3430.02, z = 37.09},
    {x = -4205.81, y = -3430.02, z = 37.09},
    {x = -4207.34, y = -3431.82, z = 37.09},
    {x = -4202.31, y = -3429.72, z = 37.09},
    {x = -4201.2, y = -3432.66, z = 37.09},
    {x = -4235.85, y = -3428.87, z = 45.48},
    {x = -4228.56, y = -3450.46, z = 43.56},
    {x = -4223.76, y = -3461.3, z = 44.61},
    {x = -4243.9, y = -3468.63, z = 37.09},
    {x = -4259.25, y = -3470.88, z = 37.08},
    {x = -4229.83, y = -3422.19, z = 41.48},
    {x = -4221.04, y = -3428.73, z = 41.48},
    {x = -4204.81, y = -3422.55, z = 41.48},
    {x = -4193.06, y = -3419.21, z = 42.5},
    {x = -4214.4, y = -3425.81, z = 45.58},
    {x = -4207.84, y = -3417.93, z = 45.59}
}

