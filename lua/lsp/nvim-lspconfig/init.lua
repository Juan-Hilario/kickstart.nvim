return {
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
  config = function()
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'
    local root_pattern = require('lspconfig.util').root_pattern

    require('mason').setup()
    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_enable = true,
    }

    local capabilities = cmp_nvim_lsp.default_capabilities()
    local on_attach = function(client, bufnr)
      if client.name == 'tsserver' then
        client.server_capabilities.documentFormattingProvider = false
      end
    end
    local lsp_flags = {
      debounce_text_changes = 150,
    }

    vim.lsp.config['ts_ls'] = {
      on_attach = on_attach,
      capabilities = capabilities,
      flags = lsp_flags,
      filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
      cmd = { 'typescript-language-server', '--stdio' },
      root_dir = root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', '.git'),
    }
    vim.lsp.enable 'ts_ls'

    vim.lsp.config['emmet_ls'] = {
      on_attach = on_attach,
      capabilities = capabilities,
      flags = lsp_flags,
      filetypes = { 'html', 'css', 'scss', 'javascriptreact', 'typescriptreact', 'svelte' },
      init_options = {
        html = {
          options = {
            ['bem.enabled'] = true,
          },
        },
      },
    }
    vim.lsp.enable 'emmet_ls'

    vim.lsp.config['eslint'] = {
      settings = {
        format = false,
        lintTask = {
          enable = true,
        },
      },
    }

    vim.lsp.enable 'eslint'

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
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

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    local servers = {

      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },
    }

    local ensure_installed = {
      'lua_ls', -- Lua language server
      'typescript-language-server', -- TypeScript/JavaScript LSP
      'html', -- HTML LSP
      'cssls', -- CSS LSP
      'jsonls', -- JSON LSP
      'pyright', -- Python LSP
      'stylua', -- Used to format Lua code
      'eslint-lsp',
      'emmet-ls',
      'json-lsp',
    }

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- require('mason-lspconfig').setup {
    --   handlers = {
    --     function(server_name)
    --       local server = servers[server_name] or {}
    --       -- This handles overriding only values explicitly passed
    --       -- by the server configuration above. Useful when disabling
    --       -- certain features of an LSP (for example, turning off formatting for ts_ls)
    --       server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    --       require('lspconfig')[server_name].setup(server)
    --     end,
    --   },
    -- }
  end,
}
