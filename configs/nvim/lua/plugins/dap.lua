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

        require("dapui").setup()

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
                -- Pass the function itself, not its result, so it runs when the session starts.
                python = project_python,
                -- Run from the project root like `uv run`; debugpy defaults to the script's directory.
                cwd = "${workspaceFolder}",
                -- Show output and accept input() in a terminal split instead of the REPL.
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
    end,
}
