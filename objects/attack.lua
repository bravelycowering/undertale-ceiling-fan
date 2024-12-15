return function(w, h, img, cre, upd, dra)
    return function()
        local self = {}
        self.width = w or 16
        self.height = h or 16
        self.image = img or IMAGE "attack_default"
        self.update = upd or function(self, battle)
            self.x = self.x + self.xv
            self.y = self.y + self.yv
            if self.x < battle.box.x + self.width / 2 and self.xv < 0 then
                self.x = battle.box.x + self.width / 2
                self.xv = 2
            end
            if self.x > battle.box.x + battle.box.width - self.width / 2 and self.xv > 0 then
                self.x = battle.box.x + battle.box.width - self.width / 2
                self.xv = -2
            end
            if self.y < battle.box.y + self.height / 2 and self.yv < 0 then
                self.y = battle.box.y + self.height / 2
                self.yv = 3
            end
            if self.y > battle.box.y + battle.box.height - self.height / 2 and self.yv > 0 then
                self.y = battle.box.y + battle.box.height - self.height / 2
                self.yv = -3
            end
        end
        self.draw = dra or function(self, battle)
            love.graphics.draw(self.image, self.x - self.image:getWidth() / 2, self.y - self.image:getHeight() / 2)
        end
        self.spawned = cre or function(self, battle)
            self.xv = 2
            self.yv = 3
        end
        return self
    end
end