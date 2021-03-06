-------------------------------------------------------------------------------
--    ENHANCED NOTIFICATION FRAMEWORK
--    Copyright (C) 2017 saibotk (tkindanight)
-------------------------------------------------------------------------------
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------

-- Initialize local object
local ENHANCED_NOTIFICATIONS = {notif_table = {}}

-------------------------------------------------------------------------------
-- Signature:   NewNotification( table )  table = {title, subtext, color, image}
-- Description: Creates a new notification with the given parameters, updates notification table / positions
--              parameters are optional, atleast give a title or subtext or image
-- Returns:     Nothing
-------------------------------------------------------------------------------
function ENHANCED_NOTIFICATIONS:NewNotification(t)
	setmetatable(t, {__index = {title = nil, image = nil, subtext = nil, color = nil, lifetime = nil}})

	if not t.title and not t.subtext and not t.image then return end

	-- print("Creating Notification...")
	-- Add notif to table
	table.insert(self.notif_table, 1, self:CreateNotificationElement(t.title, t.color, t.subtext, t.image, tonumber(t.lifetime)))

	self:Update()
end

-------------------------------------------------------------------------------
-- Signature:   Update()
-- Description: Updates positions of stored notifications and cleans up the table
-- Returns:     Nothing
-------------------------------------------------------------------------------
function ENHANCED_NOTIFICATIONS:Update()
	local offset = 8
	local curY = 0

	for k, v in pairs(self.notif_table) do
		if not IsValid(v) or v:GetAlpha() == 0 then
			if IsValid(v) then
				v:Remove()
			end

			table.remove(self.notif_table, k)
		end
	end

	for _, v in ipairs(self.notif_table) do
		if IsValid(v) and v:GetAlpha() >= 0 then
			v:SetPos(15, 15 + curY)

			local _, h = v:GetSize()

			curY = curY + h + offset
		end
	end
end

-------------------------------------------------------------------------------
-- Signature:   FindNotification( table ) table = { title, subtext, image }
-- Description: Returns the id of the first found notification matching one of
--              the parameters (optional, atleast give one parameter)
-- Returns:     Int id (in notif_table)
-------------------------------------------------------------------------------
function ENHANCED_NOTIFICATIONS:FindNotification(t)
	setmetatable(t, {__index = {title = nil, subtext = nil, image = nil}})
	if not t.title and not t.subtext and not t.image then return end

	for i, v2 in pairs(self.notif_table) do
		local bg = v2:GetChild(0)

		for _, v in pairs(bg:GetChildren()) do
			if v:GetClassName() == "DLabel" and (v:GetText() == t.title or v:GetText() == t.subtext) or v:GetClassName() == "DImage" and v:GetImage() == t.image then
				return i
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Signature:   RemoveNotification( id )
-- Description: Removes a notification and invokes Update()
-- Returns:     Nothing
-------------------------------------------------------------------------------
function ENHANCED_NOTIFICATIONS:RemoveNotification(id)
	if IsVaild(self.notif_table[id]) then
		self.notif_table[id]:Remove()
	end

	table.remove(self.notif_table, id)

	self:Update()
end

-------------------------------------------------------------------------------
-- Signature:   Clear()
-- Description: Clears the entire notification table and marks all elements to be removed
-- Returns:     Nothing
-------------------------------------------------------------------------------
function ENHANCED_NOTIFICATIONS:Clear()
	for k, v in pairs(self.notif_table) do
		if IsValid(v) then
			v:Remove()
		end

		table.remove(self.notif_table, k)
	end
end

-------------------------------------------------------------------------------
-- Signature:   GetVersion()
-- Description: Returns the version of Enhanced Notification Framework
-- Returns:     String
-------------------------------------------------------------------------------
function ENHANCED_NOTIFICATIONS:GetVersion()
	return "1.3.2"
end

-------------------------------------------------------------------------------
-- Signature:   CreateNotificationElement( title, color, subtext, image, lifetime )
-- Description: Creates the vgui elements with the given parameters
-- Returns:     DNotify object
-------------------------------------------------------------------------------
function ENHANCED_NOTIFICATIONS:CreateNotificationElement(title, color, subtext, image, lifetime)
	-- calculating the correct offsets and sizes
	local height = math.Clamp(ScrH() / 15, 75, 200)
	local width = height * 5
	local imgOffset = height * 0.05
	local imgSize = height - (imgOffset * 2)
	local textOffsetX = height
	local textWidth = width - (height * 1.1)
	local titleOffsetY = height * 0.1
	local titleHeight = height * 0.4
	local subtextOffsetY = height * 0.5
	local subtextHeight = height * 0.5

	-- components
	local notif = vgui.Create("DNotify") -- the notification
	local bg = vgui.Create("DPanel", notif) --The background panel
	local img = vgui.Create("DImage", bg) --The image
	local lblTitle = vgui.Create("DLabel", bg) -- the title
	local lblSubtext = vgui.Create("DLabel", bg) -- the subtext

	-- notify properties
	notif:SetSize(width, height)

	-- background properties
	bg:Dock(FILL)

	-- image properties
	img:SetSize(imgSize, imgSize)
	img:SetPos(imgOffset, imgOffset)

	-- title properties
	lblTitle:SetSize(textWidth, titleHeight)
	lblTitle:SetPos(textOffsetX, titleOffsetY)
	lblTitle:SetTextColor(Color(255, 250, 250))
	lblTitle:SetFont("Trebuchet24")
	lblTitle:SetContentAlignment(4)

	-- subtext properties
	lblSubtext:SetSize(textWidth, subtextHeight)
	lblSubtext:SetPos(textOffsetX, subtextOffsetY)
	lblSubtext:SetTextColor(Color(255, 250, 250))
	lblSubtext:SetFont("HudHintTextLarge")
	lblSubtext:SetContentAlignment(7)
	lblSubtext:SetWrap(true)

	-- placeholder checking
	notif:SetLife(lifetime or 5)
	bg:SetBackgroundColor(color or Color(150, 150, 150))
	img:SetImage(image or "vgui/ttt/tbn_ic_default")
	lblTitle:SetText(title or "")
	lblSubtext:SetText(subtext or "")

	notif:AddItem(bg)

	return notif
end

return ENHANCED_NOTIFICATIONS
