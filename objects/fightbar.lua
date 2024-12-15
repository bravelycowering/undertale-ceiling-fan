return function(opponent, at, x, y, lines, speed, sound, attackanim, cutoff) local self = {}
    self.image = IMAGE "attack_target"
    self.x = x - self.image:getWidth() / 2
    self.y = y - self.image:getHeight() / 2
    self.attackline = {IMAGE "attack_line", IMAGE "attack_line_2"}
    self.lines = lines or {0}
    self.speed = speed or 6
    self.sound = sound
    self.hitlines = {}
	self.misslines = {}
    self.time = 0
    self.opponent = opponent
	local maxfadeanim = 20
	self.fadeanim = 0
	self.cutoff = cutoff or 1
	self.at = at
	attackanim = attackanim or require "objects.knifeanim"
	self.attackanim = nil
    function self:getaccuracy(position)
        local leftsize = self.image:getWidth() / 2
        local rightsize = leftsize
        local leftaccuracy = 1 - (leftsize - position) / leftsize
        local rightaccuracy = 2 + (rightsize - position - leftsize) / leftsize
        return math.min(leftaccuracy, rightaccuracy)
    end
    function self:update()
		if self.fadeanim > 0 then
			self.fadeanim = self.fadeanim + 1
			self.hitlines = {}
			self.misslines = {}
		end
        self.time = self.time + 1
        if self.time < 15 then
            return
        end
        for i = 1, #self.lines do
            self.lines[i] = self.lines[i] + self.speed
        end
        for i = 1, #self.misslines do
            self.misslines[i] = self.misslines[i] + self.speed
        end
        if ISPRESSED "SELECT" and #self.lines > 0 then
            self.hitlines[#self.hitlines+1] = self.lines[1]
            table.remove(self.lines, 1)
            if self.sound then
				PLAYSOUND (self.sound)
			end
			if #self.lines == 0 then
				local accuracy = {}
				for index, value in ipairs(self.hitlines) do
					accuracy[index] = self:getaccuracy(value)
				end
				self.attackanim = attackanim(self.opponent, accuracy)
			end
        end
		local edge = self.cutoff * self.image:getWidth()
        if #self.lines > 0 and self.lines[1] > edge then
            self.misslines[#self.misslines+1] = self.lines[1]
            table.remove(self.lines, 1)
			if #self.lines == 0 then
				if #self.hitlines > 0 then
					local accuracy = {}
					for index, value in ipairs(self.hitlines) do
						accuracy[index] = self:getaccuracy(value)
					end
					self.attackanim = attackanim(self.opponent, accuracy)
				else
					self.opponent:miss()
				end
			end
        end
		if self.attackanim then
			if self.attackanim:update() == false then
				self.attackanim = nil
				self:onattack(self.hitlines)
			end
		end
		return self.fadeanim < maxfadeanim
    end
    function self:draw()
		local edge = self.cutoff * self.image:getWidth()
		local a = 1 - self.fadeanim / maxfadeanim
		love.graphics.setColor(1, 1, 1, a)
        love.graphics.draw(self.image, self.x + self.image:getWidth() * self.fadeanim / maxfadeanim / 2, self.y, 0, a, 1)
		love.graphics.setColor(1, 1, 1, 1)
        if self.time < 15 then
            return
        end
        for i = 1, #self.lines do
            love.graphics.draw(self.attackline[1], self.x + self.lines[i] - self.attackline[1]:getWidth() / 2, self.y)
        end
        for i = 1, #self.misslines do
			love.graphics.setColor(1, 1, 1, (edge - self.misslines[i] + 20) / 20)
            love.graphics.draw(self.attackline[1], self.x + self.misslines[i] - self.attackline[1]:getWidth() / 2, self.y)
        end
		love.graphics.setColor(1, 1, 1, 1)
        for i = 1, #self.hitlines do
            local img = self.attackline[math.floor(self.time/6)%2+1]
            love.graphics.draw(img, self.x + self.hitlines[i] - img:getWidth() / 2, self.y)
        end
		if self.attackanim then
			self.attackanim:draw()
		end
    end
    function self:onattack(hitlines)
		local dmg = 0
		for index, value in ipairs(hitlines) do
			dmg = dmg + (self.at + math.random(2) - opponent.def) * self:getaccuracy(value) * 2.2
		end
		self.opponent:damage(math.max(0, math.ceil(dmg)))
    end
return self end