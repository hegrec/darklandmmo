local store = CreateStore("Blaine Conrad's General Store")

for i,v in pairs(items.GetAll()) do
	AddStock(store,i,10,10)
end