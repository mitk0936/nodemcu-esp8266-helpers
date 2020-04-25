local function create_commander(on_callback, write_callback, cleanup_callback, set_timeout) 
  local default_command_timeout_ms = 5000;
  
  local commander = {
    queue = {},
    is_executing = false,
    current_exec = nil,
    buffer = '',
    command_timeout = nil
  };

  function commander.completed_command()
    commander.is_executing = false;
    commander.current_exec = nil;
    commander.buffer = '';

    if (commander.command_timeout) then
      commander.command_timeout(); -- cleanup the timeout for command, as it completed
    end 

    local next_command = table.remove(commander.queue, 1);

    if (next_command) then
      commander.exec(
        next_command.command,
        next_command.response_parser,
        next_command.on_complete,
        next_command.until_char,
        next_command.timeout_ms
      );
    end
  end

  function commander.exec(command, response_parser, on_complete, until_char, timeout_ms)
    local to_exec = {
      command = command,
      response_parser = response_parser,
      on_complete = on_complete,
      until_char = until_char,
      timeout_ms = timeout_ms or default_command_timeout_ms
    };

    if (commander.is_executing) then
      commander.queue[#commander.queue + 1] = to_exec;
      return;
    end

    commander.is_executing = true;

    commander.current_exec = to_exec;
    commander.buffer = '';

    on_callback(until_char, commander.feed);

    set_timeout(500, function ()
      print('writing', command, 'waiting for char', to_exec.until_char);

      write_callback(to_exec.command);

      commander.command_timeout = set_timeout(to_exec.timeout_ms, function ()
        local ok = to_exec.on_complete(commander.buffer, false, true);

        if (not ok) then
          -- will be retried
          table.insert(commander.queue, 1, to_exec);
        end

        commander.completed_command();
      end);
    end);
  end

  function commander.feed(data_string)
    commander.buffer = commander.buffer..data_string;
    
    local data_parsed, result = commander.current_exec.response_parser(commander.buffer);

    if (data_parsed) then
      commander.current_exec.on_complete(result, true, false);
      commander.completed_command();
    end
  end

  return commander.exec;
end

return {
  create_commander = create_commander
};
