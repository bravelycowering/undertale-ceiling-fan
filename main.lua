local controlleftalt = {
	SELECT = "return",
	CANCEL = "lshift",
	MENU = "lctrl"
}
local controlrightalt = {
	SELECT = "kpenter",
	CANCEL = "rshift",
	MENU = "rctrl"
}

CONTROLS = {
	LEFT = "left",
	RIGHT = "right",
	UP = "up",
	DOWN = "down",
	SELECT = "z",
	CANCEL = "x",
--	HEAL = "e",
	MENU = "c"
}

local pressed = {
	LEFT = false,
	RIGHT = false,
	UP = false,
	DOWN = false,
	SELECT = false,
	CANCEL = false,
--	HEAL = false,
	MENU = false
}

local titles = {"DELTARUNE", "NUT DEALER", "ULTRA NEED", "DUAL ENTER", "ELDER TUNA", "RENTAL DUE", "TUNDRA EEL", "UN-ALTERED"}
love.window.setTitle(titles[math.floor(love.math.random() * #titles + 1)])

love.graphics.setDefaultFilter("nearest", "nearest")

local images = {}
local fonts = {}
local sounds = {}
local music = {}

TIME = 0

DEBUG = false

function CLEARCACHE()
	images = {}
	fonts = {}
	sounds = {}
	music = {}
end

function ABSIMAGE(path)
	if images[path] == nil then
		xpcall(function()
			images[path] = love.graphics.newImage(path..".png")
		end, function()
			images[path] = false
		end)
	end
	return images[path]
end

function IMAGE(path)
	return ABSIMAGE("assets/sprites/"..path)
end

function FONT(path)
	if not fonts[path] then
		local data = love.filesystem.read("string", "assets/sprites/"..path..".txt")
		fonts[path] = love.graphics.newImageFont("assets/sprites/"..path..".png", data, 1)
	end
	return fonts[path]
end

function SOUND(path)
	if not sounds[path] then
		sounds[path] = love.audio.newSource("assets/sounds/"..path, "static")
	end
	print(path)
	return sounds[path]
end

function PLAYSOUND(path)
	local sound = SOUND(path)
	sound:stop()
	sound:seek(0)
	sound:play()
end

function STOPSOUND(path)
	local sound = SOUND(path)
	sound:stop()
	sound:seek(0)
end

function MUSIC(path)
	if not music[path] then
		music[path] = love.audio.newSource("assets/music/"..path, "stream")
	end
	return music[path]
end

function ISDOWN(id)
	return (controlleftalt[id] and love.keyboard.isDown(controlleftalt[id])) or (controlrightalt[id] and love.keyboard.isDown(controlrightalt[id])) or love.keyboard.isDown(CONTROLS[id])
end

function ISPRESSED(id)
	return not pressed[id] and ((controlleftalt[id] and love.keyboard.isDown(controlleftalt[id])) or (controlrightalt[id] and love.keyboard.isDown(controlrightalt[id])) or love.keyboard.isDown(CONTROLS[id]))
end

local scenestack = {}

function SETSCENE(scene)
	for key, value in pairs(pressed) do
		pressed[key] = ISDOWN(key)
	end
	scenestack = {scene}
	scene:update()
end

function PUSHSCENE(scene)
	for key, value in pairs(pressed) do
		pressed[key] = ISDOWN(key)
	end
	scenestack[#scenestack+1] = scene
	scene:update()
end

function POPSCENE()
	for key, value in pairs(pressed) do
		pressed[key] = ISDOWN(key)
	end
	scenestack[#scenestack] = nil
	if #scenestack == 0 then
		RELOAD(false)
	end
end

local scale = 1
local translatex = 0
local translatey = 0

function MOUSEX()
	return math.floor(love.mouse.getX() / scale - translatex)
end

function MOUSEY()
	return math.floor(love.mouse.getY() / scale - translatey)
end

local programargs

local mounted

function LOADMOD(path)
	TIME = 0
	love.audio.stop()
	if type(path) == "boolean" then
		CLEARCACHE()
	end
	scenestack = {}
	if path ~= nil then
		if mounted and path ~= true then
			love.filesystem.unmount(mounted)
		end
		if type(path) == "string" then
			love.filesystem.mount(path, "assets", false)
			mounted = path
		end
	end
	for key, value in pairs(package.loaded) do
		package.loaded[key] = nil
	end
end

function RELOAD(path)
	LOADMOD(path)
	love.load(programargs)
end

local function exists(file)
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			-- Permission denied, but it exists
		  	return true
	   	end
	end
	return ok, err
end

--- Check if a directory exists in this path
local function isdir(path)
	-- "/" works on both Unix and Windows
	return exists(path.."/")
end

local function copyall(from, to)

end

local function copytotemp(from, to)
	local file = io.open(from, "rb")
	local contents = file:read("*a")
	file:close()
	return love.filesystem.write(to, contents)
end

local loadfromarg = false

function love.load(args)
	love.filesystem.createDirectory("mods")
	local path = args[1]
	if path and not loadfromarg then
		print("Mod path provided")
		if isdir(path) then
			print("Mod is a folder, cant deal with yet, no zip library")
		elseif exists(path) then
			print("Mod is a file")
			loadfromarg = true
			copytotemp(path, "temp.zip")
		else
			print("Mod does not exist")
		end
	end
	if loadfromarg then
		LOADMOD("temp.zip")
	end
	programargs = args
	require "assets.main"
end

local paused = false

function love.update()
	local scalex = love.graphics.getWidth() / 640
	local scaley = love.graphics.getHeight() / 480
	scale = math.min(scalex, scaley)
	translatex = scalex / scale * 320 - 320
	translatey = scaley / scale * 240 - 240
	if paused then return end
	if #scenestack > 0 then
		scenestack[#scenestack]:update()
	end
	for key, value in pairs(pressed) do
		pressed[key] = ISDOWN(key)
	end
	TIME = TIME + 1
end

function love.draw()
	love.graphics.scale(scale)
	love.graphics.translate(translatex, translatey)
	love.graphics.setScissor(translatex * scale, translatey * scale, 640 * scale, 480 * scale)
	if #scenestack > 0 then
		scenestack[#scenestack]:draw()
	end
	if DEBUG and scenestack[#scenestack].debugdraw then
		scenestack[#scenestack]:debugdraw()
	end
	love.graphics.setScissor()
	love.graphics.origin()
	if paused then
		love.graphics.scale(2, 2)
		love.graphics.setFont(FONT "fnt_karma_big")
		love.graphics.setColor(0.25, 0, 0)
		love.graphics.print("PAUSED", 9, 9)
		love.graphics.setColor((math.sin(love.timer.getTime()*5)+1)/2, 0, 0)
		love.graphics.print("PAUSED", 6, 6)
		love.graphics.setColor(1, 1, 1)
	end
end

function love.focus()
	if scenestack[#scenestack].focus then
		scenestack[#scenestack]:focus()
	end
end

function love.keypressed(key)
	if key == "f4" then
		love.window.setFullscreen(not love.window.getFullscreen())
	end
	if key == "f3" then
		DEBUG = not DEBUG
	end
	if key == "f2" then
		love.window.setFullscreen(false)
		local width, height, mode = love.window.getMode()
		mode.resizable = not mode.resizable
		love.window.updateMode(640, 480, mode)
	end
	if key == "f8" then
		paused = not paused
	end
	if key == "r" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
		RELOAD(false)
	end
end

function love.graphics.outline(obj, color, modx, mody, shrinkbox)
	local size = 1 / scale
	local shrink = shrinkbox or 0
	local col = {love.graphics.getColor()}
	love.graphics.setColor(color)
	if obj.width and obj.height then
		local offsetx = (modx or 0) * obj.width + shrink
		local offsety = (mody or 0) * obj.height + shrink
		love.graphics.rectangle("fill", obj.x + offsetx, obj.y + offsety, obj.width - shrink * 2, size)
		love.graphics.rectangle("fill", obj.x + offsetx, obj.y + offsety, size, obj.height - shrink * 2)
		love.graphics.rectangle("fill", obj.x + offsetx, obj.y + offsety + obj.height - size - shrink * 2, obj.width - shrink * 2, size)
		love.graphics.rectangle("fill", obj.x + offsetx + obj.width - size - shrink * 2, obj.y + offsety, size, obj.height - shrink * 2)
	else
		love.graphics.rectangle("fill", obj.x + (1 - size) / 2, obj.y - 10, size, 21)
		love.graphics.rectangle("fill", obj.x - 10, obj.y + (1 - size) / 2, 21, size)
	end
	love.graphics.rectangle("fill", obj.x-1, obj.y-1, 2, 2)
	if obj.xv or obj.yv then
		local xv = obj.xv or 0
		local yv = obj.yv or 0
		local invcol = color
		invcol[1] = 1 - invcol[1]
		invcol[2] = 1 - invcol[2]
		invcol[3] = 1 - invcol[3]
		love.graphics.setColor(invcol)
		love.graphics.setLineWidth(size)
		love.graphics.line(obj.x, obj.y, obj.x + xv * 3, obj.y + yv * 3)
	end
	love.graphics.setColor(col)
end

PLAYSOUND "mus_intronoise.ogg"