return {
    {
        "NTBBloodbath/doom-one.nvim",
        config = function()
            -- Override the palette's background (default: #282c34)
            require("doom-one.colors").dark.bg = "#202224"
        end,
    },
    {
        "danilo-augusto/vim-afterglow",
    },
    {
        "ramojus/mellifluous.nvim",
        config = function()
            require("mellifluous").setup({
                color_overrides = {
                    dark = {
                        bg = function()
                            return require("mellifluous.color").new("#202224")
                            --return require("mellifluous.color").new("#1a1a1a")
                        end,
                    },
                },
                flat_background = {
                    line_numbers = true,
                    cursor_line_number = true,
                },
            })
        end,
    },
}
