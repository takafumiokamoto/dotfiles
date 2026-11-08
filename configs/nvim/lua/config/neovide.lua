vim.opt.linespace = -1
vim.keymap.set({ "n", "v" }, "<D-v>", [["+p]])
vim.keymap.set({ "i", "c" }, "<D-v>", "<C-r>+")
vim.keymap.set({ "n", "v", "i" }, "<D-a>", "<Esc>ggVG", { desc = "Select All" })
vim.g.neovide_fullscreen = false
local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
local main_color = normal_hl.bg and string.format("%x", normal_hl.bg) or "282c34"
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_title_background_color = main_color
--vim.g.neovide_title_text_color = "white"
vim.g.neovide_title_text_color = main_color
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0
vim.g.neovide_input_macos_option_key_is_meta = "only_left"

vim.g.neovide_input_ime = false
local ime_input = vim.api.nvim_create_augroup("ime_input", { clear = true })
local function set_ime(args)
    vim.g.neovide_input_ime = args.event:match("Enter$") ~= nil
end
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave", "TermEnter", "TermLeave" }, {
    group = ime_input,
    callback = set_ime,
})
vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    group = ime_input,
    pattern = "[\\/\\?]",
    callback = set_ime,
})

vim.g.neovide_padding_top = 0
vim.g.neovide_padding_bottom = 0
vim.g.neovide_padding_right = 0
vim.g.neovide_padding_left = 0
vim.g.neovide_progress_bar_enabled = false
local animation = os.getenv("NEOVIDE_ANIMATION_ENABLE")
if animation == "1" then
    vim.g.neovide_cursor_animate_in_insert_mode = true
    vim.g.neovide_cursor_animate_command_line = true
    vim.g.neovide_cursor_smooth_blink = true
    vim.g.neovide_cursor_vfx_mode = "railgun"
else
    vim.g.neovide_position_animation_length = 0
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = false
    vim.g.neovide_cursor_animation_far_lines = 0
    vim.g.neovide_cursor_animation_length = 0
end
