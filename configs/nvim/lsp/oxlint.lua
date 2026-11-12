return {
    cmd = { "oxlint", "--lsp" },
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
    },
    root_markers = { ".oxlintrc.json", "package.json", ".git" },
}
