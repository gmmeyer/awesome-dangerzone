local beautiful = require('beautiful')
local awful = require('awful')
awful.rules = require('awful.rules')

local rules = {}


function rules.init(context)
  awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = context.clientkeys,
                     buttons = context.clientbuttons } },

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
  }

end

return rules
