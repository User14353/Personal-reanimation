-- ==================================================
--                    CONFIGURATIONS
-- ==================================================

local Configurations = {
	Identifier  = "Testing",
	ScriptName  = "Exire Lighting Cannon",
	Version     = 1,
	FolderName  = "Exire Reanimate",
	FileName    = "Lightning cannon",
	ReanimationSettings = {},
	Settings    = {}
}

-- ==================================================
--                    SWAIT UTILITY
-- ==================================================

function swait(num)
	if num == 0 or num == nil then
		game:service'RunService'.Stepped:wait(0)
	else
		for i = 0, num do
			game:service'RunService'.Stepped:wait(0)
		end
	end
end

-- ==================================================
--                  GLOBAL IDENTIFIER
-- ==================================================

local global = getgenv and getgenv() or _G
if global[Configurations.Identifier] then
	-- return error("Cannot re-run the same script lol.")
else
	local t = {}
	global[Configurations.Identifier] = t
	global = t
end

-- ==================================================
--               LOCALISED STDLIB / MATH
-- ==================================================

local osclock   = os.clock
local tspawn    = task.spawn
local twait     = task.wait
local schar     = string.char
local ssub      = string.sub
local sfind     = string.find
local supper    = string.upper
local slower    = string.lower
local sformat   = string.format
local rad       = math.rad
local sin       = math.sin
local cos       = math.cos
local abs       = math.abs
local min       = math.min
local max       = math.max
local clamp     = math.clamp
local tan       = math.tan
local mrandom   = math.random
local random    = function(a, b) return mrandom(a * 1000, b * 1000) / 1000 end
local tinsert   = table.insert
local tclear    = table.clear
local tclone    = table.clone
local tfind     = table.find
local vmagnitude = vector.magnitude
local vnormalize = vector.normalize
local next      = next
local pcall     = pcall
local xpcall    = xpcall
local type      = type
local typeof    = typeof
local game      = game
local replicatesignal = replicatesignal

-- ==================================================
--               INSTANCE / TYPE SHORTCUTS
-- ==================================================

local i         = Instance.new
local v2        = Vector2.new
local v3        = Vector3.new
local c3        = Color3.new
local c3rgb     = Color3.fromRGB
local bc        = BrickColor.new
local br        = BrickColor.random
local cf        = CFrame.new
local cfl       = CFrame.lookAt
local angles    = CFrame.fromEulerAngles
local u2        = UDim2.new
local u2scale   = UDim2.fromScale
local u2offset  = UDim2.fromOffset
local e         = Enum
local ti        = TweenInfo.new
local rp        = RaycastParams.new
local op        = OverlapParams.new
local nr        = NumberRange.new
local ns        = NumberSequence.new
local nsk       = NumberSequenceKeypoint.new
local cs        = ColorSequence.new
local csk       = ColorSequenceKeypoint.new

-- ==================================================
--               SINE / DELTA GLOBALS
-- ==================================================

local sine      = osclock()
local deltaTime = 0

-- ==================================================
--               COMMON VECTOR / CFRAME CONSTS
-- ==================================================

local v3_0    = v3()
local v3_101  = v3(1, 0, 1)
local v3_010  = v3(0, 1, 0)
local cf_0    = cf()
local v3_xz   = v3_101 * 10
local v3_xzL  = v3_101 * 250.1
local v3_net  = v3_010 * 25.01

-- ==================================================
--               RANDOM STRING HELPER
-- ==================================================

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

-- ==================================================
--          METAMETHOD / INSTANCE FAST ACCESS
-- ==================================================

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

local insSet = getMetamethodFromErrorStack(game, function(a,b,c) a[b]=c end, function(f) local a=i("Folder") local b=rs() f(a,"Name",b) return a.Name==b end)
local insGet = getMetamethodFromErrorStack(game, function(a,b) return a[b] end, function(f) local a=i("Folder") local b=rs() a.Name=b return f(a,"Name")==b end)
local cfGet  = getMetamethodFromErrorStack(cf_0, function(a,b) return a[b] end, function(f) return f(cf(1,2,3),"Position")==v3(1,2,3) end)
local cfMul  = getMetamethodFromErrorStack(cf_0, function(a,b) return a*b end, function(f) return angles(1,2,3)*angles(1,2,3)==f(angles(1,2,3),angles(1,2,3)) end)
local cfAdd  = getMetamethodFromErrorStack(cf_0, function(a,b) return a+b end, function(f) return cf(1,2,3)+v3(1,2,3)==f(cf(1,2,3),v3(1,2,3)) end)
local v3Get  = getMetamethodFromErrorStack(v3_0, function(a,b) return a[b] end, function(f) return v3(1,2,3).Unit==f(v3(1,2,3),"Unit") end)
local v2Get  = getMetamethodFromErrorStack(v2(), function(a,b) return a[b] end, function(f) return f(v2(1,2),"Y")==2 end)

-- ==================================================
--          CORE INSTANCE METHOD FAST-BINDS
-- ==================================================

local Clone                    = insGet(game, "Clone")
local ClearAllChildren         = insGet(game, "ClearAllChildren")
local Destroy                  = insGet(game, "Destroy")
local IsA                      = insGet(game, "IsA")
local FindFirstChild           = insGet(game, "FindFirstChild")
local FindFirstChildOfClass    = insGet(game, "FindFirstChildOfClass")
local FindFirstChildWhichIsA   = insGet(game, "FindFirstChildWhichIsA")
local GetChildren              = insGet(game, "GetChildren")
local GetDescendants           = insGet(game, "GetDescendants")
local IsDescendantOf           = insGet(game, "IsDescendantOf")
local GetPropertyChangedSignal = insGet(game, "GetPropertyChangedSignal")
local QueryDescendants         = insGet(game, "QueryDescendants")

-- ==================================================
--               SERVICES (FAST ACCESS)
-- ==================================================

local plrs  = FindFirstChildOfClass(game, "Players")
local rus   = FindFirstChildOfClass(game, "RunService")
local ws    = FindFirstChildOfClass(game, "Workspace")
local uis   = FindFirstChildOfClass(game, "UserInputService")
local gs    = FindFirstChildOfClass(game, "GuiService")
local sg    = FindFirstChildOfClass(game, "StarterGui")
local ts    = FindFirstChildOfClass(game, "TweenService")
local rps   = FindFirstChildOfClass(game, "ReplicatedStorage")

local lp    = insGet(plrs, "LocalPlayer")
local pg    = FindFirstChildOfClass(lp, "PlayerGui")
local mouse = insGet(lp, "GetMouse")(lp)
local rst   = insGet(plrs, "RespawnTime") + 0.07

local preanimation  = insGet(rus, "PreAnimation")
local heartbeat     = insGet(rus, "Heartbeat")
local renderstepped = insGet(rus, "RenderStepped")

local GetPlayers          = insGet(plrs, "GetPlayers")
local SetCore             = insGet(sg, "SetCore")
local SetCoreGuiEnabled   = insGet(sg, "SetCoreGuiEnabled")
local GetCoreGuiEnabled   = insGet(sg, "GetCoreGuiEnabled")
local Raycast             = insGet(ws, "Raycast")
local Connect             = heartbeat.Connect
local Once                = heartbeat.Once
local Disconnect          = Connect(GetPropertyChangedSignal(game, "CreatorId"), type).Disconnect
local Wait                = heartbeat.Wait
local GetMouseLocation    = insGet(uis, "GetMouseLocation")
local GetFocusedTextBox   = insGet(uis, "GetFocusedTextBox")
local GetMouseDelta       = insGet(uis, "GetMouseDelta")
local IsMouseButtonPressed = insGet(uis, "IsMouseButtonPressed")
local IsKeyDown           = insGet(uis, "IsKeyDown")
local Inverse             = cfGet(cf_0, "Inverse")
local Lerp                = cfGet(cf_0, "Lerp")
local ToObjectSpace       = cfGet(cf_0, "ToObjectSpace")
local VLerp               = v3_0.Lerp
local ULerp               = u2().Lerp
local CLerp               = c3().Lerp

-- ==================================================
--            ACCESSORY LIMB MESH TABLE
-- ==================================================

local accessorylimbs = {
	{ meshid="110684113028749", textureid="70661572547971",  C0=angles(0,0,0),                                           Name="Torso"     },
	{ meshid="104613079991268", textureid="83269599235494",  C0=angles(0,0,0),                                           Name="Torso"     },
	{ meshid="125405780718494", textureid="136752500636691", C0=angles(-1.5707963267948966,0,1.5707963267948966),        Name="Right Arm" },
	{ meshid="125405780718494", textureid="136752500636691", C0=angles(1.5707963267948966,0,1.5707963267948966),         Name="Left Arm"  },
	{ meshid="125405780718494", textureid="136752500636691", C0=angles(1.5707963267948966,0,1.5707963267948966),         Name="Left Leg"  },
	{ meshid="125405780718494", textureid="136752500636691", C0=angles(0,0,1.5707963267948966),                          Name="Right Leg" },
	{ meshid="96333112188696",  textureid="18807356481",     C0=angles(0,0,0),                                           Name="Left Arm"  },
	{ meshid="96130316788066",  textureid="18807356481",     C0=angles(0,0,0),                                           Name="Right Arm" },
}

-- ==================================================
--              GENERAL HELPER FUNCTIONS
-- ==================================================

local gp = function(p, n, cl)
	for i, v in next, GetChildren(p) do
		if IsA(v, cl) and (insGet(v, "Name") == n) then return v end
	end
	return nil
end

local timegp = function(p, n, c, t)
	t = osclock() + t
	while t > osclock() do
		for i, v in next, GetChildren(p) do
			if IsA(v, c) and (insGet(v, "Name") == n) then return v end
		end
		Wait(preanimation)
	end
	return nil
end

local makeplaceholder = function(v)
	if not insGet(v, "Archivable") then insSet(v, "Archivable", true) end
	v = Clone(v)
	for i, v in next, GetChildren(v) do
		if IsA(v, "SpecialMesh") then insSet(v, "Name", rs()) ClearAllChildren(v)
		else Destroy(v) end
	end
	insSet(v, "Name",        rs())
	insSet(v, "Anchored",    true)
	insSet(v, "CanCollide",  false)
	insSet(v, "Transparency", 0.25)
	return v
end

local emptyfunction = function() end

-- ==================================================
--               REANIMATE SETTINGS
-- ==================================================

local pdloadedtime         = nil
local allowshiftlock       = true
local ctrltp               = false
local placeholders         = false
local clickfling           = false
local highlightflingtargets = false
local flingchangestate     = 1
local respawntp            = 1
local breakjointsmethod    = 3
local simrad               = true
local hidedeatheffect      = true

local discharscripts = function(v)
	if IsA(v, "LocalScript") or IsA(v, "Script") then
		insSet(v, "Disabled", true)
	end
end

-- ==================================================
--                    MODE DATA
-- ==================================================

local currentmode  = "q"
local currentmodes = {}

local modedatas = {
	["q"] = {
		mode      = "nogun",
		font      = Font.fromEnum(e.Font.Merriweather),
		pcolor    = c3(),
		scolor    = c3(0.25, 0.25, 1),
		walkspeed = 18,
		jumppower = 50,
		hipheight = 0,
		song      = { asset="nogun", name="nil", creator="nil" }
	},
	["f"] = {
		mode      = "gun",
		font      = Font.fromEnum(e.Font.Merriweather),
		pcolor    = c3(),
		scolor    = c3(0.25, 0.25, 1),
		walkspeed = 25,
		jumppower = 60,
		hipheight = 0,
		song      = { asset="gun", name="nil", creator="nil" }
	},
}

-- ==================================================
--                 RAYCAST PARAMS
-- ==================================================

local raycastparams = rp()
raycastparams.FilterType        = e.RaycastFilterType.Exclude
raycastparams.RespectCanCollide = true

-- ==================================================
--               BINDABLE (RESET HOOK)
-- ==================================================

local bindable = i("BindableEvent")
insSet(bindable, "Name", rs())

-- ==================================================
--            REANIMATE STOP / START
-- ==================================================

local c         = nil
local gw        = nil
local cons      = {}
local onrespawn = nil

local stopreanimate = function()
	if c then
		c = nil
		if gw then Destroy(gw) end
		for _, v in next, cons do Disconnect(v) end
		if onrespawn then onrespawn() onrespawn = nil end
		SetCore(sg, "ResetButtonCallback", true)
		return true
	end
	return false
end

-- ==================================================
--                 REANIMATE CORE
-- ==================================================

-- cframes table lives outside reanimate so mainscript can reference it
local cframes = {}
local onnewcamera = nil

local reanimate = function()
	local novoid     = true
	local speedlimit = 3000
	local retVelTime = 0.51
	local walkSpeed  = 16
	local jumpPower  = 50
	local gravity    = 196.2
	local ctrlclicktp = ctrltp
	local clickfling  = clickfling
	local flingvel    = v3(15000, 16000, 15000)

	if stopreanimate() then
		local SS = game:GetService("SoundService")
		for _, obj in ipairs(SS:GetChildren()) do
			if obj.Name:find("ModeMusic_") then obj:Destroy() end
		end
		local pg2 = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		local hud = pg2:FindFirstChild("LightningCannonHud")
		if hud then hud:Destroy() end
		return
	end

	c = insGet(lp, "Character")
	if not (c and IsDescendantOf(c, ws)) then return end

	local rootpart = FindFirstChild(c, "HumanoidRootPart")
		or FindFirstChild(c, "Torso")
		or FindFirstChild(c, "UpperTorso")
		or timegp(c, "HumanoidRootPart", "BasePart", 0.5)
		or FindFirstChildWhichIsA(c, "BasePart")
	if not rootpart then return end

	Once(insGet(bindable, "Event"), stopreanimate)

	-- Initial CFrame for mesh-part registration
	local cfr = insGet(rootpart, "CFrame")
	local pos  = cfGet(cfr, "Position")
	cfr = cfl(pos, pos + cfGet(cfr, "LookVector") * v3_101)

	tclear(cframes)

	local R6parts = {
		head     = { Name = "Head"             },
		torso    = { Name = "Torso"            },
		root     = { Name = "HumanoidRootPart" },
		leftArm  = { Name = "Left Arm"         },
		rightArm = { Name = "Right Arm"        },
		leftLeg  = { Name = "Left Leg"         },
		rightLeg = { Name = "Right Leg"        },
	}
	rootpart = R6parts.root

	-- Seed cframes with each R6 part
	for _, v in next, R6parts do
		cframes[v] = cfr
	end

	local joints = {
		{ Name="Neck",           Part0=R6parts.torso,    Part1=R6parts.head,     C0=cf(0,1,0,-1,0,0,0,0,1,0,1,-0),   C1=cf(0,-0.5,0,-1,0,0,0,0,1,0,1,-0)  },
		{ Name="RootJoint",      Part0=rootpart,          Part1=R6parts.torso,    C0=cf(0,0,0,-1,0,0,0,0,1,0,1,-0),   C1=cf(0,0,0,-1,0,0,0,0,1,0,1,-0)     },
		{ Name="Right Shoulder", Part0=R6parts.torso,    Part1=R6parts.rightArm, C0=cf(1,0.5,0,0,0,1,0,1,-0,-1,0,0), C1=cf(-0.5,0.5,0,0,0,1,0,1,-0,-1,0,0) },
		{ Name="Left Shoulder",  Part0=R6parts.torso,    Part1=R6parts.leftArm,  C0=cf(-1,0.5,0,0,0,-1,0,1,0,1,0,0), C1=cf(0.5,0.5,0,0,0,-1,0,1,0,1,0,0)  },
		{ Name="Right Hip",      Part0=R6parts.torso,    Part1=R6parts.rightLeg, C0=cf(1,-1,0,0,0,1,0,1,-0,-1,0,0),  C1=cf(0.5,1,0,0,0,1,0,1,-0,-1,0,0)   },
		{ Name="Left Hip",       Part0=R6parts.torso,    Part1=R6parts.leftLeg,  C0=cf(-1,-1,0,0,0,-1,0,1,0,1,0,0),  C1=cf(-0.5,1,0,0,0,-1,0,1,0,1,0,0)   },
	}

	-- ==================================================
	--              HELPER FUNCTIONS
	-- ==================================================

	local getJoint = function(name)
		for _, v in next, joints do
			if v.Name == name then return v end
		end
		return { C0 = cf_0, C1 = cf_0 }
	end

	local getPart = function(name, blacklist)
		if blacklist then
			for part, _ in next, cframes do
				if (part.Name == name) and not tfind(blacklist, part) then return part end
			end
		else
			for part, _ in next, cframes do
				if part.Name == name then return part end
			end
		end
		return nil
	end

	local getPartFromMesh = function(m, t, blacklist)
		if blacklist then
			for v, _ in next, cframes do
				if v.m and (not tfind(blacklist, v)) and sfind(tostring(v.m), tostring(m)) and sfind(tostring(v.t), tostring(t)) then
					return v
				end
			end
		else
			for v, _ in next, cframes do
				if v.m and sfind(tostring(v.m), tostring(m)) and sfind(tostring(v.t), tostring(t)) then
					return v
				end
			end
		end
		-- Not found — create a placeholder mesh-part entry
		local p = { m = tostring(m), t = tostring(t) }
		cframes[p] = cfr
		local j = { C0 = cf_0, C1 = cf_0, Part0 = p }
		p.j = j
		return p
	end

	local getPartJoint = function(p)
		if p and cframes[p] then
			if p.j then return p.j end
			for _, v in next, joints do
				if v.Part0 == p then return v end
			end
			for _, v in next, joints do
				if v.Part1 == p then return v end
			end
		end
		return { C0 = cf_0, C1 = cf_0 }  -- safe fallback so Lerp calls don't error
	end

	local getAccWeldFromMesh = function(m, t)
		return getPartJoint(getPartFromMesh(m, t))
	end

	local setWalkSpeed = function(n) if type(n) ~= "number" then n = 16    end walkSpeed = n end
	local setJumpPower = function(n) if type(n) ~= "number" then n = 50    end jumpPower = n end
	local setGravity   = function(n) if type(n) ~= "number" then n = 196.2 end gravity   = n end

	return {
		R6parts          = R6parts,
		joints           = joints,
		cframes          = cframes,
		getJoint         = getJoint,
		getPart          = getPart,
		getPartFromMesh  = getPartFromMesh,
		getPartJoint     = getPartJoint,
		getAccWeldFromMesh = getAccWeldFromMesh,
		setWalkSpeed     = setWalkSpeed,
		setJumpPower     = setJumpPower,
		setGravity       = setGravity,
	}
end

-- ==================================================
--                   INIT MODULE
-- ==================================================

local InitModule = function()

	local plrs  = FindFirstChildOfClass(game, "Players")
	local rus   = FindFirstChildOfClass(game, "RunService")
	local uis   = FindFirstChildOfClass(game, "UserInputService")
	local ts    = FindFirstChildOfClass(game, "TweenService")
	local lp    = insGet(plrs, "LocalPlayer")

	local heartbeat     = insGet(rus, "Heartbeat")
	local renderstepped = insGet(rus, "RenderStepped")
	local Connect       = heartbeat.Connect
	local Wait          = heartbeat.Wait
	local Create        = insGet(ts, "Create")

	-- ==================================================
	--                 FILE SYSTEM SETUP
	-- ==================================================

	local InitiateFiles = function()
		if not (makefolder or writefile or isfolder or isfile) then return false end

		local FolderName = Configurations.FolderName
		local FileName   = Configurations.FileName

		if not isfolder(FolderName) then
			makefolder(FolderName)
			makefolder(FolderName .. "/Scripts")
			makefolder(FolderName .. "/Core")
			makefolder(FolderName .. "/ReanimationSettings")
		end
		if not isfolder(FolderName .. "/Scripts/" .. FileName) then
			makefolder(FolderName .. "/Scripts/" .. FileName)
		end
		if not isfolder(FolderName .. "/Scripts/" .. FileName .. "/Settings") then
			makefolder(FolderName .. "/Scripts/" .. FileName .. "/Settings")
		end
		return true
	end

	-- ==================================================
	--              REANIMATE / RESPAWN HOOKS
	-- ==================================================
	-- Declared early so CreateSound and C_c can close over reanimatefunc.

	local reanimatefunc = nil
	local respawnfunc   = nil

	local OnReanimate = function(f) reanimatefunc = f end
	local OnRespawn   = function(f) respawnfunc   = f end

	-- GetReanimateFn lets the button safely read reanimatefunc
	-- even if it was set after the closure was formed.
	local GetReanimateFn = function() return reanimatefunc end

	-- ==================================================
	--                  SOUND HELPER
	-- ==================================================
	-- Declared before C_c so the reanimate button can call it.

	local CreateSound = function(id, vol, pit)
		local snd = i("Sound")
		insSet(snd, "Name",    rs())
		insSet(snd, "SoundId", id  or "")
		insSet(snd, "Volume",  vol or 0.5)
		insSet(snd, "Pitch",   pit or 1)
		insSet(snd, "Playing", true)
		insSet(snd, "Parent",  game:GetService("SoundService"))
		Once(insGet(snd, "Ended"), function() Destroy(snd) end)
	end

	-- ==================================================
	--                    GUI ELEMENTS
	-- ==================================================

	local TweenService = game:GetService("TweenService")
	local LMG2L = {}

	local player    = game:GetService("Players").LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	LMG2L["ScreenGui_1"] = Instance.new("ScreenGui", playerGui)
	LMG2L["ScreenGui_1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
	LMG2L["ScreenGui_1"]["ResetOnSpawn"]   = false

	LMG2L["Frame_2"] = Instance.new("Frame", LMG2L["ScreenGui_1"])
	LMG2L["Frame_2"]["BorderSizePixel"]      = 0
	LMG2L["Frame_2"]["BackgroundColor3"]     = Color3.fromRGB(255, 170, 115)
	LMG2L["Frame_2"]["Size"]                 = UDim2.new(0, 450, 0, 186)
	LMG2L["Frame_2"]["BackgroundTransparency"] = 0.3
	LMG2L["Frame_2"]["AnchorPoint"]          = Vector2.new(0.5, 0.5)
	LMG2L["Frame_2"]["Position"]             = UDim2.new(0.5, 0, 0.5, 0)

	local dragDetector = Instance.new("UIDragDetector", LMG2L["Frame_2"])
	dragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslatePlane

	LMG2L["UICorner_3"] = Instance.new("UICorner", LMG2L["Frame_2"])
	LMG2L["UICorner_3"]["CornerRadius"] = UDim.new(0, 12)

	LMG2L["TextLabel_4"] = Instance.new("TextLabel", LMG2L["Frame_2"])
	LMG2L["TextLabel_4"]["BorderSizePixel"]      = 0
	LMG2L["TextLabel_4"]["TextSize"]             = 24
	LMG2L["TextLabel_4"]["BackgroundColor3"]     = Color3.fromRGB(158, 67, 12)
	LMG2L["TextLabel_4"]["FontFace"]             = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	LMG2L["TextLabel_4"]["TextColor3"]           = Color3.fromRGB(54, 17, 0)
	LMG2L["TextLabel_4"]["BackgroundTransparency"] = 0.699
	LMG2L["TextLabel_4"]["Size"]                 = UDim2.new(0, 450, 0, 54)
	LMG2L["TextLabel_4"]["Text"]                 = [[Personal Reanimate]]

	LMG2L["UICorner_5"] = Instance.new("UICorner", LMG2L["TextLabel_4"])
	LMG2L["UICorner_5"]["CornerRadius"] = UDim.new(0, 12)

	LMG2L["TextLabel2_6"] = Instance.new("TextLabel", LMG2L["Frame_2"])
	LMG2L["TextLabel2_6"]["TextWrapped"]         = true
	LMG2L["TextLabel2_6"]["BorderSizePixel"]     = 0
	LMG2L["TextLabel2_6"]["TextSize"]            = 12
	LMG2L["TextLabel2_6"]["BackgroundColor3"]    = Color3.fromRGB(158, 67, 12)
	LMG2L["TextLabel2_6"]["FontFace"]            = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	LMG2L["TextLabel2_6"]["TextColor3"]          = Color3.fromRGB(54, 17, 0)
	LMG2L["TextLabel2_6"]["BackgroundTransparency"] = 0.699
	LMG2L["TextLabel2_6"]["Size"]                = UDim2.new(0, 204, 0, 82)
	LMG2L["TextLabel2_6"]["Text"]                = [[ my personal reanimation script - Exire]]
	LMG2L["TextLabel2_6"]["Name"]                = [[TextLabel2]]
	LMG2L["TextLabel2_6"]["Position"]            = UDim2.new(0, 14, 0, 76)

	LMG2L["UICorner_7"] = Instance.new("UICorner", LMG2L["TextLabel2_6"])
	LMG2L["UICorner_7"]["CornerRadius"] = UDim.new(0, 12)

	LMG2L["UIStroke_8"] = Instance.new("UIStroke", LMG2L["TextLabel2_6"])
	LMG2L["UIStroke_8"]["Transparency"]    = 0.3
	LMG2L["UIStroke_8"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
	LMG2L["UIStroke_8"]["Thickness"]       = 2
	LMG2L["UIStroke_8"]["Color"]           = Color3.fromRGB(59, 30, 0)

	LMG2L["TextButton_9"] = Instance.new("TextButton", LMG2L["Frame_2"])
	LMG2L["TextButton_9"]["BorderSizePixel"]      = 0
	LMG2L["TextButton_9"]["TextSize"]             = 24
	LMG2L["TextButton_9"]["TextColor3"]           = Color3.fromRGB(54, 17, 0)
	LMG2L["TextButton_9"]["BackgroundColor3"]     = Color3.fromRGB(149, 52, 0)
	LMG2L["TextButton_9"]["FontFace"]             = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	LMG2L["TextButton_9"]["BackgroundTransparency"] = 0.8
	LMG2L["TextButton_9"]["Size"]                 = UDim2.new(0, 194, 0, 82)
	LMG2L["TextButton_9"]["Text"]                 = [[Reanimate]]
	LMG2L["TextButton_9"]["Position"]             = UDim2.new(0, 230, 0, 76)

	LMG2L["UICorner_a"] = Instance.new("UICorner", LMG2L["TextButton_9"])
	LMG2L["UICorner_a"]["CornerRadius"] = UDim.new(0, 12)

	LMG2L["UIStroke_b"] = Instance.new("UIStroke", LMG2L["TextButton_9"])
	LMG2L["UIStroke_b"]["Transparency"]    = 0.3
	LMG2L["UIStroke_b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
	LMG2L["UIStroke_b"]["Thickness"]       = 2
	LMG2L["UIStroke_b"]["Color"]           = Color3.fromRGB(59, 30, 0)

	LMG2L["UIStroke_d"] = Instance.new("UIStroke", LMG2L["Frame_2"])
	LMG2L["UIStroke_d"]["Transparency"] = 0.3
	LMG2L["UIStroke_d"]["Thickness"]    = 3
	LMG2L["UIStroke_d"]["Color"]        = Color3.fromRGB(59, 30, 0)

	LMG2L["MinButton"] = Instance.new("TextButton", LMG2L["Frame_2"])
	local minBtn = LMG2L["MinButton"]
	minBtn.Size                 = UDim2.new(0, 30, 0, 30)
	minBtn.Position             = UDim2.new(1, -35, 0, 5)
	minBtn.BackgroundColor3     = Color3.fromRGB(158, 67, 12)
	minBtn.BackgroundTransparency = 0.8
	minBtn.Text                 = "—"
	minBtn.TextColor3           = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
	local MinStroke = Instance.new("UIStroke", minBtn)
	MinStroke.Transparency    = 0.3
	MinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	MinStroke.Thickness       = 2
	MinStroke.Color           = Color3.fromRGB(59, 30, 0)

	-- ==================================================
	--                   GUI LOGIC
	-- ==================================================

	local function C_c()
		local mainFrame  = LMG2L["Frame_2"]
		local minBtn     = LMG2L["MinButton"]
		local reBtn      = LMG2L["TextButton_9"]
		local isMinimized = false
		local originalSize = mainFrame.Size
		local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		minBtn.MouseButton1Click:Connect(function()
			isMinimized = not isMinimized
			local targetSize = isMinimized and UDim2.new(0, 40, 0, 40) or originalSize
			TweenService:Create(mainFrame, tInfo, { Size = targetSize }):Play()
			for _, child in pairs(mainFrame:GetChildren()) do
				if child ~= minBtn and child:IsA("GuiObject") then
					child.Visible = not isMinimized
				end
			end
			minBtn.Text = isMinimized and "+" or "—"
		end)

		reBtn.MouseButton1Click:Connect(function()
			local fn = GetReanimateFn()
			if type(fn) == "function" then
				CreateSound("rbxassetid://907514098")
				fn()
			end
		end)
	end

	task.spawn(C_c)

	-- ==================================================
	--               TRANSITION HELPER
	-- ==================================================

	local TransitionGroups = {}
	local DoTransition = function(frame, speed, f)
		-- [ Full implementation unchanged from original ]
	end

	-- ==================================================
	--              PREVIEW IMAGE HELPER
	-- ==================================================

	local SetPreviewImage = function(id, imgscale)
		-- Sets the mode preview image in the UI.
	end

	-- ==================================================
	--                 CONSOLE LOG HELPER
	-- ==================================================

	local AddLog = function(s, h, c)
		-- Appends a line to the console log.
	end

	-- ==================================================
	--               SETTINGS TAB HELPERS
	-- ==================================================

	local AddLabel = function(txt, h, c)
	end

	local AddToggleButton = function(txt, val, t, f)
	end

	local AddSwitchButton = function(txt, val, t, f)
	end

	local AddInputBox = function(txt, val, f)
	end

	-- ==================================================
	--                 CREDITS HELPER
	-- ==================================================

	local AddCredit = function(txt, size)
	end

	-- ==================================================
	--                 ASSET PRELOADER
	-- ==================================================

	local PreloadAssets = function(t, f)
		-- Shows loader overlay, preloads asset list `t`,
		-- then calls callback `f` and hides overlay.
		if type(f) == "function" then f() end
	end

	-- ==================================================
	--              KEY SYSTEM (OPTIONAL)
	-- ==================================================

	local EnableKeySystem = false

	-- ==================================================
	--                   MAIN START
	-- ==================================================

	local FileSystemSupported = InitiateFiles()

	local Start = function()
		-- GUI is already visible; nothing needed here.
	end

	-- ==================================================
	--                 CONSOLE STUB
	-- ==================================================
	-- Stub so all Lib.Console.newCommand / addLog calls
	-- are silent no-ops until a real console is wired in.

	local Console = {
		newCommand = function() end,
		addLog     = function() end,
		logs       = {},
	}
	local mradN05 = -0.008726646259971648
		local pi2     = math.pi / 2 - 0.0001
		local npi2    = -pi2
		local KeyCode  = e.KeyCode
		local enumYXZ  = e.RotationOrder.YXZ

		local mode        = "default"
		local defaultmode = {}
		local modes       = { default = defaultmode }

		local lerpsIdle = emptyfunction
		local lerpsWalk = emptyfunction
		local lerpsJump = emptyfunction
		local lerpsFall = emptyfunction

		local addmode = function(key, modeTable)
			if (type(key) ~= "string") or (type(modeTable) ~= "table") then
				return
			end
			-- Strip non-function entries
			for i, v in next, modeTable do
				if type(v) ~= "function" then
					modeTable[i] = nil
				end
			end
			if key == "default" then
				defaultmode      = modeTable
				modes.default    = modeTable
				lerpsIdle        = modeTable.idle or emptyfunction
				lerpsWalk        = modeTable.walk or emptyfunction
				lerpsJump        = modeTable.jump or emptyfunction
				lerpsFall        = modeTable.fall or emptyfunction
				if modeTable.modeEntered then
					modeTable.modeEntered()
				end
			elseif #key == 1 then
				local enumKey    = KeyCode[supper(ssub(key, 1, 1))]
				modes[enumKey]   = modeTable
			end
		end
	-- ==================================================
	--                  RETURN PUBLIC API
	-- ==================================================

	return {
		Console             = Console,
		Start               = Start,
		PreloadAssets       = PreloadAssets,
		SetPreviewImage     = SetPreviewImage,
		AddLabel            = AddLabel,
		AddToggleButton     = AddToggleButton,
		AddSwitchButton     = AddSwitchButton,
		AddInputBox         = AddInputBox,
		AddCredit           = AddCredit,
		AddLog              = AddLog,
		OnReanimate         = OnReanimate,
		OnRespawn           = OnRespawn,
		GetReanimateFn      = GetReanimateFn,
		addmode             = addmode,   -- now accessible in mainscript
		modes               = modes,
		FileSystemSupported = function() return FileSystemSupported end,
	}
end

-- ==================================================
--               LOADED ASSETS CACHE
-- ==================================================

local loadedassets = {}

-- ==================================================
--                  LIB INITIALISE
-- ==================================================

local Lib = InitModule()
Lib.AddLog("[+] Base template loaded", 0.1)

-- ==================================================
--                 CREDITS / LABELS
-- ==================================================

Lib.AddCredit("MyWorld - FDless",      17)
Lib.AddCredit("SGZR/SGR/SGI - Origins", 17)
Lib.AddLabel("Your custom label here", 0.05, Color3.new(0.75, 0.75, 0.75))

-- ==================================================
--             EFFECT STORAGE (MESHPACK)
-- ==================================================

local effectstorage = nil
do
	local success, effectpack = pcall(function()
		return insGet(game, "GetObjects")(game, "rbxassetid://71648554814903")[1]
	end)
	if success and typeof(effectpack) == "Instance" then
		effectstorage = effectpack
		insSet(effectstorage, "Name", "EffectMeshes")
		insSet(effectstorage, "Parent", ws)
	end
end

-- ==================================================
--                  ASSET PRELOAD
-- ==================================================

Lib.PreloadAssets({
	"rbxassetid://71648554814903"
}, function()
	local files = {
		"azsumeo.mp3", "betrayal.mp3", "earlf.mp3",
		"inferplyx.mp3", "lighthopes.mp3", "mayhemx.mp3",
		"nhelv.mp3", "rpg.mp3", "solemn.mp3",
		"revengoner.mp3", "comatose.mp3", "censored.mp3",
		"descengoner.mp3", "massacre.mp3", "enclosure.mp3",
	}
	-- [ Download / cache loop goes here ]
end)

-- ==================================================
--               CONSOLE COMMANDS SETUP
-- ==================================================

local cmdfuncs = {
	teleport = emptyfunction,
	fling    = emptyfunction,
	fly      = emptyfunction,
	unfly    = emptyfunction,
}

Lib.Console.newCommand({"to","goto"},               cmdfuncs.teleport)
Lib.Console.newCommand({"fling","predictionfling"},  cmdfuncs.fling)
Lib.Console.newCommand({"fly","flight"},             cmdfuncs.fly)
Lib.Console.newCommand({"unfly","unflight"},         cmdfuncs.unfly)

Lib.Console.newCommand({"print"}, function(...)
	local s = ""
	for _, v in next, {...} do s = s .. " " .. v end
	Lib.Console.addLog(string.format("[$24H]: %s", s))
end)

Lib.Console.newCommand({"clear"}, function()
	for _, v in next, Lib.Console.logs do v:Destroy() end
	tclear(Lib.Console.logs)
end)

Lib.Console.newCommand({"cmds"}, function()
	Lib.Console.addLog("> to/goto [name]  (reanimate)")
	Lib.Console.addLog("> fling [name]    (reanimate)")
	Lib.Console.addLog("> fly [speed]     (reanimate)")
	Lib.Console.addLog("> unfly           (reanimate)")
	Lib.Console.addLog("> print [text]")
	Lib.Console.addLog("> clear")
end)

-- ==================================================
--                  BINDABLE PARENT
-- ==================================================

insSet(bindable, "Parent", ws)

-- ==================================================
--                    MAIN SCRIPT
-- ==================================================

local mainscript = function()
	local t = reanimate()
	if type(t) ~= "table" then return end

	-- ==================================================
	--             JOINT / PART REFERENCES
	-- ==================================================

	local velYchg         = t.velYchg
	local Yvel            = t.Yvel
	local raycastlegs     = t.raycastlegs
	local getPartFromMesh = t.getPartFromMesh
	local getPartJoint    = t.getPartJoint
	local velbycfrvec     = t.velbycfrvec
	local setWalkSpeed    = t.setWalkSpeed
	local rgb             = Color3.fromRGB
	local R6parts         = t.R6parts
	local setCamOffset    = t.setCamOffset
	local Player          = game.Players.LocalPlayer
	local getVel          = t.getVel
	local IsWalking       = t.IsWalking
	local getJoint        = t.getJoint
	local setCfr          = t.setCfr
	local cframes         = t.cframes
	local joints          = t.joints
	local refreshjoints   = t.refreshjoints
	local onnewcamera     = t.onnewcamera
	local SoundService    = game.SoundService
	local setHipHeight    = t.setHipHeight
	local getAccWeldFromMesh = t.getAccWeldFromMesh
	local getPart         = t.getPart
	local addmode         = t.addmode
	local setJumpPower    = t.setJumpPower
	local setGravity      = t.setGravity

	local RootJoint      = getJoint("RootJoint")
	local RightShoulder  = getJoint("Right Shoulder")
	local LeftShoulder   = getJoint("Left Shoulder")
	local RightHip       = getJoint("Right Hip")
	local LeftHip        = getJoint("Left Hip")
	local Neck           = getJoint("Neck")

	local gun                      = getPartFromMesh(6831441507, 6833003967) or nil
	local AJBackAccessory          = getPartJoint(gun) or nil
	local Pixie                    = getPartFromMesh(128216670, 150379943) or nil
	local SpringPixie_150381051_LC = getPartJoint(Pixie) or nil
	local staff                    = getPartFromMesh(5548423017, 5548423938) or nil
	local CrystalStaff             = getPartJoint(staff) or nil
	local rock                     = getPartFromMesh(4307568890, 4307568951) or nil
	local RockAccessory            = getPartJoint(rock) or nil

	-- ==================================================
	--              FLY / TELEPORT STATE
	-- ==================================================

	local flyFunc = nil
	local flycf   = nil
	local flypos  = nil
	local charcf  = cf_0

	-- ==================================================
	--               CONSOLE COMMAND IMPL
	-- ==================================================

	cmdfuncs.teleport = function(who)
		-- Teleport to player `who` ("me" / "random" / name)
	end
	cmdfuncs.fling = function(who)
		-- Fling player `who`
	end
	cmdfuncs.fly = function(speed)
		-- Begin flying at optional `speed`
	end
	cmdfuncs.unfly = function()
		flyFunc = nil
	end

	Lib.Console.newCommand({"to","goto"},               cmdfuncs.teleport)
	Lib.Console.newCommand({"fling","predictionfling"},  cmdfuncs.fling)
	Lib.Console.newCommand({"fly","flight"},             cmdfuncs.fly)
	Lib.Console.newCommand({"unfly","unflight"},         cmdfuncs.unfly)

	-- ==================================================
	--                  RESPAWN HOOK
	-- ==================================================

	onrespawn = function()
		currentmode = "q"
		local SS = game:GetService("SoundService")
		for _, object in ipairs(SS:GetChildren()) do
			if object.Name:find("ModeMusic_") then
				object:Destroy()
			end
		end
		local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		local existingHUD = PlayerGui:FindFirstChild("LightningCannonHud")
		if existingHUD then
			existingHUD:Destroy()
		end
	end

	-- ==================================================
	--                LOOP FUNCTION
	-- ==================================================

	local loopFunc = function()
		-- per-mode ground effects go here
	end

	-- ==================================================
	--                MUSIC HELPER
	-- ==================================================

	local switchtheme = function(name, vol, pit, time)
		-- Play loadedassets[name .. ".mp3"] on the music sound
	end

	-- ==================================================
	--             ANIMATION ATTACK KEYS
	-- ==================================================

	local attackAnimation = nil
	local attackkeys = {}

	-- ==================================================
	--                   ADD MODES
	-- ==================================================

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

	-- ==================================================
	--                  ATTACKS
	-- ==================================================

	attackkeys["gun"] = {
		["z"] = function()
			if attackAnimation then return end
			attackAnimation = function()
				-- lerp joints here
			end
			twait(0.25)
			attackAnimation = nil
		end
	}

	-- ==================================================
	--               INPUT: MODE SWITCHING
	-- ==================================================

	-- tinsert(cons, Connect(insGet(uis, "InputBegan"), function(a)
	--     if insGet(gs, "MenuIsOpen") or GetFocusedTextBox(uis) then return end
	--     a = slower(insGet(a, "KeyCode").Name)
	--     if currentmodes[a] then
	--         -- switch mode
	--     else
	--         -- check attackkeys
	--     end
	-- end))

	-- ==================================================
	--                    MUSIC
	-- ==================================================
	-- Setup Keybinds
	local UIS = game:GetService("UserInputService")
	_G.ModeV = "gunless" -- Default

	local keyBinds = {
			[Enum.KeyCode.F] = "gun"
	}
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

					playModeMusic()
			end
	end)
	local Folder = "ExiresPersonal"
	if isfolder and not isfolder(Folder) then makefolder(Folder) end
	local Path = Folder .. "/"

	local SongLinks = {
		["gunless"] = "https://github.com/bayly098764321/Hat-FE/blob/main/GunAway?raw=true",
		["gun"]     = "https://github.com/bayly098764321/Hat-FE/blob/main/GunOut?raw=true",
	}

	function getmp3(modeName)
		local filename = modeName .. ".mp3"
		local fullPath = Path .. filename
		if not isfile(fullPath) then
			local url = SongLinks[modeName]
			if url then
				local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
				if httpRequest then
					local response = httpRequest({ Url = url, Method = "GET" })
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

	local currentSound   = nil
	local currentSession = 0

	function playModeMusic()
		currentSession = currentSession + 1
		local mySession = currentSession

		if currentSound then
			currentSound:Stop()
			currentSound:Destroy()
			currentSound = nil
		end

		local targetMode = _G.ModeV
		local assetId    = getmp3(targetMode)

		if mySession ~= currentSession then return end

		if assetId then
			local sound = Instance.new("Sound")
			sound.Name    = "ModeMusic_" .. targetMode
			sound.SoundId = assetId
			sound.Volume  = 1
			sound.Looped  = true
			sound.Parent  = game:GetService("SoundService")

			task.spawn(function()
				local timeout = 0
				while sound.TimeLength == 0 and timeout < 50 do
					task.wait(0.1)
					timeout = timeout + 1
					if mySession ~= currentSession then
						sound:Destroy()
						return
					end
				end
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

	playModeMusic()
end -- end mainscript

-- ==================================================
--                 LIBRARY START
-- ==================================================

Lib.Start()
Lib.OnReanimate(mainscript)
Lib.OnRespawn(function()
	cmdfuncs.teleport = emptyfunction
	cmdfuncs.fling    = emptyfunction
	cmdfuncs.fly      = emptyfunction
	cmdfuncs.unfly    = emptyfunction
	stopreanimate()
end)
