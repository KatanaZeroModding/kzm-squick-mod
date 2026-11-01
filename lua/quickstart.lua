-- libLassebq re-dofiles every loadlist script on each hooked event. Always return the same
-- hook table (ADR 0022). Returning {} after the first load breaks
-- skip/resume: the first dofile often runs during gml_Script_* hooks in room_init, before
-- obj_saveprompt / obj_titlemenu fire.
if _G.__SPEEDRUN_QUICKSTART_HOOKS then
  return _G.__SPEEDRUN_QUICKSTART_HOOKS
end

local LOG_PATH = "mods/speedrun-quickstart/quickstart.log"
local VK_SHIFT = 16

local state = _G.__SPEEDRUN_QUICKSTART_STATE or {
  startup = true,
  resume_checked = false,
}
_G.__SPEEDRUN_QUICKSTART_STATE = state

local function log(msg)
  local f = io.open(LOG_PATH, "a")
  if f then
    f:write(os.date("%Y-%m-%d %H:%M:%S "), tostring(msg), "\n")
    f:close()
  end
end

-- Runtime functions in this libLassebq are `room_goto`, not `GML_room_goto`.
-- Scripts are `GMLScript_<name>`. Try both so a prefix change does not silently no-op.
local function resolve(name)
  local fn = rawget(_G, name)
  if type(fn) == "function" then
    return fn
  end
  fn = rawget(_G, "GML_" .. name)
  if type(fn) == "function" then
    return fn
  end
  return nil
end

local function script_fn(name)
  local fn = rawget(_G, "GMLScript_" .. name)
  if type(fn) == "function" then
    return fn
  end
  fn = rawget(_G, "gml_Script_" .. name)
  if type(fn) == "function" then
    return fn
  end
  return nil
end

local function global(name)
  local ok, value = pcall(function()
    return _pGlobal[name]
  end)
  if ok then
    return value
  end
  return nil
end

local function truthy(value)
  return value == true or value == 1
end

local function skip_to_title()
  if not state.startup then
    return
  end
  local goto_room = resolve("room_goto")
  local title = rawget(_G, "room_title")
  if type(goto_room) ~= "function" or type(title) ~= "number" then
    log("skip failed: room_goto=" .. type(goto_room) .. " room_title=" .. tostring(title))
    return
  end
  local ok, err = pcall(goto_room, title)
  if not ok then
    log("room_goto error: " .. tostring(err))
  end
end

-- Mirrors the title menu's "Continue previous speedrun? -> YES" path. Never pass GML arrays
-- back into GML calls from here: libLassebq mishandles their refcounts and corrupts the heap.
local function try_resume()
  if not truthy(global("mid_speedrun")) then
    return false, "no saved speedrun"
  end
  local key_check = resolve("keyboard_check")
  if type(key_check) == "function" and truthy(key_check(VK_SHIFT)) then
    return false, "Shift held, staying on title"
  end

  local load_run = script_fn("load_current_speedrun")
  if type(load_run) ~= "function" then
    return false, "load_current_speedrun missing"
  end
  local ok, loaded = pcall(load_run)
  if not ok or not truthy(loaded) then
    return false, "load_current_speedrun failed: " .. tostring(loaded)
  end

  local room = global("continue_room")
  local room_exists = resolve("room_exists")
  if type(room) ~= "number" or type(room_exists) ~= "function" or not truthy(room_exists(room)) then
    return false, "invalid continue_room: " .. tostring(room)
  end

  _pGlobal.speedrun = 1
  local goto_room = resolve("room_goto")
  if type(goto_room) ~= "function" then
    return false, "room_goto missing"
  end
  goto_room(room)
  local room_name = resolve("room_get_name")
  if type(room_name) == "function" then
    return true, room_name(room)
  end
  return true, tostring(room)
end

local skip_intro = { Create = skip_to_title }

local hooks = {
  obj_saveprompt = skip_intro,
  obj_optionsprompt = skip_intro,
  obj_logo = skip_intro,
  obj_splash = skip_intro,

  obj_titlemenu = {
    Step = function()
      state.startup = false
      if state.resume_checked then
        return
      end
      state.resume_checked = true

      local ok, resumed, detail = pcall(try_resume)
      if not ok then
        log("resume error: " .. tostring(resumed))
      elseif resumed then
        log("resumed speedrun in " .. tostring(detail))
      else
        log("no resume: " .. tostring(detail))
      end
    end,
  },
}

log("hooks ready")
_G.__SPEEDRUN_QUICKSTART_HOOKS = hooks
return hooks
