return function(x, y, w, h, soul) local self = {}
    self.x = x or 275
    self.y = y or 400
    self.height = h or 21
    self.widthmul = w or 1.25
    self.showtext = true
    function self:update()
        
    end
    function self:draw()
        if self.showtext then
            love.graphics.draw(IMAGE "hptext", self.x - 31, self.y + 5)
            love.graphics.setFont(FONT "fnt_karma_big")
            love.graphics.print((("0"):rep(#tostring(soul.maxhp) - #tostring(soul.hp))) .. soul.hp.." / "..soul.maxhp, self.x + self.widthmul * soul.maxhp + 14, self.y + (self.height - 21) / 2)
        end
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x, self.y, soul.maxhp * self.widthmul, self.height)
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", self.x, self.y, soul.hp * self.widthmul, self.height)
        love.graphics.setColor(1, 1, 1)
    end
return self end