-- example battle with a single opponent
return function(self)
	-- define a bullet type
    local testbullet = self:makebullet {
        spawned = function(self)
            self.damage = 1
        end,
        update = function(self, battle)
            self.y = self.y + 2
        end,
        width = 8,
        height = 8,
    }
	-- what should happen on the enemy's turn
    function self:onenemyturn(turncount)
		-- define the only attack
        self:startattack(function()
			-- queue 10 bullets to spawn at random parts of the battle box
            for i = 1, 10 do
                local x = self.box.x + math.random() * self.box.width
                self:queuespawn(testbullet, x, self.box.y - 150)
                self:wait(0.5)
            end
			-- queue the end of the attack after all that
            self:queue(function()
                self:endattack("* Dummy looks like it's going to\n  fall over")
            end)
        end)
    end
	-- starting dialogue
    self.dialogue:settext("* You encountered the Dummy.")
	-- define the opponent
    local opponent = self:makeopponent("Dummy", "dummy", 100, {
        canspare = true,
        fleechance = 1,
    })
	-- define the opponent's check dialogue and potential act menu options
	-- putting % will print the default check line containing the opponent's name and stats
    opponent:makeacts("%\n* A cotton heart and a button eye\n* You are the apple of my eye", {
		{
			text = "* Talk",
			onclick = function()
				-- end the turn with custom text
				self:endturn({
					"* It doesn't seem much for\n  conversation.",
					"* If Toriel was here, she would\n  be thrilled."
				})
			end
		},
	})
end