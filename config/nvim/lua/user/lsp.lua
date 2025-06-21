-------------------------------------------------------------------------------
-- user/lsp.lua
-------------------------------------------------------------------------------

local function setup_mason()
    local ok, mason = pcall(require, 'mason')
    if not ok then
        vim.notify('mason not found')
        return
    end
    mason.setup({
        ui = {
            icons = {
                package_installed = 'O',
                package_pending = '-',
                package_uninstalled = 'X',
            },
        },
    })
end


local function on_attach(_, bufnr)
    local function map(mode, lhs, rhs, desc)
        local opts = {
            noremap = true,
            silent = true,
            buffer = bufnr,
            desc = 'LSP: ' .. desc,
        }
        vim.keymap.set(mode, lhs, rhs, opts)
    end
    local function remap(mode, lhs, rhs, desc)
        local opts = {
            remap = true,
            silent = true,
            buffer = bufnr,
            desc = 'LSP: ' .. desc .. ' (remap)',
        }
        vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- core
    map('n', 'gd', vim.lsp.buf.definition, 'go to definition')
    map('n', 'K', vim.lsp.buf.hover, 'hover documentation')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'rename symbol')
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'code action')

    -- diagnostics
    remap('n', '<leader>d[', '[d', 'previous diagnostic')
    remap('n', '<leader>d]', ']d', 'next diagnostic')
    map('n', '<leader>dl', vim.diagnostic.setloclist, 'open diagnostics list')
    map('n', '<leader>do', vim.diagnostic.open_float, 'show diagnostic float')
end


local function on_attach_event_callback(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
        return
    end
    for bufnr, _ in pairs(client.attached_buffers) do
        on_attach(client, bufnr)
    end
end


local function setup_lsp_config()
    -- cmp-nvim-lsp
    local capabilities
    local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if ok then
        capabilities = cmp_nvim_lsp.default_capabilities()
    else
        vim.notify('cmp-nvim-lsp not found; fallback to empty capabilities')
        capabilities = {}
    end

    -- default config for all language servers
    vim.lsp.config('*', {
        capabilities = capabilities,
    })
    local lspGroup = vim.api.nvim_create_augroup('LspGroup', { clear = true })
    vim.api.nvim_create_autocmd('LspAttach', {
        group = lspGroup,
        callback = on_attach_event_callback,
    })

    -- basedpyright
    vim.lsp.config('basedpyright', {
        settings = {
            basedpyright = {
                autoSearchPaths = true,
                disableOrganizeImports = true,
                disableTaggedHints = false,
                analysis = {
                    autoImportCompletions = false,
                    autoSearchPaths = true,
                    diagnosticMode = 'openFilesOnly',
                    -- setting below can be overridden by pyrightconfig.json
                    diagnosticSeverityOverrides = {
                        -- values: error/warning/information/true/false/none
                        reportMissingImports = 'error',
                    },
                    ignore = {
                        -- file paths to ignore
                    },
                },
            },
        },
    })

    -- lua-ls / lua-language-server
    vim.lsp.config('lua_ls', {
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file('', true),
                    checkThirdParty = false,
                },
                format = {
                    enable = true,
                    defaultConfig = {
                        indent_style = 'space',
                        indent_size = '4',
                    },
                },
            },
        },
    })

    vim.lsp.enable('basedpyright')
    vim.lsp.enable('bashls')
    vim.lsp.enable('lua_ls')
end


local function setup()
    vim.diagnostic.config({
        underline = true,
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        severity_sort = true,
    })
    setup_lsp_config()
    setup_mason()
end


return { setup = setup }
