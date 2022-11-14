require("grapple").setup({
    ---@type "debug" | "info" | "warn" | "error"
    log_level = "warn",

    ---The scope used when creating, selecting, and deleting tags
    scope = "global",

    ---The save location for tags
    save_path = vim.fn.stdpath("data") .. "/" .. "grapple.json",

    ---Window options used for the popup menu
    popup_options = {
        relative = "editor",
        width = 60,
        height = 12,
        style = "minimal",
        focusable = false,
        border = "single",
    },

    integrations = {
        ---Support for saving tag state using resession.nvim
        resession = false,
    },
})
