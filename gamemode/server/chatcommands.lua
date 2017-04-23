local commandList = {}
function GM:PlayerSay(pl,txt,public)
	if string.find(txt,"/") == 1 then
		local args = string.sub(txt,2) --chop off the /
		args = string.Explode(" ",args)
		local cmd = args[1]
		table.remove(args,1)
	
		if !commandList[cmd] then return "" end
	
	
		return commandList[cmd](pl,args) or ""
	end
	return txt
end

function AddChatCommand(name,callback)

	commandList[name] = callback
	
end