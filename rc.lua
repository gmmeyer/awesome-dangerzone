-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious")
local radical = require("radical")
local obvious = require("obvious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local lain = require("lain")
local menubar = require("menubar")

-- Quake Console
local scratch = require("scratch")
local quake = require("quake")

-- Load Debian menu entries
require("debian.menu")

-- load error handling
require('config.errors')

-- load config
local config = require('config')

-- {{{ Wibox
markup = lain.util.markup
separators = lain.util.separators

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock("%a %b %d, %I:%M")
mytextclock:set_font("Terminus 14")

-- calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 12 })

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
    settings = function()
      widget:set_text(" " .. mem_now.used .. "MB ")
      widget:set_font("Terminus 14")
    end
})

-- CPU
cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
    settings = function()
      widget:set_text(" " .. cpu_now.usage .. "% ")
      widget:set_font("Terminus 14")
    end
})

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
    settings = function()
      widget:set_text(" " .. coretemp_now .. "°C ")
      widget:set_font("Terminus 14")
    end
})

-- / fs
fsicon = wibox.widget.imagebox(beautiful.widget_hdd)
fswidget = lain.widgets.fs({
    settings  = function()
      widget:set_text(" " .. fs_now.used .. "% ")
      widget:set_font("Terminus 14")
    end
})

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_battery)
batwidget = lain.widgets.bat({
    settings = function()
      widget:set_font("Terminus 14")
      if bat_now.perc == "N/A" then
        widget:set_markup(" AC ")
        baticon:set_image(beautiful.widget_ac)
        return
      elseif tonumber(bat_now.perc) <= 5 then
        baticon:set_image(beautiful.widget_battery_empty)
      elseif tonumber(bat_now.perc) <= 15 then
        baticon:set_image(beautiful.widget_battery_low)
      else
        baticon:set_image(beautiful.widget_battery)
      end
      widget:set_markup(" " .. bat_now.perc .. "% ")
    end
})

-- pulseaudio volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.pulseaudio({
    settings = function()
      widget:set_font("Terminus 14")
      if volume_now.muted == "yes" or volume_now.status == "off" then
        volicon:set_image(beautiful.widget_vol_mute)
        widget:set_text(" " .. 0 .. "% ")
      elseif tonumber(volume_now.left) == 0 then
        volicon:set_image(beautiful.widget_vol_no)
      elseif tonumber(volume_now.left) <= 50 then
        volicon:set_image(beautiful.widget_vol_low)
      else
        volicon:set_image(beautiful.widget_vol)
      end

      widget:set_text(" " .. volume_now.left .. "% ")
    end
})

-- Net
neticon = wibox.widget.imagebox(beautiful.widget_net)
neticon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
netwidget = lain.widgets.net({
    settings = function()
      widget:set_font("Terminus 14")
      widget:set_markup(markup("#7AC82E", " " .. net_now.received)
                          .. " " ..
                          markup("#46A8C3", " " .. net_now.sent .. " "))
    end
})

mysystray = wibox.widget.systray()
-- theme.bg_systray = "#313131"

-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}

mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ config.modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ config.modkey }, 3, awful.client.toggletag),
  awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
      if c == client.focus then
        c.minimized = true
      else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() then
          awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
      end
  end),
  awful.button({ }, 3, function ()
      if instance then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({ width=250 })
      end
  end),
  awful.button({ }, 4, function ()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
  end),
  awful.button({ }, 5, function ()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(config.layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(config.layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(config.layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(config.layouts, -1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s, height = 34 })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(spr)
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])
  left_layout:add(spr)

  -- Widgets that are aligned to the upper right
  local right_layout_toggle = true
  local function right_layout_add (...)
    local arg = {...}
    if right_layout_toggle then
      right_layout:add(arrl_ld)
      for i, n in pairs(arg) do
        right_layout:add(wibox.widget.background(n ,beautiful.bg_focus))
      end
    else
      right_layout:add(arrl_dl)
      for i, n in pairs(arg) do
        right_layout:add(n)
      end
    end
    right_layout_toggle = not right_layout_toggle
  end

  right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(arrl)
  right_layout:add(spr)
  right_layout_add(volicon, volumewidget)
  right_layout_add(cpuicon, cpuwidget)
  right_layout_add(memicon, memwidget)
  right_layout_add(fsicon, fswidget)
  right_layout_add(tempicon, tempwidget)
  right_layout_add(neticon, netwidget)
  right_layout_add(baticon, batwidget)
  if s == 1 then right_layout_add(mysystray) end
  right_layout_add(mytextclock, spr)
  right_layout_add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
               awful.button({ }, 3, function () config.mymainmenu:toggle() end),
               awful.button({ }, 4, awful.tag.viewnext),
               awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local quakeconsole = {}
for s = 1, screen.count() do
   quakeconsole[s] = quake({ terminal = config.terminal,
			     height = 0.4,
           width = 0.95,
           vert = 'top',
           horoz = 'center',
           name = "quake_console_" .. s,
			     screen = s })
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  awful.key({ config.modkey,           }, "Left",   awful.tag.viewprev       ),
  awful.key({ config.modkey,           }, "Right",  awful.tag.viewnext       ),
  awful.key({ config.modkey,           }, "Escape", awful.tag.history.restore),

  awful.key({ config.modkey,           }, "j",
    function ()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
  end),
  awful.key({ config.modkey,           }, "k",
    function ()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
  end),

  awful.key({ config.modkey,           }, "w", function () config.mymainmenu:show() end),

  -- Layout manipulation
  awful.key({ config.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
  awful.key({ config.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
  awful.key({ config.modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ config.modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
  awful.key({ config.modkey,           }, "u", awful.client.urgent.jumpto),
  awful.key({ config.modkey,           }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
  end),

  -- Standard program
  awful.key({ config.modkey,           }, "Return", function () awful.util.spawn(config.terminal) end),
  awful.key({ config.modkey, "Control" }, "r", awesome.restart),
  awful.key({ config.modkey, "Shift"   }, "q", awesome.quit),

  awful.key({ config.modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ config.modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ config.modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
  awful.key({ config.modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
  awful.key({ config.modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
  awful.key({ config.modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
  awful.key({ config.modkey,           }, "space", function () awful.layout.inc(config.layouts,  1) end),
  awful.key({ config.modkey, "Shift"   }, "space", function () awful.layout.inc(config.layouts, -1) end),

  awful.key({ config.modkey, "Control" }, "n", awful.client.restore),

  -- Prompt
  awful.key({ config.modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

  awful.key({ config.modkey }, "x",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
  end),
  -- Menubar
  awful.key({ config.modkey }, "p", function() menubar.show() end),

  -- Scratchpad
  -- This launches the scratchpad
  awful.key({config.modkey, "Shift" }, "`", function() scratch("urxvt -name urxvt_drop", "top", "center", 0.95, 0.40) end)
  -- awful.key({config.modkey }, "`", function() scratch("urxvt -name urxvt_drop -e bash -c 'tmux -q has-session && exec tmux attach-session -d || exec tmux new-session -n$USER -s$USER@$HOSTNAME'", "top", "center", 0.95, 0.40) end)
)

globalkeys = awful.util.table.join(
   globalkeys,
   awful.key({ config.modkey }, "`",
	     function () quakeconsole[mouse.screen]:toggle() end)
     )

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
                                     awful.key({ config.modkey }, "#" .. i + 9,
                                       function ()
                                         local screen = mouse.screen
                                         local tag = awful.tag.gettags(screen)[i]
                                         if tag then
                                           awful.tag.viewonly(tag)
                                         end
                                     end),
                                     awful.key({ config.modkey, "Control" }, "#" .. i + 9,
                                       function ()
                                         local screen = mouse.screen
                                         local tag = awful.tag.gettags(screen)[i]
                                         if tag then
                                           awful.tag.viewtoggle(tag)
                                         end
                                     end),
                                     awful.key({ config.modkey, "Shift" }, "#" .. i + 9,
                                       function ()
                                         if client.focus then
                                           local tag = awful.tag.gettags(client.focus.screen)[i]
                                           if tag then
                                             awful.client.movetotag(tag)
                                           end
                                         end
                                     end),
                                     awful.key({ config.modkey, "Control", "Shift" }, "#" .. i + 9,
                                       function ()
                                         if client.focus then
                                           local tag = awful.tag.gettags(client.focus.screen)[i]
                                           if tag then
                                             awful.client.toggletag(tag)
                                           end
                                         end
  end))
end

-- Set keys
root.keys(globalkeys)
-- }}}

-- these are misc customizations
require('misc')(config)
