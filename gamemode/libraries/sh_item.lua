

local itemList = {}

items = {}
items.__index = items
function items.Create(baseType,varStr,ID,Owner) --varStr is glon stored

	local item = {}
	item.BaseType = baseType or "NULL"
	item.ID = tonumber(ID) or 0
	item.Owner = Owner or NULL
	if varStr then
		item.Variables = glon.decode(varStr)
	else
		item.Variables = {}
	end
	setmetatable(item,items)	
	return item
end

function items.RegisterClass(name)
	itemList[name] = {}
	return itemList[name]
end

function items.Get(name)
	return itemList[name]
end

function items.GetAll()
	return itemList
end



function items:__tostring()

	return "[Item #"..self.ID.."]"..self.BaseType

end
function items:SetVar(var,val)
	self.Variables[var] = val
	tmysql.query("UPDATE rpg_items SET Variables='"..tmysql.escape(glon.encode(self.Variables)).."'")
	if self.Owner then
		umsg.Start("updateVar",self.Owner)
			umsg.Long(self.ID)
			umsg.String(var)
			umsg.FindValue(val)
		umsg.End()
	end
end
function items:GetVar(var)
	return self.Variables[var]
end
function items:GetID()
	return self.ID
end
function items:GetClass()

	return self.BaseType

end

function items:Send(pl)

	umsg.Start("i2c",pl)
		umsg.String(self.BaseType)
		umsg.Long(self.ID)
		umsg.Entity(self.Owner)
		for i,v in pairs(self.Variables) do
			umsg.Short(i)
			umsg.FindValue(v)
		end
	umsg.End()
	return self.ID --this is where it is stored in the clientside item buffer, send this in a usermessage AFTER you send the item and you'll be able to grab it in your usermessage's callback clientside

end

--not within metatable because the item doesn't yet exist on the client. putting it here anyways because i can
if SERVER then return end
local itemBuffer = {}
local function ReceiveItem(um)

	local iType = um:ReadString()
	local id = um:ReadLong()
	local pOwner = um:ReadEntity()
	local item = items.Create(iType,nil,id,pOwner)
	
	
	local index = um:ReadShort()
	
	if index != 0 then
	
		local vType = um:ReadString()
		local func = "Read"..vType
		local value = um[func](um)
		
		while (index != 0) do
		
			item.Variables[index] = value
			
			index = um:ReadShort()
			vType = um:ReadString()
			local func = "Read"..vType
			value = um[func](um)
			
		end
		
	end
	
	table.insert(itemBuffer,{id,item})

end
usermessage.Hook("i2c",ReceiveItem)

function items.BufferGrab(index)
	local item
	local ind
	for i,v in pairs(itemBuffer) do
		if v[1] == index then
			item = v[2]
			ind = i
		end
	end
	table.remove(itemBuffer,ind) --grabbing an item clears it from the buffer!!!!
	return item
end
	