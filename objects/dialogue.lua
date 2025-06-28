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
	self.speed = 0.5 -- WHY DOES INCREASING THIS MAKE IT SLOWER
	self.x = x or 50
	self.y = y or 50
	self.cantskip = false
	self.justswitched = false
	self.menus = {}
	self.columns = 2
	self.columnspacing = 256
	self.rowspacing = 32
	self.charwidthoverride = nil
	local timer = 0
	local delays = {
		["!"] = 8,
		["?"] = 8,
		["."] = 8,
		[":"] = 4,
		[";"] = 4,
		[","] = 4,
	}
	function self:makechoices(menu, soul, cols, rows)
		if #menu == 0 then return end
		self.menus[#self.menus+1] = menu
		menu.columns = cols or 1
		menu.options = #menu
		menu.option = 1
		menu.soul = soul
		menu.rows = rows
		menu.page = 1
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
			local maxperpage = menu.options
			if menu.rows then
				maxperpage = menu.columns * menu.rows
			end
			local pageoptions = math.min(maxperpage, menu.options - maxperpage * (menu.page - 1))
			local maxpages = math.ceil(menu.options / maxperpage)
			local optionindex = menu.option + (menu.page - 1) * maxperpage
			local option = menu[optionindex]
			local row = math.ceil(menu.option/menu.columns)-1
			local column = (menu.option-1)%menu.columns
			if ISPRESSED "RIGHT" then
				menu.option = menu.option + 1
				local newrow = math.ceil(menu.option/menu.columns)-1
				menu.page = menu.page + newrow - row
				if menu.page > maxpages then
					menu.page = 1
				end
				pageoptions = math.min(maxperpage, menu.options - maxperpage * (menu.page - 1))
				menu.option = menu.option + (row - newrow) * menu.columns
				if menu.option > pageoptions then
					menu.option = menu.option - menu.columns
					if row == 0 then
						menu.page = menu.page + 1
						if menu.page > maxpages then
							menu.page = 1
						end
					end
				end
				if menu.option < 1 then
					menu.option = 1
				end
				PLAYSOUND "snd_squeak.wav"
			end
			if ISPRESSED "LEFT" then
				menu.option = menu.option - 1
				local newrow = math.ceil(menu.option/menu.columns)-1
				menu.page = menu.page + newrow - row
				if menu.page < 1 then
					menu.page = maxpages
				end
				pageoptions = math.min(maxperpage, menu.options - maxperpage * (menu.page - 1))
				menu.option = menu.option + (row - newrow) * menu.columns
				if menu.option > pageoptions then
					menu.option = menu.option - menu.columns
				end
				if menu.option > pageoptions then
					menu.option = pageoptions
				end
				if menu.option < 1 then
					menu.option = 1
				end
				PLAYSOUND "snd_squeak.wav"
			end
			if ISPRESSED "DOWN" then
				menu.option = menu.option + menu.columns
				if menu.option > pageoptions then
					menu.option = menu.option - (row + 1) * menu.columns
				end
				PLAYSOUND "snd_squeak.wav"
			end
			if ISPRESSED "UP" then
				menu.option = menu.option - menu.columns
				if menu.option < 1 then
					menu.option = menu.option + math.ceil(pageoptions / menu.columns) * menu.columns
					if menu.option > pageoptions then
						menu.option = menu.option - menu.columns
					end
				end
				PLAYSOUND "snd_squeak.wav"
			end
			if ISPRESSED "SELECT" and not self.justswitched then
				PLAYSOUND "snd_select.wav"
				if option.onclick then
					option.onclick(optionindex)
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
				local width = self.charwidthoverride or self.font:getWidth(char)
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
			local maxperpage = menu.options
			if menu.rows then
				maxperpage = menu.columns * menu.rows
			end
			local pageoptions = math.min(maxperpage, menu.options - maxperpage * (menu.page - 1))
			for i = 1, pageoptions do
				local row = math.ceil(i/menu.columns)-1
				local column = (i-1)%menu.columns
				local option = menu[i + (menu.page - 1) * maxperpage]
				love.graphics.setColor(option.color or {1, 1, 1})
				self:print(option.text, self.x + 48 + column * self.columnspacing, self.y + row * self.rowspacing)
			end
			love.graphics.setColor(1, 1, 1)
			if menu.rows then
				self:print("  PAGE "..menu.page, self.x + 48 + self.columnspacing, self.y + self.rowspacing * 2)
			end
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