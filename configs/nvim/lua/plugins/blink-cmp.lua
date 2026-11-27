return {
    "saghen/blink.cmp",
    dependencies = {
        "saghen/blink.lib",
        "rafamadriz/friendly-snippets",
    },
    build = {
        -- build() writes cargo's output only to blink's log file, so run cargo through lazy first to see it.
        "cargo build --release",
        function()
            require("blink.cmp").build():pwait()
        end,
    },

    opts = {
        keymap = { preset = "default" },
        completion = { documentation = { auto_show = false } },
        sources = { default = { "lsp", "path", "snippets", "buffer" } },
        fuzzy = { implementation = "rust" },
    },
}
