-- Quake like console on top
-- Similar to:
--   http://git.sysphere.org/awesome-configs/tree/scratch/drop.lua

-- But uses a different implementation. The main difference is that we
-- are able to detect the Quake console from its name
-- (QuakeConsoleNeedsUniqueName by default).

-- Use:

-- local quake = require("quake")
-- local quakeconsole = {}
-- for s = 1, screen.count() do
--    quakeconsole[s] = quake({ terminal = config.terminal,
-- 			        height = 0.3,
--                              screen = s })
-- end

-- config.keys.global = awful.util.table.join(
--    config.keys.global,
--    awful.key({ modkey }, "`",
-- 	     function () quakeconsole[mouse.screen]:toggle() end)

-- If you have a rule like "awful.client.setslave" for your terminals,
-- ensure you use an exception for
-- QuakeConsoleNeedsUniqueName. Otherwise, you may run into problems
-- with focus.

local setmetatable = setmetatable
local string = string
local pairs = pairs
local awful  = require("awful")
local capi   = { mouse = mouse,
		 screen = screen,
		 client = client,
		 timer = timer }


local naughty = require("naughty")
-- I use a namespace for my modules...
module("quake")

local QuakeConsole = {}

function QuakeConsole:find()
	local client = nil
	local i = 0
	for c in awful.client.iterate(function (c)
				 -- c.name may be changed!
				 return c.instance == self.name
						end,
						nil, self.screen) do
		 i = i + 1
		 if i == 1 then
	client = c
		 else
	-- Additional matching clients, let's remove the sticky bit
	-- which may persist between awesome restarts. We don't close
	-- them as they may be valuable. They will just turn into a
	-- classic terminal.
	c.sticky = false
	c.ontop = false
	c.above = false
		 end
	end

	return client
end

-- Display
function QuakeConsole:display()
   -- First, we locate the terminal
	 local client = self:find()

   if not client and not self.visible then
      -- The terminal is not here yet but we don't want it yet. Just do nothing.
      return
   end


   if not client then
      -- The client does not exist, we spawn it
      awful.util.spawn(self.terminal .. " " .. string.format(self.argname, self.name),
		       true, self.screen)
			-- there is a bug with floating screens that have windows on them that the quake console will be at the bottom
			-- this is a hack to fix that
			local console = self
			spawnnw = function(c)
							     if c.instance == console.name and c.screen == console.screen then
										console:display(mouse)
										capi.client.disconnect_signal("manage",spawnnw)
							     end
							  end
			capi.client.connect_signal("manage",spawnnw)
			return
	end

	self:format(client)

	-- Toggle display
	if self.visible then
		 client.hidden = false
		 client:raise()
		 capi.client.focus = client
		 awful.client.movetotag(awful.tag.selected(self.screen), client)
	else
		 client.hidden = true
		 local ctags = client:tags()
		 for i, t in pairs(ctags) do
				 ctags[i] = nil
		 end
		 client:tags(ctags)
	end

end

function QuakeConsole:format(client)
	awful.client.floating.set(client, true)

	-- Comptute size
	local geom = capi.screen[self.screen].workarea
	local width, height = self.width, self.height
	if width  <= 1 then width = geom.width * width end
	if height <= 1 then height = geom.height * height end
	local x, y
	if     self.horiz == "left"  then x = geom.x
	elseif self.horiz == "right" then x = geom.width + geom.x - width
	else   x = geom.x + (geom.width - width)/2 end
	if     self.vert == "top"    then y = geom.y
	elseif self.vert == "bottom" then y = geom.height + geom.y - height
	else   y = geom.y + (geom.height - height)/2 end

	-- Resize

	client.border_width = 0
	-- we want it to honor size_hints
	client.size_hints_honor = true

	client:geometry({ x = x, y = y, width = width, height = height })

	-- Sticky and on top
	client.ontop = true
	client.above = true
	client.skip_taskbar = true
	client.sticky = self.sticky
	-- This is not a normal window, don't apply any specific keyboard stuff
	client:buttons({})
	client:keys({})

end

-- Create a console
function QuakeConsole:new(config)
   -- The "console" object is just its configuration.

   -- The application to be invoked is:
   --   config.terminal .. " " .. string.format(config.argname, config.name)
   config.terminal = config.terminal or "urxvt" -- application to spawn
   config.name     = config.name     or "QuakeConsoleNeedsUniqueName" -- window name
   config.argname  = config.argname  or "-name %s"     -- how to specify window name

   -- If width or height <= 1 this is a proportion of the workspace
   config.height   = config.height   or 0.25	       -- height
   config.width    = config.width    or 1	       -- width
   config.vert     = config.vert     or "top"	       -- top, bottom or center
   config.horiz    = config.horiz    or "center"       -- left, right or center

   config.screen   = config.screen or capi.mouse.screen
   config.visible  = config.visible or false -- Initially, not visible
	 config.sticky   = config.sticky or false

   local console = setmetatable(config, { __index = QuakeConsole })
	 local quake = self
   capi.client.connect_signal("manage",
			  function(c)
			     if c.instance == console.name and c.screen == console.screen then
						console:display(mouse)
			     end
			  end)
   capi.client.connect_signal("unmanage",
			  function(c)
			     if c.instance == console.name and c.screen == console.screen then
				console.visible = false
			     end
			  end)

   -- "Reattach" currently running QuakeConsole. This is in case awesome is restarted.
   local reattach = capi.timer { timeout = 5 }
   reattach:connect_signal("timeout",
		       function()
			  reattach:stop()
			  console:display()
		       end)
   reattach:start()
   return console
end

-- Toggle the console
function QuakeConsole:toggle()
   self.visible = not self.visible
   self:display()
end

setmetatable(_M, { __call = function(_, ...) return QuakeConsole:new(...) end })
