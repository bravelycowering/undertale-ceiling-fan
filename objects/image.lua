return function(img, x, y, scale) local self = {}
    self.x = x
    self.y = y
    self.scale = scale or 1
    self.image = img
    function self:update()
        self.width = self.image:getWidth() * self.scale
        self.height = self.image:getHeight() * self.scale
    end
    self:update()
    function self:draw()
        if not self.hidden then love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale) end
    end
return self end