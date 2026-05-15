--[[
	╔══════════════════════════════════════════════════════════════════════╗
	║        CFrame Lerp Animation Editor  •  Executor Edition  v2.1      ║
	║  Direct Motor6D.C0 lerping  •  NO AnimationTracks / KeyframeSeq     ║
	║  CoreGui parent  •  Screen-scaled  •  R6 safe                       ║
	╚══════════════════════════════════════════════════════════════════════╝

	FIXES in v2.1:
	  - Right arm no longer detected as accessory (match by Motor6D.Name, not Parent.Name)
	  - Roblox Animate LocalScript is disabled so default animations stop fighting C0
	  - Joints are fetched AFTER a short yield so they exist when the script runs
	  - Accessory section only built when actual accessories are found
	  - RenderStepped loop properly overrides all C0 every frame
--]]

-- ═══════════════════════════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Camera           = workspace.CurrentCamera

local player = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
--  WAIT FOR CHARACTER + JOINTS
-- ═══════════════════════════════════════════════════════════════════════
local char = player.Character or player.CharacterAdded:Wait()

-- Wait until the Torso exists (guarantees Motor6Ds are loaded)
local function waitForRig(c)
	local t = c:FindFirstChild("Torso")
		or c:FindFirstChild("UpperTorso")
		or c:FindFirstChild("HumanoidRootPart")
	if not t then
		c.ChildAdded:Wait()
		task.wait(0.1)
	end
	task.wait(0.1) -- one extra tick for Motor6Ds to replicate
end
waitForRig(char)

-- ═══════════════════════════════════════════════════════════════════════
--  DISABLE ROBLOX DEFAULT ANIMATE SCRIPT
--  Without this the Animate LocalScript rewrites Motor6D.C0 every frame
--  and fights our lerping — animations will appear frozen / glitchy.
-- ═══════════════════════════════════════════════════════════════════════
local function disableAnimate(c)
	local anim = c:FindFirstChild("Animate")
	if anim and anim:IsA("LocalScript") then
		anim.Disabled = true
	end
	-- Also stop any running AnimationTracks on the Humanoid
	local hum = c:FindFirstChildOfClass("Humanoid")
	if hum then
		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:Stop(0)
			end
		end
	end
end
disableAnimate(char)

-- ═══════════════════════════════════════════════════════════════════════
--  SCREEN SCALING  (design baseline 1920×1080)
-- ═══════════════════════════════════════════════════════════════════════
local BASE_W, BASE_H = 1920, 1080

local function calcScale()
	local vp = Camera.ViewportSize
	return math.min(vp.X / BASE_W, vp.Y / BASE_H)
end
local S = calcScale()

local function px(n)   return math.max(1, math.round(n * S)) end
local function ud(s,o) return UDim.new(s, px(o)) end
local FS = {
	tiny = math.max(8,  px(10)),
	sm   = math.max(9,  px(11)),
	md   = math.max(10, px(13)),
	lg   = math.max(11, px(15)),
}
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() S = calcScale() end)

-- ═══════════════════════════════════════════════════════════════════════
--  MATH HELPERS
-- ═══════════════════════════════════════════════════════════════════════
local cf     = CFrame.new
local angles = CFrame.Angles
local function cfMul(a,b) return a*b end
local function Lerp(a,b,t) return a:Lerp(b,t) end
local pi     = math.pi
local sin    = math.sin
local fmt    = string.format

-- ═══════════════════════════════════════════════════════════════════════
--  RUNTIME STATE
-- ═══════════════════════════════════════════════════════════════════════
local sine  = 0
local ALPHA = 0.2

-- ═══════════════════════════════════════════════════════════════════════
--  R6 DEFAULT C0 VALUES
-- ═══════════════════════════════════════════════════════════════════════
local R6_DEF = {
	RootJoint     = { pos = cf(0,0,0),     rot = angles(-pi/2, 0, pi)  },
	Neck          = { pos = cf(0,1,0),     rot = angles(-pi/2, 0, pi)  },
	RightShoulder = { pos = cf(1,0.5,0),   rot = angles(0,  pi/2, 0)   },
	LeftShoulder  = { pos = cf(-1,0.5,0),  rot = angles(0, -pi/2, 0)   },
	RightHip      = { pos = cf(0.5,-1,0),  rot = angles(0,  pi/2, 0)   },
	LeftHip       = { pos = cf(-0.5,-1,0), rot = angles(0, -pi/2, 0)   },
}

local function makeJointData(name)
	local d   = R6_DEF[name] or { pos = cf(0,0,0), rot = angles(0,0,0) }
	local rx, ry, rz = d.rot:ToEulerAnglesXYZ()
	return {
		name = name, enabled = true,
		posX = d.pos.X, posY = d.pos.Y, posZ = d.pos.Z,
		rotX = rx, rotY = ry, rotZ = rz,
		sineAmp = 0, sineSpeed = 1, sineOffset = 0, sineAxis = "X",
		sinePosAmp = 0, sinePosSpeed = 2, sinePosAxis = "Y",
		spinEnabled = false, spinSpeed = 1, spinAxis = "Y",
		lockX = false, lockY = false, lockZ = false,
		_spinAngle = 0,
	}
end

-- ── The 6 standard R6 joint names (Motor6D.Name, NOT Parent.Name) ────
local PART_NAMES = {
	"RootJoint", "Neck",
	"RightShoulder", "LeftShoulder",
	"RightHip", "LeftHip",
}

-- Build a set for quick lookup
local STANDARD_JOINT_NAMES = {}
for _, n in ipairs(PART_NAMES) do STANDARD_JOINT_NAMES[n] = true end

-- ── Find Motor6D by its OWN Name, not its parent ─────────────────────
local function findJoint(c, name)
	for _, v in ipairs(c:GetDescendants()) do
		if v:IsA("Motor6D") and v.Name == name then
			return v
		end
	end
end

local joints = {}
local function refreshJoints(c)
	for _, n in ipairs(PART_NAMES) do
		joints[n] = findJoint(c, n)
	end
end
refreshJoints(char)

-- ── Animation data ────────────────────────────────────────────────────
local animData = {}
for _, n in ipairs(PART_NAMES) do animData[n] = makeJointData(n) end

-- ── Accessories: ONLY Motor6Ds whose .Name is NOT a standard joint ────
local accessoryJoints = {}
local function detectAccessories(c)
	accessoryJoints = {}
	for _, inst in ipairs(c:GetDescendants()) do
		if inst:IsA("Motor6D") and not STANDARD_JOINT_NAMES[inst.Name] then
			-- Use Motor6D.Name as the key (unique weld name)
			local key = inst.Name
			if not accessoryJoints[key] then
				accessoryJoints[key] = { motor = inst, data = makeJointData(key) }
			end
		end
	end
end
detectAccessories(char)

-- ═══════════════════════════════════════════════════════════════════════
--  UNDO / REDO
-- ═══════════════════════════════════════════════════════════════════════
local undoStack, redoStack = {}, {}
local function deepCopy(t)
	local c = {}
	for k,v in pairs(t) do c[k] = type(v)=="table" and deepCopy(v) or v end
	return c
end
local function pushUndo()
	table.insert(undoStack, deepCopy(animData))
	if #undoStack > 50 then table.remove(undoStack, 1) end
	redoStack = {}
end
local function doUndo()
	if #undoStack == 0 then return end
	table.insert(redoStack, deepCopy(animData))
	local p = table.remove(undoStack)
	for k,v in pairs(p) do animData[k] = v end
end
local function doRedo()
	if #redoStack == 0 then return end
	table.insert(undoStack, deepCopy(animData))
	local p = table.remove(redoStack)
	for k,v in pairs(p) do animData[k] = v end
end
local clipboard = nil

-- ═══════════════════════════════════════════════════════════════════════
--  CODE EXPORT  (exact syntax, full precision)
-- ═══════════════════════════════════════════════════════════════════════
local function fmtN(n) return fmt("%.16g", n) end

local function sineExpr(amp, spd, off)
	if amp == 0 then return "" end
	local sign   = amp >= 0 and "+" or "-"
	local offStr = off ~= 0 and fmt("+%s", fmtN(off)) or ""
	return fmt("%s%s*sin(sine*%s%s)", sign, fmtN(math.abs(amp)), fmtN(spd), offStr)
end

local function buildCf(d)
	local se = sineExpr(d.sinePosAmp, d.sinePosSpeed, 0)
	local sX,sY,sZ = "","",""
	if     d.sinePosAxis=="X" then sX=se
	elseif d.sinePosAxis=="Y" then sY=se
	else                           sZ=se end
	return fmt("cf(%s%s,%s%s,%s%s)", fmtN(d.posX),sX, fmtN(d.posY),sY, fmtN(d.posZ),sZ)
end

local function buildAngles(d)
	local se = sineExpr(d.sineAmp, d.sineSpeed, d.sineOffset)
	local sX,sY,sZ = "","",""
	if     d.sineAxis=="X" then sX=se
	elseif d.sineAxis=="Y" then sY=se
	else                        sZ=se end
	return fmt("angles(%s%s,%s%s,%s%s)", fmtN(d.rotX),sX, fmtN(d.rotY),sY, fmtN(d.rotZ),sZ)
end

local function exportLine(varName, d)
	return fmt("%s.C0=Lerp(%s.C0,cfMul(%s,%s),deltaTime)",
		varName, varName, buildCf(d), buildAngles(d))
end

local function generateCode()
	local lines = {}
	for _, n in ipairs(PART_NAMES) do
		if animData[n].enabled then
			table.insert(lines, exportLine(n, animData[n]))
		end
	end
	for aname, info in pairs(accessoryJoints) do
		if info.data.enabled then
			table.insert(lines, exportLine(aname, info.data))
		end
	end
	return table.concat(lines, "\n")
end

-- ═══════════════════════════════════════════════════════════════════════
--  RUNTIME ANIMATION  (RenderStepped — pure Motor6D.C0 lerp)
-- ═══════════════════════════════════════════════════════════════════════
local function applyJoint(motor, d, dt)
	if not motor or not motor.Parent or not d.enabled then return end
	if d.spinEnabled then d._spinAngle = d._spinAngle + d.spinSpeed * dt end

	local spv = sin(sine * d.sinePosSpeed)
	local sv  = sin(sine * d.sineSpeed + d.sineOffset) * d.sineAmp

	local px_ = d.posX + (d.sinePosAxis=="X" and d.sinePosAmp*spv or 0)
	local py_ = d.posY + (d.sinePosAxis=="Y" and d.sinePosAmp*spv or 0)
	local pz_ = d.posZ + (d.sinePosAxis=="Z" and d.sinePosAmp*spv or 0)

	local rx = d.rotX + (d.sineAxis=="X" and sv or 0)
	local ry = d.rotY + (d.sineAxis=="Y" and sv or 0)
	local rz = d.rotZ + (d.sineAxis=="Z" and sv or 0)

	if d.spinEnabled then
		if     d.spinAxis=="X" then rx = rx + d._spinAngle
		elseif d.spinAxis=="Y" then ry = ry + d._spinAngle
		else                        rz = rz + d._spinAngle end
	end

	motor.C0 = Lerp(motor.C0, cfMul(cf(px_,py_,pz_), angles(rx,ry,rz)), ALPHA)
end

local rtConn
local function startRuntime()
	if rtConn then rtConn:Disconnect() end
	rtConn = RunService.RenderStepped:Connect(function(dt)
		sine = sine + dt * 60 * 0.016
		for _, n in ipairs(PART_NAMES) do
			applyJoint(joints[n], animData[n], dt)
		end
		for _, info in pairs(accessoryJoints) do
			applyJoint(info.motor, info.data, dt)
		end
	end)
end
startRuntime()

-- ═══════════════════════════════════════════════════════════════════════
--  DESTROY OLD GUI (safe re-execute)
-- ═══════════════════════════════════════════════════════════════════════
local old = CoreGui:FindFirstChild("CFrameAnimEditor")
if old then old:Destroy() end

-- ═══════════════════════════════════════════════════════════════════════
--  SCREENGUI
-- ═══════════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "CFrameAnimEditor"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 999
local ok = pcall(function() ScreenGui.Parent = CoreGui end)
if not ok then ScreenGui.Parent = player.PlayerGui end

-- ═══════════════════════════════════════════════════════════════════════
--  COLOUR PALETTE
-- ═══════════════════════════════════════════════════════════════════════
local C = {
	bg       = Color3.fromRGB(10, 10, 14),
	panel    = Color3.fromRGB(18, 18, 25),
	elevated = Color3.fromRGB(26, 26, 36),
	border   = Color3.fromRGB(40, 40, 56),
	accent   = Color3.fromRGB(78, 228, 196),
	accent2  = Color3.fromRGB(158, 128, 255),
	warn     = Color3.fromRGB(251, 191, 36),
	red      = Color3.fromRGB(248, 96, 96),
	green    = Color3.fromRGB(68, 220, 118),
	text     = Color3.fromRGB(212, 212, 228),
	muted    = Color3.fromRGB(105, 105, 135),
	white    = Color3.fromRGB(255, 255, 255),
	code     = Color3.fromRGB(120, 255, 190),
}

-- ═══════════════════════════════════════════════════════════════════════
--  INSTANCE HELPERS
-- ═══════════════════════════════════════════════════════════════════════
local function make(cls, props, parent)
	local i = Instance.new(cls)
	for k,v in pairs(props) do i[k]=v end
	if parent then i.Parent=parent end
	return i
end
local function frm(props, parent)
	props.BackgroundColor3 = props.BackgroundColor3 or C.panel
	props.BorderSizePixel  = props.BorderSizePixel  or 0
	return make("Frame", props, parent)
end
local function lbl(props, parent)
	props.BackgroundTransparency = props.BackgroundTransparency or 1
	props.TextColor3 = props.TextColor3 or C.text
	props.Font       = props.Font       or Enum.Font.Gotham
	props.TextSize   = props.TextSize   or FS.sm
	return make("TextLabel", props, parent)
end
local function btn(props, parent)
	props.BackgroundColor3 = props.BackgroundColor3 or C.elevated
	props.BorderSizePixel  = 0
	props.Font             = props.Font     or Enum.Font.GothamBold
	props.TextSize         = props.TextSize or FS.tiny
	props.TextColor3       = props.TextColor3 or C.text
	props.AutoButtonColor  = false
	local b   = make("TextButton", props, parent)
	local orig = props.BackgroundColor3
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(
			math.min(1,orig.R+0.08), math.min(1,orig.G+0.08), math.min(1,orig.B+0.08)
		)}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = orig}):Play()
	end)
	return b
end
local function crn(r, parent)
	return make("UICorner", {CornerRadius = ud(0,r)}, parent)
end
local function pad(t, b, l, r, parent)
	return make("UIPadding", {
		PaddingTop=ud(0,t), PaddingBottom=ud(0,b),
		PaddingLeft=ud(0,l), PaddingRight=ud(0,r),
	}, parent)
end
local function strk(col, th, parent)
	return make("UIStroke", {Color=col, Thickness=th}, parent)
end
local function listLayout(dir, gap, valign, parent)
	return make("UIListLayout", {
		FillDirection     = dir    or Enum.FillDirection.Vertical,
		Padding           = ud(0, gap or 3),
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
		SortOrder         = Enum.SortOrder.LayoutOrder,
	}, parent)
end

-- ═══════════════════════════════════════════════════════════════════════
--  WINDOW DIMENSIONS
-- ═══════════════════════════════════════════════════════════════════════
local WIN_W    = px(498)
local WIN_H    = px(624)
local TITLE_H  = px(34)
local TOOL_H   = px(32)
local SEARCH_H = px(30)
local PRESET_H = px(30)
local CODE_H   = px(112)
local SCROLL_H = WIN_H - TITLE_H - TOOL_H - SEARCH_H - PRESET_H - px(6) - CODE_H

local vp = Camera.ViewportSize
local WX = math.round(vp.X * 0.04)
local WY = math.round(vp.Y * 0.04)

-- ═══════════════════════════════════════════════════════════════════════
--  MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════════════
local Main = frm({
	Name="Main",
	Size=UDim2.fromOffset(WIN_W, WIN_H),
	Position=UDim2.fromOffset(WX, WY),
	BackgroundColor3=C.bg, ClipsDescendants=true,
}, ScreenGui)
crn(9, Main)
strk(C.border, 1.5, Main)

-- ── Title bar ─────────────────────────────────────────────────────────
local TitleBar = frm({Size=UDim2.new(1,0,0,TITLE_H), BackgroundColor3=C.panel}, Main)
crn(9, TitleBar)
frm({Size=UDim2.new(1,0,0,px(9)), Position=UDim2.new(0,0,1,-px(9)), BackgroundColor3=C.panel}, TitleBar)
frm({Size=UDim2.new(0,px(3),1,0), BackgroundColor3=C.accent}, TitleBar)

lbl({
	Size=UDim2.new(1,-px(110),1,0), Position=UDim2.new(0,px(10),0,0),
	Text="⟁  CFrame Lerp Animation Editor",
	TextColor3=C.white, Font=Enum.Font.GothamBold, TextSize=FS.md,
	TextXAlignment=Enum.TextXAlignment.Left,
}, TitleBar)

local vb = frm({Size=UDim2.fromOffset(px(36),px(15)), Position=UDim2.new(1,-px(88),0.5,-px(7)), BackgroundColor3=C.accent2}, TitleBar)
crn(3,vb)
lbl({Size=UDim2.new(1,0,1,0), Text="v2.1", Font=Enum.Font.GothamBold, TextSize=FS.tiny, TextColor3=C.white, BackgroundTransparency=0}, vb)

local CloseBtn = btn({
	Size=UDim2.fromOffset(px(20),px(20)), Position=UDim2.new(1,-px(24),0.5,-px(10)),
	BackgroundColor3=C.red, Text="✕", TextSize=FS.tiny, TextColor3=C.white,
}, TitleBar)
crn(4, CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible=false end)

local MinBtn = btn({
	Size=UDim2.fromOffset(px(20),px(20)), Position=UDim2.new(1,-px(48),0.5,-px(10)),
	BackgroundColor3=C.elevated, Text="─", TextSize=FS.tiny, TextColor3=C.muted,
}, TitleBar)
crn(4, MinBtn)
local minimised = false
MinBtn.MouseButton1Click:Connect(function()
	minimised = not minimised
	TweenService:Create(Main, TweenInfo.new(0.18,Enum.EasingStyle.Quint), {
		Size = minimised and UDim2.fromOffset(WIN_W,TITLE_H) or UDim2.fromOffset(WIN_W,WIN_H)
	}):Play()
end)

-- ── Drag ──────────────────────────────────────────────────────────────
do
	local dragging, dragStart, startPos
	TitleBar.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=true dragStart=inp.Position startPos=Main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
			local d=inp.Position-dragStart
			Main.Position=UDim2.fromOffset(startPos.X.Offset+d.X, startPos.Y.Offset+d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
	end)
end

-- ── Toolbar ───────────────────────────────────────────────────────────
local Toolbar = frm({Size=UDim2.new(1,0,0,TOOL_H), Position=UDim2.new(0,0,0,TITLE_H), BackgroundColor3=C.panel}, Main)
pad(px(4),px(4),px(6),px(6), Toolbar)
listLayout(Enum.FillDirection.Horizontal, px(3), Enum.VerticalAlignment.Center, Toolbar)

local function tbBtn(txt, bgCol, txCol)
	local b = btn({
		Size=UDim2.new(0,0,0,px(22)), AutomaticSize=Enum.AutomaticSize.X,
		BackgroundColor3=bgCol or C.elevated,
		Text=" "..txt.." ", TextSize=FS.tiny, Font=Enum.Font.GothamBold,
		TextColor3=txCol or C.text,
	}, Toolbar)
	pad(0,0,px(5),px(5),b); crn(4,b); return b
end

local UndoBtn     = tbBtn("↩ Undo")
local RedoBtn     = tbBtn("↪ Redo")
local ResetAllBtn = tbBtn("⟳ Reset All")
local ExportBtn   = tbBtn("⬡ Export", Color3.fromRGB(14,48,40), C.accent)
local JsonExpBtn  = tbBtn("↓ JSON")
local JsonImpBtn  = tbBtn("↑ JSON")

UndoBtn.MouseButton1Click:Connect(doUndo)
RedoBtn.MouseButton1Click:Connect(doRedo)
ResetAllBtn.MouseButton1Click:Connect(function()
	pushUndo(); for _,n in ipairs(PART_NAMES) do animData[n]=makeJointData(n) end
end)

-- ── Search bar ────────────────────────────────────────────────────────
local SearchY = TITLE_H + TOOL_H + px(2)
local SearchRow = frm({
	Size=UDim2.new(1,-px(12),0,px(26)), Position=UDim2.new(0,px(6),0,SearchY),
	BackgroundColor3=C.elevated,
}, Main)
crn(6, SearchRow); strk(C.border,1, SearchRow)
lbl({Size=UDim2.new(0,px(18),1,0), Position=UDim2.new(0,px(6),0,0),
	Text="🔍", TextColor3=C.muted, TextSize=FS.sm}, SearchRow)
local SearchInput = make("TextBox",{
	Size=UDim2.new(1,-px(26),1,0), Position=UDim2.new(0,px(22),0,0),
	BackgroundTransparency=1, Text="", PlaceholderText="Search body part…",
	Font=Enum.Font.Gotham, TextSize=FS.sm, TextColor3=C.text,
	PlaceholderColor3=C.muted, ClearTextOnFocus=false,
}, SearchRow)

-- ── Presets bar ───────────────────────────────────────────────────────
local PresetY = SearchY + SEARCH_H
local PresetRow = frm({
	Size=UDim2.new(1,0,0,PRESET_H), Position=UDim2.new(0,0,0,PresetY),
	BackgroundColor3=C.panel,
}, Main)
pad(px(3),px(3),px(6),px(6), PresetRow)
listLayout(Enum.FillDirection.Horizontal, px(3), Enum.VerticalAlignment.Center, PresetRow)
lbl({Size=UDim2.new(0,px(50),1,0), Text="Presets:", TextColor3=C.muted, TextSize=FS.tiny, Font=Enum.Font.GothamBold}, PresetRow)

-- ── Scroll frame ──────────────────────────────────────────────────────
local ScrollY = PresetY + PRESET_H + px(2)
local ScrollFrame = make("ScrollingFrame",{
	Size=UDim2.new(1,-px(6),0,SCROLL_H), Position=UDim2.new(0,px(3),0,ScrollY),
	BackgroundColor3=C.bg, BorderSizePixel=0,
	ScrollBarThickness=px(4), ScrollBarImageColor3=C.accent,
	CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
	ClipsDescendants=true,
}, Main)
listLayout(Enum.FillDirection.Vertical, px(3), Enum.VerticalAlignment.Top, ScrollFrame)
pad(px(3),px(3),px(3),px(3), ScrollFrame)

-- ── Code preview panel ────────────────────────────────────────────────
local CodeY = WIN_H - CODE_H
local CodePanel = frm({Size=UDim2.new(1,0,0,CODE_H), Position=UDim2.new(0,0,0,CodeY), BackgroundColor3=C.panel}, Main)
strk(C.border, 1, CodePanel)

local codeHdr = frm({Size=UDim2.new(1,0,0,px(18)), BackgroundColor3=C.elevated}, CodePanel)
lbl({
	Size=UDim2.new(1,-px(30),1,0), Position=UDim2.new(0,px(6),0,0),
	Text="LIVE EXPORT  ·  ⬡ freezes preview  ·  ⎘ copies code",
	TextColor3=C.muted, TextSize=FS.tiny, Font=Enum.Font.GothamBold,
	TextXAlignment=Enum.TextXAlignment.Left,
}, codeHdr)

local CopyBtn = btn({
	Size=UDim2.fromOffset(px(24),px(14)), Position=UDim2.new(1,-px(26),0.5,-px(7)),
	BackgroundColor3=C.accent, Text="⎘", TextSize=FS.tiny, TextColor3=C.bg,
}, codeHdr)
crn(3, CopyBtn)

local CodeLabel = lbl({
	Size=UDim2.new(1,-px(8),1,-px(22)), Position=UDim2.new(0,px(4),0,px(20)),
	Text="-- initialising…", TextColor3=C.code,
	Font=Enum.Font.Code, TextSize=FS.tiny,
	TextXAlignment=Enum.TextXAlignment.Left,
	TextYAlignment=Enum.TextYAlignment.Top,
	TextWrapped=true,
}, CodePanel)

CopyBtn.MouseButton1Click:Connect(function()
	local code = generateCode()
	if setclipboard then pcall(setclipboard, code)
	elseif syn and syn.clipboard then pcall(syn.clipboard.set, code)
	elseif writeclipboard then pcall(writeclipboard, code)
	else
		local tb = Instance.new("TextBox")
		tb.Parent=ScreenGui tb.Size=UDim2.fromOffset(1,1)
		tb.Position=UDim2.new(2,0,2,0) tb.Text=code
		tb:CaptureFocus()
		task.delay(0.05, function() tb:ReleaseFocus() tb:Destroy() end)
	end
	CopyBtn.Text="✓"
	task.delay(1.5, function() CopyBtn.Text="⎘" end)
end)

-- ═══════════════════════════════════════════════════════════════════════
--  REUSABLE WIDGETS
-- ═══════════════════════════════════════════════════════════════════════

-- Slider row — returns (frame, setValueFn)
local function makeSliderRow(parent, labelTxt, minV, maxV, initV, onChange, lo)
	local row = frm({Size=UDim2.new(1,-px(6),0,px(22)), BackgroundTransparency=1, LayoutOrder=lo}, parent)

	lbl({
		Size=UDim2.new(0,px(78),1,0), Text=labelTxt,
		TextColor3=C.muted, TextSize=FS.tiny, Font=Enum.Font.Gotham,
		TextXAlignment=Enum.TextXAlignment.Left,
	}, row)

	local range = math.max(maxV-minV, 1e-6)
	local initT = math.clamp((initV-minV)/range, 0, 1)

	local track = frm({Size=UDim2.new(1,-px(134),0,px(4)), Position=UDim2.new(0,px(80),0.5,-px(2)), BackgroundColor3=C.border}, row)
	crn(px(2), track)
	local fill  = frm({Size=UDim2.new(initT,0,1,0), BackgroundColor3=C.accent}, track)
	crn(px(2), fill)
	local thumb = frm({Size=UDim2.fromOffset(px(10),px(10)), Position=UDim2.new(initT,-px(5),0.5,-px(5)), BackgroundColor3=C.white}, track)
	crn(px(5), thumb)

	local numBox = make("TextBox",{
		Size=UDim2.fromOffset(px(48),px(18)), Position=UDim2.new(1,-px(50),0.5,-px(9)),
		BackgroundColor3=C.elevated, BorderSizePixel=0,
		Text=fmt("%.4f",initV), Font=Enum.Font.Code,
		TextSize=FS.tiny, TextColor3=C.accent, ClearTextOnFocus=true,
	}, row)
	crn(px(3), numBox)

	local function setVal(v)
		v = math.clamp(v, minV, maxV)
		local t = math.clamp((v-minV)/range, 0, 1)
		fill.Size      = UDim2.new(t, 0, 1, 0)
		thumb.Position = UDim2.new(t, -px(5), 0.5, -px(5))
		numBox.Text    = fmt("%.4f", v)
		onChange(v)
	end

	local sliderDrag = false
	track.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 then
			sliderDrag=true
			local ap=track.AbsolutePosition; local as=track.AbsoluteSize
			setVal(minV + math.clamp((inp.Position.X-ap.X)/as.X,0,1)*range)
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if sliderDrag and inp.UserInputType==Enum.UserInputType.MouseMovement then
			local ap=track.AbsolutePosition; local as=track.AbsoluteSize
			setVal(minV + math.clamp((inp.Position.X-ap.X)/as.X,0,1)*range)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 then sliderDrag=false end
	end)
	numBox.FocusLost:Connect(function()
		local v=tonumber(numBox.Text); if v then pushUndo(); setVal(v) end
	end)

	return row, setVal
end

-- Toggle
local function makeToggle(parent, labelTxt, initState, onChange, lo)
	local row = frm({Size=UDim2.new(1,-px(6),0,px(22)), BackgroundTransparency=1, LayoutOrder=lo}, parent)
	lbl({
		Size=UDim2.new(1,-px(50),1,0), Text=labelTxt,
		TextColor3=C.muted, TextSize=FS.tiny, Font=Enum.Font.Gotham,
		TextXAlignment=Enum.TextXAlignment.Left,
	}, row)
	local trk = frm({Size=UDim2.fromOffset(px(34),px(17)), Position=UDim2.new(1,-px(38),0.5,-px(8)), BackgroundColor3=initState and C.accent or C.border}, row)
	crn(px(9), trk)
	local knob = frm({
		Size=UDim2.fromOffset(px(13),px(13)),
		Position=initState and UDim2.new(1,-px(15),0.5,-px(6)) or UDim2.new(0,px(2),0.5,-px(6)),
		BackgroundColor3=C.white,
	}, trk)
	crn(px(7), knob)
	local state = initState
	local function setState(v)
		state=v
		TweenService:Create(trk,TweenInfo.new(0.12),{BackgroundColor3=v and C.accent or C.border}):Play()
		TweenService:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-px(15),0.5,-px(6)) or UDim2.new(0,px(2),0.5,-px(6))}):Play()
	end
	trk.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 then state=not state; setState(state); onChange(state) end
	end)
	return row, setState
end

-- Axis selector
local function makeAxisSelect(parent, labelTxt, initAxis, onChange, lo)
	local row = frm({Size=UDim2.new(1,-px(6),0,px(22)), BackgroundTransparency=1, LayoutOrder=lo}, parent)
	lbl({
		Size=UDim2.new(0,px(78),1,0), Text=labelTxt,
		TextColor3=C.muted, TextSize=FS.tiny, Font=Enum.Font.Gotham,
		TextXAlignment=Enum.TextXAlignment.Left,
	}, row)
	local AX   = {"X","Y","Z"}
	local btns = {}
	for i,ax in ipairs(AX) do
		local active = ax==initAxis
		local b = btn({
			Size=UDim2.fromOffset(px(28),px(18)),
			Position=UDim2.new(0, px(80)+(i-1)*px(32), 0.5, -px(9)),
			BackgroundColor3=active and C.accent or C.elevated,
			Text=ax, TextSize=FS.tiny, Font=Enum.Font.GothamBold,
			TextColor3=active and C.bg or C.text,
		}, row)
		crn(px(3), b); btns[ax]=b
		b.MouseButton1Click:Connect(function()
			for _,a in ipairs(AX) do
				btns[a].BackgroundColor3 = a==ax and C.accent or C.elevated
				btns[a].TextColor3       = a==ax and C.bg     or C.text
			end
			onChange(ax)
		end)
	end
	return row
end

-- Separator
local function makeSep(parent, txt, lo)
	local s = frm({Size=UDim2.new(1,-px(6),0,px(13)), BackgroundTransparency=1, LayoutOrder=lo}, parent)
	lbl({Size=UDim2.new(1,0,1,0), Text=txt, TextColor3=Color3.fromRGB(55,55,78),
		TextSize=math.max(7,FS.tiny-1), Font=Enum.Font.GothamBold,
		TextXAlignment=Enum.TextXAlignment.Left}, s)
end

-- ═══════════════════════════════════════════════════════════════════════
--  PER-JOINT SECTION BUILDER
-- ═══════════════════════════════════════════════════════════════════════
local DISPLAY_NAMES = {
	RootJoint     = "Torso        (RootJoint)",
	Neck          = "Head         (Neck)",
	RightShoulder = "R Arm        (RightShoulder)",
	LeftShoulder  = "L Arm        (LeftShoulder)",
	RightHip      = "R Leg        (RightHip)",
	LeftHip       = "L Leg        (LeftHip)",
}

local jointSections = {}
local loCount = 0
local function nlo() loCount=loCount+1; return loCount end

local MIRROR_MAP = {
	RightShoulder="LeftShoulder", LeftShoulder="RightShoulder",
	RightHip="LeftHip",          LeftHip="RightHip",
}

local function buildJointSection(name, d, parentFrame, isAcc)
	local dispName = isAcc and ("✦ Acc: "..name) or (DISPLAY_NAMES[name] or name)
	local sectionCollapsed = false

	-- Header
	local header = frm({Size=UDim2.new(1,-px(6),0,px(28)), BackgroundColor3=C.elevated, LayoutOrder=nlo()}, parentFrame)
	crn(px(5), header); strk(C.border, 1, header)

	local arrowL = lbl({
		Size=UDim2.fromOffset(px(16),px(28)), Position=UDim2.new(0,px(5),0,0),
		Text="▼", TextColor3=C.accent, TextSize=FS.tiny, Font=Enum.Font.GothamBold,
	}, header)
	lbl({
		Size=UDim2.new(1,-px(58),1,0), Position=UDim2.new(0,px(22),0,0),
		Text=dispName, TextColor3=C.text, TextSize=FS.sm, Font=Enum.Font.GothamBold,
		TextXAlignment=Enum.TextXAlignment.Left,
	}, header)

	local enBtn = btn({
		Size=UDim2.fromOffset(px(38),px(15)), Position=UDim2.new(1,-px(42),0.5,-px(7)),
		BackgroundColor3=d.enabled and Color3.fromRGB(16,50,38) or C.elevated,
		Text=d.enabled and "ON" or "OFF", TextSize=FS.tiny, Font=Enum.Font.GothamBold,
		TextColor3=d.enabled and C.green or C.muted,
	}, header)
	crn(px(3), enBtn)
	enBtn.MouseButton1Click:Connect(function()
		d.enabled=not d.enabled
		enBtn.BackgroundColor3=d.enabled and Color3.fromRGB(16,50,38) or C.elevated
		enBtn.Text=d.enabled and "ON" or "OFF"
		enBtn.TextColor3=d.enabled and C.green or C.muted
	end)

	-- Body
	local body = frm({Size=UDim2.new(1,-px(6),0,0), AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundColor3=C.panel, LayoutOrder=nlo()}, parentFrame)
	crn(px(5), body)
	listLayout(Enum.FillDirection.Vertical, px(2), Enum.VerticalAlignment.Top, body)
	pad(px(5),px(6),px(5),px(5), body)

	header.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 then
			sectionCollapsed=not sectionCollapsed
			body.Visible=not sectionCollapsed
			arrowL.Text=sectionCollapsed and "▶" or "▼"
		end
	end)

	-- Position
	makeSep(body,"──  POSITION",nlo())
	local _,setPX = makeSliderRow(body,"Pos X",-5,5, d.posX, function(v) d.posX=v end, nlo())
	local _,setPY = makeSliderRow(body,"Pos Y",-5,5, d.posY, function(v) d.posY=v end, nlo())
	local _,setPZ = makeSliderRow(body,"Pos Z",-5,5, d.posZ, function(v) d.posZ=v end, nlo())

	-- Rotation
	makeSep(body,"──  ROTATION  (radians)",nlo())
	local _,setRX = makeSliderRow(body,"Rot X",-pi,pi, d.rotX, function(v) d.rotX=v end, nlo())
	local _,setRY = makeSliderRow(body,"Rot Y",-pi,pi, d.rotY, function(v) d.rotY=v end, nlo())
	local _,setRZ = makeSliderRow(body,"Rot Z",-pi,pi, d.rotZ, function(v) d.rotZ=v end, nlo())

	-- Sine rotation
	makeSep(body,"──  SINE  ·  Rotation",nlo())
	local _,setSAmp  = makeSliderRow(body,"Amplitude",-pi,pi, d.sineAmp,    function(v) d.sineAmp=v    end, nlo())
	local _,setSSpd  = makeSliderRow(body,"Speed",    0.1, 8, d.sineSpeed,  function(v) d.sineSpeed=v  end, nlo())
	local _,setSOff  = makeSliderRow(body,"Offset",  -pi,pi, d.sineOffset, function(v) d.sineOffset=v end, nlo())
	makeAxisSelect(body,"Axis",d.sineAxis,function(ax) d.sineAxis=ax end,nlo())

	-- Sine position
	makeSep(body,"──  SINE  ·  Position",nlo())
	local _,setSPAmp = makeSliderRow(body,"Amplitude",-3,3, d.sinePosAmp,   function(v) d.sinePosAmp=v   end, nlo())
	local _,setSPSpd = makeSliderRow(body,"Speed",   0.1,8, d.sinePosSpeed, function(v) d.sinePosSpeed=v end, nlo())
	makeAxisSelect(body,"Axis",d.sinePosAxis,function(ax) d.sinePosAxis=ax end,nlo())

	-- Spin
	makeSep(body,"──  INFINITE SPIN",nlo())
	makeToggle(body,"Enabled",d.spinEnabled,function(v) d.spinEnabled=v d._spinAngle=0 end,nlo())
	local _,setSpnSpd = makeSliderRow(body,"Speed",0,10, d.spinSpeed, function(v) d.spinSpeed=v end, nlo())
	makeAxisSelect(body,"Axis",d.spinAxis,function(ax) d.spinAxis=ax end,nlo())

	-- Axis lock
	makeSep(body,"──  AXIS LOCK",nlo())
	local lockRow = frm({Size=UDim2.new(1,-px(6),0,px(22)), BackgroundTransparency=1, LayoutOrder=nlo()}, body)
	lbl({Size=UDim2.new(0,px(78),1,0), Text="Lock Axis", TextColor3=C.muted, TextSize=FS.tiny,
		Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, lockRow)
	for i,ax in ipairs({"X","Y","Z"}) do
		local b = btn({
			Size=UDim2.fromOffset(px(34),px(18)),
			Position=UDim2.new(0, px(80)+(i-1)*px(38), 0.5, -px(9)),
			BackgroundColor3=d["lock"..ax] and C.warn or C.elevated,
			Text=ax.." 🔒", TextSize=FS.tiny,
		}, lockRow)
		crn(px(3),b)
		b.MouseButton1Click:Connect(function()
			d["lock"..ax]=not d["lock"..ax]
			b.BackgroundColor3=d["lock"..ax] and C.warn or C.elevated
		end)
	end

	-- Actions
	makeSep(body,"──  ACTIONS",nlo())
	local actRow = frm({Size=UDim2.new(1,-px(6),0,px(24)), BackgroundTransparency=1, LayoutOrder=nlo()}, body)
	listLayout(Enum.FillDirection.Horizontal, px(4), Enum.VerticalAlignment.Center, actRow)

	local function aBtn(txt, bgCol, txCol)
		local b = btn({
			Size=UDim2.new(0,0,0,px(20)), AutomaticSize=Enum.AutomaticSize.X,
			BackgroundColor3=bgCol or C.elevated, Text=" "..txt.." ",
			TextSize=FS.tiny, TextColor3=txCol or C.text,
		}, actRow)
		pad(0,0,px(5),px(5),b); crn(px(3),b); return b
	end

	local resetBtn = aBtn("⟳ Reset")
	local copyBtn  = aBtn("⎘ Copy")
	local pasteBtn = aBtn("⎗ Paste")

	if MIRROR_MAP[name] then
		local mBtn = aBtn("↔ Mirror", Color3.fromRGB(20,24,52), C.accent2)
		mBtn.MouseButton1Click:Connect(function()
			pushUndo()
			local o = animData[MIRROR_MAP[name]]
			if o then
				o.posX=-d.posX; o.posY=d.posY; o.posZ=d.posZ
				o.rotX=d.rotX;  o.rotY=-d.rotY; o.rotZ=-d.rotZ
				o.sineAmp=d.sineAmp; o.sineSpeed=d.sineSpeed; o.sineAxis=d.sineAxis
				o.sinePosAmp=d.sinePosAmp; o.sinePosSpeed=d.sinePosSpeed; o.sinePosAxis=d.sinePosAxis
			end
		end)
	end

	resetBtn.MouseButton1Click:Connect(function()
		pushUndo()
		local fresh=makeJointData(name)
		for k,v in pairs(fresh) do d[k]=v end
		setPX(d.posX); setPY(d.posY); setPZ(d.posZ)
		setRX(d.rotX); setRY(d.rotY); setRZ(d.rotZ)
		setSAmp(d.sineAmp); setSSpd(d.sineSpeed); setSOff(d.sineOffset)
		setSPAmp(d.sinePosAmp); setSPSpd(d.sinePosSpeed)
		setSpnSpd(d.spinSpeed)
	end)
	copyBtn.MouseButton1Click:Connect(function() clipboard=deepCopy(d) end)
	pasteBtn.MouseButton1Click:Connect(function()
		if not clipboard then return end
		pushUndo()
		for k,v in pairs(clipboard) do d[k]=v end
		setPX(d.posX); setPY(d.posY); setPZ(d.posZ)
		setRX(d.rotX); setRY(d.rotY); setRZ(d.rotZ)
		setSAmp(d.sineAmp); setSSpd(d.sineSpeed); setSOff(d.sineOffset)
		setSPAmp(d.sinePosAmp); setSPSpd(d.sinePosSpeed)
		setSpnSpd(d.spinSpeed)
	end)

	jointSections[name] = {header=header, body=body}
end

-- Build standard joints
for _, n in ipairs(PART_NAMES) do
	buildJointSection(n, animData[n], ScrollFrame, false)
end

-- Build accessory sections (only if any found)
for aname, info in pairs(accessoryJoints) do
	buildJointSection(aname, info.data, ScrollFrame, true)
end

-- ═══════════════════════════════════════════════════════════════════════
--  PRESETS
-- ═══════════════════════════════════════════════════════════════════════
local PRESETS = {
	{name="Idle", apply=function()
		pushUndo()
		animData.RootJoint.sinePosAmp=0.06;  animData.RootJoint.sinePosAxis="Y"; animData.RootJoint.sinePosSpeed=2
		animData.Neck.rotX=-0.1
		animData.RightShoulder.sineAmp=0.06; animData.RightShoulder.sineAxis="X"; animData.RightShoulder.sineSpeed=2
		animData.LeftShoulder.sineAmp=0.06;  animData.LeftShoulder.sineAxis="X";  animData.LeftShoulder.sineSpeed=2
	end},
	{name="Walk", apply=function()
		pushUndo()
		animData.RightHip.sineAmp=0.45;       animData.RightHip.sineAxis="X";      animData.RightHip.sineSpeed=1
		animData.LeftHip.sineAmp=-0.45;        animData.LeftHip.sineAxis="X";       animData.LeftHip.sineSpeed=1
		animData.RightShoulder.sineAmp=-0.35;  animData.RightShoulder.sineAxis="X"; animData.RightShoulder.sineSpeed=1
		animData.LeftShoulder.sineAmp=0.35;    animData.LeftShoulder.sineAxis="X";  animData.LeftShoulder.sineSpeed=1
		animData.RootJoint.sinePosAmp=0.08;    animData.RootJoint.sinePosAxis="Y";  animData.RootJoint.sinePosSpeed=2
		animData.Neck.sineAmp=0.04;            animData.Neck.sineAxis="Y";          animData.Neck.sineSpeed=2
	end},
	{name="Pose", apply=function()
		pushUndo()
		animData.RightShoulder.rotX=-1.2; animData.RightShoulder.rotZ=0.4
		animData.LeftShoulder.rotX=-1.2;  animData.LeftShoulder.rotZ=-0.4
		animData.RightHip.rotX=-0.3;      animData.LeftHip.rotX=-0.3
		animData.Neck.rotX=-0.15
	end},
	{name="Crazy", apply=function()
		pushUndo()
		for _,n in ipairs(PART_NAMES) do
			animData[n].spinEnabled=true
			animData[n].spinSpeed=(math.random()*4)+1
			animData[n].spinAxis=({"X","Y","Z"})[math.random(1,3)]
			animData[n].sineAmp=math.random()*0.9
			animData[n].sinePosAmp=math.random()*0.6
		end
	end},
	{name="Reset All", apply=function()
		pushUndo(); for _,n in ipairs(PART_NAMES) do animData[n]=makeJointData(n) end
	end},
}
for _,p in ipairs(PRESETS) do
	local b = btn({
		Size=UDim2.new(0,0,0,px(22)), AutomaticSize=Enum.AutomaticSize.X,
		BackgroundColor3=C.elevated, Text=" "..p.name.." ", TextSize=FS.tiny, Font=Enum.Font.GothamBold,
	}, PresetRow)
	pad(0,0,px(5),px(5),b); crn(px(4),b)
	b.MouseButton1Click:Connect(p.apply)
end

-- ═══════════════════════════════════════════════════════════════════════
--  SEARCH FILTER
-- ═══════════════════════════════════════════════════════════════════════
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
	local q = SearchInput.Text:lower()
	for name, sec in pairs(jointSections) do
		local vis = q==""
			or name:lower():find(q,1,true)~=nil
			or (DISPLAY_NAMES[name] or ""):lower():find(q,1,true)~=nil
		sec.header.Visible = vis
		if not vis then sec.body.Visible = false end
	end
end)

-- ═══════════════════════════════════════════════════════════════════════
--  EXPORT / JSON
-- ═══════════════════════════════════════════════════════════════════════
local previewFrozen = false

ExportBtn.MouseButton1Click:Connect(function()
	previewFrozen = not previewFrozen
	ExportBtn.TextColor3 = previewFrozen and C.warn or C.accent
	ExportBtn.Text       = previewFrozen and " ⬡ Frozen " or " ⬡ Export "
	if previewFrozen then CodeLabel.Text = generateCode() end
end)

JsonExpBtn.MouseButton1Click:Connect(function()
	local t = {}
	for _,n in ipairs(PART_NAMES) do
		local d=animData[n]
		t[n]={posX=d.posX,posY=d.posY,posZ=d.posZ,rotX=d.rotX,rotY=d.rotY,rotZ=d.rotZ,
			sineAmp=d.sineAmp,sineSpeed=d.sineSpeed,sineOffset=d.sineOffset,sineAxis=d.sineAxis,
			sinePosAmp=d.sinePosAmp,sinePosSpeed=d.sinePosSpeed,sinePosAxis=d.sinePosAxis,
			spinEnabled=d.spinEnabled,spinSpeed=d.spinSpeed,spinAxis=d.spinAxis,enabled=d.enabled}
	end
	local ok,json=pcall(function() return HttpService:JSONEncode(t) end)
	CodeLabel.Text = ok and json or "-- JSON encode failed"
end)

JsonImpBtn.MouseButton1Click:Connect(function()
	CodeLabel.Text="-- Paste JSON here, then click '↑ JSON' again"
	local conn; conn=JsonImpBtn.MouseButton1Click:Connect(function()
		conn:Disconnect()
		local ok,t=pcall(function() return HttpService:JSONDecode(CodeLabel.Text) end)
		if ok and type(t)=="table" then
			pushUndo()
			for n,vals in pairs(t) do
				if animData[n] then for k,v in pairs(vals) do animData[n][k]=v end end
			end
			CodeLabel.Text="-- ✓ JSON imported"
		else CodeLabel.Text="-- ✗ Invalid JSON" end
	end)
end)

-- ═══════════════════════════════════════════════════════════════════════
--  LIVE PREVIEW
-- ═══════════════════════════════════════════════════════════════════════
local previewTimer = 0
RunService.RenderStepped:Connect(function(dt)
	previewTimer = previewTimer + dt
	if previewTimer >= 0.5 and not previewFrozen then
		previewTimer = 0
		local lines, i = {}, 0
		for line in generateCode():gmatch("[^\n]+") do
			i=i+1; lines[i]=line; if i>=5 then break end
		end
		if i > 0 then CodeLabel.Text = table.concat(lines,"\n") end
	end
end)

-- ═══════════════════════════════════════════════════════════════════════
--  CHARACTER RESPAWN
-- ═══════════════════════════════════════════════════════════════════════
player.CharacterAdded:Connect(function(newChar)
	char = newChar
	waitForRig(newChar)
	disableAnimate(newChar)
	refreshJoints(newChar)
	detectAccessories(newChar)
	startRuntime()
end)

-- ═══════════════════════════════════════════════════════════════════════
--  INIT PREVIEW
-- ═══════════════════════════════════════════════════════════════════════
task.delay(0.25, function() CodeLabel.Text = generateCode() end)

print(fmt("[CFrameAnimEditor v2.1]  scale=%.2fx  %dx%d  joints=%d  accessories=%d",
	S, WIN_W, WIN_H,
	#PART_NAMES,
	(function() local n=0; for _ in pairs(accessoryJoints) do n=n+1 end; return n end)()
))
