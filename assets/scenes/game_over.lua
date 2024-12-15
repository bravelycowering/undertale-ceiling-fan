return function(soul) local self = {}
    self.soul = soul
    self.fade = 0
    self.timer = 0
    self.fadeout = false
    self.dialogue = require "objects.dialogue" (nil, "fnt_default_big", 109, 322, true)
    self.music = MUSIC "determination.mp3"
    self.music:play()
    self.music:setLooping(true)
    function self:update()
        self.timer = self.timer + 1
        if self.fadeout then
            if self.fade > 0 then
                self.fade = self.fade - 0.015
                self.music:setVolume(self.fade)
            else
                RELOAD()
            end
        else
            if self.fade < 1 then
                self.fade = self.fade + 0.01
            else
                self.fade = 1
            end
        end
        if self.timer == 60 then
            self.dialogue:settext("Stay determined!")
        end
        if ISPRESSED "SELECT" then
            self.dialogue:settext("")
            self.fadeout = true
            self.timer = 999
        end
        if self.soul then
            self.soul:update()
        end
        self.dialogue:update()
    end
    function self:draw()
        love.graphics.setColor(self.fade, self.fade, self.fade)
        love.graphics.draw(IMAGE "game_over", 320 - IMAGE "game_over":getWidth() / 2, 50)
        love.graphics.setColor(1, 1, 1)
        if self.soul then
            self.soul:draw()
        end
        self.dialogue:draw()
    end
return self end