local dpi = require("beautiful.xresources").apply_dpi
local wibox = require('wibox')
local gears = require('gears')
local tabbed_module = require(
    tostring(...):match(".*bling") .. ".module.tabbed"
)

local opts = {
  layout = {
	layout = wibox.layout.fixed.horizontal,
	spacing = dpi(3)
  },
  widget_template = {
	{
	  widget = wibox.container.background,
	  forced_width = dpi(10),
	  forced_height = dpi(10)
	},
	widget = wibox.container.background,
	bg = '#181818',
	shape = gears.shape.circle,
	create_callback = function(self, cl)
	  awful.tooltip {
		objects = { self },
		text = cl.icon_name
	  }
	end
  }
}

local function fill_in_template(cl, idx, tabobj)
  local widget = wibox.widget(opts.widget_template)
  opts.widget_template.create_callback(widget, cl)
  widget.id = cl.window
  widget:buttons(awful.button({}, 1, function()
	-- require('naughty').notify({ text = "activating " .. cl.name })
	tabbed_module.switch_to(tabobj, idx)
  end))
  return widget
end

return {
  register = function(parent, c)
	local layout = wibox.widget(opts.layout)
	c.bling_tasklist_display = layout

	function layout:remove_by_id(id)
	  for idx, child in ipairs(self.children) do
		if child.id == id then
		  self:remove(idx)
		  return
		end
	  end
	end
	
	parent:add(layout)
  end,
  initiate = function()
	-- Client added to a existing tab group
	awesome.connect_signal("bling::tabbed::client_added", function(tabobj, cl)
	  -- Ignore tabbing with oneself
	  if #tabobj.clients <= 1 then
		return
	  end
	  require('naughty').notify { text = "Adding " .. cl.name }
	  for idx, c in ipairs(tabobj.clients) do
		if c ~= cl then
		  cl.bling_tasklist_display:add(fill_in_template(c, idx, tabobj))
		  c.bling_tasklist_display:add(fill_in_template(cl, #tabobj.clients, tabobj))
		end
	end
	end)

	-- Client removed from existing tab group
	awesome.connect_signal("bling::tabbed::client_removed", function(tabobj, cl)
	  cl.bling_tasklist_display:reset()
	  for _, c in ipairs(tabobj.clients) do
		c.bling_tasklist_display:remove_by_id(cl.window)
	  end
	end)
  end
}
