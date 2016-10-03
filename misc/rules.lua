local awful = require("awful")
awful.rules = require("awful.rules")
local beautiful = require('beautiful')

function run_rules(config)

  clientkeys = awful.util.table.join(
    awful.key({ config.modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ config.modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ config.modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ config.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ config.modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ config.modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ config.modkey,           }, "n",
      function (c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
    end),
    awful.key({ config.modkey,           }, "m",
      function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
  )

  clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ config.modkey }, 1, awful.mouse.client.move),
    awful.button({ config.modkey }, 3, awful.mouse.client.resize))

    -- {{{ Rules
    awful.rules.rules = {
      -- All clients will match this rule.
      { rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = awful.client.focus.filter,
                       keys = clientkeys,
                       buttons = clientbuttons } },
      { rule = { class = "MPlayer" },
        properties = { floating = true } },
      { rule = { class = "pinentry" },
        properties = { floating = true } },
      { rule = { class = "gimp" },
        properties = { floating = true } },
      { rule = {class = "Pidgin"},
        properties = { tag=tags[1][2], floating = true } },
      { rule = {class = "Skype"},
        properties = { tag=tags[1][2], floating = true } },

      { rule = {class = "Scudcloud"},
        properties = { tag=tags[1][2], floating = true } },

      { rule = {class = "Slack"},
        properties = { tag=tags[1][2], floating = true } },

      { rule = {class = "slack"},
        properties = { tag=tags[1][2], floating = true } },


      {rule = {class = "Yakuake"}, properties = {floating = true,  maximized_vertical   = false,
                                                 maximized_horizontal = false,
                                                 maximized= false} }
      -- Set Firefox to always map on tags number 2 of screen 1.
      -- { rule = { class = "Firefox" },
      --   properties = { tag = tags[1][2] } },
    }
end

return run_rules
