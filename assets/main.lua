local scripts
local files
local option = 1
local debugoptions = 0
local minopiton = 1
local translatey = 0
local brightnesstimer = 0
local function reloadFiles()
    CLEARCACHE()
    scripts = {
        "*assets.scenes.battle",
        "*assets.scenes.game_over",
        "*assets.scripts.samplebattle",
        "*assets.scripts.triobattle",
		"*assets.scripts.menulessbattle",
        "*assets.scripts.sixbattle",
    }
    debugoptions = #scripts
    files = love.filesystem.getDirectoryItems("mods")
    for index, value in ipairs(files) do
        scripts[#scripts+1] = value
    end
    if option > #scripts then
        option = #scripts
    end
    if option < minopiton then
        option = minopiton
    end
end
reloadFiles()
option = 1 + debugoptions
if #files == 0 then
	option = 2
end
SETSCENE({
    focus = reloadFiles,
    update = function(self)
        if DEBUG then
            minopiton = 1
        else
            minopiton = 1 + debugoptions
        end
        if option < minopiton then
            option = minopiton
        end
        translatey = translatey + ((option * -30 + 275 + 30) - translatey) / 10
        if brightnesstimer < 50 then
            brightnesstimer = brightnesstimer + 2
        end
        if ISPRESSED "MENU" and not love.keyboard.isDown("lctrl") then
            PLAYSOUND "snd_select.wav"
            if love.system.getOS() == "Windows" then
                os.execute('start "" "'..love.filesystem.getSaveDirectory().."/mods"..'"')
            else
                os.execute('xdg-open "'..love.filesystem.getSaveDirectory().."/mods"..'"')
            end
        end
        if #scripts - minopiton + 1 == 0 then
            return
        end
        local oldimg = ABSIMAGE("mods/"..scripts[option].."/preview")
        if ISPRESSED "DOWN" then
            PLAYSOUND "snd_squeak.wav"
            option = option + 1
            if option > #scripts then
                option = minopiton
            end
        end
        if ISPRESSED "UP" then
            PLAYSOUND "snd_squeak.wav"
            option = option - 1
            if option < minopiton then
                option = #scripts
            end
        end
        if ISPRESSED "SELECT" then
            love.graphics.clear(0, 0, 0)
            love.graphics.setFont(FONT "fnt_karma_big")
            love.graphics.print("Loading...", 5, 460)
            love.graphics.present()
            if option <= debugoptions then
                local scene
				if option == 2 then
					scene = require "assets.scenes.game_over" ()
				else
					scene = require "assets.scenes.battle" ()
				end
                if option == 3 then
                    require "assets.scripts.samplebattle" (scene)
                end
                if option == 4 then
                    require "assets.scripts.triobattle" (scene)
                end
                if option == 5 then
                    require "assets.scripts.menulessbattle" (scene)
                end
                if option == 6 then
                    require "assets.scripts.sixbattle" (scene)
                end
                SETSCENE(scene)
            else
				RELOAD("mods/"..scripts[option])
            end
        end
        local newimg = ABSIMAGE("mods/"..scripts[option].."/preview")
        if newimg ~= oldimg then
            brightnesstimer = 0
        end
    end,
    draw = function(self)
        love.graphics.setColor(brightnesstimer/100, brightnesstimer/100, brightnesstimer/100)
        local previewimage
        if scripts[option] then
            previewimage = ABSIMAGE("mods/"..scripts[option].."/preview")
        end
        if previewimage then
            love.graphics.draw(previewimage, 320 - previewimage:getWidth()/2, 240 - previewimage:getHeight()/2)
        else
            love.graphics.draw(IMAGE "boss_battle_bg", 15, 45)
            love.graphics.draw(IMAGE "dummy", 280, 177, 0, 2, 2)
        end
        love.graphics.setFont(FONT "fnt_default_big")
        love.graphics.translate(0, translatey)
        local listempty = true
        for index = minopiton, #scripts do
            listempty = false
            local value = scripts[index]
            local opacity = 1
            if index < option then
                opacity = 1 - math.abs(index - option) / 11
            else
                opacity = 1 - math.abs(index - option) / 6
            end
            if opacity <= 0.1 then
                opacity = 0.1
            end
            if opacity > 0 then
                love.graphics.setColor(0, 0, 0)
                love.graphics.print(value, 62, -20 + index * 30)
                love.graphics.print(value, 58, -20 + index * 30)
                love.graphics.print(value, 60, -18 + index * 30)
                love.graphics.print(value, 60, -22 + index * 30)
            end
            if index == option then
                love.graphics.setColor(1, 0, 0)
                love.graphics.draw(IMAGE "soul", 30, -13 + index * 30)
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(1, 1, 1, opacity)
            end
            love.graphics.print(value, 60, -20 + index * 30)
        end
        if listempty then
            love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.print("- No mods installed -\n- Press C to open folder -", 60, 120)
            option = 2
        end
        love.graphics.translate(0, -translatey)
        love.graphics.setFont(FONT "fnt_karma_big")
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Select a mod:", 7, 10)
        love.graphics.print("Select a mod:", 13, 10)
        love.graphics.print("Select a mod:", 10, 7)
        love.graphics.print("Select a mod:", 10, 13)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Select a mod:", 10, 10)
		if not DEBUG then
			love.graphics.setColor(1, 1, 1, 0.5)
			love.graphics.setFont(FONT "fnt_default")
			love.graphics.print("Press F3 to toggle DEBUG MODE", 4, 464)
			love.graphics.print("Press C to open mods folder", 420, 464)
		end
    end,
    debugdraw = function(self)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(FONT "fnt_default")
        love.graphics.print("DEBUG MODE", 0, 464)
        love.graphics.print("Option: "..option, 200, 464)
        love.graphics.print("Translate Y: "..string.format("%f", translatey), 400, 464)
    end
})