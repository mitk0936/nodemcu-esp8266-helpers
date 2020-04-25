local function set_timeout(time, callback)
  local timeout = tmr.create();

  timeout:register(time, tmr.ALARM_SINGLE, function()
    timeout:unregister();
    callback();
  end);

  timeout:start();

  return function ()
    timeout:unregister();
  end
end

return {
  set_timeout = set_timeout
};