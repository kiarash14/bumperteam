local function set_bot_photo(msg, success, result)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/bot.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    set_profile_photo(file, ok_cb, false)
    send_large_msg(receiver, 'Photo changed!', ok_cb, false)
    redis:del("bot:photo")
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end
local function parsed_url(link)
  local parsed_link = URL.parse(link)
  local parsed_path = URL.parse_path(parsed_link.path)
  return parsed_path[2]
end

local function run(msg,matches)
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    local group = msg.to.id
    if not is_admin(msg) then
    	return
    end
    if msg.media then
      	if msg.media.type == 'ph' and redis:get("b:ph") then
      		if redis:get("b:ph") == 'waiting' then
        		load_photo(msg.id, set_bot_photo, msg)
      		end
      	end
    end
    if matches[1] == "sbph" then
    	redis:set("b:ph", "waiting")
    	return 'Please send me bot photo now'
    end
    if matches[1] == "m" then
    	if matches[2] == "n" then
    		redis:set("b:mr", "n")
    		return "M r > on"
    	end
    	if matches[2] == "f" then
    		redis:del("b:m")
    		return "M r > f"
    	end
    	return
    end
    if matches[1] == "pm" then
    	send_large_msg("user#id"..matches[2],matches[3])
    	return "Msg sent"
    end
    if matches[1] == "bl" then
    	if is_admin2(matches[2]) then
    		return "You can't block admins"
    	end
    	block_user("user#id"..matches[2],ok_cb,false)
    	return "User blocked"
    end
    if matches[1] == "unbl" then
    	unblock_user("user#id"..matches[2],ok_cb,false)
    	return "User unblocked"
    end
    if matches[1] == "imp" then
    	local hash = parsed_url(matches[2])
    	import_chat_link(hash,ok_cb,false)
    end
    return
end
return {
  patterns = {
    "^(pm) (%d+) (.*)$",
    "^(imp) (.*)$",
    "^([Uu]nbl) (%d+)$",
    "^([Bb]l) (%d+)$",
	"^([Mm]r) (on)$",
	"^([Mm]r) (off)$",
    "^([Ss]bph)$",
	"%[(ph)%]"
  },
  run = run,
}
