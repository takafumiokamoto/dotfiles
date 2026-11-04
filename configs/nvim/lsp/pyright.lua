return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
            },
        },
    },
    -- Pyright does not discover a project's .venv on its own.
    before_init = function(_, config)
        local python = config.root_dir and (config.root_dir .. "/.venv/bin/python")
        if python and vim.uv.fs_stat(python) then
            config.settings.python.pythonPath = python
        end
    end,
}
