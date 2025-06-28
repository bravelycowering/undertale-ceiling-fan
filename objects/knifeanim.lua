return function(opponent, accuracy) local self = {}
	self.x = opponent.x
	self.y = opponent.y - 120
	self.timer = 45
	function self:update()
		if self.timer == 45 then
			PLAYSOUND("snd_laz.wav")
		end
		self.timer = self.timer - 2
		return self.timer > 0
	end
	function self:draw()
		love.graphics.print({{1, 0, 0}, "KILLING YOU!!!"}, self.x, self.y + self.timer * 3, self.timer / (10/2))
	end
return self end