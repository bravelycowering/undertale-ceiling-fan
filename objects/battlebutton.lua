return function(x, y, col, highlightcol, spr, sprselected, onclick, sx, sy) local self = {}
    self.x = x
    self.y = y
    self.onclick = onclick or function() end
    self.col = col or {1, 0.5, 0.152941176}
    self.highlightcol = highlightcol or {1, 1, 0}
    self.image = IMAGE (spr or "fight_button")
    self.imageselected = IMAGE (sprselected or spr or "fight_button")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.hover = false
    self.soulx = sx or 16
    self.souly = sy or (self.height / 2)
    function self:update(battle)
        if not (
			self.x > battle.soul.x + battle.soul.width / 2
			or
			self.x + self.width < battle.soul.x - battle.soul.width / 2
			or
			self.y > battle.soul.y + battle.soul.height / 2
			or
			self.y + self.height < battle.soul.y - battle.soul.height / 2
		) then
            self.hover = true
        else
            self.hover = false
        end
        if self.hover and ISPRESSED "SELECT" then
            PLAYSOUND "snd_select.wav"
            self:onclick()
        end
    end
    function self:draw()
        if self.hover then
            love.graphics.setColor(self.highlightcol)
            love.graphics.draw(self.imageselected, self.x, self.y)
        else
            love.graphics.setColor(self.col)
            love.graphics.draw(self.image, self.x, self.y)
        end
        love.graphics.setColor(1, 1, 1)
    end
return self end