-- Nodemcu modules: net
local throw_server_error = function (conn)
  conn:send('HTTP/1.1 500 INTERNAL SERVER ERROR\r\n\r\n', function ()
    conn:close()
  end);
end

-- Nodemcu modules: net
local send_response = function (conn, content_type, body, on_complete)
  conn:send('HTTP/1.1 200 OK\r\n\r\n', function ()
    conn:send('Content-type: '..content_type, function ()
      conn:send(body, function ()
        conn:close();
        on_complete();
      end)
    end)
  end)
end

-- Nodemcu modules: net, file
local send_file = function (
  conn,
  filename,
  content_type
)
  local filename = filename;
  local data_to_get = 0;
  local chunk = 256;

  conn:send('HTTP/1.1 200 OK \r\n'..content_type..'\r\n\r\n');
  
  conn:on('sent', function(conn) 
    if file.open(filename, 'r') then
      file.seek('set', data_to_get)
      local line = file.read(chunk)
      file.close()

      if line then
        conn:send(line);
        data_to_get = data_to_get + chunk
        if (string.len(line) == chunk) then
          return;
        end
      end
    end
    conn:close();
  end)
end

-- Nodemcu modules: net, sjson
local start = function (on_request)
  local srv = net.createServer(net.TCP);

  local extract_json_from_payload = function (payload)
    print(payload);
    local json = payload:match('(%b{})');
    local parsed, parsedJson = pcall(sjson.decode, json);
    return ((not parsed) and {} or parsedJson);
  end

  srv:listen(80, function (conn)
    conn:on('receive', function (conn, payload)
      local _, _, method, url, vars = string.find(payload, '([A-Z]+) /([^?]*)%??(.*) HTTP');
      local json_body = extract_json_from_payload(payload);

      if (on_request) then
        return on_request({
          conn = conn,
          payload = payload,
          method = method,
          url = url,
          vars = vars,
          json_body = json_body
        })
      end

      print('Missing on_request callback');
    end)
  end);
end

return {
  start = start,
  send_response = send_response,
  send_file = send_file,
  throw_server_error = throw_server_error
};