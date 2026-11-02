-- Keep visual selection after indenting
vim.keymap.set('v', '>', '>gv', { desc = 'Indent and reselect' })
vim.keymap.set('v', '<', '<gv', { desc = 'Unindent and reselect' })

-- Navigate by paragraph with BS/CR
vim.keymap.set('v', '<CR>', '}')
vim.keymap.set({'n', 'o', 'v'}, '<BS>', '{')
vim.keymap.set({'n', 'o'}, '<CR>', function()
  return vim.bo.buftype == '' and '}' or '<CR>'
end, { expr = true })

-- Use tab and shift-tab to indent region (keep visual selection)
vim.keymap.set('n', '<Tab>',   'v>', { desc = 'Indent line' })
vim.keymap.set('n', '<S-Tab>', 'v<', { desc = 'Unindent line' })
vim.keymap.set('v', '<Tab>',   '>gv', { desc = 'Indent selection' })
vim.keymap.set('v', '<S-Tab>', '<gv', { desc = 'Unindent selection' })

-- Use ; as :
vim.keymap.set('n', ';', ':', { desc = 'Command mode' })

-- Remove Q because who needs ex mode?
vim.keymap.set('n', 'Q', '<nop>', { desc = 'Disabled (Ex mode)' })

-- Display current filename
vim.keymap.set('n', '<C-x>', '<cmd>echo expand("%:p")<CR>', { desc = 'Show full path' })

-- Search for files with Telescope
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<C-g>', '<cmd>Telescope buffers<CR>', { desc = 'Switch buffers' })

-- Mark todo item as done
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.keymap.set('', '<CR>', ':s/\\[ \\]/[X]/<CR>:nohl<CR>', {
      buffer = true,  -- makes this mapping local to the buffer
      desc = 'Mark todo done'
    })
  end,
})

-- Use Neovim's built-in inspector (for colorscheme debugging)
vim.keymap.set('n', '<F3>', '<cmd>Inspect<CR>', { desc = 'Inspect highlight' })

-- Resize windows with Alt+hjkl
vim.keymap.set('n', '<a-j>', '<c-w>+', { desc = 'Increase window height' })
vim.keymap.set('n', '<a-k>', '<c-w>-', { desc = 'Decrease window height' })
vim.keymap.set('n', '<a-l>', '<c-w><', { desc = 'Decrease window width'  })
vim.keymap.set('n', '<a-h>', '<c-w>>', { desc = 'Increase window width'  })

-- Quick fold toggle
vim.keymap.set('n', '<leader>z', 'za', { desc = 'Toggle fold' })
vim.keymap.set('n', '<leader>Z', 'zA', { desc = 'Toggle fold recursively' })

-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

-- LSP keymaps (buffer-local; only active when an LSP attaches).
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf, noremap = true, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,
      vim.tbl_extend('force', opts, { desc = 'Code action' }))
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename,
      vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
    vim.keymap.set('n', '<leader>cf',
      function() vim.lsp.buf.format({ async = false, name = 'ruff' }) end,
      vim.tbl_extend('force', opts, { desc = 'Format buffer (ruff)' }))
  end,
})

-- Run pytest for the test under the cursor.
-- Verbose by design: every step logs via vim.api.nvim_echo so it always lands
-- in :messages, regardless of which notify handler is installed.
local function log(msg)
  vim.api.nvim_echo({ { '[run-test] ' .. msg, 'Normal' } }, true, {})
end

local function run_test_under_cursor()
  local file = vim.fn.expand('%')
  log('file=' .. file .. ' ft=' .. vim.bo.filetype)
  if file == '' then return log('abort: no file') end
  if vim.bo.filetype ~= 'python' then return log('abort: not python') end

  local ok_node, node = pcall(vim.treesitter.get_node)
  if not ok_node or not node then
    return log('abort: treesitter.get_node() returned nothing (parser not attached?)')
  end
  log('start node=' .. node:type())

  local function name_of(n)
    local field = n:field('name')[1]
    return field and vim.treesitter.get_node_text(field, 0) or nil
  end

  local test_name, class_name
  local cur = node
  while cur do
    local t = cur:type()
    if t == 'function_definition' and not test_name then
      local n = name_of(cur)
      if n and n:match('^test_') then test_name = n end
    elseif t == 'class_definition' and test_name then
      class_name = name_of(cur)
      break
    end
    cur = cur:parent()
  end

  if not test_name then return log('no enclosing test_* function') end
  log('found test=' .. test_name .. ' class=' .. (class_name or '<none>'))

  local nodeid = file .. '::' .. (class_name and (class_name .. '::' .. test_name) or test_name)
  local cmd = 'pytest ' .. vim.fn.shellescape(nodeid)

  local ok_unnamed = pcall(vim.fn.setreg, '"', cmd)
  local ok_plus    = pcall(vim.fn.setreg, '+', cmd)
  log('clipboard set: unnamed=' .. tostring(ok_unnamed) .. ' plus=' .. tostring(ok_plus))

  if vim.env.TMUX then
    local pane = vim.fn.system({ 'tmux', 'display-message', '-p', '#{last_pane_id}' }):gsub('%s+$', '')
    log('tmux last_pane_id=' .. pane .. ' (shell_error=' .. vim.v.shell_error .. ')')
    if vim.v.shell_error == 0 and pane ~= '' then
      vim.fn.system({ 'tmux', 'send-keys', '-t', pane, cmd, 'Enter' })
      log('tmux send-keys shell_error=' .. vim.v.shell_error)
    end
  end

  log('cmd: ' .. cmd)
end

vim.keymap.set('n', '<leader>tt', run_test_under_cursor, { desc = 'Run test under cursor (tmux/clipboard)' })
