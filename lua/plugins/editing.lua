require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind 'prepend'
require('mini.ai').setup { n_lines = 500 }
require('mini.pairs').setup()
local function statusline_sections()
  local S = MiniStatusline
  return {
    git = S.section_git { trunc_width = 40 },
    diff = S.section_diff { trunc_width = 75 },
    diagnostics = S.section_diagnostics { trunc_width = 75 },
    lsp = S.section_lsp { trunc_width = 75 },
    filename = S.section_filename { trunc_width = 140 },
    fileinfo = S.section_fileinfo { trunc_width = 120 },
    location = S.section_location { trunc_width = 75 },
    search = S.section_searchcount { trunc_width = 75 },
  }
end

local function snacks_statusline()
  if vim.bo.filetype == 'snacks_picker_list' then
    return '%#MiniStatuslineFilename# Explorer'
  elseif vim.bo.filetype:match '^snacks_' then
    return ''
  end
end

require('mini.statusline').setup {
  content = {
    active = function()
      local special = snacks_statusline()
      if special then
        return special
      end
      local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
      local s = statusline_sections()
      return MiniStatusline.combine_groups {
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { s.git, s.diff, s.diagnostics, s.lsp } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { s.filename } },
        '%=',
        { hl = 'MiniStatuslineFileinfo', strings = { s.fileinfo } },
        { hl = mode_hl, strings = { s.search, s.location } },
      }
    end,
    inactive = function()
      local special = snacks_statusline()
      if special then
        return special
      end
      local s = statusline_sections()
      return MiniStatusline.combine_groups {
        { hl = 'MiniStatuslineDevinfo', strings = { s.git, s.diff, s.diagnostics, s.lsp } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { s.filename } },
        '%=',
        { hl = 'MiniStatuslineFileinfo', strings = { s.fileinfo } },
        { hl = 'MiniStatuslineDevinfo', strings = { s.location } },
      }
    end,
  },
}

require('which-key').setup {
  spec = {
    { '<leader>c', group = 'Code', mode = { 'n', 'x' } },
    { '<leader>d', group = 'Debug' },
    { '<leader>g', group = 'Git' },
    { '<leader>h', group = 'Git hunk', mode = { 'n', 'v' } },
    { '<leader>m', group = 'Multicursor', mode = { 'n', 'x' } },
    { '<leader>o', group = 'Open' },
    { '<leader>r', group = 'Rename' },
    { '<leader>s', group = 'Search' },
    { '<leader>S', group = 'Search & replace' },
    { '<leader>t', group = 'Toggle' },
    { '<leader>x', group = 'Quickfix / diagnostics' },
  },
}

require('guess-indent').setup {}

local mc = require 'multicursor-nvim'
mc.setup()
local set = vim.keymap.set
set({ 'n', 'x' }, '<C-n>', function()
  mc.matchAddCursor(1)
end, { desc = 'Add cursor at next match' })
set({ 'n', 'x' }, '<C-Up>', function()
  mc.lineAddCursor(-1)
end, { desc = 'Add cursor above' })
set({ 'n', 'x' }, '<C-Down>', function()
  mc.lineAddCursor(1)
end, { desc = 'Add cursor below' })
set({ 'n', 'x' }, '<leader>ma', mc.matchAllAddCursors, { desc = 'Cursor at every match' })
set({ 'n', 'x' }, '<leader>mm', mc.operator, { desc = 'Cursor at matches in range (operator)' })
set({ 'n', 'x' }, 'ga', mc.addCursorOperator, { desc = 'Cursor on every line of motion' })
set('n', '<C-LeftMouse>', mc.handleMouse)
set('n', '<C-LeftDrag>', mc.handleMouseDrag)
set('n', '<C-LeftRelease>', mc.handleMouseRelease)
set({ 'n', 'x' }, '<C-q>', mc.toggleCursor, { desc = 'Pause / resume cursors' })
mc.addKeymapLayer(function(layer)
  layer({ 'n', 'x' }, 'q', function()
    mc.matchSkipCursor(1)
  end)
  layer({ 'n', 'x' }, 'Q', mc.deleteCursor)
  layer({ 'n', 'x' }, '<Left>', mc.prevCursor)
  layer({ 'n', 'x' }, '<Right>', mc.nextCursor)
  layer('n', '<Esc>', function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)

require('oil').setup {}
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Edit parent directory' })

require('grug-far').setup {}
local grug = require 'grug-far'
vim.keymap.set('n', '<leader>Ss', grug.open, { desc = 'Search & replace' })
vim.keymap.set('n', '<leader>Sw', function()
  grug.open { prefills = { search = vim.fn.expand '<cword>' } }
end, { desc = 'Search & replace current word' })
vim.keymap.set('x', '<leader>Sw', function()
  grug.with_visual_selection()
end, { desc = 'Search & replace selection' })
vim.keymap.set('n', '<leader>Sf', function()
  grug.open { prefills = { paths = vim.fn.expand '%' } }
end, { desc = 'Search & replace in current file' })

require('quicker').setup {
  keys = {
    {
      '>',
      function()
        require('quicker').expand { before = 2, after = 2, add_to_existing = true }
      end,
      desc = 'Expand quickfix context',
    },
    {
      '<',
      function()
        require('quicker').collapse()
      end,
      desc = 'Collapse quickfix context',
    },
  },
}
vim.keymap.set('n', '<leader>q', function()
  require('quicker').toggle()
end, { desc = 'Toggle quickfix' })
vim.keymap.set('n', '<leader>l', function()
  require('quicker').toggle { loclist = true }
end, { desc = 'Toggle loclist' })
