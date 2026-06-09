{ pkgs, ... }:
{
  home.username = "xavier";
  home.homeDirectory = "/Users/xavier";
  home.stateVersion = "24.11"; # set once, don't bump casually

  # User packages (your CLI tools live here now, not systemPackages)
  home.packages = with pkgs; [
    ripgrep
    yazi
    claude-code
    gh
  ];

  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.lua
        p.nix
        p.typescript
        p.tsx
        p.rust
        p.bash
        p.markdown
        p.javascript
      ]))
      {
        plugin = tokyonight-nvim;
        type = "lua";
        config = ''
          require("tokyonight").setup({
            style = "night",
          })
          vim.cmd.colorscheme("tokyonight")
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require("telescope.builtin")
          vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Grep" })
          vim.keymap.set("n", "<leader>sS", builtin.lsp_dynamic_workspace_symbols, { desc = "Workspace symbols" })
        '';
      }
      plenary-nvim # dependency of telescope and others
      nvim-web-devicons # File icons
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require("gitsigns").setup()
        '';
      }
      # completion sources — loaded before nvim-cmp so it can find them
      cmp-nvim-lsp # LSP completion (inert until a language server is attached)
      cmp-path # filesystem path completion
      cmp-buffer # words from the current buffer
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require("cmp")
          cmp.setup({
            snippet = {
              -- Neovim's built-in snippet engine (0.10+), no extra plugin needed
              expand = function(args)
                vim.snippet.expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ["<C-Space>"] = cmp.mapping.complete(), -- manually trigger completion
              ["<C-e>"] = cmp.mapping.abort(), -- dismiss the menu
              ["<CR>"] = cmp.mapping.confirm({ select = false }), -- confirm (only if explicitly selected)
              ["<C-j>"] = cmp.mapping.select_next_item(),
              ["<C-k>"] = cmp.mapping.select_prev_item(),
            }),
            sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "path" },
            }, {
              { name = "buffer" },
            }),
          })
        '';
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup({
            options = {
              theme = "auto",
            },
            sections = {
              -- left: two items
              lualine_a = { "mode" },
              lualine_b = { "branch" },
              lualine_c = {},
              -- right: two items (filetype in the medium "branch" styling,
              -- filename in the bright styling line:col used to have)
              lualine_x = {},
              lualine_y = { "filetype" },
              lualine_z = { "filename" },
            },
          })
        '';
      }
      {
        plugin = telescope-frecency-nvim;
        type = "lua";
        config = ''
          require("telescope").load_extension("frecency")
          -- frecency is now the default file finder, scoped to the current project
          vim.keymap.set("n", "<leader><leader>", function()
            require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
          end, { desc = "Find files (frecency)" })
        '';
      }
      {
        plugin = conform-nvim;
        type = "lua";
        config = ''
          require("conform").setup({
            formatters_by_ft = {
              nix = { "nixfmt" },
            },
            format_on_save = {
              timeout_ms = 2000,
              lsp_format = "fallback",
            },
          })
        '';
      }
      {
        plugin = nvim-lint;
        type = "lua";
        config = ''
          require("lint").linters_by_ft = {
            nix = { "statix", "deadnix" },
          }
          -- generic: re-lint on the events where diagnostics should refresh
          vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
            callback = function() require("lint").try_lint() end,
          })
        '';
      }
    ];
    # Tools wrapped onto neovim's own PATH so conform/nvim-lint always find them.
    extraPackages = with pkgs; [
      nixfmt-rfc-style
      statix
      deadnix
    ];
    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.termguicolors = true
    '';
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };
  programs.oh-my-posh = {
    enable = true;
    enableBashIntegration = true;
    useTheme = "amro";
  };

  programs.bash = {
    enable = true;
  };

  programs.lazydocker = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
    enableBashIntegration = true;
  };

  # Ghostty config, generated by Nix → ~/.config/ghostty/config
  home.file.".config/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    theme = TokyoNight
  '';
}
