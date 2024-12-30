return function(x, y, w, h, tw, th) local self = {}
	local Soul = require "objects.soul"
	self.x = x or 250
	self.y = y or 250
	self.width = w or 140
	self.height = h or 140
	self.targetwidth = tw or w or self.width
	self.targetheight = th or h or self.height
	self.resizing = false
	self.anchorhoriz = 0.5
	self.anchorvert = 1
	self.resizetimer = 0
	self.resizetime = 20
	self.smoothresize = false
	self.enabled = true
	function self:makesoul(soul)
		local xpos, ypos = self.x + self.width / 2, self.y + self.height / 2
		self.soul = soul or Soul(xpos, ypos)
		self.soul.x = xpos
		self.soul.y = ypos
		return self.soul
	end
	function self:removesoul()
		self.soul = nil
	end
	function self:update()
		self.resizing = false
		if self.resizetimer < self.resizetime then
			self.resizing = true
			self.resizetimer = self.resizetimer + 1
			local changeamount = 1 / (self.resizetime - self.resizetimer)
			if self.smoothresize then
				changeamount = self.resizetimer / self.resizetime /2
			end
			if self.resizetimer == self.resizetime then
				changeamount = 1
			end
			-- print(self.resizetimer, self.resizetime, changeamount, (self.targetwidth - self.width) * changeamount)
			local targetx = self.x - (self.targetwidth - self.width) * self.anchorhoriz
			local targety = self.y - (self.targetheight - self.height) * self.anchorvert
			self.x = self.x + (targetx - self.x) * changeamount
			self.y = self.y + (targety - self.y) * changeamount
			self.width = self.width + (self.targetwidth - self.width) * changeamount
			self.height = self.height + (self.targetheight - self.height) * changeamount
		end
		if self.soul and self.enabled then
			if self.soul.x < self.x + 13 then
				self.soul.x = self.x + 13
			end
			if self.soul.y < self.y + 13 then
				self.soul.y = self.y + 13
			end
			if self.soul.x > self.x + self.width - 13 then
				self.soul.x = self.x + self.width - 13
			end
			if self.soul.y > self.y + self.height - 13 then
				self.soul.y = self.y + self.height - 13
			end
		end
	end
	function self:draw()
		if not self.enabled or self.hidden then
			return
		end
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("fill", self.x, self.y, self.width, 5)
		love.graphics.rectangle("fill", self.x, self.y, 5, self.height)
		love.graphics.rectangle("fill", self.x, self.y + self.height - 5, self.width, 5)
		love.graphics.rectangle("fill", self.x + self.width - 5, self.y, 5, self.height)
	end
	function self:resize(w, h)
		self.resizetimer = 0
		self.targetwidth = w
		self.targetheight = h
	end
	self:makesoul()
return self end