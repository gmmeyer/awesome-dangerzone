-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious")
local radical = require("radical")
local obvious = require("obvious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local lain = require("lain")

awesome.font = "Ubuntu 14"

-- Quake Console
local scratch = require("scratch")

-- Load Debian menu entries
require("debian.menu")

beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker/theme.lua")
modkey = "Mod4"
altkey = "Mod1"
terminal = 'urxvt'
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

local context = {

}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
                   title = "Oops, there were errors during startup!",
                   text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
                           -- Make sure we don't go into an endless error loop
                           if in_error then return end
                           in_error = true

                           naughty.notify({ preset = naughty.config.presets.critical,
                                            title = "Oops, an error happened!",
                                            text = err })
                           in_error = false
  end)
end
-- }}}

local config = require('config')
config.autorun.init(context)
config.menu.init(context)
config.rules.init(context)
config.keybinds.init(context)


-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.max,
  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end


-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}




-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
                        -- Enable sloppy focus
                        c:connect_signal("mouse::enter", function(c)
                                           if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                                           and awful.client.focus.filter(c) then
                                             client.focus = c
                                           end
                        end)

                        if not startup then
                          -- Set the windows at the slave,
                          -- i.e. put it at the end of others instead of setting it master.
                          -- awful.client.setslave(c)

                          -- Put windows in a smart way, only if they does not set an initial position.
                          if not c.size_hints.user_position and not c.size_hints.program_position then
                            awful.placement.no_overlap(c)
                            awful.placement.no_offscreen(c)
                          end
                        end

                        local titlebars_enabled = false
                        if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
                          -- buttons for the titlebar
                          local buttons = awful.util.table.join(
                            awful.button({ }, 1, function()
                                client.focus = c
                                c:raise()
                                awful.mouse.client.move(c)
                            end),
                            awful.button({ }, 3, function()
                                client.focus = c
                                c:raise()
                                awful.mouse.client.resize(c)
                            end)
                          )

                          -- Widgets that are aligned to the left
                          local left_layout = wibox.layout.fixed.horizontal()
                          left_layout:add(awful.titlebar.widget.iconwidget(c))
                          left_layout:buttons(buttons)

                          -- Widgets that are aligned to the right
                          local right_layout = wibox.layout.fixed.horizontal()
                          right_layout:add(awful.titlebar.widget.floatingbutton(c))
                          right_layout:add(awful.titlebar.widget.maximizedbutton(c))
                          right_layout:add(awful.titlebar.widget.stickybutton(c))
                          right_layout:add(awful.titlebar.widget.ontopbutton(c))
                          right_layout:add(awful.titlebar.widget.closebutton(c))

                          -- The title goes in the middle
                          local middle_layout = wibox.layout.flex.horizontal()
                          local title = awful.titlebar.widget.titlewidget(c)
                          title:set_align("center")
                          middle_layout:add(title)
                          middle_layout:buttons(buttons)

                          -- Now bring it all together
                          local layout = wibox.layout.align.horizontal()
                          layout:set_left(left_layout)
                          layout:set_right(right_layout)
                          layout:set_middle(middle_layout)

                          awful.titlebar(c):set_widget(layout)
                        end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
