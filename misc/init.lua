local rules = require('misc.rules')
local signals = require('misc.signals')
local apps = require('misc.apps')

function run(config)
  rules(config)
  signals(config)
  apps(config)
end

return run
