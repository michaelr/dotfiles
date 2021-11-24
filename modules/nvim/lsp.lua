-- Enable (broadcasting) snippet capability for completion
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
--
--
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol
                                                                     .make_client_capabilities())

require'lspconfig'.elixirls.setup{
    cmd = lang_servers_cmd.elixirls
}
-- bash
require'lspconfig'.bashls.setup {  cmd = lang_servers_cmd.bashls}

-- cmake
-- require'lspconfig'.cmake.setup {cmd = lang_servers_cmd.cmake}

-- css
require'lspconfig'.cssls.setup {
    capabilities = capabilities,
    cmd = lang_servers_cmd.cssls
}

-- docker
require'lspconfig'.dockerls.setup {cmd = lang_servers_cmd.dockerls}

-- go
require'lspconfig'.gopls.setup {cmd = lang_servers_cmd.gopls}

-- Haskell
require'lspconfig'.hls.setup {
    settings = {languageServerHaskell = {formattingProvider = "brittany"}},
    cmd = lang_servers_cmd.hls
}

-- html
require'lspconfig'.html.setup {capabilities = capabilities, cmd = lang_servers_cmd.html}

-- json
require'lspconfig'.jsonls.setup {cmd = lang_servers_cmd.jsonls}

-- lua
require'lspconfig'.sumneko_lua.setup {
    cmd = {"lua-language-server"},
    settings = {Lua = {diagnostics = {globals = {'vim', 'lang_servers_cmd'}}}}
}

-- nix
require'lspconfig'.rnix.setup {cmd = lang_servers_cmd.rnix}

-- Python
require'lspconfig'.pyright.setup {cmd = lang_servers_cmd.pyright}

-- Rust
require'rust-tools'.setup()
require'lspconfig'.rust_analyzer.setup {
    on_attach = function()
        require'lsp_signature'.on_attach({
            bind = true,
            handler_opts = {border = 'single'}
        })
    end
}

-- TypeScript/JavaScript
require'lspconfig'.tsserver.setup {cmd = lang_servers_cmd.tsserver}

-- vim
require'lspconfig'.vimls.setup {cmd = lang_servers_cmd.vimls}

-- signature help
require'lsp_signature'.on_attach({bind = true, handler_opts = {border = 'single'}})

-- vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]

--

-- Jump to Definition/Refrences/Implementation
vim.api.nvim_set_keymap('n', 'gd', [[<cmd>lua vim.lsp.buf.definition()<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gi', [[<cmd>lua vim.lsp.buf.implementation()<CR>]],
                        {noremap = true, silent = true})

-- Completion

vim.o.completeopt = "menuone,noselect"

-- Setup nvim-cmp.
local cmp = require 'cmp'
local lspkind = require('lspkind')

lspkind.init({})

cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    formatting = {format = lspkind.cmp_format({with_text = true, maxwidth = 50})},
    mapping = {
        ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
        -- If you want to remove the default `<C-y>` mapping, You can specify
        -- `cmp.config.disable` value.
        ['<C-y>'] = cmp.config.disable,
        ['<C-e>'] = cmp.mapping({i = cmp.mapping.abort(), c = cmp.mapping.close()}),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = false
        }),
        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    })
})

  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })



-- AUTO FORMATTING

vim.api.nvim_command[[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]

-- lsp shit that can't be done in lua atm.
-- Note: This is even worse then writing vimscript (Can't believe that would be possible but here you go)
-- vim.api.nvim_command(
--  'autocmd BufWritePre *.rs  lua vim.lsp.buf.formatting_sync(nil, 1000)')
-- vim.api.nvim_command(
--  'autocmd BufWritePre *.hs  lua vim.lsp.buf.formatting_sync(nil, 1000)')
-- vim.api.nvim_command(
--  'autocmd BufWritePre *.py  lua vim.lsp.buf.formatting_sync(nil, 1000)')
-- vim.api.nvim_command(
--  'autocmd BufWritePre *.lua lua vim.lsp.buf.formatting_sync(nil, 1000)')
-- vim.api.nvim_command(
--  'autocmd BufWritePre *.nix lua vim.lsp.buf.formatting_sync(nil, 1000)')

-- Prettify LSP diagnostic messages/icons

require('lspkind').init({})

vim.fn.sign_define("LspDiagnosticsSignError", {
    texthl = "LspDiagnosticsSignError",
    text = "",
    numhl = "LspDiagnosticsSignError"
})
vim.fn.sign_define("LspDiagnosticsSignWarning", {
    texthl = "LspDiagnosticsSignWarning",
    text = "",
    numhl = "LspDiagnosticsSignWarning"
})
vim.fn.sign_define("LspDiagnosticsSignHint", {
    texthl = "LspDiagnosticsSignHint",
    text = "",
    numhl = "LspDiagnosticsSignHint"
})
vim.fn.sign_define("LspDiagnosticsSignInformation", {
    texthl = "LspDiagnosticsSignInformation",
    text = "",
    numhl = "LspDiagnosticsSignInformation"
})

