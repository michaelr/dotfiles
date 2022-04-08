-- Enable (broadcasting) snippet capability for completion
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
--
--
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol
                                                                     .make_client_capabilities())

require'lspconfig'.elixirls.setup{
    capabilities = capabilities,
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

-- TypeScript/JavaScript
-- from: https://jose-elias-alvarez.medium.com/configuring-neovims-lsp-client-for-typescript-development-5789d58ea9c
-- TODO: should I use this on_attach function for all lang servers?
local buf_map = function(bufnr, mode, lhs, rhs, opts)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts or {
        silent = true,
    })
end
local on_attach = function(client, bufnr)
    vim.cmd("command! LspDef lua vim.lsp.buf.definition()")
    vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")
    vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
    vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
    vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
    vim.cmd("command! LspRefs lua vim.lsp.buf.references()")
    vim.cmd("command! LspTypeDef lua vim.lsp.buf.type_definition()")
    vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
    vim.cmd("command! LspDiagPrev lua vim.lsp.diagnostic.goto_prev()")
    vim.cmd("command! LspDiagNext lua vim.lsp.diagnostic.goto_next()")
    vim.cmd("command! LspDiagLine lua vim.lsp.diagnostic.show_line_diagnostics()")
    vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")
    buf_map(bufnr, "n", "gd", ":LspDef<CR>")
    buf_map(bufnr, "n", "gr", ":LspRename<CR>")
    buf_map(bufnr, "n", "gy", ":LspTypeDef<CR>")
    buf_map(bufnr, "n", "K", ":LspHover<CR>")
    buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>")
    buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>")
    buf_map(bufnr, "n", "ga", ":LspCodeAction<CR>")
    buf_map(bufnr, "n", "<Leader>a", ":LspDiagLine<CR>")
    buf_map(bufnr, "i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>")
    if client.resolved_capabilities.document_formatting then
        vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
end
require'lspconfig'.tsserver.setup {
    capabilities = capabilities,
    cmd = lang_servers_cmd.tsserver,
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
        local ts_utils = require("nvim-lsp-ts-utils")
        ts_utils.setup({
            eslint_bin = "eslint_d",
            eslint_enable_diagnostics = true,
            eslint_enable_code_actions = true,
            enable_formatting = true,
            formatter = "prettier",
            -- disable 'Could not find a declaration file for module..'
            filter_out_diagnostics_by_code = { 7016 },
        })
        ts_utils.setup_client(client)
        -- buf_map(bufnr, "n", "gs", ":TSLspOrganize<CR>")
        -- buf_map(bufnr, "n", "gi", ":TSLspRenameFile<CR>")
        -- buf_map(bufnr, "n", "go", ":TSLspImportAll<CR>")

        on_attach(client, bufnr)
    end,
}
--require'lspconfig'["null-ls"].setup({ capabilities = capabilities, on_attach = on_attach })

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
    formatting = {
        format = lspkind.cmp_format({
            with_text = true,
            maxwidth = 50,
            menu = {
                buffer = "[buf]",
                nvim_lsp = "[lsp]",
                nvim_lua = "[lua]",
                path = "[path]",
                luasnip = "[snip]",
                treesitter = "[tsit]"
            }
    })},
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
    --sources = cmp.config.sources({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' }, -- only gets enabled in lua files
        { name = 'treesitter' },
        { name = 'path' },
        { name = 'luasnip' },
        { name = 'buffer', keyword_length = 3 },
    }
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

-- Gutter diagnostic icons

local signs = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = ""
}
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { texthl = hl, numhl = hl, text = icon })
end

