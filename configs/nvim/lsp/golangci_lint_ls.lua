return {
    cmd = { "golangci-lint-langserver" },
    filetypes = { "go", "gomod" },
    root_markers = {
        ".golangci.yml",
        ".golangci.yaml",
        ".golangci.toml",
        ".golangci.json",
        "go.work",
        "go.mod",
        ".git",
    },
    init_options = {
        -- The server runs this command (golangci-lint v2 flags) with the buffer's directory appended.
        command = {
            "golangci-lint",
            "run",
            -- the server only reads JSON from stdout
            "--output.json.path=stdout",
            "--show-stats=false",
            -- turn off every other output a project's .golangci.yml may enable
            "--output.text.path=",
            "--output.tab.path=",
            "--output.html.path=",
            "--output.checkstyle.path=",
            "--output.junit-xml.path=",
            "--output.teamcity.path=",
            "--output.sarif.path=",
            -- the server ignores the output when the exit code is 0
            "--issues-exit-code=1",
        },
    },
}
