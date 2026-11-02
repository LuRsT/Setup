-- Common Configuration
require('config.common')

-- Keymaps
require('config.keymaps')

-- Plugins
require('config.plugins')

-- Colorscheme
require('config.colors')

vim.api.nvim_create_user_command('R', function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.fn.jobstart({ 'sh', '-c', opts.args }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then return end
      if data[#data] == '' then table.remove(data) end -- trim trailing empty line
      vim.api.nvim_buf_set_lines(buf, row, row, false, data)
    end,
    on_stderr = function(_, data)
      if data and #data > 0 and data[1] ~= '' then
        vim.notify(table.concat(data, '\n'), vim.log.levels.WARN)
      end
    end,
  })
end, { nargs = '+', complete = 'shellcmd' })

-- Functions (if converted to Lua)
vim.cmd.source('~/.config/nvim/lua/config/functions.vim')
