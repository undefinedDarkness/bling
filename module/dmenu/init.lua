local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
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

local options_widget = wibox.widget.textbox("")

local options = [[
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
        local grep_cmd =
            [[echo -e "]] .. options .. [[" | grep --color=auto "]] .. input ..
                [["]]
        awful.spawn.easy_async_with_shell(grep_cmd, function(output)
            -- naughty.notify({title=output})
            options_widget.text = output
        end)
    end,
    done_callback = function() promptPop.visible = false end,
    exe_callback = function(result)
        -- open in save_cmd
        local save_cmd = [[echo "]] .. result ..
                             [[" > $HOME/.cache/awesome/bling_dmenu_out]]
        awful.spawn.with_shell(save_cmd)
    end

})

promptPop = popupLib(dpi(400), dpi(250), {
    myprompt,
    options_widget,
    layout = wibox.layout.fixed.vertical
})

-- will be called from the run script
awesome.connect_signal("bling::dmenu", function()
    if promptPop.visible then
        promptPop.visible = false
    else
        promptPop.visible = true

        awful.spawn.easy_async_with_shell(
            "cat $HOME/.cache/awesome/bling_dmenu_in",
            function(out) options = out end)
        myprompt:run()
    end

end)
