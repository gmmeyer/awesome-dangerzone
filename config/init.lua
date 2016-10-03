local gears = require("gears")
local beautiful = require('beautiful')
local menubar = require("menubar")
local awful = require("awful")

beautiful.init(os.getenv('HOME') .. '/.config/awesome/themes/powerarrow-darker/theme.lua')

if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.tile.bottom,
  -- awful.layout.suit.tile.top,
  -- awful.layout.suit.max,
  -- awful.layout.suit.magnifier
}
-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end


local config = {
  modkey = 'Mod4',
  altkey = 'Mod1',
  terminal = 'urxvt',
  layouts = layouts
}

awesome.font = 'Terminus 14'
theme.font = 'Terminus 14'
menubar.font = 'Terminus 14'

theme.awful_widget_height           = 24
theme.awful_widget_margin_top       = 2

theme.menu_height                   = '26'
theme.menu_width                    = '140'

config.mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
                              theme = { height = 36, width = 130 }})

--common

editor = os.getenv('EDITOR') or 'editor'
editor_cmd = config.terminal .. ' -e ' .. editor

-- Menubar configuration
menubar.utils.altkey = config.altkey -- Set the mysettings.altkey for applications that require it
-- Scan for applications
menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/",
                                   "/usr/local/share/applications",
                                   "~/.local/share/applications"
}

return config
