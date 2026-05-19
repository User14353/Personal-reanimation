local osclock = os.clock
local tspawn = task.spawn
local twait = task.wait
local schar = string.char
local ssub = string.sub
local sfind = string.find
local supper = string.upper
local mrandom = math.random
local sin = math.sin
local cos = math.cos
local rad = math.rad
local abs = math.abs
local tan = math.tan
local min = math.min
local clamp = math.clamp
local tinsert = table.insert
local tclear = table.clear
local tclone = table.clone
local tfind = table.find
local random = function(a, b)
    return mrandom(a * 1000, b * 1000) / 1000
end
local vmagnitude = vector.magnitude -- faster than indexing with Magnitude
local vnormalize = vector.normalize -- faster than indexing with Unit

-- the script doesnt have to read global varaibles every time to get them
-- why not have them saved in local varaibles for faster access times
local next = next
local pcall = pcall
local xpcall = xpcall
local type = type
local typeof = typeof
local game = game
local replicatesignal = replicatesignal

local i = Instance.new
local v2 = Vector2.new
local v3 = Vector3.new
local c3 = Color3.new
local cf = CFrame.new
local cfl = CFrame.lookAt
local angles = CFrame.fromEulerAngles -- faster than .Angles
local u2 = UDim2.new
local e = Enum
local rp = RaycastParams.new
local cs = ColorSequence.new
local csk = ColorSequenceKeypoint.new

local sine = osclock()
local deltaTime = 0
local v3_0 = v3()
local v3_101 = v3(1, 0, 1)
local v3_010 = v3(0, 1, 0)
local cf_0 = cf()
local v3_xz = v3_101 * 10
local v3_xzL = v3_101 * 250.1
local v3_net = v3_010 * 25.01
local pdloadedtime = nil

local enumMD = e.MouseBehavior.Default
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURATION: Replace with the target User ID
local TARGET_USER_ID = 562932753 -- << CHANGE THIS

local function applyTags(player)
    if player.UserId == TARGET_USER_ID and player.UserId ~= LocalPlayer.UserId then
        player.CharacterAdded:Connect(function(character)
            local head = character:WaitForChild("Head")

            -- 1. Create Highlight
            local highlight = Instance.new("Highlight")
            highlight.Name = "OwnerHighlight"
            highlight.FillColor = Color3.fromRGB(255, 215, 0) -- Gold
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = character

            -- 2. Create Overhead Text (BillboardGui)
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "OwnerTag"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0) -- Position above head
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = head

            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = billboard
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "OWNER / DEV"
            textLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
            textLabel.TextStrokeTransparency = 0 -- Black outline
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.GothamBold
        end)

        -- Apply immediately if character already exists
        if player.Character then
            -- Trigger CharacterAdded logic
            -- (Normally need to fire a custom event, but for executor
            --  you can manually call the logic here if character already loaded)
        end
    end
end

-- Apply to existing players
for _, player in pairs(Players:GetPlayers()) do
    applyTags(player)
end

-- Apply to new players
Players.PlayerAdded:Connect(applyTags)
-- not "local function rs" to not assign debug names
local rs = function()
    local s = ""
    for i = 1, mrandom(8, 15) do
        if mrandom(2) == 2 then
            s = s .. schar(mrandom(65, 90))
        else
            s = s .. schar(mrandom(97, 122))
        end
    end
    return s
end

-- it runs even faster if u call __index and __newindex metamethods directly
local getMetamethodFromErrorStack = function(userdata, f, test)
    local ret = nil
    xpcall(f, function()
        ret = debug.info(2, "f")
    end, userdata, nil, 0)
    if (type(ret) ~= "function") or not test(ret) then
        return f
    end
    return ret
end
local insSet = getMetamethodFromErrorStack(game, function(a, b, c)
    a[b] = c
end, function(f)
    local a = i("Folder")
    local b = rs()
    f(a, "Name", b)
    return a.Name == b
end)
local insGet = getMetamethodFromErrorStack(game, function(a, b)
    return a[b]
end, function(f)
    local a = i("Folder")
    local b = rs()
    a.Name = b
    return f(a, "Name") == b
end)
local cfGet = getMetamethodFromErrorStack(cf_0, function(a, b)
    return a[b]
end, function(f)
    return f(cf(1, 2, 3), "Position") == v3(1, 2, 3)
end)
local cfMul = getMetamethodFromErrorStack(cf_0, function(a, b)
    return a * b
end, function(f)
    return angles(1, 2, 3) * angles(1, 2, 3) == f(angles(1, 2, 3), angles(1, 2, 3))
end)
local cfAdd = getMetamethodFromErrorStack(cf_0, function(a, b)
    return a + b
end, function(f)
    return cf(1, 2, 3) + v3(1, 2, 3) == f(cf(1, 2, 3), v3(1, 2, 3))
end)
local v3Get = getMetamethodFromErrorStack(v3_0, function(a, b)
    return a[b]
end, function(f)
    return v3(1, 2, 3).Unit == f(v3(1, 2, 3), "Unit")
end)
local v2Get = getMetamethodFromErrorStack(v2(), function(a, b)
    return a[b]
end, function(f)
    return f(v2(1, 2), "Y") == 2
end)
-- multiplying and adding vector3 is faster if you use the * and + operators
-- its faster to multiply X and Y of vector2 than to multiply vector2 and then get X and Y from it

-- no need to index instances every time to call their functions
local Clone = insGet(game, "Clone")
local ClearAllChildren = insGet(game, "ClearAllChildren")
local Destroy = insGet(game, "Destroy")
local IsA = insGet(game, "IsA")
local FindFirstChildOfClass = insGet(game, "FindFirstChildOfClass")
local FindFirstChild = insGet(game, "FindFirstChild")
local FindFirstChildWhichIsA = insGet(game, "FindFirstChildWhichIsA")
local GetChildren = insGet(game, "GetChildren")
local IsDescendantOf = insGet(game, "IsDescendantOf")
local QueryDescendants = insGet(game, "QueryDescendants")
local GetPropertyChangedSignal = insGet(game, "GetPropertyChangedSignal")

-- findfirstchildofclass faster than getservice
local plrs = FindFirstChildOfClass(game, "Players")
local rus = FindFirstChildOfClass(game, "RunService")
local ws = FindFirstChildOfClass(game, "Workspace")
local uis = FindFirstChildOfClass(game, "UserInputService")
local gs = FindFirstChildOfClass(game, "GuiService")
local sg = FindFirstChildOfClass(game, "StarterGui")
local lp = insGet(plrs, "LocalPlayer")
local pg = FindFirstChildOfClass(lp, "PlayerGui")
local mouse = insGet(lp, "GetMouse")(lp)
-- local cdsb=insGet(lp,"ConnectDiedSignalBackend")
local rst = insGet(plrs, "RespawnTime") + 0.07 -- 1/15
local preanimation = insGet(rus, "PreAnimation")
local heartbeat = insGet(rus, "Heartbeat")
local renderstepped = insGet(rus, "RenderStepped")
local PostSimulation = insGet(rus, "PostSimulation")
local PreSimulation = insGet(rus, "PreSimulation")
local GetPlayers = insGet(plrs, "GetPlayers")
local SetCoreGuiEnabled = insGet(sg, "SetCoreGuiEnabled")
local GetCoreGuiEnabled = insGet(sg, "GetCoreGuiEnabled")
local Raycast = insGet(ws, "Raycast")
local Connect = heartbeat.Connect
local Disconnect = Connect(GetPropertyChangedSignal(game, "CreatorId"), type).Disconnect
local Wait = heartbeat.Wait
local GetMouseLocation = insGet(uis, "GetMouseLocation")
local GetFocusedTextBox = insGet(uis, "GetFocusedTextBox")
local GetMouseDelta = insGet(uis, "GetMouseDelta")
local IsMouseButtonPressed = insGet(uis, "IsMouseButtonPressed")
local IsKeyDown = insGet(uis, "IsKeyDown")
local GetDescendants = insGet(game, "GetDescendants")

local Inverse = cfGet(cf_0, "Inverse")
local Lerp = cfGet(cf_0, "Lerp")
local ns = NumberSequence.new
local nsk = NumberSequenceKeypoint.new
local nr = NumberRange.new
local u2scale = UDim2.fromScale
local u2offset = UDim2.fromOffset
local RigsTable = {}
local VLerp = v3_0.Lerp
local ULerp = u2().Lerp
local CLerp = c3().Lerp

local guiTheme={
	guiTitle="Exire's Reanimation",
	windowTitleColor=c3(1, 0.631372, 0.333333),
	windowTopColor=c3(0.168627, 0.101960, 0.078431),
	windowBottomColor=c3(0, 0, 0),
	windowMinimizedSize={X=220,Y=60},
	windowRegularSize={X=220,Y=290},
	buttonsTextColor=c3(0.960784, 0.525490, 0.325490),
	labelsTextColor=c3(0.968627, 0.654901, 0.396078),
	listTopColor=c3(0,0,0),
	listBottomColor=c3(0.0705882,0.0705882,0.0705882)
}

local accessorylimbs={
	{ meshid="110684113028749",textureid="70661572547971",C0=angles(0,0,0),Name="Torso" },
	{ meshid="104613079991268",textureid="83269599235494",C0=angles(0,0,0),Name="Torso" },
	{ meshid="125405780718494",textureid="136752500636691",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Arm" },
	{ meshid="125405780718494",textureid="136752500636691",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Arm" },
	{ meshid="125405780718494",textureid="136752500636691",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Leg" },
	{ meshid="125405780718494",textureid="136752500636691",C0=angles(0,0,1.5707963267948966),Name="Right Leg" },
	{ meshid="96333112188696",textureid="18807356481",C0=angles(0,0,0),Name="Left Arm" },
	{ meshid="96130316788066",textureid="18807356481",C0=angles(0,0,0),Name="Right Arm" },




	{meshid="11263221350",textureid="11263219250",C0=angles(0,0,0),Name="Left Arm"},

	{meshid="11159370334",textureid="11159284657",C0=angles(0,0,0),Name="Right Arm"},


	--// Noob Rigs 

	{meshid="137702817952968",textureid="135650240593878",C0=angles(0,0,80.05),Name="Left Arm"},
	{meshid="137702817952968",textureid="135650240593878",C0=angles(0,0,80.05),Name="Right Arm"},
	{meshid="137702817952968",textureid="73798034827573",C0=angles(0,0,80.09),Name="Left Leg"},
	{meshid="137702817952968",textureid="73798034827573",C0=angles(0,0,80.09),Name="Right Leg"},
	{meshid="126825022897778",textureid="125975972015302",C0=angles(0,0,0),Name="Torso"},

	--// White Rigs 

	{
	meshid="139733645770094",textureid="130809869695496",C0=angles(0,0,80.09),Name="Left Arm"
	},
	{
	meshid="90736849096372",textureid="79186624401216",C0=angles(0,0,80.09),Name="Right Arm"
	},
	{
	meshid="99608462237958",textureid="130809869695496",C0=angles(0,0,80.09),Name="Left Leg"
	},
	{
	meshid="105141400603933",textureid="71060417496309",C0=angles(0,0,80.09),Name="Right Leg"
	},


	{
	meshid="126825022897778",textureid="130689541138804",C0=angles(0,0,0),Name="Torso"
	},
	{
	meshid="100128920324073",textureid="133680105074740",C0=angles(rad(-75),rad(15),rad(-20)),Name="Right Leg"
	},
	{
	meshid="130309145260656",textureid="82390202293774",C0=angles(rad(-75),rad(-15),rad(20)),Name="Left Arm"
	},
	{
	meshid="130309145260656",textureid="93374633946646",C0=angles(rad(-75),rad(-15),rad(20)),Name="Left Leg"
	},
	{
	meshid="100128920324073",textureid="97155254696037",C0=angles(rad(-75),rad(15),rad(-20)),Name="Right Arm"
	},
	{ meshid = "18919712035", Name = "Torso", C0 = CFrame.identity, textureid = "18430134193" },--95290698984301

	{meshid="18881741455",textureid="18430134193",C0=angles(0,0,0),Name="Left Leg"},
	{meshid="18881739115",textureid="18430134193",C0=angles(0,0,0),Name="Right Leg"},

	{meshid="14255522247",textureid="",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Arm"},
	{meshid="14255522247",textureid="",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Arm"},

	{meshid="12344207333",textureid="",C0=angles(2,0,0),Name="Left Arm"},
	{meshid="12344206657",textureid="",C0=angles(2,0,0),Name="Right Arm"},

	{meshid="13831073174",textureid="",C0=cfMul(cf(0.017,0,-0.23),angles(-1.4835298641951802,-0.15707963267948966,2.199114857512855)),Name="Left Arm"},
	{meshid="13839903766",textureid="",C0=cfMul(cf(0,-0.62,-0.01),angles(1.6580627893946132,0.15707963267948966,-2.199114857512855)),Name="Right Arm"},

	{meshid="11159370334",textureid="11159285454",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Leg"},
	{meshid="12652772399",textureid="12652775021",C0=cf(0,-0.125,0),Name="Right Leg"},

	{meshid="14768684979",textureid="",C0=angles(0,0,1.5707963267948966),Name="Left Leg"},
	{meshid="14768684979",textureid="",C0=angles(0,0,1.5707963267948966),Name="Right Leg"},

	{meshid="14768666349",textureid="",C0=cf_0,Name="Torso"},
	{meshid="14241018198",textureid="",C0=cf_0,Name="Torso"},
	{meshid="13421774668",textureid="",C0=cf_0,Name="Torso"},

	{meshid="4324138105",textureid="4324138210",C0=cfMul(angles(-1.6144295580947547,1.5707963267948966,0),cf(-0.125,0.3,0)),Name="Left Arm"},
	{meshid="4154474745",textureid="4154474807",C0=cfMul(angles(1.5271630954950384,-1.5707963267948966,0),cf(-0.125,-0.3,0)),Name="Left Arm"},
	{meshid="3030546036",textureid="3650191503",C0=cfMul(angles(1.5271630954950384,1.5707963267948966,0),cf(0.125,-0.3,0)),Name="Right Arm"},
	{meshid="3030546036",textureid="3443321249",C0=cfMul(angles(-1.6144295580947547,-1.5707963267948966,0),cf(0.125,0.3,0)),Name="Right Arm"},
	{meshid="3030546036",textureid="3360974849",C0=cfMul(angles(1.5271630954950384,1.5707963267948966,0),cf(-0.125,-0.35,0)),Name="Left Leg"},
	{meshid="3030546036",textureid="3360978739",C0=cfMul(angles(-1.6144295580947547,-1.5707963267948966,0),cf(-0.125,0.3,0)),Name="Left Leg"},
	{meshid="3030546036",textureid="3033898741",C0=cfMul(angles(1.5271630954950384,-1.5707963267948966,0),cf(0.125,-0.35,0)),Name="Right Leg"},
	{meshid="3030546036",textureid="3409604993",C0=cfMul(angles(-1.6144295580947547,1.5707963267948966,0),cf(0.125,0.3,0)),Name="Right Leg"},
	{meshid="4324138105",textureid="4391374782",C0=cfMul(angles(-1.6144295580947547,1.5707963267948966,0),cf(0.125,0.3,0)),Name="Right Arm"},
	{meshid="4324138105",textureid="4391374782",C0=cfMul(angles(-1.6144295580947547,1.5707963267948966,0),cf(0.125,0.3,0)),Name="Right Arm"},
	{meshid="4819720316",textureid="4819722776",C0=angles(0,0,0.2617993877991494),Name="Torso"},


	{meshid="117287001096396",textureid="",C0=cf_0,Name="Left Arm"},
	{meshid="117287001096396",textureid="",C0=cf_0,Name="Right Arm"},

	{meshid="90736849096372",textureid="",C0=angles(0,0,1.5707963267948966),Name="Left Arm"},
	{meshid="105141400603933",textureid="",C0=angles(0,0,1.5707963267948966),Name="Right Arm"},

	{meshid="11263221350",textureid="11263219250",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Arm"},
	{meshid="11159370334",textureid="11159284657",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Arm"},

	{meshid="14255522247",textureid="",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Arm"},
	{meshid="14255522247",textureid="",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Arm"},

	{meshid="17374767929",textureid="",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Arm"},
	{meshid="17374767929",textureid="",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Arm"},

	{meshid="12344207333",textureid="",C0=angles(2,0,0),Name="Left Arm"},
	{meshid="12344206657",textureid="",C0=angles(2,0,0),Name="Right Arm"},

	{meshid="13831073174",textureid="",C0=cf(0.017,0,-0.23)*angles(-1.4835298641951802,-0.15707963267948966,2.199114857512855),Name="Left Arm"},
	{meshid="13839903766",textureid="",C0=cf(0,-0.62,-0.01)*angles(1.6580627893946132,0.15707963267948966,-2.199114857512855),Name="Right Arm"},

	{meshid="121304376791439",textureid="",C0=cf_0,Name="Left Leg"},
	{meshid="121304376791439",textureid="",C0=cf_0,Name="Right Leg"},

	{meshid="11159370334",textureid="11159285454",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Leg"},
	{meshid="12652772399",textureid="12652775021",C0=cf(0,-0.125,0),Name="Right Leg"},

	{meshid="14768684979",textureid="",C0=angles(0,0,1.5707963267948966),Name="Left Leg"},
	{meshid="14768684979",textureid="",C0=angles(0,0,1.5707963267948966),Name="Right Leg"},

	{meshid="17387586286",textureid="",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Leg"},
	{meshid="17387586286",textureid="",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Leg"},

	{meshid="14768666349",textureid="",C0=cf_0,Name="Torso"},
	{meshid="14241018198",textureid="",C0=cf_0,Name="Torso"},
	{meshid="13421774668",textureid="",C0=cf_0,Name="Torso"},
	{meshid="110684113028749",textureid="",C0=cf_0,Name="Torso"},
	{meshid="127552124837034",textureid="",C0=angles(0,0,1.5707963267948966),Name="Torso"},

	{meshid="4324138105",textureid="4324138210",C0=angles(-1.6144295580947547,1.5707963267948966,0)*cf(-0.125,0.3,0),Name="Left Arm"},
	{meshid="4154474745",textureid="4154474807",C0=angles(1.5271630954950384,-1.5707963267948966,0)*cf(-0.125,-0.3,0),Name="Left Arm"},
	{meshid="3030546036",textureid="3650191503",C0=angles(1.5271630954950384,1.5707963267948966,0)*cf(0.125,-0.3,0),Name="Right Arm"},
	{meshid="3030546036",textureid="3443321249",C0=angles(-1.6144295580947547,-1.5707963267948966,0)*cf(0.125,0.3,0),Name="Right Arm"},
	{meshid="3030546036",textureid="3360974849",C0=angles(1.5271630954950384,1.5707963267948966,0)*cf(-0.125,-0.35,0),Name="Left Leg"},
	{meshid="3030546036",textureid="3360978739",C0=angles(-1.6144295580947547,-1.5707963267948966,0)*cf(-0.125,0.3,0),Name="Left Leg"},
	{meshid="3030546036",textureid="3033898741",C0=angles(1.5271630954950384,-1.5707963267948966,0)*cf(0.125,-0.35,0),Name="Right Leg"},
	{meshid="3030546036",textureid="3409604993",C0=angles(-1.6144295580947547,1.5707963267948966,0)*cf(0.125,0.3,0),Name="Right Leg"},
	{meshid="4819720316",textureid="4819722776",C0=angles(0,0,0.2617993877991494),Name="Torso"},
	
	{meshid="117287001096396",textureid="",C0=cf_0,Name="Left Arm"},
	{meshid="117287001096396",textureid="",C0=cf_0,Name="Right Arm"},

	{meshid="90736849096372",textureid="",C0=angles(0,0,1.5707963267948966),Name="Left Arm"},
	{meshid="105141400603933",textureid="",C0=angles(0,0,1.5707963267948966),Name="Right Arm"},

	{meshid="11263221350",textureid="",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Arm"},
	{meshid="11159370334",textureid="",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Arm"},

	{meshid="14255522247",textureid="",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Arm"},
	{meshid="14255522247",textureid="",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Arm"},

	{meshid="17374767929",textureid="",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Arm"},
	{meshid="17374767929",textureid="",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Arm"},

	{meshid="12344207333",textureid="",C0=angles(2,0,0),Name="Left Arm"},
	{meshid="12344206657",textureid="",C0=angles(2,0,0),Name="Right Arm"},

	{meshid="13831073174",textureid="",C0=cf(0.017,0,-0.23)*angles(-1.4835298641951802,-0.15707963267948966,2.199114857512855),Name="Left Arm"},
	{meshid="13839903766",textureid="",C0=cf(0,-0.62,-0.01)*angles(1.6580627893946132,0.15707963267948966,-2.199114857512855),Name="Right Arm"},

	{meshid="121304376791439",textureid="",C0=cf_0,Name="Left Leg"},
	{meshid="121304376791439",textureid="",C0=cf_0,Name="Right Leg"},

	{meshid="11159370334",textureid="11159285454",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Leg"},
	{meshid="12652772399",textureid="12652775021",C0=cf(0,-0.125,0),Name="Right Leg"},

	{meshid="139733645770094",textureid="",C0=angles(0,0,1.5707963267948966),Name="Left Leg"},
	{meshid="99608462237958",textureid="",C0=angles(0,0,1.5707963267948966),Name="Right Leg"},

	{meshid="17387586286",textureid="",C0=angles(1.5707963267948966,0,1.5707963267948966),Name="Left Leg"},
	{meshid="17387586286",textureid="",C0=angles(-1.5707963267948966,0,1.5707963267948966),Name="Right Leg"},

	{meshid="14768666349",textureid="",C0=cf_0,Name="Torso"},
	{meshid="14241018198",textureid="",C0=cf_0,Name="Torso"},
	{meshid="13421774668",textureid="",C0=cf_0,Name="Torso"},
	{meshid="110684113028749",textureid="",C0=cf_0,Name="Torso"},
	{meshid="127552124837034",textureid="",C0=angles(0,0,1.5707963267948966),Name="Torso"},

	{meshid="4324138105",textureid="4324138210",C0=angles(-1.6144295580947547,1.5707963267948966,0)*cf(-0.125,0.3,0),Name="Left Arm"},
	{meshid="4154474745",textureid="4154474807",C0=angles(1.5271630954950384,-1.5707963267948966,0)*cf(-0.125,-0.3,0),Name="Left Arm"},
	{meshid="3030546036",textureid="3650191503",C0=angles(1.5271630954950384,1.5707963267948966,0)*cf(0.125,-0.3,0),Name="Right Arm"},
	{meshid="3030546036",textureid="3443321249",C0=angles(-1.6144295580947547,-1.5707963267948966,0)*cf(0.125,0.3,0),Name="Right Arm"},
	{meshid="3030546036",textureid="3360974849",C0=angles(1.5271630954950384,1.5707963267948966,0)*cf(-0.125,-0.35,0),Name="Left Leg"},
	{meshid="3030546036",textureid="3360978739",C0=angles(-1.6144295580947547,-1.5707963267948966,0)*cf(-0.125,0.3,0),Name="Left Leg"},
	{meshid="3030546036",textureid="3033898741",C0=angles(1.5271630954950384,-1.5707963267948966,0)*cf(0.125,-0.35,0),Name="Right Leg"},
	{meshid="3030546036",textureid="3409604993",C0=angles(-1.6144295580947547,1.5707963267948966,0)*cf(0.125,0.3,0),Name="Right Leg"},
	{meshid="4819720316",textureid="4819722776",C0=angles(0,0,0.2617993877991494),Name="Torso"}
}

--querydescendants faster than getchildren and checks in lua
local timeQueryDescendants=function(p,s,t)
	t=osclock()+t
	local refresh=true
	local con=Connect(insGet(p,"DescendantAdded"),function()
		refresh=true
	end)
	local res=nil
	repeat
		if refresh then
			res=QueryDescendants(p,s)
			if next(res) then
				--not using break to have one less jump opcode
				Disconnect(con)
				return res
			end
			refresh=false
		end
		Wait(preanimation)
	until (osclock()>t)
	Disconnect(con)
	return res
end
local makeplaceholder=function(v)
	if not insGet(v,"Archivable") then
		insSet(v,"Archivable",true)
	end
	v=Clone(v)
	local mesh=FindFirstChildOfClass(v,"SpecialMesh")
	if mesh then
		insSet(mesh,"Parent",nil)
		ClearAllChildren(v)
		ClearAllChildren(mesh)
		insSet(mesh,"Name",rs())
		insSet(mesh,"Parent",v)
	else
		ClearAllChildren(v)
	end
	insSet(v,"Name",rs())
	insSet(v,"Anchored",true)
	insSet(v,"CanCollide",false)
	insSet(v,"Transparency",0.25)
	return v
end
local emptyfunction=function() end

local i1=i("Frame") 
local i2=i("Frame") 
local i3=i("Frame") 
local i4=i("ScrollingFrame") 
local i5=i("UIListLayout") 
local i6=i("UIGradient") 
local i7=i("TextBox") 
local i8=i("TextButton") 
local i9=i("UIGradient") 
local i10=i("ScreenGui") 
insSet(i1,"AnchorPoint",v2(0.5,0))
insSet(i1,"Active",true)
insSet(i1,"BorderSizePixel",0)
insSet(i1,"ClipsDescendants",true)
insSet(i1,"Position",u2(0.5,0,0.5,guiTheme.windowRegularSize.Y/-2))
insSet(i1,"Size",u2(0,guiTheme.windowRegularSize.X,0,guiTheme.windowRegularSize.Y))
insSet(i1,"Name",rs())
insSet(i1,"Parent",i10)
insSet(i2,"BackgroundColor3",c3(1,1,1))
insSet(i2,"BorderSizePixel",0)
insSet(i2,"Size",u2(0,guiTheme.windowRegularSize.X,0,guiTheme.windowRegularSize.Y))
insSet(i2,"Name",rs())
insSet(i2,"Parent",i1)
insSet(i3,"BackgroundColor3",c3(1,1,1))
insSet(i3,"BorderSizePixel",0)
insSet(i3,"Position",u2(0,5,0,guiTheme.windowMinimizedSize.Y-2))
insSet(i3,"Size",u2(1,-10,0,guiTheme.windowRegularSize.Y-guiTheme.windowMinimizedSize.Y-3))
insSet(i3,"Name",rs())
insSet(i3,"Parent",i2)
insSet(i4,"Active",true)
insSet(i4,"BackgroundTransparency",1)
insSet(i4,"BorderSizePixel",0)
insSet(i4,"Size",u2(1,-3,1,0))
insSet(i4,"AutomaticCanvasSize",e.AutomaticSize.Y)
insSet(i4,"CanvasSize",u2(0,0,0,0))
insSet(i4,"ScrollBarThickness",7)
insSet(i4,"Name",rs())
insSet(i4,"Parent",i3)
insSet(i5,"Name",rs())
insSet(i5,"Parent",i4)
insSet(i5,"SortOrder",e.SortOrder.LayoutOrder)
insSet(i6,"Name",rs())
insSet(i6,"Parent",i3)
insSet(i6,"Color",cs({csk(0,guiTheme.listTopColor),csk(1,guiTheme.listBottomColor)}))
insSet(i6,"Rotation",90)
insSet(i7,"Font",e.Font.SourceSans)
insSet(i7,"FontSize",e.FontSize.Size18)
insSet(i7,"ClearTextOnFocus",false)
insSet(i7,"Text",guiTheme.guiTitle)
insSet(i7,"TextColor3",guiTheme.windowTitleColor)
insSet(i7,"TextSize",16)
insSet(i7,"AnchorPoint",v2(0.5,0))
insSet(i7,"BackgroundTransparency",1)
insSet(i7,"Position",u2(0.5,0,0,guiTheme.windowMinimizedSize.Y/2))
insSet(i7,"Name",rs())
insSet(i7,"Parent",i2)
insSet(i8,"AnchorPoint",v2(1,0))
insSet(i8,"BackgroundTransparency",1)
insSet(i8,"Position",u2(1,0,0,0))
insSet(i8,"Size",u2(0,40,0,guiTheme.windowMinimizedSize.Y))
insSet(i8,"Name",rs())
insSet(i8,"Parent",i2)
insSet(i8,"Font",e.Font.SourceSans)
insSet(i8,"FontSize",e.FontSize.Size18)
insSet(i8,"Text","-")
insSet(i8,"TextColor3",c3(1,1,1))
insSet(i8,"TextSize",16)
insSet(i9,"Name",rs())
insSet(i9,"Parent",i2)
insSet(i9,"Color",cs({csk(0,guiTheme.windowTopColor),csk(1,guiTheme.windowBottomColor)}))
insSet(i9,"Rotation",90)
insSet(i10,"ZIndexBehavior",e.ZIndexBehavior.Sibling)
insSet(i10,"IgnoreGuiInset",true)
insSet(i10,"ResetOnSpawn",false)
insSet(i10,"DisplayOrder",2147483647)
insSet(i10,"Name",rs())
local guimin=false
local minloop=false
local i1X=guiTheme.windowRegularSize.X
local i1Y=guiTheme.windowRegularSize.Y
local i1Xdest=i1X
local i1Ydest=i1Y
Connect(insGet(i8,"MouseButton1Click"),function()
	guimin = not guimin
	if guimin then
		i1Xdest=guiTheme.windowMinimizedSize.X
		i1Ydest=guiTheme.windowMinimizedSize.Y
	else
		i1Xdest=guiTheme.windowRegularSize.X
		i1Ydest=guiTheme.windowRegularSize.Y
	end
	if minloop then
		return
	end
	minloop=true
	insSet(i3,"Visible",true) 
	sine=osclock()
	local lastsine=sine
	while true do
		sine=osclock()
		local deltaTime=(sine-lastsine)*10
		lastsine=sine
		local difX=i1Xdest-i1X
		local difY=i1Ydest-i1Y
		if (abs(difY)<=1) and (abs(difX)<=1) then
			i1X=i1Xdest
			i1Y=i1Ydest
			insSet(i1,"Size",u2(0,i1X,0,i1Y))
			insSet(i3,"Visible",not guimin) 
			minloop=false
			return
		end
		i1X=i1X+difX*deltaTime
		i1Y=i1Y+difY*deltaTime
		insSet(i1,"Size",u2(0,i1X,0,i1Y))
		twait()
	end
	insSet(i3,"Visible",not guimin) 
	minloop=false
end)
local Draggable=function(window,obj)
	local MB1enum = e.UserInputType.MouseButton1
	local TOUCHenum = e.UserInputType.Touch
	obj = obj or window
	local activeEntered = 0
	local mouseStart = nil
	local dragStart = nil
	local inputbegancon = nil
	local rendersteppedcon = nil
	local inputendedcon = nil
	local inputendedf=function(a)
		a=insGet(a,"UserInputType")
		if (a==MB1enum) or (a==TOUCHenum) then
			Disconnect(rendersteppedcon)
			Disconnect(inputendedcon)
		end
	end
	local rendersteppedf=function()
		local off = GetMouseLocation(uis)-mouseStart
		insSet(window,"Position",dragStart+u2(0,v2Get(off,"X"),0,v2Get(off,"Y")))
	end
	local inputbeganf=function(a)
		a=insGet(a,"UserInputType")
		if ((a==MB1enum) or (a==TOUCHenum)) and (activeEntered==0) and not GetFocusedTextBox(uis) then
			mouseStart=GetMouseLocation(uis)
			dragStart=insGet(window,"Position")
			if rendersteppedcon then Disconnect(rendersteppedcon) end
			rendersteppedcon = Connect(renderstepped,rendersteppedf)
			if inputendedcon then Disconnect(inputendedcon) end
			inputendedcon = Connect(insGet(uis,"InputEnded"),inputendedf)
		end
	end
	Connect(insGet(obj,"MouseEnter"),function()
		if inputbegancon then Disconnect(inputbegancon) end
		inputbegancon = Connect(insGet(uis,"InputBegan"),inputbeganf)
	end)
	Connect(insGet(obj,"MouseLeave"),function()
		Disconnect(inputbegancon)
	end)
	local ondes=function(d)
		if IsA(d,"GuiObject") then
			local thisEntered = false
			local thisAdded = false
			local con0 = Connect(insGet(d,"MouseEnter"),function()
				thisEntered = true
				if (not thisAdded) and insGet(d,"Active") then
					activeEntered = activeEntered + 1
					thisAdded = true
				end
			end)
			local con1 = Connect(insGet(d,"MouseLeave"),function()
				thisEntered = false
				if thisAdded then
					activeEntered = activeEntered - 1
					thisAdded = false
				end
			end)
			local con2 = Connect(GetPropertyChangedSignal(d,"Active"),function()
				if thisEntered then
					if thisAdded and not insGet(d,"Active") then
						activeEntered = activeEntered - 1
						thisAdded = false
					elseif insGet(d,"Active") and not thisAdded then
						activeEntered = activeEntered + 1
						thisAdded = true
					end
				end
			end)
			local con3 = nil
			con3 = Connect(insGet(d,"AncestryChanged"),function()
				if not IsDescendantOf(d,window) then
					if thisAdded then
						activeEntered = activeEntered - 1
					end
					Disconnect(con0)
					Disconnect(con1)
					Disconnect(con2)
					Disconnect(con3)
				end
			end)
		end
	end
	Connect(insGet(window,"DescendantAdded"),ondes)
	for i,v in next,QueryDescendants(window,"GuiObject") do 
		ondes(v)
	end
end
local btn=function(txt, f)
	local i1=i("TextBox") 
	local i2=i("TextButton")
	insSet(i1,"Font",e.Font.SourceSans)
	insSet(i1,"FontSize",e.FontSize.Size14)
	insSet(i1,"Text",txt)
	insSet(i1,"ClearTextOnFocus",false)
	insSet(i1,"Position",u2(0.5,0,0.5,0))
	insSet(i1,"TextColor3",guiTheme.buttonsTextColor)
	insSet(i1,"Name",rs())
	insSet(i1,"Parent",i2)
	insSet(i2,"BackgroundTransparency",1)
	insSet(i2,"TextTransparency",1)
	insSet(i2,"Size",u2(1,0,0,14))
	insSet(i2,"Name",rs())
	if f then 
		Connect(insGet(i2,"MouseButton1Click"),f) 
	end 
	insSet(i2,"Parent",i4)
	return i1
end
local lbl=function(txt)
	local i1=i("TextBox") 
	local i2=i("Frame") 
	insSet(i1,"Font",e.Font.SourceSans)
	insSet(i1,"FontSize",e.FontSize.Size14)
	insSet(i1,"Text",txt)
	insSet(i1,"ClearTextOnFocus",false)
	insSet(i1,"TextColor3",guiTheme.labelsTextColor)
	insSet(i1,"Position",u2(0.5,0,0.5))
	insSet(i1,"BackgroundTransparency",1)
	insSet(i1,"Name",rs())
	insSet(i1,"Parent",i2)
	insSet(i2,"Size",u2(1,0,0,14))
	insSet(i2,"BackgroundTransparency",1)
	insSet(i2,"Name",rs())
	insSet(i2,"Parent",i4)
	return i1
end
local swtc=function(txt,options,onchanged)
	local current=0
	local swtcbtn=nil
	local btnpressed=function()
		current=current+1
		if current>#options then
			current=1
		end
		local option=options[current]
		insSet(swtcbtn,"Text",txt..": "..option.text)
		onchanged(option.value)
	end
	swtcbtn=btn(txt,btnpressed)
	btnpressed()
	return swtcbtn
end

Draggable(i1)

local allowshiftlock=nil
local ctrltp=nil
local placeholders=nil
local clickfling=nil
local highlightflingtargets=nil
local discharscripts=nil
local flingchangestate=nil
local respawntp=1
local breakjointsmethod=1
local simrad=true
local hidedeatheffect=true
local permadeath=nil
local refit=true

local c=nil
local cons={}
local cframes={}
local charcons={}
local flingtable={}
local onnewcamera=nil
local stopreanimate=function() 
	if c then
		c=nil
		if permadeath then
			-- replicatesignal(cdsb)
		end
		for i,v in next,cframes do
			local p=i.v
			if p then
				Destroy(p)
			end
		end
		tclear(cframes)
		for i,v in next,flingtable do
			if v then --it could be false
				Destroy(v)
			end
		end
		tclear(flingtable)
		for i,v in next,charcons do
			Disconnect(v)
		end
		tclear(charcons)
		for i,v in next,cons do
			Disconnect(v)
		end
		tclear(cons)
		insSet(uis,"MouseBehavior",enumMD)
		onnewcamera()
		return true
	end
	return false
end
local reanimate=function()
	--[[
		FDless reanimate by MyWorld
		optimize the optimized
	]]

	local novoid = true --prevents parts from going under workspace.FallenPartsDestroyHeight if you control them
	local speedlimit = 3000 --makes your parts move slower if the magnitude of their velocity is higher than this
	local retVelTime = 0.51 --time that claimed parts have velocity to reclaim in case u lose them
	local walkSpeed = 30 --your walkspeed (can be changed at runtime)
	local jumpPower = 50 --your jump power (can be changed at runtime)
	local gravity = 196.2 --how fast the characters velocity decreases while falling (can be changed at runtime)
	local ctrlclicktp = ctrltp --makes you teleport where u point ur mouse cursor at when click and hold ctrl down
	local clickfling = clickfling --makes you fling the person you clicked when its available to do so
	local flingvel = v3(15000,16000,15000) --the rotation velocity that ur character will have while flinging

	if stopreanimate() then 
		local SoundService = game:GetService("SoundService")

		for _, object in ipairs(SoundService:GetChildren()) do
				if object.Name:find("ModeMusic_") then
						object:Destroy()
				end
		end

		local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		
		local existingHUD = PlayerGui:FindFirstChild("StarGlitcherHUD")
		if existingHUD then
			existingHUD:Destroy()
			return
		end
	return end
	c=insGet(lp,"Character")
	if not (c and IsDescendantOf(c,ws)) then return end

	local rootpart=QueryDescendants(c,">BasePart#HumanoidRootPart")[1] or QueryDescendants(c,">BasePart#Torso")[1] or QueryDescendants(c,">BasePart#UpperTorso")[1] or timeQueryDescendants(c,">BasePart#HumanoidRootPart",10)[1] or (c and FindFirstChildWhichIsA(c,"BasePart"))
	if not rootpart then return end

	local cam=nil
	--theres a way to have ws.currentcamera nil on heartbeat and still have the game run normally
	local refcam=function()
		local newcam=insGet(ws,"CurrentCamera")
		while not newcam do
			Wait(GetPropertyChangedSignal(ws,"CurrentCamera"))
			newcam=insGet(ws,"CurrentCamera")
		end
		cam=newcam
	end
	refcam()
	local camcf=insGet(cam,"CFrame")
	local enumCamS=e.CameraType.Scriptable
	local camt=insGet(cam,"CameraType")
	local camcon0=nil
	local camcon1=nil
	local camcon2=nil
	onnewcamera=function()
		refcam()
		if camcon0 then 
			Disconnect(camcon0)
			Disconnect(camcon1)
			camcon0=nil
		end
		if not c then 
			if insGet(cam,"CameraType")==enumCamS then
				insSet(cam,"CameraType",camt)
			end
			return Disconnect(camcon2) 
		end
		camcon0=Connect(GetPropertyChangedSignal(cam,"CFrame"),function()
			if insGet(cam,"CFrame")~=camcf then
				insSet(cam,"CFrame",camcf)
			end
		end)
		camcon1=Connect(GetPropertyChangedSignal(cam,"CameraType"),function()
			if insGet(cam,"CameraType")~=enumCamS then
				insSet(cam,"CameraType",enumCamS)
			end
		end)
		if insGet(cam,"CameraType")~=enumCamS then
			insSet(cam,"CameraType",enumCamS)
		end
		if insGet(cam,"CFrame")~=camcf then
			insSet(cam,"CFrame",camcf)
		end
	end
	camcon2=Connect(GetPropertyChangedSignal(ws,"CurrentCamera"),onnewcamera)
	onnewcamera()

	local velYdelta=insGet(ws,"Gravity")*0.025
	Connect(GetPropertyChangedSignal(ws,"Gravity"),function()
		velYdelta=insGet(ws,"Gravity")*0.025
	end)

	local fpdh=insGet(ws,"FallenPartsDestroyHeight")
	novoid=novoid and (fpdh+1)

	local Yvel=0
	local cfr=insGet(rootpart,"CFrame")
	local pos=cfGet(cfr,"Position")
	cfr=cfl(pos,pos+cfGet(cfr,"LookVector")*v3_101)
	local primarypart=nil
	local shiftlock=false
	local firstperson=false
	local xzvel=v3_0
	local v3_0150=v3_010*1.5
	local camcfLV=cfGet(camcf,"LookVector")
	local camrot=cfl(v3_0,camcfLV)
	local camrotX,camrotY=camrot:ToEulerAnglesYXZ()
	local camcfRV=cfGet(camrot,"RightVector")
	local cammag=-vmagnitude((cfGet(camcf,"Position")-(pos+v3_0150)))

	local R6parts={ 
		head={Name="Head"},
		torso={Name="Torso"},
		root={Name="HumanoidRootPart"},
		leftArm={Name="Left Arm"},
		rightArm={Name="Right Arm"},
		leftLeg={Name="Left Leg"},
		rightLeg={Name="Right Leg"}
	}
	rootpart=R6parts.root
	for i,v in next,R6parts do
		cframes[v]=cfr
	end
	local joints={
		{
			Name="Neck",
			Part0=R6parts.torso,Part1=R6parts.head,
			C0=cf(0,1,0,-1,0,0,0,0,1,0,1,-0),
			C1=cf(0,-0.5,0,-1,0,0,0,0,1,0,1,-0)
		},
		{
			Name="RootJoint",
			Part0=rootpart,Part1=R6parts.torso,
			C0=cf(0,0,0,-1,0,0,0,0,1,0,1,-0),
			C1=cf(0,0,0,-1,0,0,0,0,1,0,1,-0)
		},
		{
			Name="Right Shoulder",
			Part0=R6parts.torso,Part1=R6parts.rightArm,
			C0=cf(1,0.5,0,0,0,1,0,1,-0,-1,0,0),
			C1=cf(-0.5,0.5,0,0,0,1,0,1,-0,-1,0,0)
		},
		{
			Name="Left Shoulder",
			Part0=R6parts.torso,Part1=R6parts.leftArm,
			C0=cf(-1,0.5,0,0,0,-1,0,1,0,1,0,0),
			C1=cf(0.5,0.5,0,0,0,-1,0,1,0,1,0,0)
		},
		{
			Name="Right Hip",
			Part0=R6parts.torso,Part1=R6parts.rightLeg,
			C0=cf(1,-1,0,0,0,1,0,1,-0,-1,0,0),
			C1=cf(0.5,1,0,0,0,1,0,1,-0,-1,0,0)
		},
		{
			Name="Left Hip",
			Part0=R6parts.torso,Part1=R6parts.leftLeg,
			C0=cf(-1,-1,0,0,0,-1,0,1,0,1,0,0),
			C1=cf(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
		}
	}

	local refreshedjoints={}
	local refreshjointsI=nil
	refreshjointsI=function(part)
		refreshedjoints[part]=true
		for i,v in next,joints do
			local part0=v.Part0
			local part1=v.Part1
			if part1 and (part0==part) then
				cframes[part1]=cfMul(cframes[part],cfMul(v.C0,Inverse(v.C1)))
				if not refreshedjoints[part1] then
					refreshjointsI(part1)
				end
			elseif part0 and (part1==part) then
				cframes[part0]=cfMul(cframes[part],cfMul(v.C1,Inverse(v.C0)))
				if not refreshedjoints[part0] then
					refreshjointsI(part0)
				end
			end
		end
	end
	refreshjointsI(rootpart)
	tclear(refreshedjoints)

	local attachments={
		RightShoulderAttachment={R6parts.rightArm,cf(0,1,0,1,0,0,0,1,0,0,0,1)},
		RightGripAttachment={R6parts.rightArm,cf(0,-1,0,1,0,0,0,1,0,0,0,1)},
		LeftFootAttachment={R6parts.leftLeg,cf(0,-1,0,1,0,0,0,1,0,0,0,1)},
		LeftShoulderAttachment={R6parts.leftArm,cf(0,1,0,1,0,0,0,1,0,0,0,1)},
		LeftGripAttachment={R6parts.leftArm,cf(0,-1,0,1,0,0,0,1,0,0,0,1)},
		RootAttachment={rootpart,cf(0,0,0,1,0,0,0,1,0,0,0,1)},
		RightFootAttachment={R6parts.rightLeg,cf(0,-1,0,1,0,0,0,1,0,0,0,1)},
		NeckAttachment={R6parts.torso,cf(0,1,0,1,0,0,0,1,0,0,0,1)},
		BodyFrontAttachment={R6parts.torso,cf(0,0,-0.5,1,0,0,0,1,0,0,0,1)},
		BodyBackAttachment={R6parts.torso,cf(0,0,0.5,1,0,0,0,1,0,0,0,1)},
		LeftCollarAttachment={R6parts.torso,cf(-1,1,0,1,0,0,0,1,0,0,0,1)},
		RightCollarAttachment={R6parts.torso,cf(1,1,0,1,0,0,0,1,0,0,0,1)},
		WaistFrontAttachment={R6parts.torso,cf(0,-1,-0.5,1,0,0,0,1,0,0,0,1)},
		WaistCenterAttachment={R6parts.torso,cf(0,-1,0,1,0,0,0,1,0,0,0,1)},
		WaistBackAttachment={R6parts.torso,cf(0,-1,0.5,1,0,0,0,1,0,0,0,1)},
		HairAttachment={R6parts.head,cf(0,0.6,0,1,0,0,0,1,0,0,0,1)},
		HatAttachment={R6parts.head,cf(0,0.6,0,1,0,0,0,1,0,0,0,1)},
		FaceFrontAttachment={R6parts.head,cf(0,0,-0.6,1,0,0,0,1,0,0,0,1)},
		FaceCenterAttachment={R6parts.head,cf(0,0,0,1,0,0,0,1,0,0,0,1)}
	}

	local getPart=function(name,blacklist)
		if blacklist then
			for i,v in next,cframes do
				if (i.Name==name) and not tfind(blacklist,i) then
					return i
				end
			end
		else
			for i,v in next,cframes do
				if i.Name==name then
					return i
				end
			end
		end
		return nil
	end

	local getJoint=function(name)
		for i,v in next,joints do
			if v.Name==name then
				return v
			end
		end
		return {C0=cf_0,C1=cf_0}
	end

	local getPartFromMesh=function(m,t,blacklist)
		if blacklist then
			for v,_ in next,cframes do
				if v.m and (not tfind(blacklist,v)) and sfind(v.m,m) and sfind(v.t,t) then
					return v
				end
			end
		else
			for v,_ in next,cframes do
				if v.m and sfind(v.m,m) and sfind(v.t,t) then
					return v
				end
			end
		end
		local p={m=m,t=t}
		cframes[p]=cfr
		local j={C0=cf_0,C1=cf_0,Part0=p}
		p.j=j
		return p
	end

	local getPartJoint=function(p)
		if cframes[p] then
			local j=p.j
			if j then
				return j
			end
			for i,v in next,joints do
				if v.Part0==p then
					return v
				end
			end
			for i,v in next,joints do
				if v.Part1==p then
					return v
				end
			end
		end
		return nil
	end

	local getAccWeldFromMesh=function(m,t)
		return getPartJoint(getPartFromMesh(m,t))
	end

	local raycastparams=rp()
	raycastparams.FilterType=e.RaycastFilterType.Exclude
	raycastparams.RespectCanCollide=true
	local rayfilter={}
	local characters={}
	local refreshrayfilter=function()
		tclear(rayfilter)
		for i,v in next,characters do
			tinsert(rayfilter,v)
		end
		raycastparams.FilterDescendantsInstances=rayfilter
	end
	local rootparts={}
	for i,v in next,accessorylimbs do
		v.p=getPart(v.Name)
	end
	local makePartCons=function(p,t)
		if (t.p==p) and insGet(p,"Anchored") then
			t.p=nil
		end
		local con0=Connect(GetPropertyChangedSignal(p,"Anchored"),function()
			if insGet(p,"Anchored") then
				if t.p==p then
					t.c=nil
					t.p=nil
				end
			elseif not t.p then
				t.p=p
			end
		end)
		local con1=nil
		con1=Connect(insGet(p,"AncestryChanged"),function()
			if not IsDescendantOf(p,ws) then
				Disconnect(con0)
				Disconnect(con1)
				if t.p==p then
					t.p=nil
				end
				if refit and c then
					-- replicatesignal(cdsb)
				end
			end
		end)
	end
	local ondes=function(v)
		if IsA(v,"Attachment") then
			local v1=attachments[insGet(v,"Name")]
			if v1 then
				local p=insGet(v,"Parent")
				if insGet(p,"Parent")~=c then
					local meshid=nil
					local textureid=nil
					if IsA(p,"MeshPart") then
						meshid=insGet(p,"MeshId")
						textureid=insGet(p,"TextureID")
					elseif IsA(p,"BasePart") then
						local sm=FindFirstChildOfClass(p,"SpecialMesh")
						if sm then
							meshid=insGet(sm,"MeshId")
							textureid=insGet(sm,"TextureId")
						else
							return
						end
					else
						return
					end
					for i,_ in next,cframes do
						if (meshid==i.m) and (textureid==i.t) then
							local p1=i.p
							if p1 then
								if p1==p then
									return
								end
							else
								i.p=p
								makePartCons(p,i)
								return
							end
						else
							local j=i.j
							if j and sfind(meshid,i.m) and sfind(textureid,i.t) then
								i.m=meshid
								i.t=textureid
								i.l=insGet(p,"Position")
								i.p=p
								makePartCons(p,i)
								i.j=nil
								i.Name=insGet(p,"Name")
								j.C0=insGet(v,"CFrame")
								j.C1=v1[2]
								j.Part1=v1[1]
								tinsert(joints,j)
								return
							end
						end
					end
					for i,l in next,accessorylimbs do
						if l.p and sfind(meshid,l.meshid) and sfind(textureid,l.textureid) then
							local t={Name=insGet(p,"Name"),l=insGet(p,"Position"),m=meshid,t=textureid,p=p}
							makePartCons(p,t)
							if placeholders then
								t.v=makeplaceholder(p)
								t.b=false
							end
							cframes[t]=insGet(p,"CFrame")
							tinsert(joints,{Part0=t,Part1=l.p,C0=l.C0,C1=cf_0})
							l.p=nil
							return
						end
					end
					local t={Name=insGet(p,"Name"),l=insGet(p,"Position"),m=meshid,t=textureid,p=p}
					makePartCons(p,t)
					if placeholders then
						t.v=makeplaceholder(p)
						t.b=false
					end
					cframes[t]=insGet(p,"CFrame")
					tinsert(joints,{Part0=t,Part1=v1[1],C0=insGet(v,"CFrame"),C1=v1[2]})
				end
			end
		end
	end

	local simradv=0
	local enumH=e.CoreGuiType.Health
	local onplayer=function(v)
		simradv=simradv+1000
		local islp=v==lp
		local lastc=nil
		local oncharacter=function()
			local newc=insGet(v,"Character")
			if newc and (newc~=lastc) then
				lastc=newc
				characters[v]=newc
				refreshrayfilter()
				if islp then
					if discharscripts then
						Connect(insGet(newc,"DescendantAdded"),discharscripts)
						for i,v in next,QueryDescendants(newc,"Script") do
							insSet(v,"Disabled",true)
						end
					end
					local hrp=timeQueryDescendants(newc,">BasePart#HumanoidRootPart",10)[1]
					if not (hrp and c and IsDescendantOf(newc,ws)) then return end
					c=newc
					local fi,fv=next(flingtable)
					if fi then
						if permadeath and not pdloadedtime then
							 -- replicatesignal(cdsb)
							pdloadedtime=osclock()+rst
						end
						if flingchangestate==3 then
							local hum=FindFirstChildOfClass(c,"Humanoid")
							if hum then
								insGet(hum,"ChangeState")(hum,e.HumanoidStateType.Physics)
								insGet(hum,"SetStateEnabled")(hum,e.HumanoidStateType.Seated,false)
							end
						elseif flingchangestate==1 then
							local hum=FindFirstChildOfClass(c,"Humanoid")
							if hum then
								insGet(hum,"ChangeState")(hum,e.HumanoidStateType.Physics)
							end
						elseif flingchangestate==2 then
							local hum=FindFirstChildOfClass(c,"Humanoid")
							if hum then
								insGet(hum,"SetStateEnabled")(hum,e.HumanoidStateType.Seated,false)
							end
						end
						for i,v in next,tclone(flingtable) do
							if not c then
								return
							end
							local startpos=insGet(i,"Position")
							local stoptime=sine+3
							while true do
								twait()
								if sine>stoptime then
									break
								end
								if insGet(i,"Anchored") or not IsDescendantOf(i,ws) then
									break
								end
								if vmagnitude(startpos-insGet(i,"Position"))>200 then
									break
								end
								local tcf=cfAdd(insGet(i,"CFrame"),insGet(i,"AssemblyLinearVelocity")*(sin(sine*15)+1))
								if novoid and (cfGet(tcf,"Y")<novoid) then
									tcf=cfAdd(tcf,v3_010*(novoid-cfGet(tcf,"Y")))
								end
								insSet(hrp,"CFrame",tcf)
								insSet(hrp,"AssemblyLinearVelocity",insGet(i,"AssemblyLinearVelocity")*v3_101*75)
								insSet(hrp,"AssemblyAngularVelocity",flingvel)
							end
							if v then
								Destroy(v)
							end
							flingtable[i]=nil
						end
						insSet(hrp,"AssemblyLinearVelocity",v3_0)
						insSet(hrp,"AssemblyAngularVelocity",v3_0)
						insSet(hrp,"CFrame",cfr)
						twait(0.15)
					end
					if respawntp==0 then
						twait()
					elseif respawntp==1 then
						local startpos=pos+v3(mrandom(-32,32),0,mrandom(-32,32))
						local dir=nil
						local poscheck=true
						while poscheck do
							poscheck=false
							for i,v in next,rootparts do
								local diff=(startpos-insGet(v,"Position"))*v3_101
								if vmagnitude(diff)<10 then
									poscheck=true
									dir=dir or (vnormalize(diff)*3)
									startpos=startpos+dir
								end
							end
							local diff=(startpos-pos)*v3_101
							if vmagnitude(diff)<10 then
								poscheck=true
								dir=dir or (vnormalize(diff)*3)
								startpos=startpos+dir
							end
						end
						startpos=cfAdd(cfGet(cfr,"Rotation"),startpos)
						insSet(hrp,"CFrame",startpos)
						insSet(hrp,"AssemblyLinearVelocity",v3_0)
						insSet(hrp,"AssemblyAngularVelocity",v3_0)
						twait(0.25)
					elseif respawntp==2 then
						insSet(hrp,"CFrame",cfAdd(cfr,cfGet(cfr,"RightVector")*3.5-cfGet(cfr,"LookVector")*3.5))
						insSet(hrp,"AssemblyLinearVelocity",v3_0)
						insSet(hrp,"AssemblyAngularVelocity",v3_0)
						twait(0.25)
					elseif respawntp==3 then
						local t=osclock()+0.25
						if pdloadedtime and pdloadedtime>t then
							t=pdloadedtime
						end
						local startcf=cfAdd(cfMul(cfGet(cfr,"Rotation"),angles(1.5707963267948966,0,0)),pos*v3_101+v3_010*min(fpdh+30,v3Get(pos,"Y")-5))
						while twait() do
							insSet(hrp,"CFrame",startcf)
							insSet(hrp,"AssemblyLinearVelocity",v3_0)
							insSet(hrp,"AssemblyAngularVelocity",v3_0)
							if osclock()>t then
								break
							end
						end
					end
					if newc~=c then
						return
					end
					primarypart=insGet(newc,"PrimaryPart") or hrp
					if hidedeatheffect and GetCoreGuiEnabled(sg,enumH) then
						SetCoreGuiEnabled(sg,enumH,false)
					end
					if pdloadedtime then
						if (osclock()<pdloadedtime) then
							twait(pdloadedtime-osclock())
						end
						pdloadedtime=nil
					end
					if breakjointsmethod==4 then
						local h=FindFirstChildOfClass(newc,"Humanoid")
						if h then
							replicatesignal(insGet(h,"ServerBreakJoints"))
						else
							insGet(newc,"BreakJoints")(newc)
						end
					elseif breakjointsmethod==1 then
						insGet(newc,"BreakJoints")(newc)
						local h=FindFirstChildOfClass(newc,"Humanoid")
						if h then
							insSet(h,"Health",0)
						end
					elseif breakjointsmethod==2 then
						local h=FindFirstChildOfClass(newc,"Humanoid")
						if h then
							insSet(h,"Health",0)
						else
							insGet(newc,"BreakJoints")(newc)
						end
					else
						insGet(newc,"BreakJoints")(newc)
					end
					cons.ondes=Connect(insGet(newc,"DescendantAdded"),ondes)
					for i,v in next,QueryDescendants(newc,"Attachment") do
						ondes(v)
					end
				else
					local hrp=timeQueryDescendants(newc,">BasePart#HumanoidRootPart",10)[1]
					if hrp and IsDescendantOf(newc,ws) then
						rootparts[v]=hrp
					end
				end
			end
		end
		charcons[v]=Connect(GetPropertyChangedSignal(v,"Character"),oncharacter)
		oncharacter()
	end


	tinsert(cons,Connect(insGet(plrs,"PlayerRemoving"),function(v)
		simradv=simradv-1000
		local charcon=charcons[v]
		if charcon then
			Disconnect(charcon)
		end
		characters[v]=nil
		rootparts[v]=nil
	end))
	for i,v in next,GetPlayers(plrs) do simradv=simradv+1000 if v~=lp then tspawn(onplayer,v) end end
	tinsert(cons,Connect(insGet(plrs,"PlayerAdded"),onplayer))
	onplayer(lp)
	local setsimrad=emptyfunction
	if simrad then
		setsimrad=function()
			if pcall(insSet,lp,"SimulationRadius",simradv) then
				setsimrad=function()
					insSet(lp,"SimulationRadius",simradv)
				end
			else
				setsimrad=emptyfunction
			end
		end
	end

	local mradN05=-0.008726646259971648
	local pi2=math.pi/2-0.0001
	local npi2=-pi2
	local KeyCode=e.KeyCode
	local enumYXZ=e.RotationOrder.YXZ
	local enumMB2=e.UserInputType.MouseButton2
	local enumMLCP=e.MouseBehavior.LockCurrentPosition
	local enumMLC=(insGet(uis,"TouchEnabled") and enumMLCP) or e.MouseBehavior.LockCenter 
	local enumMW=e.UserInputType.MouseWheel
	local enumMM=e.UserInputType.MouseMovement

	local mouseBehavior=insGet(uis,"MouseBehavior")
	tinsert(cons,Connect(GetPropertyChangedSignal(uis,"MouseBehavior"),function()
		if insGet(uis,"MouseBehavior")~=mouseBehavior then
			insSet(uis,"MouseBehavior",mouseBehavior)
		end
	end))

	local mode="default"
	local defaultmode={}
	local modes={default=defaultmode}

	local lerpsIdle=emptyfunction
	local lerpsWalk=emptyfunction
	local lerpsJump=emptyfunction
	local lerpsFall=emptyfunction

	local addmode=function(key,mode)
		if (type(key)~="string") or (type(mode)~="table") then
			return
		end
		for i,v in next,mode do
			if type(v)~="function" then
				mode[i]=nil
			end
		end
		if key=="default" then
			defaultmode=mode
			modes.default=mode
			lerpsIdle=mode.idle or emptyfunction
			lerpsWalk=mode.walk or emptyfunction
			lerpsJump=mode.jump or emptyfunction
			lerpsFall=mode.fall or emptyfunction
			if mode.modeEntered then
				mode.modeEntered()
			end
		elseif #key==1 then
			key=KeyCode[supper(ssub(key,1,1))]
			modes[key]=mode
		end
	end

	local keyW=KeyCode.W
	local Wpressed=IsKeyDown(uis,keyW)
	local keyA=KeyCode.A
	local Apressed=IsKeyDown(uis,keyA)
	local keyS=KeyCode.S
	local Spressed=IsKeyDown(uis,keyS)
	local keyD=KeyCode.D
	local Dpressed=IsKeyDown(uis,keyD)
	local keySpace=KeyCode.Space
	local jumpingInput=IsKeyDown(uis,keySpace)

	local FWmovement=0
	local RTmovement=0
	local isWalking=false
	local refreshKeyboardMovement=function()
		if Wpressed then if Spressed then if Dpressed then if Apressed then isWalking=false else FWmovement=0 RTmovement=1 isWalking=true end else if Apressed then FWmovement=0 RTmovement=-1 isWalking=true else isWalking=false end end else FWmovement=1 if Dpressed then if Apressed then RTmovement=0 else RTmovement=1 end else if Apressed then RTmovement=-1 else RTmovement=0 end end isWalking=true end else if Spressed then FWmovement=-1 if Dpressed then if Apressed then RTmovement=0 else RTmovement=1 end else if Apressed then RTmovement=-1 else RTmovement=0 end end isWalking=true else if Dpressed then if Apressed then isWalking=false else FWmovement=0 RTmovement=1 isWalking=true end else if Apressed then FWmovement=0 RTmovement=-1 isWalking=true else isWalking=false end end end end
	end
	refreshKeyboardMovement()

	local keyShift=KeyCode.LeftShift
	tinsert(cons,Connect(insGet(uis,"InputBegan"),function(a)
		if insGet(gs,"MenuIsOpen") or GetFocusedTextBox(uis) then
			return
		end
		a=insGet(a,"KeyCode")
		if a==keyW then
			Wpressed=true
			refreshKeyboardMovement()
		elseif a==keyA then
			Apressed=true
			refreshKeyboardMovement()
		elseif a==keyS then
			Spressed=true
			refreshKeyboardMovement()
		elseif a==keyD then
			Dpressed=true
			refreshKeyboardMovement()
		elseif a==keySpace then
			jumpingInput=true
		elseif a==keyShift then
			shiftlock=allowshiftlock and not shiftlock
		elseif modes[a] then
			local modeLeft=modes[mode].modeLeft
			if modeLeft then
				modeLeft()
			end
			if mode==a then
				mode="default"
			else
				mode=a
			end
			local modet=modes[mode]
			lerpsIdle=modet.idle or defaultmode.idle or emptyfunction
			lerpsWalk=modet.walk or defaultmode.walk or emptyfunction
			lerpsJump=modet.jump or defaultmode.jump or emptyfunction
			lerpsFall=modet.fall or defaultmode.fall or emptyfunction
			if modes[mode].modeEntered then
				modes[mode].modeEntered()
			end
		end
	end))
	tinsert(cons,Connect(insGet(uis,"InputEnded"),function(a)
		a=insGet(a,"KeyCode")
		if a==keyW then
			Wpressed=false
			refreshKeyboardMovement()
		elseif a==keyA then
			Apressed=false
			refreshKeyboardMovement()
		elseif a==keyS then
			Spressed=false
			refreshKeyboardMovement()
		elseif a==keyD then
			Dpressed=false
			refreshKeyboardMovement()
		elseif a==keySpace then
			jumpingInput=false
		end
	end))

	local thumbstickEndX=0
	local thumbstickStartY=0

	local thumbstickSizeMultiplier=0

	local jumpStartX=0
	local jumpStartY=0
	local jumpEndX=0
	local jumpEndY=0

	local thumbstickInputObject=nil
	local jumpInputObject=nil
	local cameraRotateInputObject=nil
	local cameraZoomInputObject=nil

	local thumbstickTouchStart=v3_0
	local cameraZoomInputMagnitude=0

	tinsert(cons,Connect(insGet(uis,"TouchStarted"),function(inputObject)
		if insGet(gs,"MenuIsOpen") or GetFocusedTextBox(uis) then
			return
		end

		local touchPos=insGet(inputObject,"Position")
		local touchX=v3Get(touchPos,"X")
		local touchY=v3Get(touchPos,"Y")

		if (not thumbstickInputObject) and touchX<thumbstickEndX and touchY>thumbstickStartY then
			thumbstickInputObject=inputObject
			thumbstickTouchStart=insGet(inputObject,"Position")
			isWalking=false
		elseif (not jumpInputObject) and touchY>jumpStartY and touchX>jumpStartX and touchX<jumpEndX and touchY<jumpEndY then
			jumpInputObject=inputObject
			jumpingInput=true
		elseif not cameraRotateInputObject then
			cameraRotateInputObject=inputObject
		else
			cameraZoomInputObject=inputObject
			cameraZoomInputMagnitude=vmagnitude(insGet(cameraRotateInputObject,"Position")-insGet(cameraZoomInputObject,"Position"))
		end
	end))
	tinsert(cons,Connect(insGet(uis,"TouchMoved"),function(inputObject)
		local touchPos=insGet(inputObject,"Position")
		local touchX=v3Get(touchPos,"X")
		local touchY=v3Get(touchPos,"Y")
		if inputObject==thumbstickInputObject then
			local direction=insGet(inputObject,"Position")-thumbstickTouchStart
			local directionMag=vmagnitude(direction)/thumbstickSizeMultiplier
			if directionMag>0.05 then
				isWalking=true
				direction=vnormalize(direction)*min(1,(directionMag-0.05)/0.95) 
				FWmovement=-v3Get(direction,"Y")
				RTmovement=v3Get(direction,"X")
			else
				isWalking=false
			end
		elseif inputObject==jumpInputObject then
			jumpingInput=touchY>jumpStartY and touchX>jumpStartX and touchX<jumpEndX and touchY<jumpEndY
		else
			if cameraZoomInputObject then
				local newMagnitude=vmagnitude(insGet(cameraRotateInputObject,"Position")-insGet(cameraZoomInputObject,"Position"))
				cammag=cammag+(newMagnitude-cameraZoomInputMagnitude)*0.04*(0.75-cammag/4)
				cameraZoomInputMagnitude=newMagnitude
				if cammag<0 then
					firstperson=false
				else
					cammag=0
					firstperson=true
				end
			elseif inputObject==cameraRotateInputObject then
				local rotation=GetMouseDelta(uis)
				camrotX=clamp(v2Get(rotation,"Y")*mradN05+camrotX,npi2,pi2)
				camrotY=v2Get(rotation,"X")*mradN05+camrotY
				camrot=angles(camrotX,camrotY,0,enumYXZ)
				camcfLV=cfGet(camrot,"LookVector")
				camcfRV=cfGet(camrot,"RightVector")
			end
		end
	end))
	tinsert(cons,Connect(insGet(uis,"TouchEnded"),function(inputObject)
		if inputObject==thumbstickInputObject then
			thumbstickInputObject=nil
			isWalking=false
		elseif inputObject==jumpInputObject then
			jumpInputObject=nil
			jumpingInput=false
		elseif inputObject==cameraRotateInputObject then
			cameraRotateInputObject=nil
			cameraZoomInputObject=nil
		elseif inputObject==cameraZoomInputObject then
			cameraZoomInputObject=nil
		end
	end))

	local refreshTouchRegions=function()
		local sX=insGet(mouse,"ViewSizeX")
		local sY=insGet(mouse,"ViewSizeY")
		local isSmallScreen=min(sX,sY)<=500

		sY=sY+insGet(gs,"TopbarInset").Height

		thumbstickEndX=sX*0.4
		thumbstickStartY=(sY+0)*0.333

		if isSmallScreen then
			thumbstickSizeMultiplier=35
			jumpStartX=sX-95
			jumpStartY=sY-90
			jumpEndX=jumpStartX+70
			jumpEndY=jumpStartY+70
		else
			thumbstickSizeMultiplier=60
			jumpStartX=sX-170
			jumpStartY=sY-210
			jumpEndX=jumpStartX+120
			jumpEndY=jumpStartY+120
		end
	end
	tinsert(cons,Connect(GetPropertyChangedSignal(mouse,"ViewSizeX"),refreshTouchRegions))
	tinsert(cons,Connect(GetPropertyChangedSignal(mouse,"ViewSizeY"),refreshTouchRegions))
	tinsert(cons,Connect(GetPropertyChangedSignal(gs,"TopbarInset"),refreshTouchRegions))
	refreshTouchRegions()

	local mouseCameraMove=false
	tinsert(cons,Connect(insGet(uis,"InputChanged"),function(a,b)
		if b then return end
		local inputType=insGet(a,"UserInputType")
		if mouseCameraMove and inputType==enumMM then
			local rotation=GetMouseDelta(uis)
			camrotX=clamp(v2Get(rotation,"Y")*mradN05+camrotX,npi2,pi2)
			camrotY=v2Get(rotation,"X")*mradN05+camrotY
			camrot=angles(camrotX,camrotY,0,enumYXZ)
			camcfLV=cfGet(camrot,"LookVector")
			camcfRV=cfGet(camrot,"RightVector")
		elseif inputType==enumMW then
			cammag=cammag+v3Get(insGet(a,"Position"),"Z")*(0.75-cammag/4)
			if cammag<0 then
				firstperson=false
			else
				cammag=0
				firstperson=true
			end
		end
	end))

	local predictionfling=function(target)
		if typeof(target)~="Instance" then 
			target=insGet(mouse,"Target")
			if not target then
				return false
			end
		end
		if not IsDescendantOf(target,ws) then
			return false
		end
		if IsA(target,"BasePart") or IsA(target,"Humanoid") then 
			target=insGet(target,"Parent") 
			if IsA(target,"Accessory") then
				target=insGet(target,"Parent")
			end
		end
		if (not IsA(target,"Model")) or (target==c) then
			return false
		end
		local targetpart=QueryDescendants(target,">BasePart#HumanoidRootPart")[1] or QueryDescendants(target,">BasePart#Torso")[1] or QueryDescendants(target,">BasePart#UpperTorso")[1]
		if (not targetpart) or (flingtable[targetpart]~=nil) then
			return false
		end
		if permadeath then
			-- replicatesignal(cdsb)
		end
		if highlightflingtargets then
			local h=i("Highlight")
			insSet(h,"Name",rs())
			insSet(h,"Adornee",target)
			insSet(h,"OutlineColor",c3(1,0,0))
			insSet(h,"Parent",i10)
			flingtable[targetpart]=h
		else
			flingtable[targetpart]=false
		end
		return true
	end

	if ctrlclicktp then
		ctrlclicktp=KeyCode.LeftControl
		local tpoff=v3_010*3
		if clickfling then
			tinsert(cons,Connect(insGet(mouse,"Button1Down"),function()
				if insGet(mouse,"Target") then
					if IsKeyDown(uis,ctrlclicktp) then
						pos=cfGet(insGet(mouse,"Hit"),"Position")+tpoff
						cfr=cfl(pos,pos+camcfLV*v3_101)
						xzvel=v3_0
						Yvel=0
					else
						predictionfling()
					end
				end
			end))
		else
			tinsert(cons,Connect(insGet(mouse,"Button1Down"),function()
				if insGet(mouse,"Target") and IsKeyDown(uis,ctrlclicktp) then
					pos=cfGet(insGet(mouse,"Hit"),"Position")+tpoff
					cfr=cfl(pos,pos+camcfLV*v3_101)
					xzvel=v3_0
					Yvel=0
				end
			end))
		end
	elseif clickfling then
		tinsert(cons,Connect(insGet(mouse,"Button1Down"),predictionfling))
	end

	local hhOff=3
	local hhOff1=3.01
	local setHipHeight=function(n)
		hhOff=n+3
		hhOff1=n+3.01
	end

	local noYvelTime=1
	local lastsine=sine
	-- Attack state (read inside mainFunction's lerp step)
	local attackActive = false
	local attackProgress = 0       -- 0..1 drives the lerp weight
	local attackDuration = 0.45    -- seconds the attack animation runs
	local currentAttackMode = nil  -- which mode's attack is playing
	local currentAttackKey  = nil  -- which key triggered it (e.g. "z")

	-- Attack definitions table
	-- Layout: attacks[modeName][keyName] = function(progress)
	-- progress is 0→1 over attackDuration, then auto-resets
	-- Use it to drive a sin curve or a one-shot lerp weight
	local attacks = {}

	local function registerAttack(modeName, keyName, fn)
			if not attacks[modeName] then attacks[modeName] = {} end
			attacks[modeName][keyName] = fn
	end

	local function fireAttack(modeName, keyName)
			local modeAttacks = attacks[modeName]
			if not modeAttacks then return end
			local fn = modeAttacks[keyName]
			if not fn then return end
			attackActive = true
			attackProgress = 0
			currentAttackMode = modeName
			currentAttackKey  = keyName
	end

-- Add more modes/keys the same way:
-- registerAttack("default", "x", function(p) ... end)
-- registerAttack("f",       "x", function(p) ... end)
-- ──────────────────────────────────────────────────────────────────
	local mainFunction=function()

		sine=osclock()
		local delta=sine-lastsine
		deltaTime=min(delta*10,1)
		lastsine=sine

		if shiftlock then
			if allowshiftlock then
				if mouseBehavior~=enumMLC then
					mouseBehavior=enumMLC
					insSet(uis,"MouseBehavior",mouseBehavior)
				end
				mouseCameraMove=true
			else
				shiftlock=false
			end
		elseif firstperson then
			if mouseBehavior~=enumMLC then
				mouseBehavior=enumMLC
				insSet(uis,"MouseBehavior",mouseBehavior)
			end
			mouseCameraMove=true
		elseif IsMouseButtonPressed(uis,enumMB2) then
			if mouseBehavior~=enumMLCP then
				mouseBehavior=enumMLCP
				insSet(uis,"MouseBehavior",mouseBehavior)
			end
			mouseCameraMove=true
		else
			if mouseBehavior~=enumMD then
				mouseBehavior=enumMD
				insSet(uis,"MouseBehavior",mouseBehavior)
			end
			mouseCameraMove=false
		end

		local raycastresult=Raycast(ws,pos,v3_010*(fpdh-v3Get(pos,"Y")),raycastparams)
		local onground=nil
		if raycastresult then
			onground=raycastresult.Distance<hhOff1
			if onground then
				Yvel=0
				pos=pos+v3_010*(v3Get(raycastresult.Position,"Y")+hhOff-v3Get(pos,"Y"))*min(delta*20,1)
				if jumpingInput and (jumpPower>0) then
					Yvel=jumpPower
					onground=false
				end
			else
				Yvel=Yvel-gravity*delta
				raycastresult=v3Get(raycastresult.Position,"Y")
				if v3Get(pos,"Y")+Yvel*delta<raycastresult then
					Yvel=0
					pos=pos+v3_010*(raycastresult+hhOff-v3Get(pos,"Y"))
				end
			end
		else
			Yvel=0
			onground=false
		end

		if firstperson then
			if isWalking then
				if walkSpeed==0 then
					xzvel=v3_0
					if onground then
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsIdle()
						noYvelTime=min(noYvelTime+delta*0.3,1)
						xzvel=xzvel*(1-noYvelTime)
					elseif Yvel>0 then
						pos=pos+v3_010*Yvel*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsJump()
						noYvelTime=0
					else
						pos=pos+v3_010*Yvel*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsFall()
						noYvelTime=0
					end
				else
					xzvel=vnormalize(vnormalize(camcfLV*v3_101)*FWmovement+vnormalize(camcfRV*v3_101)*RTmovement)*walkSpeed
					if onground then
						pos=pos+xzvel*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsWalk()
						noYvelTime=min(noYvelTime+delta*0.3,1)
						xzvel=xzvel*(1-noYvelTime)
					elseif Yvel>0 then
						pos=pos+(xzvel+v3_010*Yvel)*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsJump()
						noYvelTime=0
					else 
						pos=pos+(xzvel+v3_010*Yvel)*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsFall()
						noYvelTime=0
					end
				end
			else
				xzvel=v3_0
				if onground then
					cfr=cfl(pos,pos+camcfLV*v3_101)
					camcf=cfAdd(camrot,pos+v3_0150)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsIdle()
					noYvelTime=min(noYvelTime+delta*0.3,1)
					xzvel=xzvel*(1-noYvelTime)
				elseif Yvel>0 then
					pos=pos+v3_010*Yvel*delta
					cfr=cfl(pos,pos+camcfLV*v3_101)
					camcf=cfAdd(camrot,pos+v3_0150)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsJump()
					noYvelTime=0
				else
					pos=pos+v3_010*Yvel*delta
					cfr=cfl(pos,pos+camcfLV*v3_101)
					camcf=cfAdd(camrot,pos+v3_0150)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsFall()
					noYvelTime=0
				end
			end
		elseif shiftlock then	
			if isWalking then
				if walkSpeed==0 then
					xzvel=v3_0
					if onground then
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsIdle()
						noYvelTime=min(noYvelTime+delta*0.3,1)
						xzvel=xzvel*(1-noYvelTime)
					elseif Yvel>0 then
						pos=pos+v3_010*Yvel*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsJump()
						noYvelTime=0
					else
						pos=pos+v3_010*Yvel*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsFall()
						noYvelTime=0
					end
				else
					xzvel=vnormalize(vnormalize(camcfLV*v3_101)*FWmovement+vnormalize(camcfRV*v3_101)*RTmovement)*walkSpeed
					if onground then
						pos=pos+xzvel*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsWalk()
						noYvelTime=min(noYvelTime+delta*0.3,1)
						xzvel=xzvel*(1-noYvelTime)
					elseif Yvel>0 then
						pos=pos+(xzvel+v3_010*Yvel)*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsJump()
						noYvelTime=0
					else
						pos=pos+(xzvel+v3_010*Yvel)*delta
						cfr=cfl(pos,pos+camcfLV*v3_101)
						camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsFall()
						noYvelTime=0
					end
				end
			else
				xzvel=v3_0
				if onground then
					cfr=cfl(pos,pos+camcfLV*v3_101)
					camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsIdle()
					noYvelTime=min(noYvelTime+delta*0.3,1)
					xzvel=xzvel*(1-noYvelTime)
				elseif Yvel>0 then
					pos=pos+v3_010*Yvel*delta
					cfr=cfl(pos,pos+camcfLV*v3_101)
					camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsJump()
					noYvelTime=0
				else
					pos=pos+v3_010*Yvel*delta
					cfr=cfl(pos,pos+camcfLV*v3_101)
					camcf=cfAdd(camrot,pos+v3_0150+camcfRV*1.75+camcfLV*cammag)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsFall()
					noYvelTime=0
				end
			end
		else
			if isWalking then
				if walkSpeed==0 then
					xzvel=v3_0
					if onground then
						cfr=cfAdd(cfGet(cfr,"Rotation"),pos)
						camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsIdle()
						noYvelTime=min(noYvelTime+delta*0.3,1)
						xzvel=xzvel*(1-noYvelTime)
					elseif Yvel>0 then
						pos=pos+v3_010*Yvel*delta
						cfr=cfAdd(cfGet(cfr,"Rotation"),pos)
						camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsJump()
						noYvelTime=0
					else
						pos=pos+v3_010*Yvel*delta
						cfr=cfAdd(cfGet(cfr,"Rotation"),pos)
						camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsFall()
						noYvelTime=0
					end
				else
					xzvel=vnormalize(vnormalize(camcfLV*v3_101)*FWmovement+vnormalize(camcfRV*v3_101)*RTmovement)*walkSpeed
					if onground then
						pos=pos+xzvel*delta
						cfr=cfAdd(Lerp(cfGet(cfr,"Rotation"),cfl(v3_0,xzvel),deltaTime),pos)
						camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsWalk()
						noYvelTime=min(noYvelTime+delta*0.3,1)
						xzvel=xzvel*(1-noYvelTime)
					elseif Yvel>0 then
						pos=pos+(xzvel+(v3_010*Yvel))*delta
						cfr=cfAdd(Lerp(cfGet(cfr,"Rotation"),cfl(v3_0,xzvel),deltaTime),pos)
						camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsJump()
						noYvelTime=0
					else
						pos=pos+(xzvel+(v3_010*Yvel))*delta
						cfr=cfAdd(Lerp(cfGet(cfr,"Rotation"),cfl(v3_0,xzvel),deltaTime),pos)
						camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
						cframes[rootpart]=cfr
						insSet(cam,"CFrame",camcf)
						lerpsFall()
						noYvelTime=0
					end
				end
			else
				xzvel=v3_0
				if onground then
					cfr=cfAdd(cfGet(cfr,"Rotation"),pos)
					camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsIdle()
					noYvelTime=min(noYvelTime+delta*0.3,1)
					xzvel=xzvel*(1-noYvelTime)
				elseif Yvel>0 then
					pos=pos+v3_010*Yvel*delta
					cfr=cfAdd(cfGet(cfr,"Rotation"),pos)
					camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsJump()
					noYvelTime=0
				else
					pos=pos+v3_010*Yvel*delta
					cfr=cfAdd(cfGet(cfr,"Rotation"),pos)
					camcf=cfAdd(camrot,pos+v3_0150+camcfLV*cammag)
					cframes[rootpart]=cfr
					insSet(cam,"CFrame",camcf)
					lerpsFall()
					noYvelTime=0
				end
			end
		end

		refreshjointsI(rootpart)
		tclear(refreshedjoints)

		local sine15=sine*15
		local idlerv=v3(sin(sine15),sin(sine15+1.0471975511965976),sin(sine15+2.0943951023931953))
		local idleoff=idlerv*0.003910064697265625 --0.0156402587890625/4

		local claimpos=insGet(primarypart,"Position")
		local claimposY=v3Get(claimpos,"Y")
		for i,v in next,cframes do
			local part=i.p

			if part then
				if insGet(part,"ReceiveAge")==0 then
					local placeholder=i.v
					local vpos=cfGet(v,"Position")
					if novoid and (v3Get(vpos,"Y")<novoid) then
						v=cfAdd(v,v3_010*(novoid-v3Get(vpos,"Y")))
					end
					local lastpos=i.l
					local vel=(vpos-lastpos)/delta
					local mag=vmagnitude(vel)
					if mag<0.11730194091796875 then --0.0156402587890625*15/2
						if placeholder and i.b then
							insSet(placeholder,"Parent",nil)
							i.b=false
						end
						i.l=cfGet(v,"Position")
						v=cfAdd(v,idleoff)
					elseif mag>speedlimit then
						if placeholder then
							insSet(placeholder,"CFrame",v)
							if not i.b then
								insSet(placeholder,"Parent",ws)
								i.b=true
							end
						end
						vel=vnormalize(vel)*speedlimit
						local newpos=lastpos+vel*delta
						v=cfAdd(cfGet(v,"Rotation"),newpos)
						i.l=newpos
					else
						if placeholder and i.b then
							insSet(placeholder,"Parent",nil)
							i.b=false
						end
						i.l=cfGet(v,"Position")
					end
					local claimtime=i.c
					if claimtime then
						if sine-claimtime<retVelTime then
							local Ydiff=cfGet(v,"Y")-claimposY
							local velY=25.01
							local fallingTime=0
							while (Ydiff>0) or (velY>0) do
								fallingTime=fallingTime+0.025
								if fallingTime>0.6 then
									break
								end
								velY=velY-velYdelta
								Ydiff=Ydiff+(velY*0.025)
							end
							insSet(part,"AssemblyLinearVelocity",(claimpos-cfGet(v,"Position"))*v3_101/fallingTime+v3_net)
						else
							local vel1=vel*noYvelTime+xzvel
							if vmagnitude(vel1)>25.01 then
								insSet(part,"AssemblyLinearVelocity",vnormalize(vel1)*v3_xzL+v3_net)
							else
								insSet(part,"AssemblyLinearVelocity",vel1*v3_xz+v3_net)
							end
						end
					else
						i.c=sine
						local vel1=vel*noYvelTime+xzvel
						if vmagnitude(vel1)>25.01 then
							insSet(part,"AssemblyLinearVelocity",vnormalize(vel1)*v3_xzL+v3_net)
						else
							insSet(part,"AssemblyLinearVelocity",vel1*v3_xz+v3_net)
						end
					end
					insSet(part,"CFrame",v)
					insSet(part,"AssemblyAngularVelocity",idlerv)
				else
					i.c=nil
					i.l=insGet(part,"Position")
					local placeholder=i.v
					if placeholder then
						insSet(placeholder,"CFrame",v)
						if not i.b then
							insSet(placeholder,"Parent",ws)
							i.b=true
						end
					end
				end
			else
				local placeholder=i.v
				if placeholder then
					insSet(placeholder,"CFrame",v)
					if not i.b then
						insSet(placeholder,"Parent",ws)
						i.b=true
					end
				end
			end
		end
		if attackActive then
				attackProgress = attackProgress + delta / attackDuration
				if attackProgress >= 1 then
						attackProgress = 1
						attackActive   = false
				end
				local modeAttacks = attacks[currentAttackMode]
				if modeAttacks then
						local fn = modeAttacks[currentAttackKey]
						if fn then fn(attackProgress) end
				end
		end
		setsimrad()
	end

	sine=osclock()
	lastsine=sine
	tinsert(cons,Connect(heartbeat,mainFunction))
	mainFunction()

	local refreshjoints=function(v) --use this on the main part if u have parts that
		refreshjointsI(v) --are connected with each other but arent connected to rootpart
		tclear(refreshedjoints)
	end

	local legcfR=cf(1,-1,0)
	local legcfL=cf(-1,-1,0)
	local raydir=v3_010*-2
	local raycastlegs=function() --this returns 2 values: right leg raycast offset, left leg raycast offset
		local rY=Raycast(ws,cfGet(cfMul(cfr,legcfR),"Position"),raydir,raycastparams)
		local lY=Raycast(ws,cfGet(cfMul(cfr,legcfL),"Position"),raydir,raycastparams)
		if rY then
			if lY then
				return v3Get(rY.Position,"Y")-(v3Get(pos,"Y")-3),v3Get(lY.Position,"Y")-(v3Get(pos,"Y")-3)
			else
				return v3Get(rY.Position,"Y")-(v3Get(pos,"Y")-3),0
			end
		elseif lY then
			return 0,v3Get(lY.Position,"Y")-(v3Get(pos,"Y")-3)
		else
			return 0,0
		end
	end

	local velbycfrvec=function() --this returns 2 values: forward/backwards movement (from -1 to 1), right/left movement (from -1 to 1)
		local fw=cfGet(cfr,"LookVector")*xzvel/walkSpeed
		local rt=cfGet(cfr,"RightVector")*xzvel/walkSpeed
		return v3Get(fw,"X")+v3Get(fw,"Z"),v3Get(rt,"X")+v3Get(rt,"Z")
	end

	local lastvel=v3_0
	local velchg1=v3_0
	local velchgbycfrvec=function() --this returns 2 values: forward/backwards velocity change, right/left velocity change
		velchg1=velchg1+(lastvel-xzvel) --i recommend setting velchg1 to v3_0 when u start using this function or it will look worse
		lastvel=xzvel
		velchg1=velchg1-velchg1*(deltaTime/2)
		local fw=cfGet(cfr,"LookVector")*velchg1/32
		local rt=cfGet(cfr,"RightVector")*velchg1/32
		return v3Get(fw,"X")+v3Get(fw,"Z"),v3Get(rt,"X")+v3Get(rt,"Z")
	end

	local lastYvel=0
	local velYchg1=0
	local velYchg=function() --this returns Y axis velocity change
		velYchg1=clamp(velYchg1+(lastYvel-Yvel),-50,50) --i recommend setting velYchg1 to 0 when u start using this function or it will look worse
		lastYvel=Yvel
		velYchg1=velYchg1-velYchg1*(deltaTime/2)
		return velYchg1
	end

	local rotToMouse=function(alpha) --this rotates ur character towards your mouse hit position
		local pos1=pos*v3_010+cfGet(insGet(mouse,"Hit"),"Position")*v3_101
		if pos~=pos1 then --could make nan rotation
			cfr=Lerp(cfr,cfl(pos,pos1),alpha or deltaTime)
		end
	end

	local glitchJoint=function(joint,targetGlitchTime,delayFrom,delayTo,radiansFrom,radiansTo) 
		if sine>targetGlitchTime then --example usage: local glitchtime=0 addMode("x",{idle=function() glitchtime=glitchJoint(joint,glitchtime,0.2,0.4,-0.1,0.1) end})
			radiansFrom=radiansFrom*100
			radiansTo=radiansTo*100
			joint.C0=cfMul(joint.C0,angles(mrandom(radiansFrom,radiansTo)/100,mrandom(radiansFrom,radiansTo)/100,mrandom(radiansFrom,radiansTo)/100)) 
			return sine+mrandom(delayFrom*100,delayTo*100)/100
		end
		return targetGlitchTime
	end

	local setWalkSpeed=function(n)
		if type(n)~="number" then
			n=16
		end
		walkSpeed=n
	end
	local setJumpPower=function(n)
		if type(n)~="number" then
			n=50
		end
		jumpPower=n
	end
	local setGravity=function(n)
		if type(n)~="number" then
			n=196.2
		end
		gravity=n
	end
	local setCfr=function(v) --sets character cframe
		if typeof(v)=="CFrame" then
			local newpos=cfGet(v,"Position")
			camcf=cfAdd(camcf,newpos-pos)
			insSet(cam,"CFrame",camcf)
			cfr=v
			pos=newpos
		elseif typeof(v)=="Vector3" then
			camcf=cfAdd(camcf,v-pos)
			insSet(cam,"CFrame",camcf)
			cfr=cfAdd(cfGet(cfr,"Rotation"),v)
			pos=v
		end
	end
	local getVel=function() --returns character velocity
		return xzvel+v3_010*Yvel --important: use only in lerps or it might not work
	end
	local getCamCF=function() --returns camera cframe
		return camcf
	end
	local isFirstPerson=function() --returns true if user is in first person camera mode
		return firstperson
	end

	return {
		cframes=cframes,
		joints=joints,
		fling=predictionfling,
		predictionfling=predictionfling,
		refreshjoints=refreshjoints,
		raycastlegs=raycastlegs,
		velbycfrvec=velbycfrvec,
		velchgbycfrvec=velchgbycfrvec,
		velYchg=velYchg,
		addmode=addmode,
		getPart=getPart,
		getPartFromMesh=getPartFromMesh,
		getAccWeldFromMesh=getAccWeldFromMesh,
		getJoint=getJoint,
		getPartJoint=getPartJoint,
		rotToMouse=rotToMouse,
		glitchJoint=glitchJoint,
		setWalkSpeed=setWalkSpeed,
		setJumpPower=setJumpPower,
		setGravity=setGravity,
		setCfr=setCfr,
		getVel=getVel,
		getCamCF=getCamCF,
		isFirstPerson=isFirstPerson,
		setHipHeight=setHipHeight,
    fireAttack = fireAttack,
    attacks = attacks,
	}
end
local TweenService = game:GetService("TweenService")
local LMG2L = {};

local player = game:GetService("Players").LocalPlayer 
local playerGui = player:WaitForChild("PlayerGui")

LMG2L["ScreenGui_1"] = Instance.new("ScreenGui", playerGui);
LMG2L["ScreenGui_1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
LMG2L["ScreenGui_1"]["ResetOnSpawn"] = false;


-- Players.cillfall.PlayerGui.ScreenGui.Frame
LMG2L["Frame_2"] = Instance.new("Frame", LMG2L["ScreenGui_1"]);
LMG2L["Frame_2"]["BorderSizePixel"] = 0;
LMG2L["Frame_2"]["BackgroundColor3"] = Color3.fromRGB(255, 170, 115);
LMG2L["Frame_2"]["Size"] = UDim2.new(0, 450, 0, 186);
LMG2L["Frame_2"]["Position"] = UDim2.new(0, 672, 0, 412);
LMG2L["Frame_2"]["BackgroundTransparency"] = 0.3;

LMG2L["Frame_2"]["AnchorPoint"] = Vector2.new(0.5, 0.5); -- Sets the handle to the center
LMG2L["Frame_2"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

-- 3. DRAG DETECTOR (This makes it draggable)
local dragDetector = Instance.new("UIDragDetector", LMG2L["Frame_2"])
dragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslatePlane

-- Players.cillfall.PlayerGui.ScreenGui.Frame.UICorner
LMG2L["UICorner_3"] = Instance.new("UICorner", LMG2L["Frame_2"]);
LMG2L["UICorner_3"]["CornerRadius"] = UDim.new(0, 12);

-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextLabel
LMG2L["TextLabel_4"] = Instance.new("TextLabel", LMG2L["Frame_2"]);
LMG2L["TextLabel_4"]["BorderSizePixel"] = 0;
LMG2L["TextLabel_4"]["TextSize"] = 24;
LMG2L["TextLabel_4"]["BackgroundColor3"] = Color3.fromRGB(158, 67, 12);
LMG2L["TextLabel_4"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
LMG2L["TextLabel_4"]["TextColor3"] = Color3.fromRGB(54, 17, 0);
LMG2L["TextLabel_4"]["BackgroundTransparency"] = 0.699;
LMG2L["TextLabel_4"]["Size"] = UDim2.new(0, 450, 0, 54);
LMG2L["TextLabel_4"]["Text"] = [[Personal Reanimate]];

-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextLabel.UICorner
LMG2L["UICorner_5"] = Instance.new("UICorner", LMG2L["TextLabel_4"]);
LMG2L["UICorner_5"]["CornerRadius"] = UDim.new(0, 12);

-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextLabel2
LMG2L["TextLabel2_6"] = Instance.new("TextLabel", LMG2L["Frame_2"]);
LMG2L["TextLabel2_6"]["TextWrapped"] = true;
LMG2L["TextLabel2_6"]["BorderSizePixel"] = 0;
LMG2L["TextLabel2_6"]["TextSize"] = 12;
LMG2L["TextLabel2_6"]["BackgroundColor3"] = Color3.fromRGB(158, 67, 12);
LMG2L["TextLabel2_6"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
LMG2L["TextLabel2_6"]["TextColor3"] = Color3.fromRGB(54, 17, 0);
LMG2L["TextLabel2_6"]["BackgroundTransparency"] = 0.699;
LMG2L["TextLabel2_6"]["Size"] = UDim2.new(0, 204, 0, 82);
LMG2L["TextLabel2_6"]["Text"] = [[ my personal reanimation script - Exire]];
LMG2L["TextLabel2_6"]["Name"] = [[TextLabel2]];
LMG2L["TextLabel2_6"]["Position"] = UDim2.new(0, 14, 0, 76);


-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextLabel2.UICorner
LMG2L["UICorner_7"] = Instance.new("UICorner", LMG2L["TextLabel2_6"]);
LMG2L["UICorner_7"]["CornerRadius"] = UDim.new(0, 12);


-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextLabel2.UIStroke
LMG2L["UIStroke_8"] = Instance.new("UIStroke", LMG2L["TextLabel2_6"]);
LMG2L["UIStroke_8"]["Transparency"] = 0.3;
LMG2L["UIStroke_8"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_8"]["Thickness"] = 2;
LMG2L["UIStroke_8"]["Color"] = Color3.fromRGB(59, 30, 0);


-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextButton
LMG2L["TextButton_9"] = Instance.new("TextButton", LMG2L["Frame_2"]);
LMG2L["TextButton_9"]["BorderSizePixel"] = 0;
LMG2L["TextButton_9"]["TextSize"] = 24;
LMG2L["TextButton_9"]["TextColor3"] = Color3.fromRGB(54, 17, 0);
LMG2L["TextButton_9"]["BackgroundColor3"] = Color3.fromRGB(149, 52, 0);
LMG2L["TextButton_9"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
LMG2L["TextButton_9"]["BackgroundTransparency"] = 0.8;
LMG2L["TextButton_9"]["Size"] = UDim2.new(0, 194, 0, 82);
LMG2L["TextButton_9"]["Text"] = [[Reanimate]];
LMG2L["TextButton_9"]["Position"] = UDim2.new(0, 230, 0, 76);


-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextButton.UICorner
LMG2L["UICorner_a"] = Instance.new("UICorner", LMG2L["TextButton_9"]);
LMG2L["UICorner_a"]["CornerRadius"] = UDim.new(0, 12);


-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextButton.UIStroke
LMG2L["UIStroke_b"] = Instance.new("UIStroke", LMG2L["TextButton_9"]);
LMG2L["UIStroke_b"]["Transparency"] = 0.3;
LMG2L["UIStroke_b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_b"]["Thickness"] = 2;
LMG2L["UIStroke_b"]["Color"] = Color3.fromRGB(59, 30, 0);


-- Players.cillfall.PlayerGui.ScreenGui.Frame.TextButton.LocalScript
LMG2L["LocalScript_c"] = Instance.new("LocalScript", LMG2L["TextButton_9"]);

-- Players.cillfall.PlayerGui.ScreenGui.Frame.UIStroke
LMG2L["UIStroke_d"] = Instance.new("UIStroke", LMG2L["Frame_2"]);
LMG2L["UIStroke_d"]["Transparency"] = 0.3;
LMG2L["UIStroke_d"]["Thickness"] = 3;
LMG2L["UIStroke_d"]["Color"] = Color3.fromRGB(59, 30, 0);

-- 5. MINIMIZE BUTTON (Top Right)
LMG2L["MinButton"] = Instance.new("TextButton", LMG2L["Frame_2"])
local minBtn = LMG2L["MinButton"]
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(158, 67, 12)
minBtn.BackgroundTransparency = 0.8;
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
MinStroke = Instance.new("UIStroke", minBtn)
MinStroke.Transparency = 0.3;
MinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
MinStroke.Thickness = 2;
MinStroke.Color = Color3.fromRGB(59, 30, 0);


-- 6. THE LOGIC (Minimize and Reanimate)
local function C_c()
	local mainFrame = LMG2L["Frame_2"]
	local minBtn = LMG2L["MinButton"]
	local reBtn = LMG2L["TextButton_9"]
	local isMinimized = false
	local originalSize = mainFrame.Size
	local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	-- Minimize Logic with Animation
	minBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		local targetSize = isMinimized and UDim2.new(0, 40, 0, 40) or originalSize
		
		TweenService:Create(mainFrame, tInfo, {Size = targetSize}):Play()
		
		for _, child in pairs(mainFrame:GetChildren()) do
			if child ~= minBtn and child:IsA("GuiObject") then
				child.Visible = not isMinimized
			end
		end
		minBtn.Text = isMinimized and "+" or "—"
	end)

	-- Reanimate Logic
	reBtn.MouseButton1Click:Connect(function()
		local t=reanimate()
		if type(t) ~= "table" then return end
		local fireAttack = t.fireAttack
		local attacks = t.attacks
		local velYchg=t.velYchg 
		local Yvel=t.Yvel
		local raycastlegs=t.raycastlegs
		local getPartFromMesh=t.getPartFromMesh
		local getPartJoint=t.getPartJoint
		local velbycfrvec=t.velbycfrvec
		local setWalkSpeed=t.setWalkSpeed
		local rgb=Color3.fromRGB
		local R6parts=t.R6parts
		local setCamOffset=t.setCamOffset
		local Player=game.Players.LocalPlayer
		local getVel=t.getVel
		local IsWalking=t.IsWalking
		local getJoint=t.getJoint
		local setCfr=t.setCfr
		local cframes=t.cframes
		local getPart=t.getPart
		local joints=t.joints
		local refreshjoints=t.refreshjoints
		local onnewcamera=t.onnewcamera
		local SoundService=game.SoundService
		local setHipHeight=t.setHipHeight
		local getAccWeldFromMesh=t.getAccWeldFromMesh

		local addmode=t.addmode
		local getJoint=t.getJoint
		local velbycfrvec=t.velbycfrvec
		local RootJoint=getJoint("RootJoint")
		local RightShoulder=getJoint("Right Shoulder")
		local LeftShoulder=getJoint("Left Shoulder")
		local RightHip=getJoint("Right Hip")
		local LeftHip=getJoint("Left Hip")
		local Neck=getJoint("Neck")

		attacks["f"] = attacks["f"] or {}
		attacks["f"]["z"] = function(p)
				local alpha = sin(p * math.pi)
				RightShoulder.C0 = Lerp(RightShoulder.C0,
						cfMul(cf(1,0.2,0), angles(-(math.pi*0.9*alpha),2.0,0)), deltaTime*5)
				RootJoint.C0 = Lerp(RootJoint.C0,
						cfMul(cf(0,0,0), angles(-1.56-0.15*alpha,0,-3.141592502593994)), deltaTime*5)
		end

		-- Add more modes/keys the same way:
		-- registerAttack("default", "x", function(p) ... end)
		-- registerAttack("f",       "x", function(p) ... end)

		local gun                      = getPartFromMesh(6831441507, 6833003967)
		local AJBackAccessory          = getPartJoint(gun)
		local Pixie                    = getPartFromMesh(128216670, 150379943)
		local SpringPixie_150381051_LC = getPartJoint(Pixie)
		local staff                    = getPartFromMesh(5548423017, 5548423938)
		local CrystalStaff             = getPartJoint(staff)
		local rock                     = getPartFromMesh(4307568890, 4307568951)
		local RockAccessory            = getPartJoint(rock)
	
		local ModeV=""
		t.setJumpPower(65)
		t.setWalkSpeed(20)
	
	addmode("default", {
		idle = function()
			RootJoint.C0=Lerp(RootJoint.C0,cfMul(cf(0,0,0),angles(-1.4+0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			Neck.C0=Lerp(Neck.C0,cfMul(cf(0,1,0),angles(-1.729109199292016-0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			LeftHip.C0=Lerp(LeftHip.C0,cfMul(cf(-1,-1,0),angles(-0.2274227437829142-0.05*sin(sine*1.5),-1.054517599868613,0.04707908141767447-0.025*sin(sine*1.5))),deltaTime)
			LeftShoulder.C0=Lerp(LeftShoulder.C0,cfMul(cf(-1,-0.279490152994792,0),angles(3.323157445398021-0.1*sin(sine*1.5),-2.249407897800586,0.6606713965719306)),deltaTime)
			RightHip.C0=Lerp(RightHip.C0,cfMul(cf(1,-1,0),angles(-0.381719008690701-0.05*sin(sine*1.5),1.057171790310811,0.1080783656868194)),deltaTime)
			RightShoulder.C0=Lerp(RightShoulder.C0,cfMul(cf(1,-0.1809772692228613,0),angles(3.170657552728679-0.1*sin(sine*1.5),2.528360285681817,-0.4122203328217511)),deltaTime)
			AJBackAccessory.C0=Lerp(AJBackAccessory.C0,cfMul(cf(0.01787352561950684,-0.2123314142227173,-0.140083909034729),angles(0,0,-0.7)),deltaTime)
			SpringPixie_150381051_LC.C0=Lerp(SpringPixie_150381051_LC.C0,cfMul(cf(0.2000001668930054,15,-0.1002724319696426),angles(0,0,0)),deltaTime)
			CrystalStaff.C0=Lerp(CrystalStaff.C0,cfMul(cf(0.5000465794613485,1.547993442468476,-0.15),angles(0,0,-0.01)),deltaTime)
			RockAccessory.C0=Lerp(RockAccessory.C0,cfMul(cf(-0.5793895721435547,-15,0.07364007830619812),angles(0,0,0)),deltaTime)
			AJBackAccessory.Part1=getPart("Torso") AJBackAccessory.C1=cf_0
			CrystalStaff.Part1=getPart("Torso")   CrystalStaff.C1=cf_0
		end,
		walk = function()
			RootJoint.C0=Lerp(RootJoint.C0,cfMul(cf(0,0.01+0.01*sin(sine*2),0),angles(-1.563762217524132+0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			Neck.C0=Lerp(Neck.C0,cfMul(cf(0,1,0),angles(-1.624764865786233-0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			LeftHip.C0=Lerp(LeftHip.C0,cfMul(cf(-1,-1-0.01*sin(sine*2),0-0.1*sin(sine*2)),angles(-0.2274227437829142+0.5*sin(sine*2),-1.4,0-0.025*sin(sine*1.5))),deltaTime)
			LeftShoulder.C0=Lerp(LeftShoulder.C0,cfMul(cf(-1,0.5690323679070719,0),angles(1.664163951285611-0.05*sin(sine*1.5),-1.274620294979512,1.755664559685806)),deltaTime)
			RightHip.C0=Lerp(RightHip.C0,cfMul(cf(1,-1,0+0.1*sin(sine*2)),angles(0.05992280652326087-0.5*sin(sine*2),1.4,0)),deltaTime)
			RightShoulder.C0=Lerp(RightShoulder.C0,cfMul(cf(1,-0.1809772692228613,0),angles(1.664163951285611-0.05*sin(sine*1.5),-1.274620294979512,1.755664559685806)),deltaTime)
			AJBackAccessory.C0=Lerp(AJBackAccessory.C0,cfMul(cf(0.01787352561950684,-0.2123314142227173,-0.140083909034729),angles(0,0,0)),deltaTime)
			SpringPixie_150381051_LC.C0=Lerp(SpringPixie_150381051_LC.C0,cfMul(cf(0.2000001668930054,15,-0.1002724319696426),angles(0,0,0)),deltaTime)
			CrystalStaff.C0=Lerp(CrystalStaff.C0,cfMul(cf(0.5000465794613485,1.547993442468476,-0.15),angles(0,0,0.66)),deltaTime)
			RockAccessory.C0=Lerp(RockAccessory.C0,cfMul(cf(-0.5793895721435547,-15,0.07364007830619812),angles(0,0,0)),deltaTime)
			AJBackAccessory.Part1=getPart("Torso") AJBackAccessory.C1=cf_0
			CrystalStaff.Part1=getPart("Torso")   CrystalStaff.C1=cf_0
		end,
		jump = function()
			RootJoint.C0=Lerp(RootJoint.C0,cfMul(cf(0,0.01+0.01*sin(sine*2),0),angles(-1.563762217524132+0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			Neck.C0=Lerp(Neck.C0,cfMul(cf(0,1,0),angles(-1.624764865786233-0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			LeftHip.C0=Lerp(LeftHip.C0,cfMul(cf(-1.048806173759594,-0.04939832185444093-0.01*sin(sine*2),-0.7803933662280702),angles(-0.4908738521234053,-1.256966059947003,0-0.025*sin(sine*1.5))),deltaTime)
			LeftShoulder.C0=Lerp(LeftShoulder.C0,cfMul(cf(-1,-0.0736705043859649,0),angles(4.713896049228929-0.05*sin(sine*1.5),-2.053559591901652,-4.319545246988862)),deltaTime)
			RightHip.C0=Lerp(RightHip.C0,cfMul(cf(1,-0.366352817468476,-0.4648657012404058),angles(-0.3688719195921584,1.192020811940599,0.2124260631855588)),deltaTime)
			RightShoulder.C0=Lerp(RightShoulder.C0,cfMul(cf(1,-0.1809772692228613,0),angles(2.600410286811059-0.1*sin(sine*1.5),2.528360285681817,-0.4122203328217511)),deltaTime)
			AJBackAccessory.C0=Lerp(AJBackAccessory.C0,cfMul(cf(0.01787352561950684,-0.2123314142227173,-0.140083909034729),angles(0,0,0)),deltaTime)
			SpringPixie_150381051_LC.C0=Lerp(SpringPixie_150381051_LC.C0,cfMul(cf(0.2000001668930054,15,-0.1002724319696426),angles(0,0,0)),deltaTime)
			CrystalStaff.C0=Lerp(CrystalStaff.C0,cfMul(cf(0.5000465794613485,1.547993442468476,-0.15),angles(0,0,0.66)),deltaTime)
			RockAccessory.C0=Lerp(RockAccessory.C0,cfMul(cf(-0.5793895721435547,-15,0.07364007830619812),angles(0,0,0)),deltaTime)
			AJBackAccessory.Part1=getPart("Torso") AJBackAccessory.C1=cf_0
			CrystalStaff.Part1=getPart("Torso")   CrystalStaff.C1=cf_0
		end,
		fall = function()
			RootJoint.C0=Lerp(RootJoint.C0,cfMul(cf(0,0.01+0.01*sin(sine*2),0),angles(-1.563762217524132+0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			Neck.C0=Lerp(Neck.C0,cfMul(cf(0,1,0),angles(-1.624764865786233-0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			LeftHip.C0=Lerp(LeftHip.C0,cfMul(cf(-1.048806173759594,-0.04939832185444093-0.01*sin(sine*2),-0.7803933662280702),angles(-0.4908738521234053,-1.256966059947003,0-0.025*sin(sine*1.5))),deltaTime)
			LeftShoulder.C0=Lerp(LeftShoulder.C0,cfMul(cf(-1,-0.0736705043859649,0),angles(4.713896049228929-0.05*sin(sine*1.5),-2.053559591901652,-4.319545246988862)),deltaTime)
			RightHip.C0=Lerp(RightHip.C0,cfMul(cf(1,-0.366352817468476,-0.4648657012404058),angles(-0.3688719195921584,1.192020811940599,0.2124260631855588)),deltaTime)
			RightShoulder.C0=Lerp(RightShoulder.C0,cfMul(cf(1,-0.1809772692228613,0),angles(2.600410286811059-0.1*sin(sine*1.5),2.528360285681817,-0.4122203328217511)),deltaTime)
			AJBackAccessory.C0=Lerp(AJBackAccessory.C0,cfMul(cf(0.01787352561950684,-0.2123314142227173,-0.140083909034729),angles(0,0,0)),deltaTime)
			SpringPixie_150381051_LC.C0=Lerp(SpringPixie_150381051_LC.C0,cfMul(cf(0.2000001668930054,15,-0.1002724319696426),angles(0,0,0)),deltaTime)
			CrystalStaff.C0=Lerp(CrystalStaff.C0,cfMul(cf(0.5000465794613485,1.547993442468476,-0.15),angles(0,0,0.66)),deltaTime)
			RockAccessory.C0=Lerp(RockAccessory.C0,cfMul(cf(-0.5793895721435547,-15,0.07364007830619812),angles(0,0,0)),deltaTime)
			AJBackAccessory.Part1=getPart("Torso") AJBackAccessory.C1=cf_0
			CrystalStaff.Part1=getPart("Torso")   CrystalStaff.C1=cf_0
		end,
	})

	addmode("f", {
		idle = function()
			RootJoint.C0=Lerp(RootJoint.C0,cfMul(cf(0,0,0),angles(-1.4+0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			Neck.C0=Lerp(Neck.C0,cfMul(cf(0,1,0),angles(-1.729109199292016-0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			LeftHip.C0=Lerp(LeftHip.C0,cfMul(cf(-1,-1,0),angles(-0.2274227437829142-0.05*sin(sine*1.5),-1.054517599868613,0.04707908141767447-0.025*sin(sine*1.5))),deltaTime)
			LeftShoulder.C0=Lerp(LeftShoulder.C0,cfMul(cf(-1,0.5690323679070719,0),angles(1.664163951285611-0.05*sin(sine*1.5),-1.274620294979512,1.755664559685806)),deltaTime)
			RightHip.C0=Lerp(RightHip.C0,cfMul(cf(1,-1,0),angles(-0.381719008690701-0.05*sin(sine*1.5),1.057171790310811,0.1080783656868194)),deltaTime)
			RightShoulder.C0=Lerp(RightShoulder.C0,cfMul(cf(1,-0.1809772692228613,0),angles(3.170657552728679-0.1*sin(sine*1.5),2.528360285681817,-0.4122203328217511)),deltaTime)
			AJBackAccessory.C0=Lerp(AJBackAccessory.C0,cfMul(cf(0.01787352561950684,-0.2123314142227173,-0.140083909034729),angles(0,0,0)),deltaTime)
			SpringPixie_150381051_LC.C0=Lerp(SpringPixie_150381051_LC.C0,cfMul(cf(0.2000001668930054,15,-0.1002724319696426),angles(0,0,0)),deltaTime)
			CrystalStaff.C0=Lerp(CrystalStaff.C0,cfMul(cf(0.5000465794613485,1.547993442468476,-0.15),angles(0,0,0.66)),deltaTime)
			RockAccessory.C0=Lerp(RockAccessory.C0,cfMul(cf(-0.5793895721435547,-15,0.07364007830619812),angles(0,0,0)),deltaTime)
			AJBackAccessory.C1=cf_0 AJBackAccessory.Part1=getPart("Right Arm")
			CrystalStaff.C1=cf_0   CrystalStaff.Part1=getPart("Right Arm")
		end,
		walk = function()
			RootJoint.C0=Lerp(RootJoint.C0,cfMul(cf(0,0.01+0.01*sin(sine*2),0),angles(-1.563762217524132+0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			Neck.C0=Lerp(Neck.C0,cfMul(cf(0,1,0),angles(-1.624764865786233-0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			LeftHip.C0=Lerp(LeftHip.C0,cfMul(cf(-1,-1-0.01*sin(sine*2),0-0.1*sin(sine*2)),angles(-0.2274227437829142+0.5*sin(sine*2),-1.4,0-0.025*sin(sine*1.5))),deltaTime)
			LeftShoulder.C0=Lerp(LeftShoulder.C0,cfMul(cf(-1,0.5690323679070719,0),angles(1.664163951285611-0.05*sin(sine*1.5),-1.274620294979512,1.755664559685806)),deltaTime)
			RightHip.C0=Lerp(RightHip.C0,cfMul(cf(1,-1,0+0.1*sin(sine*2)),angles(0.05992280652326087-0.5*sin(sine*2),1.4,0)),deltaTime)
			RightShoulder.C0=Lerp(RightShoulder.C0,cfMul(cf(1,-0.1809772692228613,0),angles(2.600410286811059-0.1*sin(sine*1.5),2.528360285681817,-0.4122203328217511)),deltaTime)
			AJBackAccessory.C0=Lerp(AJBackAccessory.C0,cfMul(cf(0.01787352561950684,-0.2123314142227173,-0.140083909034729),angles(0,0,0)),deltaTime)
			SpringPixie_150381051_LC.C0=Lerp(SpringPixie_150381051_LC.C0,cfMul(cf(0.2000001668930054,15,-0.1002724319696426),angles(0,0,0)),deltaTime)
			CrystalStaff.C0=Lerp(CrystalStaff.C0,cfMul(cf(0.5000465794613485,1.547993442468476,-0.15),angles(0,0,0.66)),deltaTime)
			RockAccessory.C0=Lerp(RockAccessory.C0,cfMul(cf(-0.5793895721435547,-15,0.07364007830619812),angles(0,0,0)),deltaTime)
			AJBackAccessory.C1=cf_0 AJBackAccessory.Part1=getPart("Right Arm")
			CrystalStaff.C1=cf_0   CrystalStaff.Part1=getPart("Right Arm")
		end,
		jump = function()
			RootJoint.C0=Lerp(RootJoint.C0,cfMul(cf(0,0.01+0.01*sin(sine*2),0),angles(-1.563762217524132+0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			Neck.C0=Lerp(Neck.C0,cfMul(cf(0,1,0),angles(-1.624764865786233-0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			LeftHip.C0=Lerp(LeftHip.C0,cfMul(cf(-1.048806173759594,-0.04939832185444093-0.01*sin(sine*2),-0.7803933662280702),angles(-0.4908738521234053,-1.256966059947003,0-0.025*sin(sine*1.5))),deltaTime)
			LeftShoulder.C0=Lerp(LeftShoulder.C0,cfMul(cf(-1,-0.0736705043859649,0),angles(4.713896049228929-0.05*sin(sine*1.5),-2.053559591901652,-4.319545246988862)),deltaTime)
			RightHip.C0=Lerp(RightHip.C0,cfMul(cf(1,-0.366352817468476,-0.4648657012404058),angles(-0.3688719195921584,1.192020811940599,0.2124260631855588)),deltaTime)
			RightShoulder.C0=Lerp(RightShoulder.C0,cfMul(cf(1,-0.1809772692228613,0),angles(2.600410286811059-0.1*sin(sine*1.5),2.528360285681817,-0.4122203328217511)),deltaTime)
			AJBackAccessory.C0=Lerp(AJBackAccessory.C0,cfMul(cf(0.01787352561950684,-0.2123314142227173,-0.140083909034729),angles(0,0,0)),deltaTime)
			SpringPixie_150381051_LC.C0=Lerp(SpringPixie_150381051_LC.C0,cfMul(cf(0.2000001668930054,15,-0.1002724319696426),angles(0,0,0)),deltaTime)
			CrystalStaff.C0=Lerp(CrystalStaff.C0,cfMul(cf(0.5000465794613485,1.547993442468476,-0.15),angles(0,0,0.66)),deltaTime)
			RockAccessory.C0=Lerp(RockAccessory.C0,cfMul(cf(-0.5793895721435547,-15,0.07364007830619812),angles(0,0,0)),deltaTime)
			AJBackAccessory.Part1=getPart("Right Arm")
			CrystalStaff.C1=cf_0 CrystalStaff.Part1=getPart("Right Arm")
		end,
		fall = function()
			RootJoint.C0=Lerp(RootJoint.C0,cfMul(cf(0,0.01+0.01*sin(sine*2),0),angles(-1.563762217524132+0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			Neck.C0=Lerp(Neck.C0,cfMul(cf(0,1,0),angles(-1.624764865786233-0.05*sin(sine*1.5),0,-3.141592502593994)),deltaTime)
			LeftHip.C0=Lerp(LeftHip.C0,cfMul(cf(-1.048806173759594,-0.04939832185444093-0.01*sin(sine*2),-0.7803933662280702),angles(-0.4908738521234053,-1.256966059947003,0-0.025*sin(sine*1.5))),deltaTime)
			LeftShoulder.C0=Lerp(LeftShoulder.C0,cfMul(cf(-1,-0.0736705043859649,0),angles(4.713896049228929-0.05*sin(sine*1.5),-2.053559591901652,-4.319545246988862)),deltaTime)
			RightHip.C0=Lerp(RightHip.C0,cfMul(cf(1,-0.366352817468476,-0.4648657012404058),angles(-0.3688719195921584,1.192020811940599,0.2124260631855588)),deltaTime)
			RightShoulder.C0=Lerp(RightShoulder.C0,cfMul(cf(1,-0.1809772692228613,0),angles(2.600410286811059-0.1*sin(sine*1.5),2.528360285681817,-0.4122203328217511)),deltaTime)
			AJBackAccessory.C0=Lerp(AJBackAccessory.C0,cfMul(cf(0.01787352561950684,-0.2123314142227173,-0.140083909034729),angles(0,0,0)),deltaTime)
			SpringPixie_150381051_LC.C0=Lerp(SpringPixie_150381051_LC.C0,cfMul(cf(0.2000001668930054,15,-0.1002724319696426),angles(0,0,0)),deltaTime)
			CrystalStaff.C0=Lerp(CrystalStaff.C0,cfMul(cf(0.5000465794613485,1.547993442468476,-0.15),angles(0,0,0.66)),deltaTime)
			RockAccessory.C0=Lerp(RockAccessory.C0,cfMul(cf(-0.5793895721435547,-15,0.07364007830619812),angles(0,0,0)),deltaTime)
			AJBackAccessory.Part1=getPart("Right Arm")
			CrystalStaff.C1=cf_0 CrystalStaff.Part1=getPart("Right Arm")
		end,
	})


			-- ── Keybind system ─────────────────────────────────────────────
			-- Maps KeyCode → {mode, attackKey}
			-- Add entries here to bind more keys in more modes.
			local attackKeybinds = {
					[e.KeyCode.Z] = { modeKey = nil, attackKey = "z" },
					-- e.g. [e.KeyCode.X] = { modeKey = nil, attackKey = "x" },
			}
			-- modeKey = nil  means "fire for whatever current mode is active"
			-- modeKey = "f"  means "only fire when in mode f"

			local UIS = game:GetService("UserInputService")

			if _G.AttackInputConnection then
					_G.AttackInputConnection:Disconnect()
					_G.AttackInputConnection = nil
			end

			_G.AttackInputConnection = UIS.InputBegan:Connect(function(input, gpe)
					if gpe then return end

					local bind = attackKeybinds[input.KeyCode]
					if not bind then return end

					-- Determine which mode name to look up
					-- t.getJoint etc. are already captured above via the addmode calls.
					-- We read the active mode from the key-toggle logic in reanimate.
					-- The cleanest way: resolve via the current _G.ModeV string.
					local activeModeStr = tostring(_G.ModeV or "default")

					-- If the bind is mode-locked, enforce it
					if bind.modeKey and bind.modeKey ~= activeModeStr then return end

					-- Check the reanimate table has an attack for this mode
					local targetMode = bind.modeKey or activeModeStr
					if not attacks[targetMode] then
							-- Fallback to default mode attack if this mode has none
							targetMode = "default"
					end

					fireAttack(targetMode, bind.attackKey)
			end)
			-- Setup Keybinds
			_G.ModeV = "gunless" -- Default

			local keyBinds = {
				[Enum.KeyCode.F] = "gun"
			}

			local function handleModeExecution(mode)
					if mode == "gun" then
							t.setJumpPower(70)
							t.setWalkSpeed(25)
					elseif mode == "gunless" then
							t.setJumpPower(60)
							t.setWalkSpeed(16)
					end
			end


			if _G.HatInputConnection then
					_G.HatInputConnection:Disconnect()
					_G.HatInputConnection = nil
					print("Old input connection cleaned up.")
			end

			_G.HatInputConnection = UIS.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					
					local selectedMode = keyBinds[input.KeyCode]
					if selectedMode then
							if _G.ModeV == selectedMode then
									_G.ModeV = "gunless"
							else
									_G.ModeV = selectedMode
							end
							
							print("Switched to: " .. _G.ModeV)

							handleModeExecution(_G.ModeV)
							playModeMusic()
					end
			end)

		
			local Folder = "ExiresGlitcher"
			if isfolder and not isfolder(Folder) then makefolder(Folder) end
			local Path = Folder.."/"

			-- Configuration: Link your GitHub raw URLs here
			local SongLinks = {
				["gunless"] = "https://raw.githubusercontent.com/bayly098764321/Hat-FE/main/GunAway",
				["gun"]     = "https://raw.githubusercontent.com/bayly098764321/Hat-FE/main/GunOut",
			}

			function getmp3(modeName)
			    local filename = modeName..".mp3"
			    local fullPath = Path..filename
			    
			    if not isfile(fullPath) then
			        local url = SongLinks[modeName]
			        if url then
			            -- Using 'request' instead of HttpGet to bypass engine blocks
			            local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
			            
			            if httpRequest then
			                local response = httpRequest({
			                    Url = url,
			                    Method = "GET"
			                })
			                
			                if response.Success then
			                    writefile(fullPath, response.Body)
			                else
			                    warn("Download failed for " .. modeName .. " - Status: " .. tostring(response.StatusCode))
			                    return nil
			                end
			            else
			                warn("Your executor does not support 'request' or 'HttpGet'")
			                return nil
			            end
			        else
			            warn("No URL found for mode: " .. modeName)
			            return nil
			        end
			    end
			    
			    repeat task.wait() until isfile(fullPath)
			    return getcustomasset(fullPath)
			end


			local currentSound = nil
			local currentSession = 0 -- Track the latest "request"
			
			function playModeMusic()
			    currentSession = currentSession + 1
			    local mySession = currentSession -- Capture this specific "call"
			    
			    -- 1. Stop and cleanup immediately
			    if currentSound then 
			        currentSound:Stop()
			        currentSound:Destroy() 
			        currentSound = nil
			    end
			    
			    -- Use a local variable so we don't accidentally use a changed global halfway through
			    local targetMode = _G.ModeV
			    local assetId = getmp3(targetMode)
			    
			    -- CHECK: Did the user switch modes while getmp3 was downloading?
			    if mySession ~= currentSession then return end 
			
			    if assetId then
			        local sound = Instance.new("Sound")
			        sound.Name = "ModeMusic_" .. targetMode
			        sound.SoundId = assetId
			        sound.Volume = 1
			        sound.Looped = true
			        sound.Parent = game:GetService("SoundService")
			        
			        task.spawn(function()
			            local timeout = 0
			            while sound.TimeLength == 0 and timeout < 50 do
			                task.wait(0.1)
			                timeout = timeout + 1
			                -- CHECK: Did the user switch modes while we were waiting for the asset to prime?
			                if mySession ~= currentSession then 
			                    sound:Destroy() 
			                    return 
			                end
			            end
			            
			            -- Final safety check before playing
			            if mySession == currentSession then
			                sound:Play()
			                currentSound = sound
			                print("Now playing: " .. targetMode)
			            else
			                sound:Destroy()
			            end
			        end)
			    end
			end
			-- Initial play
			playModeMusic()
		end)
end;

task.spawn(C_c);
-- Configuration: Use NUMBERS only, no quotes
local BlacklistedIDs = {8514845458, 562932753} -- Add your IDs here
local MessageToSend = "Lightning Cannon By Exire"

-- Services
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- DIRECT CHECK: If table.find finds the ID, it's blacklisted
if table.find(BlacklistedIDs, LocalPlayer.UserId) then
    warn("Execution blocked: You are on the blacklist.")
    return -- STOP SCRIPT HERE
end

-- If script reaches here, user is NOT blacklisted
local function sendChat(msg)
    -- Try Modern TextChatService
    local generalChannel = TextChatService:FindFirstChild("RBXGeneral", true)
    if generalChannel then
        generalChannel:SendAsync(msg)
    else
        -- Fallback to Legacy SayMessageRequest
        local legacyEvent = ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
        if legacyEvent then
            legacyEvent:FireServer(msg, "All")
        end
    end
end

sendChat(MessageToSend)
return 1

-- ═══════════════════════════════════════════════════════
-- HOW TO ADD MORE ATTACKS
-- ═══════════════════════════════════════════════════════
--[[
    To add an X attack in default mode:
 
    registerAttack("default", "x", function(p)
        local alpha = sin(p * math.pi)
        LeftShoulder.C0 = Lerp(LeftShoulder.C0,
            cfMul(cf(-1,0.5,0), angles(-(math.pi*0.7*alpha),0,0)),
            deltaTime*4)
    end)
 
    Then add the keybind entry in attackKeybinds:
    [e.KeyCode.X] = { modeKey = nil, attackKey = "x" },
 
    To make an attack only fire in gun mode:
    [e.KeyCode.X] = { modeKey = "gun", attackKey = "x" },
 
    The attack function receives progress (0→1) every frame.
    sin(progress * math.pi) gives a smooth 0→peak→0 envelope.
    Multiply your offset by that alpha to get a clean arc.
 
    attackDuration controls how long the animation takes (seconds).
    Change it per-attack by saving the old value, setting a new one
    before fireAttack(), then restoring it, or make it a field in the
    attack table if you want per-attack durations.
]]
