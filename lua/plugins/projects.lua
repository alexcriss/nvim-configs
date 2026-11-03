local projects = {
  '~/Repos/*',
  '~/Personal/home/*',
  '~/Personal/money/*',
  '~/Personal/alerts/*',
  '~/Personal/*',
  '~/.config/*',
  '~/roles/*',
  '~/svn/tags/*',
  '~/svn/migrations/*',
}

require('neovim-project').setup {
  projects = projects,
  picker = { type = 'snacks' },
  last_session_on_startup = false,
  dashboard_mode = false,
}

vim.keymap.set({ 'n', 'x' }, '<leader>op', '<cmd>NeovimProjectDiscover<CR>', { desc = 'Open project' })
vim.keymap.set('n', '<leader>oh', '<cmd>NeovimProjectHistory<CR>', { desc = 'Open recent project' })

-- Per-project ShaDa: jumplist, marks, registers, command/search history and
-- v:oldfiles are kept separately for each project, so <C-o> and recent files
-- never wander into other projects. Outside projects the default file is used.
local function project_root(dir)
  local root = nil
  for _, pattern in ipairs(projects) do
    for _, candidate in ipairs(vim.fn.glob(pattern, false, true)) do
      if vim.fs.relpath(candidate, dir) and vim.fn.isdirectory(candidate) == 1 then
        if not root or #candidate > #root then
          root = candidate
        end
      end
    end
  end
  return root
end

local function shadafile(dir)
  local root = project_root(dir)
  if not root then
    return ''
  end
  local base = vim.fn.stdpath 'state' .. '/shada/projects'
  vim.fn.mkdir(base, 'p')
  return base .. '/' .. root:gsub('/', '%%') .. '.shada'
end

vim.o.shadafile = shadafile(vim.fn.getcwd())

local group = vim.api.nvim_create_augroup('project-shada', { clear = true })

vim.api.nvim_create_autocmd('DirChangedPre', {
  group = group,
  pattern = 'global',
  callback = function()
    vim.cmd 'wshada'
  end,
})

vim.api.nvim_create_autocmd('DirChanged', {
  group = group,
  pattern = 'global',
  callback = function()
    local file = shadafile(vim.v.event.cwd)
    if file == vim.o.shadafile then
      return
    end
    vim.o.shadafile = file

    -- :rshada! only overwrites what the new file contains, so drop the old
    -- project's state first or it would leak into (and be saved with) this one.
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      vim.api.nvim_win_call(win, function()
        vim.cmd.clearjumps()
      end)
    end
    for _, hist in ipairs { 'cmd', 'search', 'expr', 'input', 'debug' } do
      vim.fn.histdel(hist)
    end
    for c in ('abcdefghijklmnopqrstuvwxyz0123456789-'):gmatch '.' do
      vim.fn.setreg(c, {})
    end
    vim.cmd 'delmarks A-Z0-9'
    vim.v.oldfiles = {}

    pcall(vim.cmd, 'rshada!')
  end,
})
