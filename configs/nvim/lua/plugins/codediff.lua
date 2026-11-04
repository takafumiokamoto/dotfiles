return {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
        { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "CodeDiff: Open" },
    },
    config = function()
        require("codediff").setup({
            -- VS Code's dark diff colors, blended over afterglow's background (#1a1a1a).
            -- afterglow's DiffAdd/DiffDelete backgrounds match Normal, so the defaults show no tint.
            highlights = {
                line_insert = "#343a26",
                line_delete = "#481515",
                char_insert = "#495727",
                char_delete = "#6d1111",
            },
            diff = {
                cycle_hunks_across_files = true,
            },
            explorer = {
                view_mode = "tree",
                initial_focus = "modified",
            },
        })
    end,
}
