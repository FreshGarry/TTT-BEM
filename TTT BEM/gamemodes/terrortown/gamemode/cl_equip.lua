---- Traitor equipment menu
-- Please ask me if you want to use parts of this code!
-- need to rework some parts (its awful code sry)
-- reset Variables and add ConVars

-- Table with Addons
local Version = "2.4"

if not TTTFGAddons then
	TTTFGAddons = {}
end

table.insert(TTTFGAddons, "TTT Better Menu")

-- ConVar for disabling
local ChatMessage = CreateClientConVar("ttt_fgaddons_textmessage", "1", true, false, "Enables or disables the message in the chat. Def:1")

-- Hook for printing
hook.Add("TTTBeginRound", "TTTBeginRound4TTTFGAddons", function()
	local String = ""

	for i = 1, #TTTFGAddons do
		if String == "" then
			String = TTTFGAddons[i]
		else
			String = String .. ", " .. TTTFGAddons[i]
		end
	end

	if ChatMessage:GetBool() then
		chat.AddText("TTT FG Addons: ", Color(255, 255, 255), "You are running " .. String .. ".")
		chat.AddText("TTT FG Addons: ", Color(255, 255, 255), "Be sure to check out the Settings in the ", Color(255, 0, 0), "F1", Color(255, 255, 255), " menu.")
		chat.AddText("TTT FG Addons: ", Color(255, 255, 255), "You can disable this message in the Settings (", Color(255, 0, 0), "F1", Color(255, 255, 255), ").")
	end
end)

-- Setup Variables
local EquipmentAll = nil
local SearchText = false
local FirstSort = nil
local Autobought = false
local fixedDesc = {}
local LastSearched = false
local LastSortation = false
local LastSelected = false
local Selected = nil
local to_select = nil -- may cause bug

if not TTT2 then
	TTT2 = false
end

-- Colors
local BoxColor = CreateClientConVar("ttt_bettermenu_colors_box", "r90 g90 b95", true, false, "The color of the boxes in EQMenu (r g b). Def:r90 g90 b95")
local WindowColor = CreateClientConVar("ttt_bettermenu_colors_window", "nil", true, false, "The color of the EQMenu window (r g b a or nil). Def:nil")
local TabColor = CreateClientConVar("ttt_bettermenu_colors_tab", "nil", true, false, "The color of the tabs in EQMenu (r g b a or nil). Def:nil")
local color_bad = CreateClientConVar("ttt_bettermenu_colors_text_bad", "r220 g60 b60 a255", true, false, "The bad text color in EQMenu (r g b a). Def:r220 g60 b60 a255")
local color_good = CreateClientConVar("ttt_bettermenu_colors_text_good", "r0 g200 b0 a255", true, false, "The good text color in EQMenu (r g b a). Def:r0 g200 b0 a255")
local color_darkened = CreateClientConVar("ttt_bettermenu_colors_item_darkened", "r255 g255 b255 a80", true, false, "The color which is subtracted from the icon if you cant by it in EQMenu (r g b a). Def:r255 g255 b255 a80")
local FilterTextColor = CreateClientConVar("ttt_bettermenu_colors_text_filter", "r255 g255 b255 a255", true, false, "The text color in a box which shows the filter in EQMenu (r g b a). Def:r255 g255 b255 a255")
local SlotTextColor = CreateClientConVar("ttt_bettermenu_colors_text_slotcap", "r255 g255 b255 a255", true, false, "The text color on the slotcap in EQMenu (r g b a). Def:r255 g255 b255 a255")
local DescriptionTextColor = CreateClientConVar("ttt_bettermenu_colors_text_description", "r255 g255 b255 a255", true, false, "The text color of the description in EQMenu (r g b a ). Def:r255 g255 b255 a255")
local TypeTextColor = CreateClientConVar("ttt_bettermenu_colors_text_type", "r255 g255 b255 a255", true, false, "The text color of the type in EQMenu (r g b a). Def:r255 g255 b255 a255")
local TitleTextColor = CreateClientConVar("ttt_bettermenu_colors_text_title", "r255 g255 b255", true, false, "The text color of the type in EQMenu (r g b). Def:r255 g255 b255")
local OutlineColor = CreateClientConVar("ttt_bettermenu_colors_item_outline", "r255 g200 b0 a255", true, false, "The outline color of the selected item in EQMenu (r g b a). Def:r255 g200 b0 a255")

-- Setup ConVars
local AutobuyChatMessage = CreateClientConVar("ttt_bettermenu_autobuymessage", "1", true, false, "Enables or disables the autobuy messages in the chat. Def:1")
local IconSizeRaw = CreateClientConVar("ttt_bettermenu_iconsize", "64", true, false, "The items icon size in the menu. (16-1024) Def: 64")
local RowsRaw = CreateClientConVar("ttt_bettermenu_rows", "5", true, false, "The rows filled with items in the menu. (1-100) Def: 5")
local ColumsRaw = CreateClientConVar("ttt_bettermenu_colums", "3", true, false, "The colums filled with items in the menu. (1-100) Def: 3")
local CustomOn = CreateClientConVar("ttt_bettermenu_custommarker", "1", true, false, "Enables or disables the custommarker in the menu. Def: 1")
local FavoriteOn = CreateClientConVar("ttt_bettermenu_favoritemarker", "1", true, false, "Enables or disables the Favoritemarker in the menu. Def: 1")
local FixedDescBool = CreateClientConVar("ttt_bettermenu_fixeddesc", "1", true, false, "Enables or disables the fixed description function. Def: 1")
local SlotOn = CreateClientConVar("ttt_bettermenu_slotmarker", "1", true, false, "Enables or disables the slotmarker in the menu. Def: 1")
local AutobuyOn = CreateClientConVar("ttt_bettermenu_autobuymarker", "1", true, false, "Enables or disables the autobuymarker in the menu. Def: 1")
local AutobuyRoundbegin = CreateClientConVar("ttt_bettermenu_autobuy_roundbegin", "0", true, false, "Enables or disables if autobuy should be runed on the beginning of every round. Def: 0")
local CloseByPressCAgainRaw = CreateClientConVar("ttt_bettermenu_closebypressc", "1", true, false, "Closes the menu when your pressing C and its open. Def: 1")
local StandartSortRaw = CreateClientConVar("ttt_bettermenu_defaultorder", "1", true, false, "The default order of the menu. (1 = Default, 2 = Name, 3 = Slot) Def: 1")
local StandartSort = math.min(math.max(math.floor(StandartSortRaw:GetFloat()), 1), 3)

if StandartSort == 1 then
	FirstSort = "Default"
elseif StandartSort == 2 then
	FirstSort = "Name"
else
	FirstSort = "Slot"
end

-- Set up function to reach it everywhere

-- convert Variables to Tables
local function LinesToTable(Var)
	if not Var then return end

	local Table = {}
	local i = 1

	while #Var > 0 do
		local End = string.find(Var, "\n")

		Table[i] = string.sub(Var, 1, End - 1)
		Var = string.sub(Var, End + 1, #Var)
		i = i + 1
	end

	return Table
end

-- convert Colors for convar
local function ColorToString(c)
	local String = ""

	if not c then
		return "nil"
	else
		String = "r" .. c["r"] .. " g" .. c["g"] .. " b" .. c["b"]

		if c["a"] then
			String = String .. " a" .. c["a"]
		end

		return String
	end
end

local function StringToColor(String)
	local Colors = {
		[1] = "r",
		[2] = "g",
		[3] = "b",
		[4] = "a"
	}

	local Table = {}

	if String == "nil" then
		return nil
	else
		for _, k in pairs(Colors) do
			local Begin = string.find(String, k)

			if Begin then
				local End, _ = string.find(String, " ", Begin)

				if not End then
					End = #String + 1
				end

				Table[k] = string.sub(String, Begin + 1, End - 1)
			end
		end

		if Table["a"] then -- whyever the Table was not working with transperency
			return Color(Table["r"], Table["g"], Table["b"], Table["a"])
		else
			return Color(Table["r"], Table["g"], Table["b"])
		end
	end
end

-- Autobuy functions
local function AutobuyChat(text)
	if AutobuyChatMessage:GetBool() then
		chat.AddText("TTT Autobuy: ", Color(255, 255, 255), text)
	end
end

local function Autobuy()
	if file.Exists("tttautobuyscriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA") then
		local itemstobuy = LinesToTable(file.Read("tttautobuyscriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA"))

		if itemstobuy[1] and #itemstobuy <= LocalPlayer():GetCredits() and not Autobought then
			Autobought = true

			local i = 1

			while i <= #itemstobuy do
				RunConsoleCommand("ttt_order_equipment", tostring(itemstobuy[i]))

				i = i + 1
			end

			AutobuyChat("You have received your equipment.")
		elseif Autobought then
			AutobuyChat("You allready used Autobuy this round.")
		else
			AutobuyChat("You have not enough credits.")
		end
	else
		AutobuyChat("You have no items selected or the round is not active.")
	end
end

-- Translation Vars
local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation
local SafeTranslate = LANG.TryTranslation

-- Buyable weapons are loaded automatically. Buyable items are defined in
-- equip_items_shd.lua

Equipment = Equipment or {}

function GetEquipmentForRole(role)
	-- need to build equipment cache?
	if next(Equipment) == nil then --if not Equipment then
		-- start with all the non-weapon goodies
		if not TTTRoles then
			-- Default Role Table from gamefreak (for compatibility)
			TTTRoles = TTTRoles or {
				[ROLE_INNOCENT] = {
					ID = ROLE_INNOCENT,
					Rolename = "Innocent",
					String = "innocent",
					IsGood = true,
					IsEvil = false,
					IsSpecial = false,
					Creditsforkills = false,
					ShortString = "inno",
					Short = "i",
					IsDefault = true,
					DefaultColor = Color(0, 255, 0),
					winning_team = WIN_INNOCENT,
					drawtargetidcircle = false,
					AllowTeamChat = false,
					RepeatingCredits = false,
					CanCollectCredits = false,
					HasShop = false
				},
				[ROLE_TRAITOR] = {
					ID = ROLE_TRAITOR,
					Rolename = "Traitor",
					String = "traitor",
					IsGood = false,
					IsEvil = true,
					IsSpecial = true,
					Creditsforkills = true,
					ShortString = "traitor",
					Short = "t",
					IsDefault = true,
					DefaultColor = Color(255, 0, 0),
					indicator_mat = Material("vgui/ttt/sprite_traitor"),
					winning_team = WIN_TRAITOR,
					drawtargetidcircle = true,
					targetidcolor = COLOR_RED,
					AllowTeamChat = true,
					RepeatingCredits = true,
					CanCollectCredits = true,
					HasShop = true
				},
				[ROLE_DETECTIVE] = {
					ID = ROLE_DETECTIVE,
					Rolename = "Detective",
					String = "detective",
					IsGood = true,
					IsEvil = false,
					IsSpecial = true,
					Creditsforkills = true,
					ShortString = "det",
					Short = "d",
					IsDefault = true,
					DefaultColor = Color(0, 0, 255),
					winning_team = WIN_INNOCENT,
					drawtargetidcircle = true,
					targetidcolor = COLOR_BLUE,
					AllowTeamChat = true,
					RepeatingCredits = false,
					CanCollectCredits = true,
					HasShop = true
				}
			}
		end

		local tbl = table.Copy(EquipmentItems)

		for k, v in pairs(TTTRoles) do
			if v.ShopFallBack then
				tbl[v.ID] = table.Copy(EquipmentItems[v.ShopFallBack])
			end
		end

		-- find buyable weapons to load info from
		for k, v in pairs(weapons.GetList()) do
			if v and v.CanBuy then
				local data = v.EquipMenuData or {}
				local base = {
					id = WEPS.GetClass(v),
					name = v.PrintName or "Unnamed",
					limited = v.LimitedStock,
					kind = v.Kind or WEAPON_NONE,
					slot = (v.Slot or 0) + 1,
					material = v.Icon or "vgui/ttt/icon_id",
					-- the below should be specified in EquipMenuData, in which case
					-- these values are overwritten
					type = "Type not specified",
					model = "models/weapons/w_bugbait.mdl",
					desc = "No description specified."
				}

				-- Force material to nil so that model key is used when we are
				-- explicitly told to do so (ie. material is false rather than nil).
				if data.modelicon then
					base.material = nil
				end

				table.Merge(base, data)

				-- add this buyable weapon to all relevant equipment tables
				for _, r in pairs(v.CanBuy) do
					table.insert(tbl[r], base)
					for _, v2 in pairs(TTTRoles) do
						if v2.ShopFallBack and v2.ShopFallBack == r then
							table.insert(tbl[v2.ID], base)
						end
					end
				end
			end
		end

		-- mark custom items
		for r, is in pairs(tbl) do
			for _, i in pairs(is) do
				if i and i.id then
					i.custom = not table.HasValue(DefaultEquipment[r], i.id)
				end
			end
		end

		Equipment = tbl
	end

	return Equipment and Equipment[role] or {}
end

function TTT2GetEquipmentForRole(role)
	local fallbackTable = GetShopFallbackTable(role)
	if fallbackTable then
		return fallbackTable
	end

	local fallback = GetShopFallback(role)

	-- need to build equipment cache?
	if not Equipment[fallback] then
		-- start with all the non-weapon goodies
		local tbl = table.Copy(EquipmentItems[fallback])

		-- find buyable weapons to load info from
		for _, v in ipairs(weapons.GetList()) do
			if v and not v.Doublicated and v.CanBuy and table.HasValue(v.CanBuy, fallback) then
				local data = v.EquipMenuData or {}
				local base = {
					id = WEPS.GetClass(v),
					name = v.ClassName or "Unnamed",
					PrintName = data.name or data.PrintName or v.PrintName or v.ClassName or "Unnamed",
					limited = v.LimitedStock,
					kind = v.Kind or WEAPON_NONE,
					slot = (v.Slot or 0) + 1,
					material = v.Icon or "vgui/ttt/icon_id",
					-- the below should be specified in EquipMenuData, in which case
					-- these values are overwritten
					type = "Type not specified",
					model = "models/weapons/w_bugbait.mdl",
					desc = "No description specified."
				}

				-- Force material to nil so that model key is used when we are
				-- explicitly told to do so (ie. material is false rather than nil).
				if data.modelicon then
					base.material = nil
				end

				table.Merge(base, data)
				table.insert(tbl, base)
			end
		end

		-- mark custom items
		for _, i in pairs(tbl) do
			if i and i.id then
				i.custom = not table.HasValue(DefaultEquipment[fallback], i.id) -- TODO
			end
		end

		Equipment[fallback] = tbl
	end

	return Equipment[fallback] or {}
end

-- functions (Select, Search, Sortate)
local function Select(Equip, Selection) -- !rework!
	if Selection then
		LastSelected = Selection
	else
		Selection = LastSelected or ""
	end

	if Selection == "" then
		NewEquip = Equip
	elseif Selection == "Autobuy" or Selection == "Favorite" then
		NewEquip = {}

		local itemstobuy = LinesToTable(file.Read("ttt" .. string.lower(Selection) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA"))

		if itemstobuy ~= nil then
			local i = 1
			local i2 = 1

			while i <= #itemstobuy do
				if tostring(itemstobuy[i]) == tostring(Equip[i2].id) then
					NewEquip[i] = Equip[i2]
					i = i + 1
					i2 = 1
				else
					i2 = i2 + 1
				end
			end
		end
	end

	return NewEquip
end

local function Search(Equip, Search) -- Search function new(test needed)
	if Search then
		LastSearched = Search
	else
		Search = LastSearched or ""
	end

	local items = {}

	for _, k in pairs(Equip) do
		if k and k["name"] and string.find(SafeTranslate(k["name"]):lower(), Search:lower()) then
			table.insert(items, k)
		end
	end

	return items
end

local function Sortate(Equip, Sortation) -- Sortate new (test needed)
	if Sortation then
		LastSortation = Sortation
	else
		Sortation = LastSortation or "Default"
	end

	if Sortation == "Slot" then
		PrintTable(Equip)

		local SortResult = {}
		local items = {}

		for _, k in pairs(Equip) do
			local slot = k.slot

			if not slot then
				slot = 0
			end

			if not items[slot] then
				items[slot] = {}
			end

			table.insert(items[slot], k)
		end

		for _, k in pairs(items) do
			for _, v in pairs(k) do
				table.insert(SortResult, v)
			end
		end

		NewEquip = SortResult
	elseif Sortation == "Default" then
		table.sort(Equip, function(a2, b2) -- debug wrong order
			local a = a2.id
			local b = b2.id

			if tonumber(a) and not tonumber(b) then
				return true
			elseif tonumber(b) and not tonumber(a) then
				return false
			else
				return a < b
			end
		end)

		NewEquip = Equip
	elseif Sortation == "Name" then
		local PreSortResult = {}

		for i, Inhalt in ipairs(Equip) do
			PreSortResult[string.lower(SafeTranslate(Inhalt.name))] = Inhalt
		end

		local Names = {}

		for Name in pairs(PreSortResult) do
			table.insert(Names, Name)
		end

		table.sort(Names)

		for i, Name in ipairs(Names) do
			NewEquip[i] = PreSortResult[Name]
		end
	elseif Sortation == "Origin" then
		for _, k in pairs(GetEquipmentForRole(ROLE_TRAITOR)) do
			for i, v in pairs(Equip) do
				if k.id == v.id then
					Equip[i].origin = "T"
				end
			end
		end

		for _, k in pairs(GetEquipmentForRole(ROLE_DETECTIVE)) do
			for i, v in pairs(Equip) do
				if k.id == v.id then
					if v.origin == "T" then
						Equip[i].origin = "B"
					else
						Equip[i].origin = "D"
					end
				end
			end
		end

		local function SortateOrigin(val)
			if val == "T" then
				return 4
			elseif val == "D" then
				return 3
			elseif val == "B" then
				return 2
			else
				return 1
			end
		end

		table.sort(Equip, function(a, b)
			return SortateOrigin(a.origin) > SortateOrigin(b.origin)
		end)

		NewEquip = Equip
	end

	return NewEquip
end

-- function for Autobuy and Favorite
local function IsItem(AutoOrFav, item) -- !rework!
	allreadySelected = false

	local itemstobuy = LinesToTable(file.Read("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA"))

	if file.Exists("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA") and itemstobuy[1] then
		local i = 1

		while i <= #itemstobuy do
			if tostring(itemstobuy[i]) == tostring(item.id) then
				i = #itemstobuy + 1
				allreadySelected = true
			end

			i = i + 1
		end
	end

	return allreadySelected
end

local function GetTooltipList(AutoOrFav) -- !rework!
	local Names = AutoOrFav .. " Items:\n none"
	local itemstobuy = LinesToTable(file.Read("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA"))

	if file.Exists("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA") then
		local i = 1
		local i2 = 1

		while i <= #itemstobuy do
			if EquipmentAll and EquipmentAll[i2] and tostring(itemstobuy[i]) == tostring(EquipmentAll[i2].id) then
				if i == 1 then
					Names = AutoOrFav .. " Items:\n" .. SafeTranslate(EquipmentAll[i2].name)
				else
					Names = Names .. "\n" .. SafeTranslate(EquipmentAll[i2].name)
				end

				i = i + 1
				i2 = 1
			else
				i2 = i2 + 1
			end
		end
	end

	return Names
end

--[[
local function IsKindSelected(item) -- TODO !rework!
	local KindSelected = false
	local itemstobuy = LinesToTable(file.Read("tttautobuyscriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA"))
	if not IsItem("Autobuy", item) then
		if file.Exists("tttautobuyscriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA") then
			local Kinds = {}
			local i = 1
			local i2 = 1
			while i <= #itemstobuy do
				if tostring(itemstobuy[i]) == tostring(EquipmentAll[i2].id) then
					Kinds[EquipmentAll[i2].kind] = true
					i = i + 1
					i2 = 1
				else
					i2 = i2 + 1
				end
			end
			if item and (not (item.kind == 0)) then
				if Kinds[item.kind] == true then
					KindSelected = true
				end
			end
		end
	end
	return KindSelected
end
]]--

local function EditList(AutoOrFav, item) -- !rework!
	if not file.Exists("ttt" .. string.lower(AutoOrFav) .. "scriptdata", "DATA") or not file.IsDir("ttt" .. string.lower(AutoOrFav) .. "scriptdata", "data") then
		file.CreateDir("ttt" .. string.lower(AutoOrFav) .. "scriptdata")
	end

	if IsItem(AutoOrFav, item) then
		local itemstobuy = LinesToTable(file.Read("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA"))

		file.Delete("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt")
		if itemstobuy[1] and item then
			local i = 1

			while i <= #itemstobuy do
				if tostring(itemstobuy[i]) ~= tostring(item.id) then
					file.Append("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", itemstobuy[i] .. "\n")
				end

				i = i + 1
			end
		end
	else
		file.Append("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", item.id .. "\n")
	end
end

local function UpdateFavorite(AddFavorite, item)
	if item then
		if IsItem("Favorite", item) then
			AddFavorite:SetText("Delete fr. Favourites")
		else
			AddFavorite:SetText("Add to Favourites")
		end
	else
		AddFavorite:SetEnabled(false)
	end
end

local function UpdateAutobuy(AddAutobuy, item)
	if item then
		if IsItem("Autobuy", item) then
			AddAutobuy:SetText("Delete fr. Autobuy")
		else
			AddAutobuy:SetText("Add to Autobuy")
		end
	else
		AddAutobuy:SetEnabled(false)
	end
end

local function DeleteMissingItems(AutoOrFav) -- Delete missing Items in saved lists !needs rework!
	local itemstobuy = LinesToTable(file.Read("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA"))
	local itemsloaded = GetEquipmentForRole(TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole())

	if TTT2 then
		itemsloaded = TTT2GetEquipmentForRole(TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole())
	end

	local i = 1
	local i2 = 1

	if file.Exists("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", "DATA") then
		local ItemsMissing = {}

		while i <= #itemstobuy do
			while i2 <= #itemsloaded and tostring(itemstobuy[i]) ~= tostring(itemsloaded[i2].id) do
				i2 = i2 + 1
			end

			if i2 > #itemsloaded then
				ItemsMissing[#ItemsMissing + 1] = i
			end

			i = i + 1
			i2 = 1
		end

		if 0 < #ItemsMissing then
			file.Delete("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt")

			local i3 = 1
			local i4 = 1

			while i3 <= #itemstobuy do
				if i3 ~= ItemsMissing[i4] then
					file.Append("ttt" .. string.lower(AutoOrFav) .. "scriptdata/selection" .. (TTT2 and LocalPlayer():GetSubRole() or not TTT2 and LocalPlayer():GetRole()) .. ".txt", itemstobuy[i3] .. "\n")
				elseif i4 < #ItemsMissing then
					i4 = i4 + 1
				end

				i3 = i3 + 1
			end
		end
	end
end

-- Fixed Description function
local function FixedDescription(v, item) -- (maybe rework)
	local Result = SafeTranslate(v)

	if fixedDesc[item.id] and FixedDescBool:GetBool() then -- fixed description ( #"\n" = 1 )
		local Text = SafeTranslate(v)
		local MaxLength = 40

		Result = ""

		while #Text > 0 do
			if #Text < MaxLength then
				Result = Result .. Text
				Text = ""
			elseif string.find(Text, "\n", 0) and (string.find(Text, "\n", 0) < MaxLength + 1) then
				local Paragraph = 0

				while string.find(Text, "\n", Paragraph + 1) and (string.find(Text, "\n", Paragraph + 1) < MaxLength + 1) do -- find last paragraph
					Paragraph = string.find(Text, "\n", Paragraph + 1)
				end

				Result = Result .. string.sub(Text, 1, Paragraph)
				Text = string.sub(Text, Paragraph + 1)
			elseif string.find(Text, " ", 0) < MaxLength + 1 then
				local Space = 0

				while string.find(Text, " ", Space + 1) and (string.find(Text, " ", Space + 1) < MaxLength + 1) do -- find last space
					Space = string.find(Text, " ", Space + 1)
				end

				Result = Result .. string.sub(Text, 1, Space - 1) .. "\n"
				Text = string.sub(Text, Space + 1)
			else
				Result = Result .. string.sub(Text, 1, MaxLength)
				Text = string.sub(Text, MaxLength + 1)
			end
		end
	end

	return Result
end

local function ItemIsWeapon(item)
	return not tonumber(item.id)
end

local function CanCarryWeapon(item)
	return LocalPlayer():CanCarryType(item.kind)
end

-- Creates tabel of labels showing the status of ordering prerequisites
local function PreqLabels(parent, x, y)
	local tbl = {}

	tbl.credits = vgui.Create("DLabel", parent)
	tbl.credits:SetTooltip(GetTranslation("equip_help_cost"))
	tbl.credits:SetPos(x, y)

	tbl.credits.Check = function(s, sel)
		local credits = LocalPlayer():GetCredits()

		return credits > 0, GetPTranslation("equip_cost", {num = credits})
	end

	tbl.owned = vgui.Create("DLabel", parent)
	tbl.owned:SetTooltip(GetTranslation("equip_help_carry"))
	tbl.owned:CopyPos(tbl.credits)
	tbl.owned:MoveBelow(tbl.credits, y)

	tbl.owned.Check = function(s, sel)
		local Weapons = {}
		local slot = "-"

		for i in pairs(LocalPlayer():GetWeapons()) do
			Weapons[i] = SafeTranslate(LocalPlayer():GetWeapons()[i]:GetPrintName())
		end

		for i in pairs(Weapons) do
			for i2 in pairs(EquipmentAll) do
				if SafeTranslate(EquipmentAll[i2]["name"]) == Weapons[i] and EquipmentAll[i2]["kind"] == sel.kind then
					slot = EquipmentAll[i2]["slot"]
				end
			end
		end

		if ItemIsWeapon(sel) and (not CanCarryWeapon(sel)) then
			return false, GetPTranslation("equip_carry_slot", {slot = sel.kind}) .. " (Visual " .. slot .. ")"
		elseif (not ItemIsWeapon(sel)) and LocalPlayer():HasEquipmentItem(sel.id) then
			return false, GetTranslation("equip_carry_own")
		else
			return true, GetTranslation("equip_carry")
		end

		-- TODO add MinPlayers + Limit + Price indicator
	end

	tbl.bought = vgui.Create("DLabel", parent)
	tbl.bought:SetTooltip(GetTranslation("equip_help_stock"))
	tbl.bought:CopyPos(tbl.owned)
	tbl.bought:MoveBelow(tbl.owned, y)

	tbl.bought.Check = function(s, sel)
		if sel.limited and LocalPlayer():HasBought(tostring(sel.id)) then
			return false, GetTranslation("equip_stock_deny")
		else
			return true, GetTranslation("equip_stock_ok")
		end
	end

	for _, pnl in pairs(tbl) do
		pnl:SetFont("TabLarge")
	end

	return function(selected)
		local allow = true

		for k, pnl in pairs(tbl) do
			local result, text = pnl:Check(selected)

			pnl:SetTextColor(result and StringToColor(color_good:GetString()) or StringToColor(color_bad:GetString()))
			pnl:SetText(text)
			pnl:SizeToContents()

			allow = allow and result
		end

		return allow
	end
end

-- quick, very basic override of DPanelSelect
local PANEL = {}

local function DrawSelectedEquipment(pnl)
	local Table = StringToColor(OutlineColor:GetString())

	surface.SetDrawColor(Table["r"], Table["g"], Table["b"], Table["a"]) --outline color
	surface.DrawOutlinedRect(0, 0, pnl:GetWide(), pnl:GetTall())
end

function PANEL:SelectPanel(pnl)
	self.BaseClass.SelectPanel(self, pnl)

	if pnl then
		pnl.PaintOver = DrawSelectedEquipment
	end
end
vgui.Register("EquipSelect", PANEL, "DPanelSelect")

-- TODO: make set of global role colour defs, these are same as wepswitch
local color_slot = {
	[ROLE_TRAITOR] = Color(180, 50, 40, 255), -- color slot
	[ROLE_DETECTIVE] = Color(50, 60, 180, 255)-- color slot
}

function AddRoleEquipColors(Role) -- For compatibillity with TTT Vote + Totem
	color_slot[Role.ID] = Role.DefaultColor
end

local eqframe = nil

-- Menu Popup
local function TraitorMenuPopup()
	-- set and reset variables
	local ply = LocalPlayer()

	EquipmentAll = nil

	SearchText = false
	FirstSort = nil
	LastSearched = false
	LastSortation = false
	LastSelected = false
	Selected = nil

	local role = TTT2 and ply:GetSubRole() or not TTT2 and ply:GetRole()

	if not ply:IsSpec() and not IsValid(ply) or not ((role and TTTRoles[role] and TTTRoles[role].HasShop) or ply:IsActiveShopper()) or not ply:IsTerror() then return end

	-- refresh Variables
	StandartSort = math.min(math.max(math.floor(StandartSortRaw:GetFloat()), 1), 3)
	if StandartSort == 1 then
		FirstSort = "Default"
	elseif StandartSort == 2 then
		FirstSort = "Name"
	else
		FirstSort = "Slot"
	end

	if TTT2 then
		EquipmentAll = TTT2GetEquipmentForRole(LocalPlayer():GetSubRole())
	else
		EquipmentAll = GetEquipmentForRole(LocalPlayer():GetRole())
	end

	local credits = ply:GetCredits()
	local can_order = credits > 0
	local IconSize = math.min(math.max(math.floor(IconSizeRaw:GetFloat()), 16), 1024)
	local i = 1

	while i * (IconSize + 2) < 252 do -- calculate min rows
		i = i + 1
	end

	local MinRows = i
	local Rows = math.min(math.max(math.floor(RowsRaw:GetFloat()), MinRows), 100)
	local Colums = math.min(math.max(math.floor(ColumsRaw:GetFloat()), 1), 100)
	local dlistw = Colums * (IconSize + 2) + 18

	if TTT2 and #EquipmentAll == 0 then
		ply:ChatPrint("[TTT2][SHOP] You need to run 'weaponshop' in the developer console to create a shop for this role. Link it with another shop or click on the icons to add weapons and items to the shop.")

		return
	end

	-- Close any existing traitor menu
	if eqframe and IsValid(eqframe) then
		eqframe:Close()
	end

	-- create frame
	local dframe = vgui.Create("DFrame")
	local w, h = 570 - 216 + dlistw, 79 + Rows * (IconSize + 2)

	dframe:SetSize(w, h)
	dframe:Center()
	dframe:SetTitle(GetTranslation("equip_title"))
	dframe:SetVisible(true)
	dframe:ShowCloseButton(true)
	dframe:SetMouseInputEnabled(true)
	dframe:SetDeleteOnClose(true)

	if StringToColor(WindowColor:GetString()) then
		dframe.Paint = function()
			draw.RoundedBox(4, 0, 0, dframe:GetWide(), dframe:GetTall(), StringToColor(WindowColor:GetString()))
		end
	end

	local m = 5

	-- create sheet
	local dsheet = vgui.Create("DPropertySheet", dframe)

	-- Add a callback when switching tabs
	local oldfunc = dsheet.SetActiveTab

	dsheet.SetActiveTab = function(self, new)
		if self.m_pActiveTab ~= new and self.OnTabChanged then
			self:OnTabChanged(self.m_pActiveTab, new)
		end

		oldfunc(self, new)
	end

	dsheet:SetPos(0, 0)
	dsheet:StretchToParent(m, m + 25, m, m)

	if StringToColor(TabColor:GetString()) then
		dsheet.Paint = function(self, w2, h2)
			draw.RoundedBox(5, 0, 21, w2, h2 - 21, StringToColor(TabColor:GetString()))
		end
	end

	local padding = dsheet:GetPadding()

	-- Crate panel
	local dequip = vgui.Create("DPanel", dsheet)
	dequip:SetPaintBackground(false)
	dequip:StretchToParent(padding, padding, padding, padding)

	-- Determine if we already have equipment
	local owned_ids = {}

	for _, wep in pairs(ply:GetWeapons()) do
		if IsValid(wep) and wep:IsEquipment() then
			table.insert(owned_ids, wep:GetClass())
		end
	end

	-- Stick to one value for no equipment
	if #owned_ids == 0 then
		owned_ids = nil
	end

	--- Construct icon listing
	-- Equip List
	local dlist = vgui.Create("EquipSelect", dequip)
	dlist:SetPos(0, 0)
	dlist:SetSize(dlistw, h - 75)
	dlist:EnableVerticalScrollbar(true)
	dlist:EnableHorizontal(true)
	dlist:SetPadding(4)

	local function dlistwriting(Sortation, search, sel)
		if dlist then
			dlist:Clear()
		end

		local items = Select(Search(Sortate(EquipmentAll, Sortation), search), sel)

		for k, item in pairs(items) do -- do for every item
			local ic = nil

			-- Create icon panel with markers
			if item.material then
				if FavoriteOn:GetBool() and IsItem("Favorite", item) then
					-- Favorite icon
					ic = vgui.Create("LayeredIcon", dlist)

					local favouritemarker = vgui.Create("DImage")
					favouritemarker:SetImage("html/img/favourite.png")

					favouritemarker.PerformLayout = function(s)
						s:AlignTop(2)
						s:AlignRight(2)
						s:SetSize(16, 16)
					end

					favouritemarker:SetTooltip("This is a favorite item.")

					ic:AddLayer(favouritemarker)
					ic:EnableMousePassthrough(favouritemarker)
				elseif not((SlotOn:GetBool() and ItemIsWeapon(item)) or (AutobuyOn:GetBool() and IsItem("Autobuy", item)) or (CustomOn:GetBool() and item.custom)) then
					ic = vgui.Create("SimpleIcon", dlist)
				else
					ic = vgui.Create("LayeredIcon", dlist)
				end

				if item.custom and CustomOn:GetBool() then
					-- Custom marker icon
					local marker = vgui.Create("DImage")
					marker:SetImage("vgui/ttt/custom_marker")

					marker.PerformLayout = function(s)
						s:AlignBottom(2)
						s:AlignRight(2)
						s:SetSize(16, 16)
					end

					marker:SetTooltip(GetTranslation("equip_custom"))

					ic:AddLayer(marker)
					ic:EnableMousePassthrough(marker)
				end

				if ItemIsWeapon(item) and SlotOn:GetBool() then
					-- Slot marker icon
					local slot = vgui.Create("SimpleIconLabelled")
					slot:SetIcon("vgui/ttt/slotcap")

					local color = color_slot[TTT2 and ply:GetSubRole() or not TTT2 and ply:GetRole()]

					if ply.GetSubRoleData and ply:GetSubRoleData().color then
						color = ply:GetSubRoleData().color or Color(60, 60, 60)
					end

					slot:SetIconColor(color)
					slot:SetIconSize(16)
					slot:SetTooltip("Slot: " .. item.kind .. " Visual slot: " .. item.slot)
					slot:SetIconText(item.slot)
					slot:SetIconProperties(StringToColor(SlotTextColor:GetString()), "DefaultBold", {opacity = 220, offset = 1}, {10, 8})

					ic:AddLayer(slot)
					ic:EnableMousePassthrough(slot)
				end

				if AutobuyOn:GetBool() and IsItem("Autobuy", item) then
					-- Autobuy marker icon
					local autobuymarker = vgui.Create("DImage")
					autobuymarker:SetImage("html/img/addons.png")

					autobuymarker.PerformLayout = function(s)
						s:AlignBottom(2)
						s:AlignLeft(2)
						s:SetSize(16, 16)
					end

					autobuymarker:SetTooltip("This item is added to the autobuy.")

					ic:AddLayer(autobuymarker)
					ic:EnableMousePassthrough(autobuymarker)
				end

				ic:SetIconSize(IconSize)
				ic:SetIcon(item.material)
			elseif item.model then
				ic = vgui.Create("SpawnIcon", dlist)
				ic:SetModel(item.model)
			elseif item then
				ErrorNoHalt("Equipment item does not have model or material specified: " .. tostring(item) .. "\n")
			end

			ic.item = item

			if not item.kind then
				item.kind = 0
			end

			local tip = SafeTranslate(item.name) .. " (" .. SafeTranslate(item.type) .. ")"

			ic:SetTooltip(tip)

			-- If we cannot order this item, darken it
			can_order = credits > 0

			if ((not can_order) or
				-- already owned
				table.HasValue(owned_ids, item.id) or
				(tonumber(item.id) and ply:HasEquipmentItem(tonumber(item.id))) or
				-- already carrying a weapon for this slot
				(ItemIsWeapon(item) and (not CanCarryWeapon(item))) or
				-- already bought the item before
				(item.limited and ply:HasBought(tostring(item.id)))
			) then -- TODO add minPlayers
				ic:SetIconColor(StringToColor(color_darkened:GetString()))
			end

			dlist:AddPanel(ic)
		end

		-- Information what is shown
		local InfoBox = vgui.Create("ColoredBox", dequip)
		InfoBox:SetColor(StringToColor(BoxColor:GetString()))-- Box color
		InfoBox:SetPos(dlistw + 5, h - 75 - 54)
		InfoBox:SetSize(100, 25)

		local InfoText = vgui.Create("DLabel", dequip)
		InfoText:SetPos(dlistw + 12, h - 75 - 55)
		InfoText:SetSize(95, 25)
		InfoText:SetFont("DermaDefault")
		InfoText:SetColor(StringToColor(FilterTextColor:GetString()))

		local Text = "Filter: "

		if Selected and Selected ~= "" then
			Text = Text .. Selected
		else
			Text = Text .. "None"
		end

		InfoText:SetText(Text)

		-- couple panelselect with info
		if to_select or dlist:GetItems()[1] then
			dlist:SelectPanel(to_select or dlist:GetItems()[1])
		else
			dlist.OnActivePanelChanged()
		end
	end -- end dlistwriting function

	dlistwriting(FirstSort)

	-- positioning vars !rework positioning in general!
	local bw, bh = 100, 25
	local verschiebung = 30 * 2
	local dih = h - bh - m * 5
	local diw = w - dlistw - m * 6 - 2

	local dinfobg = vgui.Create("DPanel", dequip)
	dinfobg:SetPaintBackground(false)
	dinfobg:SetSize(diw, dih)
	dinfobg:SetPos(dlistw + m, 0)

	local dinfo = vgui.Create("ColoredBox", dinfobg)
	dinfo:SetColor(StringToColor(BoxColor:GetString()))-- Box color
	dinfo:SetPos(0, verschiebung)
	dinfo:SetSize(diw, dih - 250)

	local dinfolist = vgui.Create("DScrollPanel", dinfo)
	dinfolist:StretchToParent(0, 0, 0, 0)

	local dhelp = vgui.Create("ColoredBox", dinfobg)
	dhelp:SetColor(StringToColor(BoxColor:GetString()))-- box color
	dhelp:StretchToParent(0, verschiebung, 0, dih - 100 - verschiebung)
	dhelp:MoveBelow(dinfo, m)
	dhelp:SizeToContents()

	local update_preqs = PreqLabels(dhelp, m * 3, m * 2)

	-- Search Bar
	local TextEntry = vgui.Create("DTextEntry", dinfobg)
	TextEntry:SetPos(0, 0)
	TextEntry:SetSize(191, 25)
	TextEntry:SetText("Search")
	TextEntry:SetTooltip("Searches items")

	TextEntry.OnTextChanged = function(self)
		SearchText = self:GetValue()
		dlistwriting(nil, SearchText)
	end

	TextEntry.OnGetFocus = function()
		TextEntry:SetText("")
	end

	local XButton = vgui.Create("DButton", dinfobg) -- Button at search bar
	XButton:SetPos(192, 0)
	XButton:SetSize(19, 25)
	XButton:SetText("X")
	XButton:SetTooltip("Deletes the content of the search bar")

	XButton.DoClick = function()
		TextEntry:SetText("Search")

		SearchText = ""

		dlistwriting(nil, SearchText)
	end

	-- Buttons
	local dconfirm = vgui.Create("DButton", dinfobg) -- Confirm buying
	dconfirm:SetPos(0, dih - bh * 2 + 1)
	dconfirm:SetSize(bw, bh)
	dconfirm:SetEnabled(false)
	dconfirm:SetTooltip("Buys the selected item")
	dconfirm:SetText(GetTranslation("equip_confirm"))

	local AddAutobuy = vgui.Create("DButton", dinfobg) -- Add to/remove from Autobuy
	AddAutobuy:SetPos(110, dih - bh * 2 + 1)
	AddAutobuy:SetSize(bw, bh)
	AddAutobuy:SetTooltip(GetTooltipList("Autobuy"))

	local AddFavorite = vgui.Create("DButton", dinfobg) -- Add to/remove from Favourite
	AddFavorite:SetPos(110, dih - bh * 2 - 29)
	AddFavorite:SetSize(bw, bh)
	AddFavorite:SetTooltip(GetTooltipList("Favourite"))

	Selected = false

	local Filter = vgui.Create("DButton", dinfobg)
	Filter:SetPos(222, dih - bh * 2 - 29)
	Filter:SetSize(bw, bh)
	Filter:SetTooltip("Filters items")
	Filter:SetText("Show Favorites")

	Filter.DoClick = function()
		if LastSelected == "Autobuy" then
			Selected = ""

			Filter:SetText("Show Favorites")
		elseif LastSelected == "Favorite" then
			Selected = "Autobuy"

			Filter:SetText("Show All")
		else
			Selected = "Favorite"

			Filter:SetText("Show Autobuy")
		end

		dlistwriting(nil, nil, Selected)
	end

	local dcancel = vgui.Create("DButton", dframe) -- Cancel button
	dcancel:SetPos(w - 14 - bw, h - bh - 16)
	dcancel:SetSize(bw, bh)
	dcancel:SetDisabled(false)
	dcancel:SetTooltip("Closes this window")
	dcancel:SetText(GetTranslation("close"))

	dcancel.DoClick = function()
		dframe:Close()
	end

	local dSearchActive = vgui.Create("DButton", dinfobg) -- keybord on
	dSearchActive:SetPos(222, 0)
	dSearchActive:SetSize(bw, bh)

	local inputEnabled = false
	dSearchActive:SetText("Keyboard on")
	dSearchActive:SetTooltip("Toggles the keyboard between EQMenu and Gameplay")

	dSearchActive.DoClick = function ()
		if inputEnabled then
			inputEnabled = false
			SearchText = ""

			dlistwriting()

			TextEntry:SetText("Search")
			dSearchActive:SetText("Keyboard on")
			dframe:SetKeyboardInputEnabled(false)
		else
			inputEnabled = true

			dframe:SetKeyboardInputEnabled(true)
			TextEntry:RequestFocus()
			dSearchActive:SetText("Keyboard off")
		end
	end

	local dSortByName = vgui.Create("DButton", dinfobg) -- Sortation Buttons
	dSortByName:SetTooltip("Sorts the items by Name")
	dSortByName:SetPos(111, 30)
	dSortByName:SetSize(bw, bh)
	dSortByName:SetText("Sort by Name")

	dSortByName.DoClick = function()
		dlistwriting("Name")
	end

	local dSortByID = vgui.Create("DButton", dinfobg)
	dSortByID:SetTooltip("Sorts the items by ID")
	dSortByID:SetPos(0, 30)
	dSortByID:SetSize(bw, bh)
	dSortByID:SetText("Sort by Default")

	dSortByID.DoClick = function()
		dlistwriting("Default")
	end

	local dSortBySlot = vgui.Create("DButton", dinfobg)
	dSortBySlot:SetTooltip("Sorts the items by Slot")
	dSortBySlot:SetPos(222, 30)
	dSortBySlot:SetSize(bw, bh)
	dSortBySlot:SetText("Sort by Slot")

	dSortBySlot.DoClick = function()
		dlistwriting("Slot")
	end

	-- add sheets
	-- Shop
	dsheet:AddSheet(GetTranslation("equip_tabtitle"), dequip, "icon16/bomb.png", false, false, "Traitor equipment menu")

	-- Item control
	if ply:HasEquipmentItem(EQUIP_RADAR) then
		local dradar = RADAR.CreateMenu(dsheet, dframe)

		dsheet:AddSheet(GetTranslation("radar_name"), dradar, "icon16/magnifier.png", false, false, "Radar control")
	end

	if ply:HasEquipmentItem(EQUIP_DISGUISE) then
		local ddisguise = DISGUISE.CreateMenu(dsheet)

		dsheet:AddSheet(GetTranslation("disg_name"), ddisguise, "icon16/user.png", false, false, "Disguise control")
	end

	-- Weapon/item control
	if IsValid(ply.radio) or ply:HasWeapon("weapon_ttt_radio") then
		local dradio = TRADIO.CreateMenu(dsheet)

		dsheet:AddSheet(GetTranslation("radio_name"), dradio, "icon16/transmit.png", false, false, "Radio control")
	end

	-- Credit transferring
	if credits > 0 then
		local dtransfer = CreateTransferMenu(dsheet)

		dsheet:AddSheet(GetTranslation("xfer_name"), dtransfer, "icon16/group_gear.png", false, false, "Transfer credits")
	end

	hook.Run("TTTEquipmentTabs", dsheet)

	dlist.OnActivePanelChanged = function(self, _, new)
		--dinfolist writing
		dinfolist:Clear()

		local dfields = {}

		for _, k in pairs({"name", "type", "desc"}) do
			dfields[k] = vgui.Create("DLabel")
			dfields[k]:SetTooltip(GetTranslation("equip_spec_" .. k))
			dfields[k]:SetPos(m * 3, m * 2)
			dinfolist:AddItem(dfields[k])
		end

		dfields.name:SetFont("TabLarge")
		dfields.name:SetColor(NameTextColor)

		dfields.type:SetColor(StringToColor(TypeTextColor:GetString()))
		dfields.type:SetFont("DermaDefault")
		dfields.type:MoveBelow(dfields.name)

		dfields.desc:SetContentAlignment(7)
		dfields.desc:MoveBelow(dfields.type, 1)

		if FixedDescBool:GetBool() and new then
			dfields["Button"] = vgui.Create("DButton") -- Button in list

			if fixedDesc[new.item.id] then
				dfields.desc:SetFont("DebugFixed")-- monospaced font

				dfields["Button"]:SetText("Default description")
				dfields["Button"]:SetTooltip("Shows the default description (looks a bit better)")
			else
				dfields.desc:SetFont("DermaDefaultBold")

				dfields["Button"]:SetText("Fixed description")
				dfields["Button"]:SetTooltip("Shows the fixed desfixed description (to avoid too long rows)")
			end
			dfields.desc:SetColor(StringToColor(DescriptionTextColor:GetString()))

			dfields["Button"]:SetSize(bw, bh)
			dfields["Button"]:SetPos(dinfolist:GetSize() - bw - m * 3, m * 2)

			dinfolist:AddItem(dfields["Button"])

			dfields["Button"].DoClick = function()
				if fixedDesc[new.item.id] then
					fixedDesc[new.item.id] = false
				else
					fixedDesc[new.item.id] = true
				end
				dlist:SelectPanel(new) --refresh
			end
		end

		if new then
			for k, v in pairs(new.item) do
				if dfields[k] then -- fixed description
					if k == "desc" then
						local Result = FixedDescription(v, new.item)

						dfields[k]:SetText(Result .. "\n")--"\n" for better design in scroll panel
					else
						dfields[k]:SetText(SafeTranslate(v))
					end

					dfields[k]:SizeToContents()
				end
			end

			UpdateAutobuy(AddAutobuy, new.item)
			UpdateFavorite(AddFavorite, new.item)

			can_order = update_preqs(new.item)

			dconfirm:SetDisabled(not can_order)
		else -- if no item selected
			dfields["name"]:SetText("none")
			dfields["type"]:SetText("none")
			dfields["desc"]:SetText("none\n")

			dfields["name"]:SizeToContents()
			dfields["type"]:SizeToContents()
			dfields["desc"]:SizeToContents()

			dconfirm:SetDisabled(true)
		end
	end

	-- select first
	if not to_select then
		dlist:SelectPanel(dlist:GetItems()[1])
	end

	-- prep confirm action and add/delete autobuy/favorite
	dconfirm.DoClick = function()
		local pnl = dlist.SelectedPanel

		if not pnl or not pnl.item then return end

		local choice = pnl.item

		RunConsoleCommand("ttt_order_equipment", choice.id)

		dframe:Close()
	end

	AddFavorite.DoClick = function()
		EditList("Favorite", dlist.SelectedPanel.item)
		dlistwriting()
	end

	AddAutobuy.DoClick = function()
		EditList("Autobuy", dlist.SelectedPanel.item)
		dlistwriting()
	end

	-- update some basic info, may have changed in another tab
	-- specifically the number of credits in the preq list
	dsheet.OnTabChanged = function(s, old, new)
		if not IsValid(new) then return end

		if new:GetPanel() == dequip then
			can_order = update_preqs(dlist.SelectedPanel.item)

			dconfirm:SetDisabled(not can_order)
		end
	end

	dframe:MakePopup()
	dframe:SetKeyboardInputEnabled(false)

	eqframe = dframe
end
concommand.Add("ttt_cl_traitorpopup", TraitorMenuPopup)

local function ForceCloseTraitorMenu(ply, cmd, args)
	if IsValid(eqframe) then
		eqframe:Close()
	end
end
concommand.Add("ttt_cl_traitorpopup_close", ForceCloseTraitorMenu)

function GM:OnContextMenuOpen()
	local r = GetRoundState()

	if r == ROUND_ACTIVE and not LocalPlayer():IsSpecial() then
		return
	elseif r == ROUND_POST or r == ROUND_PREP then
		if CLSCORE.Reopen then
			CLSCORE:Reopen()
		else
			CLSCORE:Toggle()
		end

		return
	end

	local CloseByPressCAgain = CloseByPressCAgainRaw:GetBool()

	if eqframe and IsValid(eqframe) and CloseByPressCAgain then
		ForceCloseTraitorMenu(LocalPlayer())
	else
		RunConsoleCommand("ttt_cl_traitorpopup")
	end
end

local function ReceiveEquipment()
	local ply = LocalPlayer()

	if not IsValid(ply) then return end

	ply.equipment_items = net.ReadUInt(16)
end
net.Receive("TTT_Equipment", ReceiveEquipment)

local function ReceiveCredits()
	local ply = LocalPlayer()

	if not IsValid(ply) then return end

	ply.equipment_credits = net.ReadUInt(8)
end
net.Receive("TTT_Credits", ReceiveCredits)

local r = 0
local function ReceiveBought()
	local ply = LocalPlayer()

	if not IsValid(ply) then return end

	ply.bought = {}

	local num = net.ReadUInt(8)

	for i = 1, num do
		local s = net.ReadString()

		if s ~= "" then
			table.insert(ply.bought, s)
		end
	end

	-- This usermessage sometimes fails to contain the last weapon that was
	-- bought, even though resending then works perfectly. Possibly a bug in
	-- bf_read. Anyway, this hack is a workaround: we just request a new umsg.
	if num ~= #ply.bought and r < 10 then -- r is an infinite loop guard
		RunConsoleCommand("ttt_resend_bought")

		r = r + 1
	else
		r = 0
	end
end
net.Receive("TTT_Bought", ReceiveBought)

-- Player received the item he has just bought, so run clientside init
local function ReceiveBoughtItem()
	local is_item = net.ReadBit() == 1
	local id = is_item and net.ReadUInt(16) or net.ReadString()

	-- I can imagine custom equipment wanting this, so making a hook
	hook.Run("TTTBoughtItem", is_item, id)
end
net.Receive("TTT_BoughtItem", ReceiveBoughtItem)

concommand.Add("autobuy", function()
	Autobuy()
end)

hook.Add("TTTBeginRound", "TTTBeginRound4TTTBetterTraitorMenu", function()
	ForceCloseTraitorMenu(LocalPlayer())

	Autobought = false

	DeleteMissingItems("Autobuy")
	DeleteMissingItems("Favorite")

	if AutobuyRoundbegin:GetBool() then
		Autobuy()
	end
end)

-- Settings Tab
-- functions
local function ColorSettings(Name, tbl, a, Parent, MixerColor, ConVar)
	tbl[Name] = {}
	tbl[Name].Text = test
	tbl[Name].Text = vgui.Create("DLabel")
	tbl[Name].Text:SetText(Name .. ":")
	tbl[Name].Text:SetColor(Color(0, 0, 0))

	Parent:AddItem(tbl[Name].Text)

	tbl[Name].Mixer = vgui.Create("DColorMixer")

	if StringToColor(MixerColor:GetString()) then
		local FixedColor = StringToColor(MixerColor:GetString())

		if not StringToColor(MixerColor:GetString())["a"] then
			FixedColor["a"] = 0
		end

		tbl[Name].Mixer:SetColor(FixedColor)
	else
		tbl[Name].Mixer:SetColor(Color(0, 0, 0, 255))
	end

	tbl[Name].Mixer:SetSize(250, 150)
	tbl[Name].Mixer:SetPalette(true)
	tbl[Name].Mixer:SetAlphaBar(a)
	tbl[Name].Mixer:SetWangs(true)

	Parent:AddItem(tbl[Name].Mixer)

	tbl[Name].Confirm = vgui.Create("DButton")
	tbl[Name].Confirm:SetText("Confirm")
	tbl[Name].Confirm:SetSize(250, 25)

	tbl[Name].Confirm.DoClick = function()
		local FixedColorResult = tbl[Name].Mixer:GetColor()

		if not a then
			FixedColorResult["a"] = nil
		end

		RunConsoleCommand(ConVar, ColorToString(FixedColorResult))
	end

	Parent:AddItem(tbl[Name].Confirm)
end

-- hook for Settings -- rework: use more functions!
hook.Add("TTTSettingsTabs", "TTTSettingsTab4TTTBetterTraitorMenu", function(dtabs)
	local settings_panel = vgui.Create("DPanelList", dtabs)
	settings_panel:StretchToParent(0, 0, dtabs:GetPadding() * 2, 0)
	settings_panel:EnableVerticalScrollbar(true)
	settings_panel:SetPadding(10)
	settings_panel:SetSpacing(10)

	dtabs:AddSheet("Equipment menu", settings_panel, "icon16/cog.png", false, false, "Equipment menu settings")

	local AddonList = vgui.Create("DIconLayout", settings_panel)
	AddonList:SetSpaceX(5)
	AddonList:SetSpaceY(5)
	AddonList:Dock(FILL)
	AddonList:DockMargin(5, 5, 5, 5)
	AddonList:DockPadding(10, 10, 10, 10)

	local General_Settings = vgui.Create("DForm")
	General_Settings:SetSpacing(10)
	General_Settings:SetName("General settings")
	General_Settings:SetWide(settings_panel:GetWide() - 30)

	settings_panel:AddItem(General_Settings)

	General_Settings:CheckBox("Print chat message at the beginning of the round (TTT FG Addons)", "ttt_fgaddons_textmessage")

	local Settings_text = vgui.Create("DLabel")
	Settings_text:SetText("Standart order:")
	Settings_text:SetColor(Color(0, 0, 0))

	General_Settings:AddItem(Settings_text)

	local Settings_box = vgui.Create("DComboBox")
	Settings_box:Clear()
	Settings_box:SetValue(FirstSort)
	Settings_box:AddChoice("Default")
	Settings_box:AddChoice("Name")
	Settings_box:AddChoice("Slot")

	General_Settings:AddItem(Settings_box)

	function Settings_box:OnSelect(table_box, sort, data_box)
		if sort == "Default" then
			RunConsoleCommand("ttt_bettermenu_defaultorder", "1")
		elseif sort == "Name" then
			RunConsoleCommand("ttt_bettermenu_defaultorder", "2")
		elseif sort == "Slot" then
			RunConsoleCommand("ttt_bettermenu_defaultorder", "3")
		end
	end

	General_Settings:CheckBox("Close menu by pressing C when its open", "ttt_bettermenu_closebypressc")
	General_Settings:CheckBox("Show fixed description button", "ttt_bettermenu_fixeddesc")
	General_Settings:CheckBox("Enables or disables if autobuy should be runed on the beginning of every round.", "ttt_bettermenu_autobuy_roundbegin")
	General_Settings:CheckBox("Print chat messages when the autobuy is used (works after map change/restart)", "ttt_bettermenu_autobuymessage")

	local Icon_Settings = vgui.Create("DForm")
	Icon_Settings:SetSpacing(10)
	Icon_Settings:SetName("Icon settings")
	Icon_Settings:SetWide(settings_panel:GetWide() - 30)

	settings_panel:AddItem(Icon_Settings)

	Icon_Settings:NumSlider("Size", "ttt_bettermenu_iconsize", 16, 1024, 0)
	Icon_Settings:NumSlider("Rows", "ttt_bettermenu_rows", 1, 100, 0)
	Icon_Settings:NumSlider("Colums", "ttt_bettermenu_colums", 1, 100, 0)

	local Marker_Settings = vgui.Create("DForm")
	Marker_Settings:SetSpacing(10)
	Marker_Settings:SetName("Marker settings")
	Marker_Settings:SetWide(settings_panel:GetWide() - 30)
	Marker_Settings:CheckBox("Show custom marker", "ttt_bettermenu_custommarker")
	Marker_Settings:CheckBox("Show autobuy marker", "ttt_bettermenu_autobuymarker")
	Marker_Settings:CheckBox("Show favorite marker", "ttt_bettermenu_favoritemarker")
	Marker_Settings:CheckBox("Show slot marker", "ttt_bettermenu_slotmarker")

	settings_panel:AddItem(Marker_Settings)

	local Settings_Colors = vgui.Create("DForm")
	Settings_Colors:SetSpacing(10)
	Settings_Colors:SetName("Colors")
	Settings_Colors:SetWide(Marker_Settings:GetWide() - 30)

	settings_panel:AddItem(Settings_Colors)

	local Colors_Preset = vgui.Create("DLabel", General_Settings)
	Colors_Preset:SetText("Presets: ")
	Colors_Preset:SetColor(Color(0, 0, 0))

	Settings_Colors:AddItem(Colors_Preset)

	-- Presets here
	local DefaultColors = vgui.Create("DButton")
	DefaultColors:SetText("Default")
	DefaultColors:SetSize(250, 25)

	DefaultColors.DoClick = function()
		RunConsoleCommand("ttt_bettermenu_colors_window", "nil")
		RunConsoleCommand("ttt_bettermenu_colors_tab", "nil")
		RunConsoleCommand("ttt_bettermenu_colors_box", ColorToString(Color(90, 90, 95)))
		RunConsoleCommand("ttt_bettermenu_colors_text_title", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_type", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_description", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_filter", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_good", ColorToString(Color(0, 200, 0, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_bad", ColorToString(Color(220, 60, 60, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_slotcap", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_item_outline", ColorToString(Color(255, 200, 0, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_item_darkened", ColorToString(Color(255, 255, 255, 80)))
	end

	Settings_Colors:AddItem(DefaultColors)

	local Preset1 = vgui.Create("DButton")
	Preset1:SetText("Preset 1 (Transparent)")
	Preset1:SetSize(250, 25)

	Preset1.DoClick = function()
		RunConsoleCommand("ttt_bettermenu_colors_window", ColorToString(Color(0, 0, 0, 90)))
		RunConsoleCommand("ttt_bettermenu_colors_tab", ColorToString(Color(245, 245, 245, 90)))
		RunConsoleCommand("ttt_bettermenu_colors_box", ColorToString(Color(90, 90, 95)))
		RunConsoleCommand("ttt_bettermenu_colors_text_title", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_type", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_description", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_filter", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_good", ColorToString(Color(0, 200, 0, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_bad", ColorToString(Color(220, 60, 60, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_slotcap", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_item_outline", ColorToString(Color(255, 200, 0, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_item_darkened", ColorToString(Color(255, 255, 255, 80)))
	end

	Settings_Colors:AddItem(Preset1)

	local Preset2 = vgui.Create("DButton")
	Preset2:SetText("Preset 2 (Alternative)")
	Preset2:SetSize(250, 25)

	Preset2.DoClick = function()
		RunConsoleCommand("ttt_bettermenu_colors_window", ColorToString(Color(0, 0, 0, 90)))
		RunConsoleCommand("ttt_bettermenu_colors_tab", ColorToString(Color(245, 245, 245, 90)))
		RunConsoleCommand("ttt_bettermenu_colors_box", ColorToString(Color(0, 0, 0)))
		RunConsoleCommand("ttt_bettermenu_colors_text_title", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_type", ColorToString(Color(255, 255, 255, 100)))
		RunConsoleCommand("ttt_bettermenu_colors_text_description", ColorToString(Color(255, 255, 255, 50)))
		RunConsoleCommand("ttt_bettermenu_colors_text_filter", ColorToString(Color(255, 255, 255, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_good", ColorToString(Color(0, 175, 0, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_bad", ColorToString(Color(255, 70, 70, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_text_slotcap", ColorToString(Color(255, 255, 255, 150)))
		RunConsoleCommand("ttt_bettermenu_colors_item_outline", ColorToString(Color(255, 200, 0, 255)))
		RunConsoleCommand("ttt_bettermenu_colors_item_darkened", ColorToString(Color(100, 100, 240, 150)))
	end

	Settings_Colors:AddItem(Preset2)

	local Colors_Manual = vgui.Create("DLabel", General_Settings)
	Colors_Manual:SetText("Manual: ")
	Colors_Manual:SetColor(Color(0, 0, 0))

	Settings_Colors:AddItem(Colors_Manual)

	local Color_Settings = {}

	ColorSettings("Window", Color_Settings, true, Settings_Colors, WindowColor, "ttt_bettermenu_colors_window")
	ColorSettings("Tab", Color_Settings, true, Settings_Colors, TabColor, "ttt_bettermenu_colors_tab")
	ColorSettings("Boxes", Color_Settings, false, Settings_Colors, BoxColor, "ttt_bettermenu_colors_box")
	ColorSettings("Title", Color_Settings, false, Settings_Colors, TitleTextColor, "ttt_bettermenu_colors_text_title")
	ColorSettings("Type", Color_Settings, false, Settings_Colors, TypeTextColor, "ttt_bettermenu_colors_text_type")
	ColorSettings("Description", Color_Settings, true, Settings_Colors, DescriptionTextColor, "ttt_bettermenu_colors_text_description")
	ColorSettings("Filter", Color_Settings, true, Settings_Colors, FilterTextColor, "ttt_bettermenu_colors_text_filter")
	ColorSettings("Good Text", Color_Settings, true, Settings_Colors, color_good, "ttt_bettermenu_colors_text_good")
	ColorSettings("Bad Text", Color_Settings, true, Settings_Colors, color_bad, "ttt_bettermenu_colors_text_bad")
	ColorSettings("Slotcap Text", Color_Settings, true, Settings_Colors, SlotTextColor, "ttt_bettermenu_colors_text_slotcap")
	ColorSettings("Icon Outline", Color_Settings, true, Settings_Colors, OutlineColor, "ttt_bettermenu_colors_item_outline")
	ColorSettings("Icon Darkened", Color_Settings, true, Settings_Colors, color_darkened, "ttt_bettermenu_colors_item_darkened")

	local Version_text = vgui.Create("DLabel", General_Settings)

	if TTT2 then
		Version_text:SetText("Version: " .. Version .. " (TTT2 Compatibility mode) by Fresh Garry")
	else
		Version_text:SetText("Version: " .. Version .. " by Fresh Garry")
	end

	Version_text:SetColor(Color(100, 100, 100))
	settings_panel:AddItem(Version_text)
end)

-- weaponshop
if TTT2 then
	function GetEquipmentForRoleAll()
		-- need to build equipment cache?
		if not Equipmentnew then
			-- start with all the non-weapon goodies
			local tbl = ALL_ITEMS
			local eject = {
				"weapon_fists",
				"weapon_ttt_unarmed",
				"weapon_zm_carry",
				"bobs_blacklisted"
			}

			hook.Run("TTT2ModifyWepShopIgnoreWeps", eject) -- possibility to modify from externally

			-- find buyable weapons to load info from
			for _, v in ipairs(weapons.GetList()) do
				if v and not v.Doublicated and not string.match(v.ClassName, "base") and not string.match(v.ClassName, "event") and not table.HasValue(eject, v.ClassName) then
					local data = v.EquipMenuData or {}
					local base = {
						id = v.ClassName,
						name = v.ClassName or "Unnamed",
						PrintName = data.name or data.PrintName or v.PrintName or v.ClassName or "Unnamed",
						limited = v.LimitedStock,
						kind = v.Kind or WEAPON_NONE,
						slot = (v.Slot or 0) + 1,
						material = v.Icon or "vgui/ttt/icon_id",
						-- the below should be specified in EquipMenuData, in which case
						-- these values are overwritten
						type = "Type not specified",
						model = "models/weapons/w_bugbait.mdl",
						desc = "No description specified."
					}

					-- Force material to nil so that model key is used when we are
					-- explicitly told to do so (ie. material is false rather than nil).
					if data.modelicon then
						base.material = nil
					end

					table.Merge(base, data)
					table.insert(tbl, base)
				end
			end

			Equipmentnew = tbl
		end

		return Equipmentnew
	end

	local function WeaposhopPopup()
		-- set and reset variables
		local EquipmentT = GetEquipmentForRole(ROLE_TRAITOR)
		local EquipmentD = GetEquipmentForRole(ROLE_DETECTIVE)
		local state = false
		local mode = false

		EquipmentAll = nil
		SearchText = false
		FirstSort = nil
		LastSearched = false
		LastSortation = false
		LastSelected = false
		Selected = nil

		local sr = GetShopRoles()[1]

		-- refresh Variables
		StandartSort = math.min(math.max(math.floor(StandartSortRaw:GetFloat()), 1), 3)
		FirstSort = nil

		if StandartSort == 1 then
			FirstSort = "Default"
		elseif StandartSort == 2 then
			FirstSort = "Name"
		else
			FirstSort = "Slot"
		end

		SearchText = false
		EquipmentAll = GetEquipmentForRoleAll()

		local IconSize = math.min(math.max(math.floor(IconSizeRaw:GetFloat()), 16), 1024)
		local i = 1

		while i * (IconSize + 2) < 252 do -- calculate min rows
			i = i + 1
		end

		local MinRows = i
		local Rows = math.min(math.max(math.floor(RowsRaw:GetFloat()), MinRows), 100)
		local Colums = math.min(math.max(math.floor(ColumsRaw:GetFloat()), 1), 100)
		local dlistw = Colums * (IconSize + 2) + 18

		-- Close any existing traitor menu
		if weaponshopframe and IsValid(weaponshopframe) then
			weaponshopframe:Close()
		end

		-- create frame
		local dframe = vgui.Create("DFrame")
		local w, h = 570 - 216 + dlistw, 79 + Rows * (IconSize + 2)

		dframe:SetSize(w, h)
		dframe:Center()
		dframe:SetTitle("Weaponshop")
		dframe:SetVisible(true)
		dframe:ShowCloseButton(true)
		dframe:SetMouseInputEnabled(true)
		dframe:SetDeleteOnClose(true)

		if StringToColor(WindowColor:GetString()) then
			dframe.Paint = function()
				draw.RoundedBox(4, 0, 0, dframe:GetWide(), dframe:GetTall(), StringToColor(WindowColor:GetString()))
			end
		end

		local m = 5

		-- create sheet
		local dsheet = vgui.Create("DPropertySheet", dframe)

		-- Add a callback when switching tabs
		local oldfunc = dsheet.SetActiveTab

		dsheet.SetActiveTab = function(self, new)
			if self.m_pActiveTab ~= new and self.OnTabChanged then
				self:OnTabChanged(self.m_pActiveTab, new)
			end

			oldfunc(self, new)
		end

		dsheet:SetPos(0, 0)
		dsheet:StretchToParent(m, m + 25, m, m)

		if StringToColor(TabColor:GetString()) then
			dsheet.Paint = function(self, w2, h2)
				draw.RoundedBox(5, 0, 21, w2, h2 - 21, StringToColor(TabColor:GetString()))
			end
		end

		local padding = dsheet:GetPadding()

		-- Crate panel
		local dequip = vgui.Create("DPanel", dsheet)
		dequip:SetPaintBackground(false)
		dequip:StretchToParent(padding, padding, padding, padding)

		--- Construct icon listing
		-- Equip List
		local dlist = vgui.Create("EquipSelect", dequip)
		dlist:SetPos(0, 0)
		dlist:SetSize(dlistw, h - 75)
		dlist:EnableVerticalScrollbar(true)
		dlist:EnableHorizontal(true)
		dlist:SetPadding(4)

		dlist.selectedRole = ROLE_TRAITOR

		local function dlistwriting(Sortation, search, sel)
			if dlist then
				dlist:Clear()
			end

			local items = Select(Search(Sortate(EquipmentAll, Sortation), search), sel)

			for k, item in pairs(items) do -- do for every item
				local ic = nil

				for _, k2 in pairs(EquipmentT) do
					if k2.id == item.id then
						item.origin = "T"
					end
				end

				for _, k2 in pairs(EquipmentD) do
					if k2.id == item.id then
						if item.origin == "T" then
							item.origin = "B"
						else
							item.origin = "D"
						end
					end
				end

				-- Create icon panel with markers
				if item.material then
					if item.custom and CustomOn:GetBool() then
						-- Custom marker icon
						local marker = vgui.Create("DImage")
						marker:SetImage("vgui/ttt/custom_marker")

						marker.PerformLayout = function(s)
							s:AlignBottom(2)
							s:AlignRight(2)
							s:SetSize(16, 16)
						end

						marker:SetTooltip(GetTranslation("equip_custom"))

						ic:AddLayer(marker)
						ic:EnableMousePassthrough(marker)
					elseif not(SlotOn:GetBool() and ItemIsWeapon(item)) then
						ic = vgui.Create("SimpleClickIcon", dlist)
					else
						ic = vgui.Create("LayeredClickIcon", dlist)
					end

					if ItemIsWeapon(item) and SlotOn:GetBool() then
						-- Slot marker icon
						local slot = vgui.Create("SimpleIconLabelled")
						slot:SetIcon("vgui/ttt/slotcap")

						local color = Color(60, 60, 60)

						if item.origin == "T" then
							color = color_slot[ROLE_TRAITOR]
						elseif item.origin == "D" then
							color = color_slot[ROLE_DETECTIVE]
						elseif item.origin == "B" then
							color = Color(color_slot[ROLE_TRAITOR].r + color_slot[ROLE_DETECTIVE].r, color_slot[ROLE_TRAITOR].g + color_slot[ROLE_DETECTIVE].g, color_slot[ROLE_TRAITOR].b + color_slot[ROLE_DETECTIVE].b, 255)
						end

						slot:SetIconColor(color or Color(0, 0, 255))
						slot:SetIconSize(16)
						slot:SetTooltip("Slot: " .. item.kind .. " Visual slot: " .. item.slot)
						slot:SetIconText(item.slot)
						slot:SetIconProperties(StringToColor(SlotTextColor:GetString()), "DefaultBold", {opacity = 220, offset = 1}, {10, 8})

						ic:AddLayer(slot)
						ic:EnableMousePassthrough(slot)
					end

					ic:SetIconSize(IconSize)
					ic:SetIcon(item.material)
				elseif item.model then
					ic = vgui.Create("SpawnIcon", dlist)
					ic:SetModel(item.model)
				elseif item then
					ErrorNoHalt("Equipment item does not have model or material specified: " .. tostring(item) .. "\n")
				end

				ic.item = item

				if not item.kind then
					item.kind = 0
				end

				local tip = SafeTranslate(item.name) .. " (" .. SafeTranslate(item.type) .. ")"

				ic:SetTooltip(tip)

				-- If we cannot order this item, darken it
				if false then
					ic:SetIconColor(StringToColor(color_darkened:GetString()))
				end

				-- click on item
				ic.OnClick = function()
					if mode.status then --
						if not dlist.selectedRole or not state or not mode.status then return end

						local is_item = tonumber(ic.item.id)
						if is_item then
							EquipmentItems[dlist.selectedRole] = EquipmentItems[dlist.selectedRole] or {}

							if EquipmentTableHasValue(EquipmentItems[dlist.selectedRole], ic.item) then
								for k2, eq in pairs(EquipmentItems[dlist.selectedRole]) do
									if eq.id == ic.item.id then
										table.remove(EquipmentItems[dlist.selectedRole], k2)

										break
									end
								end

								-- remove
								net.Start("shop")
								net.WriteBool(false)
								net.WriteUInt(dlist.selectedRole - 1, ROLE_BITS)
								net.WriteString(ic.item.name)
								net.SendToServer()
							else
								table.insert(EquipmentItems[dlist.selectedRole], ic.item)

								-- add
								net.Start("shop")
								net.WriteBool(true)
								net.WriteUInt(dlist.selectedRole - 1, ROLE_BITS)
								net.WriteString(ic.item.name)
								net.SendToServer()
							end
						else
							local wepTbl = weapons.GetStored(ic.item.id)
							if wepTbl then
								wepTbl.CanBuy = wepTbl.CanBuy or {}

								if table.HasValue(wepTbl.CanBuy, dlist.selectedRole) then
									for k2, v in ipairs(wepTbl.CanBuy) do
										if v == dlist.selectedRole then
											table.remove(wepTbl.CanBuy, k2)

											break
										end
									end

									-- remove
									net.Start("shop")
									net.WriteBool(false)
									net.WriteUInt(dlist.selectedRole - 1, ROLE_BITS)
									net.WriteString(ic.item.id)
									net.SendToServer()
								else
									table.insert(wepTbl.CanBuy, dlist.selectedRole)

									-- add
									net.Start("shop")
									net.WriteBool(true)
									net.WriteUInt(dlist.selectedRole - 1, ROLE_BITS)
									net.WriteString(ic.item.id)
									net.SendToServer()
								end
							end
						end
					end

					dlist:SelectPanel(ic)

					timer.Simple(0.1, function()
						dlist.OnActivePanelChanged(_, _, ic)
					end)
				end

				dlist:AddPanel(ic)
			end

			-- couple panelselect with info
			if to_select or dlist:GetItems()[1] then
				dlist:SelectPanel(to_select or dlist:GetItems()[1])
			else
				dlist.OnActivePanelChanged()
			end
		end -- end dlistwriting function

		dlistwriting(FirstSort)

		-- positioning vars !rework positioning in general!
		local bw, bh = 100, 25
		local verschiebung = 30 * 2
		local dih = h - bh - m * 5
		local diw = w - dlistw - m * 6 - 2

		local dinfobg = vgui.Create("DPanel", dequip)
		dinfobg:SetPaintBackground(false)
		dinfobg:SetSize(diw, dih)
		dinfobg:SetPos(dlistw + m, 0)

		local dinfo = vgui.Create("ColoredBox", dinfobg)
		dinfo:SetColor(StringToColor(BoxColor:GetString()))-- Box color
		dinfo:SetPos(0, verschiebung)
		dinfo:SetSize(diw, dih - 250)

		local dinfolist = vgui.Create("DScrollPanel", dinfo)
		dinfolist:StretchToParent(0, 0, 0, 0)

		local dhelp = vgui.Create("ColoredBox", dinfobg)
		dhelp:SetColor(StringToColor(BoxColor:GetString()))-- box color
		dhelp:StretchToParent(0, verschiebung, 0, dih - 100 - verschiebung)
		dhelp:MoveBelow(dinfo, m)
		dhelp:SizeToContents()

		-- Search Bar
		local TextEntry = vgui.Create("DTextEntry", dinfobg)
		TextEntry:SetPos(0, 0)
		TextEntry:SetSize(191, 25)
		TextEntry:SetText("Search")
		TextEntry:SetTooltip("Searches items")

		TextEntry.OnTextChanged = function(self)
			SearchText = self:GetValue()

			dlistwriting(nil, SearchText)
		end

		TextEntry.OnGetFocus = function()
			TextEntry:SetText("")
		end

		local XButton = vgui.Create("DButton", dinfobg) -- Button at search bar
		XButton:SetPos(192, 0)
		XButton:SetSize(19, 25)
		XButton:SetText("X")
		XButton:SetTooltip("Deletes the content of the search bar")

		XButton.DoClick = function()
			TextEntry:SetText("Search")
			SearchText = ""

			dlistwriting(nil, SearchText)
		end

		-- Buttons
		mode = vgui.Create("DButton", dframe)
		mode:SetPos(w - 14 - bw, h - 2 * bh - 21)
		mode:SetSize(100, 25)
		mode:SetText("Reading mode")

		mode.status = true

		mode.DoClick = function()
			if mode.status == true then
				mode.status = false

				mode:SetText("Writing mode")
			else
				mode.status = true

				mode:SetText("Reading mode")
			end
		end

		local dcancel = vgui.Create("DButton", dframe) -- Cancel button
		dcancel:SetPos(w - 14 - bw, h - bh - 16)
		dcancel:SetSize(bw, bh)
		dcancel:SetDisabled(false)
		dcancel:SetTooltip("Closes this window")
		dcancel:SetText(GetTranslation("close"))

		dcancel.DoClick = function()
			dframe:Close()
		end

		local dSortByName = vgui.Create("DButton", dinfobg) -- Sortation Buttons
		dSortByName:SetTooltip("Sorts the items by Name")
		dSortByName:SetPos(111, 30)
		dSortByName:SetSize(bw, bh)
		dSortByName:SetText("Sort by Name")

		dSortByName.DoClick = function () dlistwriting("Name") end

		local dSortByID = vgui.Create("DButton", dinfobg)
		dSortByID:SetTooltip("Sorts the items by ID")
		dSortByID:SetPos(0, 30)
		dSortByID:SetSize(bw, bh)
		dSortByID:SetText("Sort by Default")

		dSortByID.DoClick = function()
			dlistwriting("Default")
		end

		local dSortBySlot = vgui.Create("DButton", dinfobg)
		dSortBySlot:SetTooltip("Sorts the items by Slot")
		dSortBySlot:SetPos(222, 30)
		dSortBySlot:SetSize(bw, bh)
		dSortBySlot:SetText("Sort by Slot")

		dSortBySlot.DoClick = function()
			dlistwriting("Slot")
		end

		local dSortByOrigin = vgui.Create("DButton", dinfobg)
		dSortByOrigin:SetTooltip("Sorts the items by Origin")
		dSortByOrigin:SetPos(222, 0)
		dSortByOrigin:SetSize(bw, bh)
		dSortByOrigin:SetText("Sort by Origin")

		dSortByOrigin.DoClick = function()
			dlistwriting("Origin")
		end

		-- add sheets
		-- Shop
		dsheet:AddSheet("Weaponshop", dequip, "icon16/bomb.png", false, false, "Edit shops")

		dlist.OnActivePanelChanged = function(self, _, new)

			--dinfolist writing
			dinfolist:Clear()

			local dfields = {}

			for _, k in pairs({"name", "type", "desc"}) do
				dfields[k] = vgui.Create("DLabel")
				dfields[k]:SetTooltip(GetTranslation("equip_spec_" .. k))
				dfields[k]:SetPos(m * 3, m * 2)

				dinfolist:AddItem(dfields[k])
			end

			dfields.name:SetFont("TabLarge")
			dfields.name:SetColor(NameTextColor)

			dfields.type:SetColor(StringToColor(TypeTextColor:GetString()))
			dfields.type:SetFont("DermaDefault")
			dfields.type:MoveBelow(dfields.name)

			dfields.desc:SetContentAlignment(7)
			dfields.desc:MoveBelow(dfields.type, 1)

			if FixedDescBool:GetBool() and new then
				dfields["Button"] = vgui.Create("DButton") -- Button in list

				if fixedDesc[new.item.id] then
					dfields.desc:SetFont("DebugFixed")-- monospaced font
					dfields["Button"]:SetText("Default description")
					dfields["Button"]:SetTooltip("Shows the default description (looks a bit better)")
				else
					dfields.desc:SetFont("DermaDefaultBold")
					dfields["Button"]:SetText("Fixed description")
					dfields["Button"]:SetTooltip("Shows the fixed desfixed description (to avoid too long rows)")
				end

				dfields.desc:SetColor(StringToColor(DescriptionTextColor:GetString()))
				dfields["Button"]:SetSize(bw, bh)
				dfields["Button"]:SetPos(dinfolist:GetSize() - bw - m * 3, m * 2)

				dinfolist:AddItem(dfields["Button"])

				dfields["Button"].DoClick = function()
					if fixedDesc[new.item.id] then
						fixedDesc[new.item.id] = false
					else
						fixedDesc[new.item.id] = true
					end

					dlist:SelectPanel(new) --refresh
				end
			end

			if new then
				for k, v in pairs(new.item) do
					if dfields[k] then -- fixed description
						if k == "desc" then
							local Result = FixedDescription(v, new.item)
							dfields[k]:SetText(Result .. "\n")--"\n" for better design in scroll panel
						else
							dfields[k]:SetText(SafeTranslate(v))
						end

						dfields[k]:SizeToContents()
					end
				end
			else -- if no item selected
				dfields["name"]:SetText("none")
				dfields["type"]:SetText("none")
				dfields["desc"]:SetText("none\n")

				dfields["name"]:SizeToContents()
				dfields["type"]:SizeToContents()
				dfields["desc"]:SizeToContents()
			end

			-- 2nd field
			dhelp:Clear()

			local x = m * 3
			local y = m * 4.5
			local dlab = vgui.Create("DLabel", dhelp)
			local CanBeBought = false

			for k, v in pairs(TTT2GetEquipmentForRole(dlist.selectedRole)) do
				if v.id == new.item.id then
					CanBeBought = true
				end
			end

			if CanBeBought then
				dlab:SetTextColor(StringToColor(color_good:GetString()))
				dlab:SetText("This Item can be bought by the selected role.")
			else
				dlab:SetTextColor(StringToColor(color_bad:GetString()))
				dlab:SetText("This Item can not be bought by the selected role.")
			end

			dlab:SetPos(x, y)
			dlab:SetFont("TabLarge")
			dlab:SetTooltip("Shows if item can be bought by sel. role.")
			dlab:SizeToContents()

			local dlab2 = vgui.Create("DLabel", dhelp)
			dlab2:SetTooltip("Shows origin of the item.")
			dlab2:CopyPos(dlab)
			dlab2:MoveBelow(dlab, y)
			dlab2:SetFont("TabLarge")
			dlab2:SetText("The origin of this item is Unknown.")

			if new.item.origin == "T" then
				dlab2:SetColor(color_slot[ROLE_TRAITOR])
				dlab2:SetText("The origin of this item is Traitor.")
			elseif new.item.origin == "D" then
				dlab2:SetColor(color_slot[ROLE_DETECTIVE])
				dlab2:SetText("The origin of this item is Detective.")
			elseif new.item.origin == "B" then
				dlab2:SetColor(Color(color_slot[ROLE_TRAITOR].r + color_slot[ROLE_DETECTIVE].r, color_slot[ROLE_TRAITOR].g + color_slot[ROLE_DETECTIVE].g, color_slot[ROLE_TRAITOR].b + color_slot[ROLE_DETECTIVE].b, 255))
				dlab2:SetText("The origin of this item is Traitor & Detective.")
			end

			dlab2:SizeToContents()
		end

		-- select first
		if not to_select then
			dlist:SelectPanel(dlist:GetItems()[1])
		end

		local menu = vgui.Create("DComboBox")
		menu:SetParent(dequip)
		menu:SetPos(dlistw + 5, h - 75 - 54)
		menu:SetSize(210, 25)
		menu:SetValue(sr.name)

		dlist.selectedRole = ROLE_TRAITOR

		for _, v in pairs(GetShopRoles()) do
			menu:AddChoice(v.name, v.index)
		end

		local fbmenu = vgui.Create("DComboBox")
		fbmenu:SetParent(dequip)
		fbmenu:SetPos(dlistw + 5, h - 75 - 24)
		fbmenu:SetSize(210, 25)

		function fbmenu:RefreshChoices()
			-- clear old data
			self:Clear()

			local rd = GetRoleByIndex(dlist.selectedRole)
			local fallback = GetConVar("ttt_" .. rd.abbr .. "_shop_fallback"):GetString()
			local fb = GetRoleByName(fallback)

			-- update state
			if fallback == SHOP_DISABLED or fallback == SHOP_UNSET and rd.fallbackTable then
				state = false
			else
				state = true
			end

			-- add linked or own shop choice
			for _, v in pairs(GetShopRoles()) do
				self:AddChoice(dlist.selectedRole == v.index and "Use own shop" or ("Link with " .. v.name), {name = v.name, data = v.name})
			end

			-- add default choice
			local tmpRd = GetRoleByIndex(dlist.selectedRole)
			if tmpRd.fallbackTable then
				self:AddChoice("Default Role Equipment", {name = tmpRd.name, data = SHOP_UNSET})
			end

			self:AddChoice("Disable shop", {name = tmpRd.name, data = SHOP_DISABLED})

			-- set default value
			if fallback == SHOP_DISABLED then
				self:SetValue("Disabled shop")
			elseif not state then
				self:SetValue("Default Role Equipment")
			else
				self:SetValue(dlist.selectedRole == fb.index and "Using own shop" or ("Linked with " .. fb.name))
			end

			-- generally update
			dlist:SelectPanel(dlist:GetItems()[1])
			dlist.OnActivePanelChanged(_, _, dlist:GetItems()[1])

			-- disable if not needed
			if not state or fb.index ~= dlist.selectedRole then
				for _, v in pairs(dlist:GetItems()) do
					if v.Toggle then
						v:Toggle(false)
					end
				end
			end
		end

		fbmenu:RefreshChoices()

		function fbmenu:OnSelect(_, _, data)
			local rd = GetRoleByIndex(dlist.selectedRole)
			local oldFallback = GetConVar("ttt_" .. rd.abbr .. "_shop_fallback"):GetString()

			if fallback ~= oldFallback then
				net.Start("shopFallback")
				net.WriteUInt(dlist.selectedRole - 1, ROLE_BITS)
				net.WriteString(data.data)
				net.SendToServer()
			end

			if data.data == SHOP_DISABLED or data.data == SHOP_UNSET or data.data ~= GetRoleByIndex(dlist.selectedRole).name then
				state = false

				for _, v in pairs(dlist:GetItems()) do
					if v.Toggle then
						v:Toggle(false)
					end
				end
			else
				state = true

				dlist:SelectPanel(dlist:GetItems()[1])
				dlist.OnActivePanelChanged(_, _, dlist:GetItems()[1])
			end
		end

		function menu:OnSelect(_, _, data)
			dlist.selectedRole = data

			fbmenu:RefreshChoices()
		end


		-- update some basic info, may have changed in another tab
		-- specifically the number of credits in the preq list
		dsheet.OnTabChanged = function(s, old, new)
			if not IsValid(new) then return end
		end

		dframe:MakePopup()
		dframe:SetKeyboardInputEnabled(true)
		weaponshopframe = dframe
	end
	net.Receive("bettermenu_weaponshop", WeaposhopPopup)
end
