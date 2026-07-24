 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#081512',
    base01 = '#0f251f',
    base02 = '#15342b',
    base03 = '#1e6d5a',
    base04 = '#99a8a4',
    base05 = '#a6b5b1',
    base06 = '#a6b5b1',
    base07 = '#a6b5b1',
    base08 = '#933636',
    base09 = '#26a589',
    base0A = '#167a63',
    base0B = '#1e9177',
    base0C = '#96e9d6',
    base0D = '#95e9d6',
    base0E = '#93ecd7',
    base0F = '#3e0f0f',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#a6b5b1',          bg = '#081512' })
  hi('TelescopeBorder',         { fg = '#1e6d5a',             bg = '#081512' })
  hi('TelescopePromptNormal',   { fg = '#a6b5b1',          bg = '#081512' })
  hi('TelescopePromptBorder',   { fg = '#1e6d5a',             bg = '#081512' })
  hi('TelescopePromptPrefix',   { fg = '#1e9177',             bg = '#081512' })
  hi('TelescopePromptCounter',  { fg = '#99a8a4',  bg = '#081512' })
  hi('TelescopePromptTitle',    { fg = '#081512',             bg = '#1e9177' })
  hi('TelescopePreviewTitle',   { fg = '#081512',             bg = '#167a63' })
  hi('TelescopeResultsTitle',   { fg = '#081512',             bg = '#26a589' })
  hi('TelescopeSelection',      { fg = '#a6b5b1',          bg = '#15342b' })
  hi('TelescopeSelectionCaret', { fg = '#1e9177',             bg = '#15342b' })
  hi('TelescopeMatching',       { fg = '#1e9177',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
