return function() local self = {}
    local Fightbar = require "objects.fightbar"
    self.turns = 0
    self.music = MUSIC "mus_prebattle1.ogg"
    self.box = require "objects.battlebox" (32, 250, 576, 140)
    self.soul = self.box:makesoul()
    self.soulname = require "objects.soulname" (self.soul, 30, 400)
    self.dialogue = require "objects.dialogue" (nil, "fnt_default_big", 52, 272)
    self.hpmeter = require "objects.healthmeter" (275, 400, nil, nil, self.soul)
    self.battlebg = require "objects.image" (IMAGE "battle_bg", 15, 9)
    self.fightbar = nil
    self.opponent = nil
    self.opponents = {}
    self.soulisactive = true
    self.soulislocked = true
    self.attacks = {}
    self.buttons = {}
    self.events = {}
    self.dialoguetext = {}
    self.snaptobuttons = true
    self.selectedbutton = 1
    self.endingturn = false
    self.wintext = "* YOU WON!"
    self.battleisover = false
    local time = 0
    local attackid = 0
    local queuetime = 0
    local attackmode = false
    local attackIDS = {}
    function self:onenemyturn(turncount)
        self:endattack("* Smells like flavor text")
    end
    function self:nextdialogue()
        local text = self.dialoguetext[1]
        if text == nil then
            self.endingturn = false
            self:onenemyturn(self.turns)
        else
            table.remove(self.dialoguetext, 1)
            self.dialogue:settext(text)
        end
    end
	function self:postattack(opponent)
		if self.fightbar then
			self.fightbar.fadeanim = 1
		end
		for i = 1, #self.opponents do
			if self.opponents[i].hp <= 0 and not self.opponents[i].killed then
				self.opponents[i]:kill()
			end
		end
		self:trytoendbattle()
	end
	function self:trytoendbattle()
		local canendbattle = true
		for i = 1, #self.opponents do
			canendbattle = canendbattle and (self.opponents[i].killed or self.opponents[i].spared)
		end
		if canendbattle then
			self.soulisactive = false
			self.soulislocked = false
			self.dialogue:settext(self.wintext.."\n* You got 0 EXP and 0 Gold")
			self.music:stop()
			self.battleisover = true
			return true
		else
			self:endturn()
			return false
		end
	end
    function self:endturn(dialogue)
        self.turns = self.turns + 1
        self.dialogue:settext("")
        self.soulisactive = false
        self.dialoguetext = {unpack(dialogue or {})}
        self.endingturn = true
        self:nextdialogue()
    end
    function self:makeopponent(name, img, hp, options)
        local opponent = require "objects.opponent" (name or "Unknown Enemy", (#self.opponents+1) / (#self.opponents + 2) * 640, 240, img or "dummy", hp or 30, options or {})
        self.opponents[#self.opponents+1] = opponent
        return opponent
    end
    function self:makebutton(x, y, sprite, spriteselected, color, colorselected, soulx, souly)
        self.buttons[#self.buttons+1] = require "objects.battlebutton" (x, y, color, colorselected, sprite, spriteselected, soulx, souly)
    end
    function self:makeopponentselectors(func)
        local options = {}
        for i = 1, #self.opponents do
            local opponent = self.opponents[i]
            if opponent and not opponent.spared and not opponent.killed then
				local ocol = {1, 1, 1}
				if opponent.canspare then
					ocol = {1, 1, 0}
				end
                options[#options+1] = {
                    text = "* " .. opponent.name,
					color = ocol,
                    onclick = function(index)
                        func(opponent, index)
                    end
                }
            end
        end
		local rows
		if #self.opponents > 3 then
			rows = 3
		end
        self.dialogue:makechoices(options, self.soul, 1, rows)
    end
    function self:makedefaultbuttons()
        self:makebutton(32, 432, "fight_button", "fight_button_selected", nil, {1, 1, 0.294117647}, function ()
			-- print("killyou")
            self:makeopponentselectors(function(opponent)
                self.soulisactive = false
                self.dialogue:settext("")
				local at = 10
				if self.soul then
					at = self.soul.at
				end
                self.fightbar = Fightbar(opponent, at, self.box.x + self.box.width / 2, self.box.y + self.box.height / 2)
            end)
        end)
        self:makebutton(185, 432, "act_button", "act_button_selected", nil, nil, function ()
            self:makeopponentselectors(function(opponent)
                self.dialogue:makechoices({
                    {
                        text = "* Check",
                        onclick = function()
                            self:endturn(opponent.checktext)
                        end
                    },
                    unpack(opponent.acts)
                }, self.soul, 2)
            end)
        end)
        self:makebutton(345, 432, "item_button", "item_button_selected", nil, nil, function ()
            self.dialogue:makechoices({
                {
                    text = "* heal pls (no items yet)",
                    onclick = function()
                        self.soul.hp = math.min(self.soul.hp + math.floor(self.soul.maxhp / 4), self.soul.maxhp)
                        self:endturn()
                    end
                }
            }, self.soul, 2)
        end)
        self:makebutton(500, 432, "mercy_button", "mercy_button_selected", nil, nil, function ()
			local canspare = false
			for i = 1, #self.opponents do
				if self.opponents[i].canspare then
					canspare = true
					break
				end
			end
			local sparecol = {1, 1, 1}
			if canspare then
				sparecol = {1, 1, 0}
			end
            self.dialogue:makechoices({
                {
                    text = "* Spare",
					color = sparecol,
                    onclick = function()
                        for i = 1, #self.opponents do
                            if self.opponents[i].canspare and not self.opponents[i].killed then
                                self.opponents[i]:spare()
                            end
                        end
						self:trytoendbattle()
                    end
                },
                {
                    text = "* Flee",
                    onclick = function()
                        local canflee = true
                        for i = 1, #self.opponents do
                            canflee = canflee and (math.random() < self.opponents[i].fleechance)
                        end
                        if canflee then
                            self.dialogue:settext("   * I'm outta here...")
                            self.dialogue:skip()
                            self.soul:flee()
                            self.soulislocked = false
                        else
                            self:endturn()
                        end
                    end
                },
            }, self.soul)
        end)
    end
    function self:setmusic(mus)
        self.music:stop()
        self.music = MUSIC(mus)
        self.music:play()
        self.music:setLooping(true)
    end
    self.music:play()
    self.music:setLooping(true)
    function self:onupdate() end
    function self:update()
        if self.soul.hp <= 0 then
            self.soul:update()
            return
        end
        if self.battleisover then
            if ISPRESSED "SELECT" and self.dialogue.text == self.dialogue.targettext then
                POPSCENE()
            end
        end
        for i = 1, #self.opponents do
            local opponent = self.opponents[i]
            opponent.x = i / (#self.opponents + 1) * 640
            opponent:update(self)
        end
        self.battlebg:update()
        if self.soulisactive then
            self.soul:update()
        end
        for index, value in pairs(self.buttons) do
            value:update(self)
        end
		if self.fightbar then
			if self.fightbar:update() == false then
				self.fightbar = nil
			end
		end
		self.dialogue:update()
        if not attackmode then
            if self.snaptobuttons and #self.dialogue.menus == 0 and self.soulisactive and self.soulislocked then
                if ISPRESSED "LEFT" then
                    self.selectedbutton = self.selectedbutton - 1
                    PLAYSOUND "snd_squeak.wav"
                    if self.selectedbutton < 1 then
                        self.selectedbutton = #self.buttons
                    end
                end
                if ISPRESSED "RIGHT" then
                    self.selectedbutton = self.selectedbutton + 1
                    PLAYSOUND "snd_squeak.wav"
                    if self.selectedbutton > #self.buttons then
                        self.selectedbutton = 1
                    end
                end
                if #self.buttons > 0 then
                    self.soul.x = self.buttons[self.selectedbutton].x + self.buttons[self.selectedbutton].soulx
                    self.soul.y = self.buttons[self.selectedbutton].y + self.buttons[self.selectedbutton].souly
                end
            end
            if self.snaptobuttons and #self.buttons > 0 then
                self.buttons[self.selectedbutton].hover = true
            end
        end
        self.hpmeter:update()
        self.box:update()
        if not self.box.resizing then
            for index, value in ipairs(self.events) do
                if value[1] <= time then
                    value[2](self)
                    table.remove(self.events, index)
                else
                    break
                end
            end
        end
        for index, value in pairs(self.attacks) do
            value:update(self)
            if not value.disabled then
                if self.soulisactive then
                    if self.soul:takedamage(value) then
                        self.attacks[index] = nil
                    end
                end
            end
        end
        if not self.box.resizing then
            time = time + 1
            if queuetime < time then
                queuetime = time
            end
        end
        if self.endingturn then
            if ISPRESSED "SELECT" and self.dialogue.text == self.dialogue.targettext then
                self:nextdialogue()
            end
        end
        self:onupdate()
    end
    function self:draw()
        if self.soul.hp <= 0 then
            self.soul:draw()
            return
        end
        self.battlebg:draw()
        for i = 1, #self.opponents do
            local opponent = self.opponents[i]
            opponent:draw()
        end
        self.soulname:draw()
        for index, value in pairs(self.buttons) do
            value:draw(self)
        end
        self.box:draw()
        self.hpmeter:draw()
        if self.soulisactive then
            self.soul:draw()
        end
		if self.fightbar then
			self.fightbar:draw()
		end
		self.dialogue:draw()
        for index, value in pairs(self.attacks) do
            value:draw(self)
        end
    end
    function self:debugdraw()
        love.graphics.outline(self.box, {1, 1, 1})
        love.graphics.outline(self.box, {1, 0, 1}, 0, 0, 8)
        love.graphics.outline(self.soul, {0, 1, 1}, -0.5, -0.5)
        love.graphics.outline(self.dialogue, {1, 1, 0})
        love.graphics.outline(self.hpmeter, {1, 1, 0})
        love.graphics.outline(self.soulname, {1, 1, 0})
        love.graphics.outline(self.battlebg, {1, 1, 0})
        for i = 1, #self.opponents do
            local opponent = self.opponents[i]
            love.graphics.outline(opponent, {1, 0.5, 0}, -0.5, -1)
        end
        for index, value in pairs(self.attacks) do
            love.graphics.outline(value, {1, 0, 0}, -0.5, -0.5)
        end
        for index, value in pairs(self.buttons) do
            love.graphics.outline(value, {0, 1, 0})
        end
        if love.keyboard.isDown("p") then
            love.graphics.setColor(0.2, 1, 0.2, 0.25)
            love.graphics.draw(IMAGE "froggit hopped close", 0, 0)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(FONT "fnt_default")
        local eventcount = 0
        for key, value in pairs(self.events) do
            eventcount = eventcount + 1
        end
        love.graphics.print("Events: "..eventcount, 0, 0)
        love.graphics.print("Queuetime: "..queuetime, 0, 16)
        love.graphics.print("Time: "..time, 0, 32)
        love.graphics.print("Mouse: "..(MOUSEX())..", "..(MOUSEY()), 0, 48)
        love.graphics.print("Attack: "..tostring(attackmode), 0, 64)
        love.graphics.print("Box resizing: "..tostring(self.box.resizing), 0, 80)
    end
    local Attack = require "objects.attack"
    function self:makebullet(options)
        local image = IMAGE(options.image or "attack_default")
        local width = options.width or image:getWidth()
        local height = options.height or image:getHeight()
        local spawned = options.spawned
        local update = options.update
        local draw = options.draw
        return Attack(width, height, image, spawned, update, draw)
    end
    function self:queue(event)
        self.events[#self.events+1] = {queuetime, event}
    end
    function self:wait(waittime)
        self:delayqueue(waittime*60)
    end
    function self:delayqueue(waittime)
        if queuetime < time then
            queuetime = time
        end
        queuetime = queuetime + waittime
    end
    function self:queuespawn(bulletconstructor, x, y, ...)
        local args = {...}
        self:queue(function()
            self:spawn(bulletconstructor, x, y, unpack(args))
        end)
    end
	function self:clearqueue()
		self.events = {}
        queuetime = time
	end
    function self:spawn(bulletconstructor, x, y, ...)
        local bullet = bulletconstructor()
        attackid = attackid + 1
        self.attacks[attackid] = bullet
        attackIDS[bullet] = attackid
        bullet.x = x
        bullet.y = y
        bullet:spawned(...)
    end
    function self:destroy(attack)
        self.attacks[attackIDS[attack]] = nil
        attackIDS[attack] = nil
    end
    function self:endattack(flavortext)
        -- time = 0
        queuetime = time
        self.attacks = {}
        attackIDS = {}
        -- self.events = {}
        self.box:removesoul()
        self.box:resize(576, 140)
        self.dialogue:settext(flavortext or "* Smells like flavor text.")
        attackmode = false
        self.soulisactive = true
    end
    function self:startattack(func, width, height, instant)
        -- time = 0
        queuetime = time
        self.attacks = {}
        attackIDS = {}
        self.soulisactive = false
        self.events = {
            {0, function(self)
                self.box:makesoul(self.soul)
                self.soulisactive = true
            end},
            {0, func}
        }
		self.dialogue:settext("")
        self.box:resize(width or 140, height or 140)
		if instant then
			self.box.resizetimer = self.box.resizetime
			self.box.width = width
			self.box.height = height
		end
        attackmode = true
    end
    self:endattack()
    self:makedefaultbuttons()
return self end