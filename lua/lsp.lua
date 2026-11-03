local servers = {
  bashls = { settings = { includeAllWorkspaceSymbols = true } },
  clangd = {},
  gopls = {},
  intelephense = {
    init_options = { licenceKey = '~/.config/intelephense' },
    settings = { intelephense = { format = { enable = false } } },
    root_markers = { 'composer.json', '.git', '.svn' },
  },
  jsonls = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        completion = { callSnippet = 'Replace' },
        workspace = { library = { vim.env.VIMRUNTIME .. '/lua', '${3rd}/luv/library' }, checkThirdParty = false },
      },
    },
  },
  perlnavigator = {},
  ruff = {},
  rust_analyzer = {},
  ty = {},
  ts_ls = {},
  yamlls = {
    settings = {
      yaml = {
        validate = true,
        format = { enable = false },
        hover = true,
        schemaStore = { enable = true, url = 'https://www.schemastore.org/api/json/catalog.json' },
      },
    },
  },
}

local mason_packages = {
  'bash-language-server',
  'clangd',
  'gopls',
  'intelephense',
  'json-lsp',
  'lua-language-server',
  'perlnavigator',
  'ruff',
  'ty',
  'typescript-language-server',
  'yaml-language-server',
  'stylua',
  'goimports',
  'delve',
  'debugpy',
}

require('mason').setup()
require('mason-registry').refresh(function()
  local registry = require 'mason-registry'
  for _, name in ipairs(mason_packages) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() then
      vim.notify('Mason: installing ' .. name)
      pkg:install()
    end
  end
end)

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
end
vim.lsp.enable(vim.tbl_keys(servers))
vim.lsp.enable 'sourcekit'

vim.api.nvim_create_user_command('LspInfo', 'checkhealth vim.lsp', {})
vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd.edit(vim.lsp.log.get_filename())
end, {})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local function map(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end

    local picker = Snacks.picker
    map('gd', picker.lsp_definitions, 'Goto definition')
    map('gD', picker.lsp_declarations, 'Goto declaration')
    map('gR', picker.lsp_references, 'References (picker)')
    map('gI', picker.lsp_implementations, 'Goto implementation')
    map('gT', picker.lsp_type_definitions, 'Goto type definition')
    map('<leader>ss', picker.lsp_symbols, 'Document symbols')
    map('<leader>sS', picker.lsp_workspace_symbols, 'Workspace symbols')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })

    if client:supports_method 'textDocument/completion' then
      -- Servers only advertise a few trigger characters (gopls: just '.'), so also
      -- trigger on identifier characters to get as-you-type completion like nvim-cmp.
      -- Only fires when the menu is closed; native fuzzy filtering handles the rest.
      local provider = client.server_capabilities.completionProvider
      local triggers = provider.triggerCharacters or {}
      if not vim.list_contains(triggers, 'a') then
        for c in ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'):gmatch '.' do
          table.insert(triggers, c)
        end
        provider.triggerCharacters = triggers
      end
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.keymap.set('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ 'selected' }).selected ~= -1 then
    return vim.keycode '<C-y>'
  end
  return MiniPairs.cr()
end, { expr = true, replace_keycodes = false })
