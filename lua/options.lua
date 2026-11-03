local o = vim.o

o.number = true
o.mouse = 'a'
o.showmode = false
o.breakindent = true
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.signcolumn = 'yes'
o.updatetime = 250
o.timeoutlen = 300
o.splitright = true
o.splitbelow = true
o.list = false
o.listchars = 'tab:-> ,trail:·,nbsp:␣'
o.inccommand = 'split'
o.cursorline = true
o.scrolloff = 10
o.winborder = 'rounded'
o.pumborder = 'rounded'
o.pummaxwidth = 80

o.pumheight = 12

-- No buffer-word autocompletion; LSP autotriggers its own menu (see lsp.lua).
o.autocomplete = false
o.complete = 'o,.^5,w^5,b^5'
o.completeopt = 'menu,menuone,noinsert,fuzzy,popup'

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('pmenu-hl', { clear = true }),
  callback = function()
    local hl = vim.api.nvim_set_hl
    hl(0, 'Pmenu', { link = 'NormalFloat' })
    hl(0, 'PmenuBorder', { link = 'FloatBorder' })
    hl(0, 'PmenuSel', { link = 'Visual' })
    hl(0, 'PmenuKind', { link = 'Type' })
    hl(0, 'PmenuKindSel', { link = 'Visual' })
    hl(0, 'PmenuExtra', { link = 'Comment' })
    hl(0, 'PmenuExtraSel', { link = 'Visual' })
    hl(0, 'PmenuMatch', { link = 'Special' })
    hl(0, 'PmenuMatchSel', { link = 'Special' })
  end,
})

-- Buffers loaded while events were suppressed (session restore, picker previews)
-- never get a filetype, so LSP and treesitter never start for them.
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('late-filetype-detect', { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == '' and vim.bo[ev.buf].buftype == '' and vim.api.nvim_buf_get_name(ev.buf) ~= '' then
      vim.cmd 'filetype detect'
    end
  end,
})

o.grepprg = 'rg --vimgrep --smart-case --hidden --glob !.git'
o.grepformat = '%f:%l:%c:%m'

o.sessionoptions = o.sessionoptions .. ',globals'

vim.schedule(function()
  o.clipboard = 'unnamedplus'
  if vim.env.SSH_TTY then
    local osc52 = require 'vim.ui.clipboard.osc52'
    local function paste()
      return { vim.split(vim.fn.getreg '', '\n'), vim.fn.getregtype '' }
    end
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = { ['+'] = osc52.copy '+', ['*'] = osc52.copy '*' },
      paste = { ['+'] = paste, ['*'] = paste },
    }
  end
end)

vim.diagnostic.config {
  virtual_text = { current_line = false, severity = { min = vim.diagnostic.severity.INFO } },
  underline = { severity = { min = vim.diagnostic.severity.ERROR } },
  signs = {
    severity = { min = vim.diagnostic.severity.INFO },
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
    linehl = { [vim.diagnostic.severity.ERROR] = 'ErrorMsg' },
    numhl = { [vim.diagnostic.severity.WARN] = 'WarningMsg' },
  },
}

if #vim.api.nvim_list_uis() > 0 then
  require('vim._core.ui2').enable {}
end
