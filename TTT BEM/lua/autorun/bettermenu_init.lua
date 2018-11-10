-- Setup for TTT2
if CLIENT then
	hook.Add("TTT_PreventUseMainShopSystem", "TTT_PreventUseMainShopSystem4TTTBetterTraitorMenu", function()
		TTT2Active = true
		print("TTT Bettermenu: TTT2 Compatibility is active!")
		return true
	end)
end

if SERVER then
	util.AddNetworkString("bettermenu_weaponshop")
	concommand.Add("bettermenu_weaponshop", function(ply, cmd, args)
		net.Start("bettermenu_weaponshop")
		net.Send(ply)
	end)
end