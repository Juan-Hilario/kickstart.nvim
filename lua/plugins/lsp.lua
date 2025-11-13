return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
    lazy = false,
    priority = 1000,
    config = function()
      local cmp_nvim_lsp = require 'cmp_nvim_lsp'
      local inlay_hint = vim.lsp.inlay_hint

      -- Mason setup
      require('mason').setup()
      require('mason-lspconfig').setup { automatic_installation = true }

      -- Optional: Mason tool installer for CLI tools
      require('mason-tool-installer').setup {
        ensure_installed = {
          'lua_ls',
          'ts_ls',
          'html',
          'cssls',
          'jsonls',
          'pyright',
          'eslint',
          'emmet_ls',
          'stylua',
        },
      }

      -- Capabilities for nvim-cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

      -- on_attach function for keymaps & inlay hints
      local on_attach = function(client, bufnr)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            inlay_hint.enable(not inlay_hint.is_enabled { bufnr = bufnr })
          end, '[T]oggle Inlay [H]ints')
        end
      end

      local lsp_flags = { debounce_text_changes = 150 }

      -- Server-specific settings
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        ts_ls = {
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            on_attach(client, bufnr)
          end,
        },
        html = {},
        cssls = {},
        jsonls = {},
        pyright = {},
        eslint = { settings = { format = false, lintTask = { enable = true } } },
        emmet_ls = {},
      }

      -- Apply default config to Mason-installed servers
      local lspconfig = vim.lsp.config
      for name, cfg in pairs(servers) do
        lspconfig[name] = vim.tbl_deep_extend('force', lspconfig[name] or {}, {
          default_config = vim.tbl_deep_extend('force', {
            capabilities = capabilities,
            on_attach = on_attach,
            flags = lsp_flags,
          }, cfg),
        })
      end
    end,
  },
}
