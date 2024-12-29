local function multiply(tbl, val)
	local ret = {}
	for key, value in pairs(tbl) do
		ret[key] = value * val
	end
	return ret
end
return function(x, y, maxhp, iframes) local self = {}
	self.x = math.floor(x or 0)
	self.y = math.floor(y or 0)
	self.maxiframes = iframes or 60
	self.iframes = 0
	self.maxhp = maxhp or 20
	self.hp = self.maxhp
	self.width = 8
	self.height = 8
	self.color = {1, 0, 0}
	self.deathtimer = 0
	self.love = 1
	self.name = "LOVE2D"
	self.at = 10
	self.df = 10
	self.fleetimer = 0
	local shards = {}
	self.inv = {
		{
			text = "* Frehel",
			onclick = function()
				self.hp = math.min(self.hp + self.maxhp, self.maxhp)
				PLAYSOUND("snd_heal_c.wav")
				self:removeItem(1)
				self.bt:endturn({"* You ate the frehel.","* You were heled for fre."})


			end
		},
		{
			text = "* aICeFghjm",
			onclick = function()
				self.hp = math.min(self.hp + math.floor(self.maxhp / 4), self.maxhp)
				PLAYSOUND("snd_heal_c.wav")
				self:removeItem(2)
				self.bt:endturn({"Placeholder food."})
			end
		},
		{
			text = "* aICeFghjm",
			onclick = function()
				self.hp = math.min(self.hp + math.floor(self.maxhp / 4), self.maxhp)
				PLAYSOUND("snd_heal_c.wav")
				self:removeItem(3)
				self.bt:endturn({"Placeholder food."})
			end
		},
		{
			text = "* aICeFghjm",
			onclick = function()
				self.hp = math.min(self.hp + math.floor(self.maxhp / 4), self.maxhp)
				PLAYSOUND("snd_heal_c.wav")
				self:removeItem(4)
				self.bt:endturn({"Placeholder food."})
			end
		},
		{
			text = "* aICeFghjm",
			onclick = function()
				self.hp = math.min(self.hp + math.floor(self.maxhp / 4), self.maxhp)
				PLAYSOUND("snd_heal_c.wav")
				self:removeItem(5)
				self.bt:endturn({"Placeholder food."})
			end
		},
		{
			text = "* aICeFghjm",
			onclick = function()
				self.hp = math.min(self.hp + math.floor(self.maxhp / 4), self.maxhp)
				PLAYSOUND("snd_heal_c.wav")
				self:removeItem(6)
				self.bt:endturn({"Placeholder food."})
			end
		},
		{
			text = "* aICeFghjm",
			onclick = function()
				self.hp = math.min(self.hp + math.floor(self.maxhp / 4), self.maxhp)
				PLAYSOUND("snd_heal_c.wav")
				self:removeItem(7)
				self.bt:endturn({"Placeholder food."})
			end
		},
		{
			text = "* aICeFghjm",
			onclick = function()
				self.hp = math.min(self.hp + math.floor(self.maxhp / 4), self.maxhp)
				PLAYSOUND("snd_heal_c.wav")
				self:removeItem(8)
				self.bt:endturn({"Placeholder food."})
			end
		}
	}
	function self:removeItem(index)
		self.inv[index] = {text = "N/A",onclick = function() end} -- in my defense, technical limitations.
	end
	function self:setItem(index, item)
		self.inv[index] = item
	end
	function self:setlove(val)
		self.love = val
		self:calcstats()
		self.hp = self.maxhp
	end
	function self:increaselove()
		self.love = self.love + 1
		self:calcstats()
	end
	function self:calcstats()
		self.maxhp = 16 + self.love*4
		if self.love == 20 then
			self.maxhp = 99
		end
		self.at = 8 + 2 * self.love
		self.df = 10 + math.floor((self.love - 1) / 4)
	end
	function self:update()
		local speed = 2
		if ISDOWN "CANCEL" then
			speed = 1
		end
		if self.hp <= 0 then
			self:deathsequence()
			return
		end
		if self.fleetimer > 0 then
			self.fleetimer = self.fleetimer + 1
			if self.fleetimer > 90 then
				POPSCENE()
			end
			return
		end
		if ISDOWN "LEFT" then
			self.x = self.x - speed
		end
		if ISDOWN "RIGHT" then
			self.x = self.x + speed
		end
		if ISDOWN "UP" then
			self.y = self.y - speed
		end
		if ISDOWN "DOWN" then
			self.y = self.y + speed
		end
--		if ISDOWN "HEAL" then
--			self.hp = self.maxhp
--		end
		if self.iframes > 0 then
			self.iframes = self.iframes - 1
		end
	end
	function self:deathsequence()
		self.deathtimer = self.deathtimer + 1
		if self.deathtimer == 2 then
			love.audio.stop()
		end
		if self.deathtimer == 30 then
			PLAYSOUND "snd_break1.wav"
		end
		if self.deathtimer == 120 then
			PLAYSOUND "snd_break2.wav"
			for i = 1, 6 do
				shards[#shards+1] = {
					x = self.x - 4,
					y = self.y - 4,
					xv = (math.random()-0.5) * 8,
					yv = math.floor(math.random() * 9) - 6
				}
			end
		end
		for index, value in ipairs(shards) do
			value.x = value.x + value.xv
			value.y = value.y + value.yv
			value.yv = value.yv + 0.1
		end
		if self.deathtimer == 210 then
			SETSCENE(require "assets.scenes.game_over" (self))
		end
	end
	function self:flee()
		self.fleetimer = 1
		PLAYSOUND "snd_escaped.wav"
	end
	function self:draw()
		if self.hp > 0 then
			love.graphics.setColor(self.color)
			if self.iframes % 10 <= 5 and self.iframes > 0 then
				love.graphics.setColor(multiply(self.color, 0.5))
			end
			local image
			if self.fleetimer > 0 then
				if self.fleetimer%10 < 5 then
					image = IMAGE "soul_flee_1"
				else
					image = IMAGE "soul_flee_2"
				end
			else
				if love.system.hasBackgroundMusic() then
					image = IMAGE "soul_headphones"
				else
					image = IMAGE "soul"
				end
			end
			love.graphics.draw(image, self.x - image:getWidth() / 2 - self.fleetimer * 1.5, self.y - image:getHeight() / 2)
			love.graphics.setColor(1, 1, 1)
		else
			if self.deathtimer < 30 then
				love.graphics.setColor(1, 0, 0)
				love.graphics.draw(IMAGE "soul", self.x - 8, self.y - 8)
				love.graphics.setColor(1, 1, 1)
			elseif self.deathtimer < 120 then
				love.graphics.draw(IMAGE "soulbreak", self.x - 10, self.y - 8)
			else
				for index, value in ipairs(shards) do
					love.graphics.draw(
						IMAGE ("soul_shard"..(math.floor(index/2 + self.deathtimer / 10))%3),
						value.x,
						value.y
					)
				end
			end
		end
	end
	function self:takedamage(bullet)
		if not (
			self.x - self.width / 2 > bullet.x + bullet.width / 2
			or
			self.x + self.width / 2 < bullet.x - bullet.width / 2
			or
			self.y - self.height / 2 > bullet.y + bullet.height / 2
			or
			self.y + self.height / 2 < bullet.y - bullet.height / 2
		) and self.iframes == 0 then
			self.hp = self.hp - (bullet.damage or 4)
			self.iframes = bullet.iframes or self.maxiframes
			PLAYSOUND "snd_hurt1.wav"
			return true
		end
	end
return self end