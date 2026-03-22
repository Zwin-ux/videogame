local function fail(message)
  error(message, 0)
end

local function read_file(path)
  local file, err = io.open(path, "r")
  if not file then
    fail("Unable to open file: " .. path .. "\n" .. tostring(err))
  end

  local contents = file:read("*a")
  file:close()
  return contents
end

local function ensure_param(name, env_name)
  local value = app.params[name]
  if (not value or value == "") and env_name then
    value = os.getenv(env_name)
  end
  if not value or value == "" then
    fail("Missing " .. name .. " input")
  end
  return value
end

local function to_anim_direction(raw)
  local value = string.lower(raw or "forward")
  if value == "reverse" then
    return AniDir.REVERSE
  elseif value == "pingpong" or value == "ping_pong" or value == "ping-pong" then
    return AniDir.PING_PONG
  else
    return AniDir.FORWARD
  end
end

local sheet_path = ensure_param("sheet", "ASEPRITE_IMPORT_SHEET")
local data_path = ensure_param("data", "ASEPRITE_IMPORT_DATA")
local output_path = ensure_param("output", "ASEPRITE_IMPORT_OUTPUT")
local layer_name = app.params.layer or os.getenv("ASEPRITE_IMPORT_LAYER") or "Base"

local metadata = json.decode(read_file(data_path))
if not metadata.frames or #metadata.frames == 0 then
  fail("No frames found in metadata: " .. data_path)
end

local first_frame = metadata.frames[1].frame
local sprite = Sprite{ fromFile=sheet_path, oneFrame=true }
app.activeSprite = sprite

app.command.ImportSpriteSheet{
  ui=false,
  type=SpriteSheetType.ROWS,
  frameBounds=Rectangle(
    first_frame.x or 0,
    first_frame.y or 0,
    first_frame.w,
    first_frame.h)
}

sprite.gridBounds = Rectangle(0, 0, first_frame.w, first_frame.h)
if sprite.layers[1] then
  sprite.layers[1].name = layer_name
end

for index, frame_data in ipairs(metadata.frames) do
  local frame = sprite.frames[index]
  if frame and frame_data.duration then
    frame.duration = frame_data.duration / 1000.0
  end
end

if metadata.meta and metadata.meta.frameTags then
  for _, tag_data in ipairs(metadata.meta.frameTags) do
    local tag = sprite:newTag(tag_data.from + 1, tag_data.to + 1)
    tag.name = tag_data.name or "Tag"
    tag.aniDir = to_anim_direction(tag_data.direction)
  end
end

sprite:saveAs(output_path)
print("Saved " .. output_path)
