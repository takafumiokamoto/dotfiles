vim.api.nvim_create_autocmd("ColorSchemePre", {
    pattern = "accent",
    callback = function()
        vim.g.accent_color = "green"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "html",
        "css",
        "scss",
        "less",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "yaml",
    },
    callback = function(args)
        vim.bo[args.buf].shiftwidth = 2
        vim.bo[args.buf].tabstop = 2
    end,
})
