return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "leoluz/nvim-dap-go",
        "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
        local dap = require("dap")
        local dap_go = require("dap-go")
        local dapui = require("dapui")

        dapui.setup()
        require("nvim-dap-virtual-text").setup()

        dap_go.setup({
            delve = {
                detached = vim.fn.has("win32") == 0,
            },
        })

        -- Prefer the project's .venv so imports resolve the same way as at runtime.
        local function python_path()
            local root = vim.fs.root(0, ".venv")
            return root and (root .. "/.venv/bin/python") or "python3"
        end

        dap.adapters.python = function(callback, config)
            local options = { source_filetype = "python" }
            if config.request == "attach" then
                callback({
                    type = "server",
                    host = config.connect.host,
                    port = config.connect.port,
                    options = options,
                })
            else
                callback({ type = "executable", command = "debugpy-adapter", options = options })
            end
        end

        dap.configurations.python = {
            {
                type = "python",
                request = "launch",
                name = "Debug current file",
                program = "${file}",
                console = "integratedTerminal",
                python = python_path,
            },
            {
                type = "python",
                request = "launch",
                name = "Debug pytest (current file)",
                module = "pytest",
                args = { "${file}" },
                console = "integratedTerminal",
                python = python_path,
            },
            {
                -- Attach needs debugpy in the target environment, e.g.
                -- uv run --with debugpy python -m debugpy --listen 5678 main.py
                type = "python",
                request = "attach",
                name = "Attach to port",
                connect = function()
                    local port = tonumber(vim.fn.input("debugpy port: ", "5678"))
                    return port and { host = "127.0.0.1", port = port } or dap.ABORT
                end,
            },
        }

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end,
}
