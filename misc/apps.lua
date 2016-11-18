local awful = require("awful")

-- Starting some applets, etc

function apps(config)
  --a function to start them and not start them again if I have to reload awesome
  function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
      findme = cmd:sub(0, firstspace-1)
    end
    awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
  end

  --the applets with the function
  awful.util.spawn_with_shell("eval $(xrdb ~/.Xresources)")
  run_once("xfsettingsd")
  -- run_once("nm-applet")
  run_once('xfce4-power-manager')
  run_once('xfce4-volumed')
  -- run_once("blueman-applet")
  run_once('pasystray')
  -- run_once('skype')
  -- run_once("pidgin")
  -- run_once('slack')
  -- run_once('scudcloud')
  --run_once('dropbox start')
  run_once('light-locker')
  run_once("unclutter -root")
  run_once('compton')


  awful.util.spawn_with_shell('killall xfce4-notifyd &')
end

return apps
