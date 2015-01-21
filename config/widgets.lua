local lain = require('lain')
local wibox = require('wibox')
local beautiful = require('beautiful')
local awful = require('awful')

local widgets = {}

function widgets.init(context)

  markup = lain.util.markup

  -- Textclock
  clockicon = wibox.widget.imagebox(beautiful.widget_clock)
  mytextclock = awful.widget.textclock("%a %b %d, %I:%M")

  -- MEM
  memicon = wibox.widget.imagebox(beautiful.widget_mem)
  memwidget = lain.widgets.mem({
      settings = function()
        widget:set_text(" " .. mem_now.used .. "MB ")
      end
  })

  -- CPU
  cpuicon = wibox.widget.background(wibox.widget.imagebox(
                                      beautiful.widget_cpu),
                                    "#313131")

  cpuwidget = wibox.widget.background(lain.widgets.cpu({
                                          settings = function()
                                            widget:set_text(" " .. cpu_now.usage .. "% ")
                                          end
                                                      }), "#313131")

  -- Coretemp
  tempicon = wibox.widget.imagebox(beautiful.widget_temp)
  tempwidget = lain.widgets.temp({
      settings = function()
        widget:set_text(" " .. coretemp_now .. "°C ")
      end
  })

  -- / fs
  fsicon = wibox.widget.background(wibox.widget.imagebox(
                                     beautiful.widget_hdd),
                                   "#313131")

  fswidget = lain.widgets.fs({
      settings  = function()
        widget:set_text(" " .. fs_now.used .. "% ")
      end
  })
  fswidgetbg = wibox.widget.background(fswidget, "#313131")

  -- Battery
  baticon = wibox.widget.imagebox(beautiful.widget_battery)
  batwidget = lain.widgets.bat({
      settings = function()
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

  -- ALSA volume
  volicon = wibox.widget.imagebox(beautiful.widget_vol)
  volumewidget = lain.widgets.alsa({
      settings = function()
        if volume_now.status == "off" then
          volicon:set_image(beautiful.widget_vol_mute)
        elseif tonumber(volume_now.level) == 0 then
          volicon:set_image(beautiful.widget_vol_no)
        elseif tonumber(volume_now.level) <= 50 then
          volicon:set_image(beautiful.widget_vol_low)
        else
          volicon:set_image(beautiful.widget_vol)
        end

        widget:set_text(" " .. volume_now.level .. "% ")
      end
  })
  volumewidgetbg = wibox.widget.background(volumewidget, "#313131")

  -- Net
  neticon = wibox.widget.imagebox(beautiful.widget_net)
  neticon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
  netwidget = wibox.widget.background(lain.widgets.net({
                                          settings = function()
                                            widget:set_markup(markup("#7AC82E", " " .. net_now.received)
                                                                .. " " ..
                                                                markup("#46A8C3", " " .. net_now.sent .. " "))
                                          end
                                                      }), "#313131")

  mysystray = wibox.widget.systray()
  theme.bg_systray = "#313131"

  -- Separators
  spr = wibox.widget.textbox(' ')
  arrl = wibox.widget.imagebox()
  arrl:set_image(beautiful.arrl)
  arrl_dl = wibox.widget.imagebox()
  arrl_dl:set_image(beautiful.arrl_dl)
  arrl_ld = wibox.widget.imagebox()
  arrl_ld:set_image(beautiful.arrl_ld)

end

return widgets
