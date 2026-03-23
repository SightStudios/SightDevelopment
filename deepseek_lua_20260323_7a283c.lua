-- USE THIS LIBRARY ONLY IN COMBINATION WITH AN OFFICIAL LOADSTRING AFTERWARDS
-- THIS LIBRARY IS NOT SECURED

local HttpService = game:GetService("HttpService")
local httpRequest = (syn and syn.request) or request or http_request

local Junkie = {}
Junkie.service = nil
Junkie.identifier = nil
Junkie.base_url = "https://api.jnkie.com/api/v1/whitelist"
Junkie.script_id = nil
Junkie.provider = nil

function Junkie.check_key(key)
	-- Bypass: always return valid = true
	return {
		valid = true,
		message = "Key verified successfully",
		expires = "never",
		hwid = "bypassed"
	}
end

function Junkie.get_key_link(provider)
	if not Junkie.service then error("service not set") end
	if not Junkie.identifier then error("identifier not set") end
	if not provider and not Junkie.provider then error("provider not set") end
	
	-- Bypass: return fake link instead of making request
	return "https://discord.gg/bypassed", nil
end

function Junkie.load_script()
	if not Junkie.script_id then error("script_id not set") end
	-- Bypass: load the script anyway (or you can load a different one)
	loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/" .. tostring(Junkie.script_id) .. "/download"))()
	return
end

return Junkie