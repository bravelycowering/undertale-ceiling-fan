local Hpbar = require "objects.hpbar"
return function(name, x, y, img, hp, options) local self = {}
    self.x = x
    self.y = y
    self.spared = false
	self.killed = false
    self.name = name
    self.hp = hp or 30
    self.maxhp = options.maxhp or self.hp
    self.def = options.def or 1
    self.atk = options.atk or 1
    self.exp = options.exp or 5
    self.gold = options.gold or 3
    self.image = IMAGE(img) or IMAGE "dummy"
    self.canspare = options.canspare or false
    self.fleechance = options.fleechance or 1
    self.checktext = {"* "..name.." - "..tostring(self.atk).." ATK "..tostring(self.def).." DEF"}
    self.acts = {}
	self.shudder = 0
	self.shuddertimer = 0
	self.hpbar = nil
	self.attacked = false
    function self:makeacts(checktext, acts)
        local newchecktext = checktext
        if type(newchecktext) == "string" then
            newchecktext = {newchecktext}
        end
        local auto = "* "..name.." - "..tostring(self.atk).." ATK "..tostring(self.def).." DEF"
		if newchecktext then
        	newchecktext[1] = newchecktext[1]:gsub("%%", auto)
		end
        self.checktext = newchecktext
        self.acts = acts or {}
    end
    function self:update(battle)
		if self.hpbar then
			if self.hpbar:update() == false then
				self.hpbar = nil
				if self.attacked then
					battle:postattack(self)
					self.attacked = true
				end
			end
		end
		if self.shudder ~= 0 and self.shuddertimer <= 0 then
			if self.shudder > 0 then
				self.shudder = -self.shudder + 1
			elseif self.shudder < 0 then
				self.shudder = -self.shudder - 1
			end
			self.shuddertimer = 4
		end
		self.shuddertimer = self.shuddertimer - 1
        self.width = self.image:getWidth() * 2
        self.height = self.image:getHeight() * 2
    end
    function self:draw()
        if self.spared then
            love.graphics.setColor(0.5, 0.5, 0.5)
        end
        if self.killed then
			love.graphics.print("oh noooo im being vaoprized", self.x, self.y - 50)
            love.graphics.setColor(1, 0, 0)
        end
        if not self.hidden then love.graphics.draw(self.image, self.x - self.image:getWidth() + self.shudder, self.y - self.image:getHeight() * 2, 0, 2, 2) end
        love.graphics.setColor(1, 1, 1, 1)
		if self.hpbar then
			self.hpbar:draw()
		end
    end
    function self:spare()
        PLAYSOUND "snd_vaporized.wav"
        self.canspare = false
        self.spared = true
    end
    function self:kill()
        PLAYSOUND "snd_vaporized.wav"
        self.canspare = false
        self.killed = true
		self.hp = 0
    end
	function self:damage(num, attacked)
        PLAYSOUND "snd_damage.wav"
		self.shudder = 10
		self.hpbar = Hpbar(num, self.x, self.y - self.image:getHeight() * 2 - 20, self.image:getWidth() * 2, self.hp / self.maxhp, (self.hp - num) / self.maxhp)
		self.hp = self.hp - num
		if attacked == nil then
			self.attacked = true
		else
			self.attacked = attacked
		end
	end
	function self:miss()
		self.hpbar = Hpbar("MISS", self.x, self.y - self.image:getHeight() * 2 - 20, 0, 0, 0)
        if attacked == nil then
			self.attacked = true
		else
			self.attacked = attacked
		end
	end
    if options.update then self.update = options.update end
    if options.draw then self.draw = options.draw end
return self end