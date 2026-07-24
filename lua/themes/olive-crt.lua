return {
  'vimcolorschemes/olive-crt.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme 'olive-crt'
    vim.cmd.hi 'Comment gui=none'
  end,
}
