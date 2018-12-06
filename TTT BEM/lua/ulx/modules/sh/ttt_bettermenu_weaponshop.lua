-- Code by Alf21 (for ULX menu) edited by fresh garry
--[[
local CATEGORY_NAME = "TTT Weaponshop"
local gamemode_error = "The current gamemode is not trouble in terrorest town"

function GamemodeCheck(calling_ply)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)

		return true
	else
		return false
	end
end

function ulx.bettermenu_weaponshop(calling_ply)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		calling_ply:ConCommand("bettermenu_weaponshop")
	end
end

local bettermenu_weaponshop = ulx.command(CATEGORY_NAME, "ulx bettermenu_weaponshop", ulx.bettermenu_weaponshop, "!bettermenu_weaponshop")
bettermenu_weaponshop:defaultAccess(ULib.ACCESS_SUPERADMIN)
bettermenu_weaponshop:setOpposite("ulx silent bettermenu_weaponshop", {_, _, _, true}, "!sbettermenu_weaponshop", true)
bettermenu_weaponshop:help("Opens the bettermenu_weaponshop.")
]]