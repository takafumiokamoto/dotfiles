local hyper = { "option", "shift" }

hs.hotkey.bind(hyper, "h", function()
    local win = hs.window.frontmostWindow()
    if win then
        win:focusWindowWest(nil, true, true)
    end
end)

hs.hotkey.bind(hyper, "j", function()
    local win = hs.window.frontmostWindow()
    if win then
        win:focusWindowSouth(nil, true, true)
    end
end)

hs.hotkey.bind(hyper, "k", function()
    local win = hs.window.frontmostWindow()
    if win then
        win:focusWindowNorth(nil, true, true)
    end
end)

hs.hotkey.bind(hyper, "l", function()
    local win = hs.window.frontmostWindow()
    if win then
        win:focusWindowEast(nil, true, true)
    end
end)
