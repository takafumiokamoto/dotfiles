return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            go = { "gofmt" },
            sh = { "shfmt" },
            bash = { "shfmt" },

            javascript = { "oxfmt" },
            javascriptreact = { "oxfmt" },
            typescript = { "oxfmt" },
            typescriptreact = { "oxfmt" },
            json = { "oxfmt" },
            yaml = { "oxfmt" },
            yml = { "oxfmt" },
            html = { "oxfmt" },
            css = { "oxfmt" },
            scss = { "oxfmt" },
            less = { "oxfmt" },
            toml = { "oxfmt" },
            markdown = { "oxfmt" },
        },
        format_on_save = {
            timeout_ms = 10000,
            lsp_format = "fallback",
        },
    },
}
