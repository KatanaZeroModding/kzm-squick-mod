local Mod = require("kzm.sdk.mod")

-- Game hooks live in lua/quickstart.lua (a loadlist entry): libLassebq re-runs every
-- loadlist file on each hooked event, and kzm/bootstrap.lua only hands out hooks once.
return Mod.define({
  id = "speedrun-quickstart",
  onLoad = function(ctx)
    ctx.log("Speedrun Quickstart loaded")
  end,
  hooks = {},
})
