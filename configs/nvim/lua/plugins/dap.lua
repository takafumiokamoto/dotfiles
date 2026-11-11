local function project_python()
    local root = vim.fs.root(0, ".venv")
    return root and (root .. "/.venv/bin/python") or "python3"
end

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
    },
    lazy = false,
    keys = {
        { "<F5>", "<cmd>DapContinue<cr>", desc = "Debug: Start/Continue" },
        { "<leader>ds", "<cmd>DapContinue<cr>", desc = "Debug: Start/Continue" },
        { "<S-F5>", "<cmd>DapTerminate<cr>", desc = "Debug: Terminate" },
        { "<F10>", "<cmd>DapStepOver<cr>", desc = "Debug: Step over" },
        { "<F11>", "<cmd>DapStepInto<cr>", desc = "Debug: Step in" },
        { "<C-F11>", "<cmd>DapStepInto<cr>", desc = "Debug: Step in" },
        { "<F35>", "<cmd>DapStepInto<cr>", desc = "Debug: Step in" },
        { "<S-F11>", "<cmd>DapStepOut<cr>", desc = "Debug: Step out" },

        { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Debug: Toggle break point" },
        {
            "<leader>dB",
            '<cmd>lua require("dap").set_breakpoint(vim.fn.input("Condition: "))<cr>',
            desc = "Debug: Set conditional break point",
        },
        { "<leader>dc", '<cmd>lua require("dap").run_to_cursor()<cr>', desc = "Debug: Run to cursor" },
        { "<leader>dl", '<cmd>lua require("dap").run_last()<cr>', desc = "Debug: Run last" },
        { "<leader>du", '<cmd>lua require("dapui").toggle()<cr>', desc = "Debug: Toggle UI" },
    },
    config = function()
        local dap = require("dap")

        require("dapui").setup({})

        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function()
                vim.api.nvim_set_hl(0, "debugPC", { bg = "#484815" })
            end,
        })

        dap.adapters.debugpy = {
            type = "executable",
            command = "debugpy-adapter",
        }

        dap.configurations.python = {
            {
                type = "debugpy",
                request = "launch",
                name = "Launch current file",
                program = "${file}",
                python = project_python,
                cwd = "${workspaceFolder}",
                console = "integratedTerminal",
            },
            {
                type = "debugpy",
                request = "launch",
                name = "pytest current file",
                module = "pytest",
                args = { "${file}" },
                python = project_python,
                cwd = "${workspaceFolder}",
                console = "integratedTerminal",
            },
        }

        dap.adapters.go = {
            type = "server",
            port = "${port}",
            executable = {
                command = "dlv",
                args = { "dap", "-l", "127.0.0.1:${port}" },
            },
        }

        dap.configurations.go = {
            {
                type = "go",
                request = "launch",
                name = "Run current Go file",
                program = "${file}",
                outputMode = "remote",
            },
        }
    end,
}
