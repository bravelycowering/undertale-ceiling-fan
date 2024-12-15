-- example battle the base menu removed
return function(self)
	local battle = self

    local testbullet = self:makebullet {
        spawned = function(self)
            self.damage = math.ceil(battle.soul.hp / 3)
			self.xv = 0
			self.yv = 4
        end,
        update = function(self, battle)
            self.y = self.y + self.yv/4
			self.x = self.x + self.xv/2
            self.damage = math.ceil(battle.soul.hp / 3)
        end,
        width = 6,
        height = 6,
    }

	self.soul:setlove(7)

	local opponent = self:makeopponent("Omega Dummy", "dummy", 220, {
        canspare = true,
        fleechance = 1,
    })
	opponent:makeacts("%\n* A cotton heart and a button eye\n* You are the apple of my eye")

	-- remove all the buttons and hide most of the UI
	self.buttons = {}
	self.soulname.hidden = true
	self.hpmeter.showtext = false

	-- reposition the hp meter
	self.hpmeter.x = 320 - self.soul.maxhp / 2 * self.hpmeter.widthmul
	self.hpmeter.y = 450

	-- remove dialogue
	self.dialogue:settext("")

	local attack
	
	attack = function()
		for i = 1, 250 do
			for index, value in ipairs(self.opponents) do
				if not (self.opponents[index].killed or self.opponents[index].spared) then
					local x = self.box.x + math.random() * self.box.width
					self:queuespawn(testbullet, x, 0)
				end
			end
			self:wait(0.015)
		end
		self:queue(function()
			if #self.buttons == 0 then
				self:makebutton(love.math.random(0, 530), 380, "fight_button", "fight_button_selected", nil, {1, 1, 0.294117647}, function ()
					opponent:damage(math.floor(love.math.random(15, 25)), false)
					self.buttons = {}
					if opponent.hp <= 0 then
						opponent:kill()
						self:clearqueue()
						self.dialogue:settext("* oh no you are have defeat\n  me noooo.....")
						self.music:stop()
						self.battleisover = true
					end
				end)
			end
		end)
		self:queue(attack)
	end

	self:startattack(attack, 650, 245, true)

	-- make the box the size of the lower half of the screen, then hide it
	self.box.x = -5
	self.box.y = 240
	self.box.hidden = true
end