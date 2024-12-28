return function(text, font, x, y, sound, texteffect) local self = {}
	self.text = ""
	self.texteffect = texteffect or function (x, y)
		if math.random() < 0.005 then
			return x - 2 + math.random() * 4, y - 2 + math.random() * 4
		end
		return x, y
	end
	self.font = FONT(font or "fnt_default_big")
	self.sound = sound or "SND_TXT2.wav"
	self.targettext = text or ""
	self.speed = 1
	self.x = x or 50
	self.y = y or 50
	self.cantskip = false
	self.justswitched = false
	self.menus = {}
	self.columns = 2
	self.columnspacing = 256
	self.rowspacing = 32
	local timer = 0
	local delays = {
		["!"] = 8,
		["?"] = 8,
		["."] = 8,
		[":"] = 4,
		[";"] = 4,
		[","] = 4,
	}
	function self:makechoices(menu, soul, cols)
		tempvar = {}
		for index, value in ipairs(menu) do
			if menu[index] ~= {text = "N/A",onclick = function() end} then
				tempvar[index] = value
			end
		end
		if #menu == 0 then return end
		if #tempvar == 0 then return end
		self.menus[#self.menus+1] = menu
		self.columns = cols or 1
		menu.options = #tempvar
		menu.option = 1
		menu.soul = soul
		self.text = ""
		self.justswitched = true
		return true
	end
	function self:update()
		if not self.cantskip then
			if ISPRESSED "CANCEL" and self.text ~= self.targettext then
				self.text = self.targettext
			end
		end
		if #self.menus <= 0 then
			timer = timer + 1
			if timer > self.speed then
				if self.text ~= self.targettext then
					local char = self.targettext:sub(#self.text+1, #self.text+1)
					self.text = self.text .. char
					timer = -(delays[char] or 0)
					if self.sound ~= true and not delays[char] and char ~= " " then
						PLAYSOUND(self.sound)
					end
				end
			end
		else
			self.text = ""
			local menu = self.menus[#self.menus]
			local i = menu.option
			local option = menu[i]
			local row = math.ceil(i/self.columns)-1
			local column = (i-1)%self.columns
			if ISPRESSED "RIGHT" then
				menu.option = menu.option + 1
				local newrow = math.ceil(menu.option/self.columns)-1
				menu.option = menu.option + (row - newrow) * self.columns
				if menu.option > menu.options then
					menu.option = menu.option - self.columns
				end
				if menu.option < 1 then
					menu.option = 1
				end
				PLAYSOUND "snd_squeak.wav"
			end
			if ISPRESSED "LEFT" then
				menu.option = menu.option - 1
				local newrow = math.ceil(menu.option/self.columns)-1
				menu.option = menu.option + (row - newrow) * self.columns
				if menu.option > menu.options then
					menu.option = menu.option - self.columns
				end
				if menu.option < 1 then
					menu.option = 1
				end
				PLAYSOUND "snd_squeak.wav"
			end
			if ISPRESSED "DOWN" then
				menu.option = menu.option + self.columns
				if menu.option > menu.options then
					menu.option = menu.option - (row + 1) * self.columns
				end
				PLAYSOUND "snd_squeak.wav"
			end
			if ISPRESSED "UP" then
				menu.option = menu.option - self.columns
				if menu.option < 1 then
					menu.option = menu.option + math.ceil(menu.options / self.columns) * self.columns
					if menu.option > menu.options then
						menu.option = menu.option - self.columns
					end
				end
				PLAYSOUND "snd_squeak.wav"
			end
			if ISPRESSED "SELECT" and not self.justswitched then
				PLAYSOUND "snd_select.wav"
				if option.onclick then
					option.onclick(i)
				end
			end
			if menu.soul then
				menu.soul.x = self.x + column * self.columnspacing + 24
				menu.soul.y = self.y + row * self.rowspacing + 14
			end
			if ISPRESSED "CANCEL" and not self.justswitched then
				self.menus[#self.menus] = nil
				PLAYSOUND "snd_squeak.wav"
			end
		end
		self.justswitched = false
	end
	function self:print(text, x, y)
		love.graphics.setFont(self.font)
		local textx = x
		local texty = y
		for i = 1, #text do
			local char = text:sub(i, i)
			if char == "\n" then
				texty = texty + self.font:getHeight()
				textx = x
			else
				local width = self.font:getWidth(char)
				if char == "*" then
					width = math.ceil(width * 0.75) + 1
				end
				love.graphics.print(char, self.texteffect(textx, texty))
				textx = textx + width
			end
		end
	end
	function self:draw()
		self:print(self.text, self.x, self.y)
		if #self.menus > 0 then
			local menu = self.menus[#self.menus]
			for i = 1, menu.options do
				local row = math.ceil(i/self.columns)-1
				local column = (i-1)%self.columns
				local option = menu[i]
				love.graphics.setColor(option.color or {1, 1, 1})
				self:print(option.text, self.x + 48 + column * self.columnspacing, self.y + row * self.rowspacing)
			end
			love.graphics.setColor(1, 1, 1)
		end
	end
	function self:skip()
		self.text = self.targettext
	end
	function self:settext(newtext, cantskip)
		self.menus = {}
		self.cantskip = cantskip
		self.text = ""
		timer = 0
		self.targettext = newtext
	end
return self end