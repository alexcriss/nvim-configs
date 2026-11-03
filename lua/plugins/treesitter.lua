local ts = require 'nvim-treesitter'

ts.setup {}

local languages = {
  'bash',
  'c',
  'css',
  'diff',
  'dockerfile',
  'git_config',
  'git_rebase',
  'gitcommit',
  'gitignore',
  'go',
  'gomod',
  'gosum',
  'gowork',
  'hcl',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'perl',
  'php',
  'python',
  'query',
  'regex',
  'sql',
  'terraform',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

ts.install(languages)

local no_indent = { ruby = true, php = true, perl = true }

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
  callback = function(ev)
    local ft = ev.match
    local lang = vim.treesitter.language.get_lang(ft) or ft
    if not vim.treesitter.language.add(lang) then
      if vim.tbl_contains(ts.get_available(), lang) then
        ts.install { lang }
      end
      return
    end
    pcall(vim.treesitter.start, ev.buf, lang)
    if no_indent[ft] then
      -- The stock indent scripts read legacy syntax groups (php's falls back to
      -- column 0 without them), so keep regex syntax running under treesitter.
      vim.bo[ev.buf].syntax = 'ON'
    else
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require('treesitter-context').setup { max_lines = 4 }
