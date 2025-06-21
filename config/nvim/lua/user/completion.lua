-------------------------------------------------------------------------------
-- user/completion.lua
-------------------------------------------------------------------------------

local function setup()
    local cmp_ok, cmp = pcall(require, 'cmp')
    if not cmp_ok then
        vim.notify('nvim-cmp not found')
        return
    end

    local luasnip_ok, luasnip = pcall(require, 'luasnip')
    if not luasnip_ok then
        vim.notify('luasnip not found')
    end

    local select_opts = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' },
            { name = 'luasnip' },
        }),
        mapping = cmp.mapping.preset.insert({
            ['<c-j>'] = cmp.mapping.scroll_docs(1),
            ['<c-k>'] = cmp.mapping.scroll_docs(-1),
            ['<c-n>'] = cmp.mapping.select_next_item(select_opts),
            ['<c-p>'] = cmp.mapping.select_prev_item(select_opts),
            ['<tab>'] = cmp.mapping.confirm({
                select = true,
                behavior = cmp.ConfirmBehavior.Replace,
            }),
        }),
        preselect = cmp.PreselectMode.Item,
        completion = {
            keyword_length = 0,
        },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        snippet = {
            expand = function (args)
                if luasnip_ok then
                    luasnip.lsp_expand(args.body)
                end
            end,
        },
        experimental = {
            ghost_text = true,
        },
    })
    cmp.setup.cmdline({'/', '?'}, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' },
        },
    })
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        completion = {
            keyword_length = 2,
        },
        sources = {
            { name = 'path' },
            { name = 'cmdline' },
        },
    })
end

return { setup = setup }
