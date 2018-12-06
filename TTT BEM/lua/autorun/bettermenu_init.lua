-- Setup for TTT2
hook.Add("TTT2ModifyFiles", "OctagonalHudOverrideTTT2", function(files)
	files["cl_equip"].file = "cl_equip.lua"
	print("TTT Bettermenu: TTT2 Compatibility is active!")
end)
--[[
if SERVER then
	util.AddNetworkString("bettermenu_weaponshop")

	concommand.Add("bettermenu_weaponshop", function(ply, cmd, args)
		net.Start("bettermenu_weaponshop")
		net.Send(ply)
	end)
end
]]