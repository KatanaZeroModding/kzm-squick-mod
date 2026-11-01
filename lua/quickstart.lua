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
  if state.startup then
    GML_room_goto(room_title)
  end
end

-- Mirrors the title menu's "Continue previous speedrun? -> YES" path. Never pass GML arrays
-- back into GML calls from here: libLassebq mishandles their refcounts and corrupts the heap.
local function try_resume()
  if not truthy(global("mid_speedrun")) then
    return false, "no saved speedrun"
  end
  if truthy(GML_keyboard_check(VK_SHIFT)) then
    return false, "Shift held, staying on title"
  end

  local ok, loaded = pcall(GMLScript_load_current_speedrun)
  if not ok or not truthy(loaded) then
    return false, "load_current_speedrun failed: " .. tostring(loaded)
  end

  local room = global("continue_room")
  if type(room) ~= "number" or not truthy(GML_room_exists(room)) then
    return false, "invalid continue_room: " .. tostring(room)
  end

  _pGlobal.speedrun = 1
  GML_room_goto(room)
  return true, GML_room_get_name(room)
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

_G.__SPEEDRUN_QUICKSTART_HOOKS = hooks
return hooks
