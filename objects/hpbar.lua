return function(text, x, y, width, from, to) local self = {}
	print(text, x, y, width, from, to)
    self.x = x
    self.y = y
    self.width = width
	self.from = from
	self.to = to
	local maxtimer = 75
	self.timer = maxtimer
	self.yv = -20
	self.texty = 10
	local dmgfont = FONT "fnt_damage"
	if type(text) == "number" then
		if text >= 0 then
			self.text = love.graphics.newText(dmgfont, {{1, 0, 0}, text})
		else
			self.text = love.graphics.newText(dmgfont, {{0, 1, 0}, -text})
		end
	elseif type(text) == "string" then
		self.text = love.graphics.newText(dmgfont, {{0.75, 0.75, 0.75}, text})
	else
		self.text = love.graphics.newText(dmgfont, text)
	end
    function self:update()
		self.timer = self.timer - 1
		self.yv = self.yv + 1
		if self.yv < 20 then
			self.texty = self.texty - self.yv / 10
		end
		return self.timer > 0
    end
    function self:draw()
		local reverseprogress = self.timer / maxtimer
		local progress = 1 - reverseprogress
        love.graphics.draw(self.text, self.x - self.text:getWidth() / 2, self.y - self.text:getHeight() - self.texty)
        love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", self.x - self.width / 2 - 2, self.y - 2, self.width + 4, 16)
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.rectangle("fill", self.x - self.width / 2, self.y, self.width, 12)
        love.graphics.setColor(0, 1, 0, 1)
		love.graphics.rectangle("fill", self.x - self.width / 2, self.y, math.max(0, (self.from * self.width) * reverseprogress + (self.to * self.width) * progress), 12)
        love.graphics.setColor(1, 1, 1, 1)
    end
return self end