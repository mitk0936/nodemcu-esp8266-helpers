local max_retries_count = 10;

-- Nodemcu modules: wifi
local sync_time = function (addresses, on_success, retries)
  local sync_retries = retries or 1;
  
  sntp.sync(addresses, on_success, function ()
    print('Failed to sync time...');

    if (sync_retries > max_retries_count) then
      return sync_time(addresses, on_success, sync_retries + 1);
    end

    print('Max retries count ('..max_retries_count..') reached. Unable to sync time');
  end);
end

return {
  sync_time = sync_time
};