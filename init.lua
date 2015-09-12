l = file.list();
for k,v in pairs(l) do
	print(k)
	if k == "Prakash.lua" then
		flag = 0
	end
end 

print(flag)

if flag == 0 then
	print(dofile("Prakash.lua"))
else
	dofile("setwifi.lua")
	print("Test")
end
