local awful = require("awful")
local menubar = require('menubar')

local menu = {}

function menu.init(context)
   -- {{{ Menu
   -- Create a laucher widget and a main menu
   myawesomemenu = {
      { "manual", context.terminal .. " -e man awesome" },
      { "edit config", context.editor_cmd .. " " .. context.awesome.conffile },
      { "restart", context.awesome.restart },
      { "quit", context.awesome.quit }
   }

   mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
                                 theme = { height = 16, width = 130 },
                              })

   mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                        menu = mymainmenu })

   -- Menubar configuration
   menubar.utils.terminal = terminal -- Set the terminal for applications that require it
   -- Scan for applications
   menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/",
                                      "/usr/local/share/applications",
                                      "~/.local/share/applications"
   }
   -- }}}
end

return menu
