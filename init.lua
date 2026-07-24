require 'settings'
require 'plugins'
require 'settings.plugin-settings'

vim.filetype.add {
  extension = {
    conf = 'nginx', -- or "toml", "ini", "dosini", etc.
  },
}

-- vim.opt.runtimepath:append '~/.config/nvim/lua'
