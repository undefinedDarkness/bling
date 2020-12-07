local awful = require("awful")
local wibox = require("wibox")
local dpi = require('beautiful').xresources.apply_dpi

-- Stolen from javacafe
-- TODO needs to be able to read different styles from widget folder
local popupLib = function(height, width, widget)
    local widgetContainer = wibox.widget {
	{widget, margins = dpi(10), widget = wibox.container.margin},
	forced_height = height,
	forced_width = width,
	layout = wibox.layout.fixed.vertical
    }

    local popupWidget = awful.popup {
	widget = widgetContainer,
	shape = gears.shape.rectangle,
	visible = false,
	ontop = true,
	placement = awful.placement.centered
    }
    return popupWidget
end

local promptPop = {}

local list_matches = wibox.widget.optionsbox("")

local options =
[[
ja
nein 
vielleicht
man muss mehr testen
]]

-- TODO has to update the matches list without first pressing a key
-- TODO the whole "one match is focused and will be selected when enter is pressed" thingy is missing
local myprompt = awful.widget.prompt({
	prompt = '>>> ',
	changed_callback = function(input)
	    local grep_cmd = [[echo -e "]] .. options .. [[" | grep --color=auto "]] .. input .. [["]]
	    awful.spawn.easy_async_with_shell(grep_cmd, function(output)
						  list_matches.options = output
	    end)
	end,
	done_callback = function()
	    promptPop.visible = false
	end
})


promptPop = popupLib(dpi(400), dpi(250), {myprompt, list_matches, layout = wibox.layout.fixed.vertical})

-- will be called from the run script
awesome.connect_signal("toggle::prompt", function()
			   if promptPop.visible then
			       promptPop.visible = false
			   else
			       promptPop.visible = true
			       myprompt:run()
			   end
end)
