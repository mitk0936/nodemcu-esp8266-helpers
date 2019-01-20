-- Nodemcu modules: file, sjson
local read_json_file = function (filename)
  if (file.open(filename)) then
    local decoded, content = pcall(sjson.decode, file.read());
    file.close();
    return decoded, content;
  end

  return false, nil;
end

-- Nodemcu modules: file
local update_file = function (filename, content)
  if (file.open(filename, 'w+')) then
    file.write(content);
    file.close();
    return true;
  end

  return false;
end

return {
  read_json_file = read_json_file,
  update_file = update_file
};