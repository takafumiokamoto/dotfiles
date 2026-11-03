return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        on_attach = function(bufnr)
            local gitsigns = require("gitsigns")

            -- Diffview (Vim の diff モード) と同じキー。
            -- diff モード中は本来の動作にフォールバックする。
            local function map(lhs, fn, desc)
                vim.keymap.set("n", lhs, function()
                    if vim.wo.diff then
                        vim.cmd.normal({ lhs, bang = true })
                    else
                        fn()
                    end
                end, { buffer = bufnr, desc = desc })
            end

            map("]c", function()
                gitsigns.nav_hunk("next")
            end, "Next git hunk")
            map("[c", function()
                gitsigns.nav_hunk("prev")
            end, "Previous git hunk")
            map("do", function()
                gitsigns.reset_hunk()
            end, "Reset git hunk")
        end,
    },
}
