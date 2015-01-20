local awful = require('awful')

-- Starting some applets, etc

--a function to start them and not start them again if I have to reload awesome
function run_once(cmd)
   findme = cmd
   firstspace = cmd:find(' ')
   if firstspace then
      findme = cmd:sub(0, firstspace-1)
   end
   awful.util.spawn_with_shell('pgrep -u $USER -x ' .. findme .. ' > /dev/null || (' .. cmd .. ')')
end

local autorun = {}

function autorun.init(context)
   -- This loads .Xresources
   -- I can't check if this has been loaded,
   -- but, that's okay, I'm not adding to the already loaded configs,
   -- I am loading all of it here
   awful.util.spawn_with_shell('eval $(xrdb ~/.Xresources) &')

   --Starting Applets
   run_once('tmux')
   run_once('xfsettingsd')
   run_once('nm-applet')
   run_once('xfce4-power-manager')
   run_once('xfce4-volumed --no-daemon')
   run_once('blueman-applet')
   run_once('pasystray')
   run_once('skype')
   run_once('pidgin')

   -- This used to really slow my computer down,
   -- but I'm gonna try it without on the mac
   run_once('dropbox start')
   --run_once('sleep 20m; dropbox start')

   for _, item in ipairs(awesome_context.autorun) do
      awful.util.spawn_with_shell(item)
   end
end

return autorun
