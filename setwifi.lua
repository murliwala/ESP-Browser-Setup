--setwifi.lua

print("Entering wifi Setup..")

wifi.setmode(wifi.STATIONAP)
cfg={}
    cfg.ssid="ESP8266"
    cfg.password="12345678" --comment to leave open
wifi.ap.config(cfg)

ap_list = ""

function listap(t)
  for bssid,v in pairs(t) do
   local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
    ap_list = ap_list.."<option value='"..ssid.."'>"..ssid.."</option>"
  end
end
wifi.sta.getap(1, listap)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end

        if path == "/favicon.ico" then
            conn:send("HTTP/1.1 404 file not found")
            return
        end   

        if (path == "/" and  vars == nil) then
            buf = buf.."<html><body style='width:90%;margin-left:auto;margin-right:auto;background-color:LightGray;'>";
            buf = buf.."<h1>SmartButton Wifi Configuration</h1>"
            buf = buf.."<form action='' method='get'>"
            buf = buf.."<h4>SSID:</h4>"
            buf = buf.."<select name='dssid'>"..ap_list.."</select>"
            buf = buf.." or <input type='text' name='ssid' value='' maxlength='100' width='100px' placeholder='ssid' />"
            buf = buf.."<br><br>"
            buf = buf.."<h4>Password:</h4>"
            buf = buf.."<input type='text' name='password' value='' maxlength='100' width='100px' placeholder='empty if AP is open' />"
            buf = buf.."<p><input type='submit' value='Submit' style='height: 25px; width: 100px;'/></p>"
            buf = buf.."</body></html>"
    
        elseif (vars ~= nil) then
            restarting = "<html><body style='width:90%;margin-left:auto;margin-right:auto;background-color:LightGray;'><h1>Restarting...You may close this window.</h1></body></html>"
            client:send(restarting);
            client:close();
            if(_GET.dssid)then
                ssid = _GET.dssid
                password1 = _GET.password
                if (_GET.ssid) then
                    ssid = _GET.ssid
                end
                if (_GET.password) then
                    password1 = _GET.password
                end
			print("Setting to: "..ssid..":"..password1)
			-- remove "Prakash" from file system.
			file.remove("Prakash.lua")
			-- open 'Prakash.lua' in 'a+' mode
			file.open("Prakash.lua", "a+")
			-- write to the end of the file
			file.writeline('wifi.setmode(wifi.STATION)')
			file.writeline('wifi.sta.config("'..ssid..'","'..password1..'")')
			file.writeline('tmr.alarm(0,1000, 1, function()')
			file.writeline('if wifi.sta.getip()==nil then')
			file.writeline('print(" Wait for IP address!")')
			file.writeline('else')
			file.writeline('print("New IP address is "..wifi.sta.getip())')
			file.writeline('tmr.stop(0)')
			file.writeline('end')
			file.writeline('end)')
			file.close()
			node.restart()
            end
        end

        client:send(buf);
        client:close();
        collectgarbage();
    end)
    
end)
