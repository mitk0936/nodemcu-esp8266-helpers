-- Nodemcu modules: wifi
local wifi_config_sta = function (ssid, password, mode)
  wifi.setmode(mode or wifi.STATIONAP);
  wifi.sta.config({ ssid = ssid, pwd = password or '' });
  wifi.sta.connect();
end

-- Nodemcu modules: wifi
local wifi_config_ap = function (ssid, password)
  wifi.ap.config({ ssid = ssid, pwd = password or '' });
end

-- Nodemcu modules: tmr, wifi, tmr
local wifi_connect = function (ssid, interval, on_complete)
  local wifi_timer = tmr.create();
  
  wifi_timer:register(interval or 1500, tmr.ALARM_AUTO, function()
    print('connecting to: '..ssid);
    if wifi.sta.getip() then
      on_complete(wifi.sta.getip());
      wifi_timer:stop();
      wifi_timer:unregister();
    end
  end);

  wifi_timer:start();
end

return {
  wifi_config_sta = wifi_config_sta,
  wifi_config_ap = wifi_config_ap,
  wifi_connect = wifi_connect
};