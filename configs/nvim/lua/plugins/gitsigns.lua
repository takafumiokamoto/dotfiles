local function nav_hunk(lhs, direction)
    return function()
        if vim.wo.diff or not vim.b.gitsigns_status_dict then
            vim.cmd.normal({ lhs, bang = true })
        else
            require("gitsigns").nav_hunk(direction)
        end
    end
end

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
        { "]c", nav_hunk("]c", "next"), desc = "Next git hunk" },
        { "[c", nav_hunk("[c", "prev"), desc = "Previous git hunk" },
    },
}
