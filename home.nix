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
    colima
    docker # the CLI only — the daemon lives inside colima's VM
    docker-compose # Normal docker doesn't include the code from here
    nodejs_22
    redis # redis-server + redis-cli
    ngrok
    pnpm
    caddy
  ];

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g allow-passthrough on
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      # vi-style pane navigation: prefix + h/j/k/l
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Copy-mode selection highlight
      set -g mode-style "bg=#283457,fg=#c0caf5"
      # Search match highlighting in copy mode
      set -g copy-mode-match-style "bg=#3d59a1,fg=#c0caf5"
      set -g copy-mode-current-match-style "bg=#7aa2f7,fg=#1a1b26"

      # vim-style copy: v to start selecting, y to yank to the macOS clipboard.
      # The display-message gives a brief "Copied" flash as confirmation, since
      # copy mode exits on yank (tmux has no highlight-on-yank like Neovim).
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy" \; display-message "Copied to clipboard"
    '';
  };

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
          vim.keymap.set("n", "<leader>gb", builtin.git_bcommits, { desc = "File commits (blame)" })
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
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = ''
          require("todo-comments").setup()
        '';
      }
      {
        # mini.ai adds the "any quote/bracket" text objects
        plugin = mini-nvim;
        type = "lua";
        config = ''
          require("mini.ai").setup({
            custom_textobjects = {
              -- `g` = the whole buffer, so yag/dag/cag/vig act on the entire file
              g = function()
                local from = { line = 1, col = 1 }
                local last = vim.fn.line("$")
                local to = { line = last, col = math.max(vim.fn.getline(last):len(), 1) }
                return { from = from, to = to }
              end,
            },
          })
        '';
      }
      {
        plugin = octo-nvim;
        type = "lua";
        config = ''
          require("octo").setup({
            picker = "telescope", -- use the telescope you already have for octo's lists
          })
          vim.keymap.set("n", "<leader>gr", "<cmd>Octo search is:open is:pr review-requested:@me<cr>", { desc = "PRs awaiting my review (Octo)" })
        '';
      }
      {
        plugin = lazygit-nvim;
        type = "lua";
        config = ''
          -- :LazyGit opens in a floating window over the current buffer by default
          vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit (floating)" })
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
            javascript = { "oxlint" },
            javascriptreact = { "oxlint" },
            typescript = { "oxlint" },
            typescriptreact = { "oxlint" },
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
      nixd # Nix LSP (completion/hover/go-to-def, nixpkgs/flake-aware)
      vtsls # TypeScript/JavaScript LSP (tsserver wrapper)
      oxlint # fast JS/TS linter (Rust); nvim-lint has a built-in parser for it
    ];
    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.termguicolors = true
      -- route yanks/deletes/pastes through the system clipboard (pbcopy/pbpaste on macOS)
      vim.opt.clipboard = "unnamedplus"

      -- open a new empty buffer in the current window
      vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New empty buffer" })

      -- briefly flash the yanked text (the LazyVim highlight-on-yank effect)
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.hl.on_yank()
        end,
      })

      -- show diagnostic messages inline, at the end of the line
      vim.diagnostic.config({
        virtual_text = true, -- the inline message text
        severity_sort = true, -- errors rank above warnings on shared lines
      })

      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("vtsls", {
        cmd = { "vtsls", "--stdio" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        capabilities = lsp_capabilities,
        settings = {
          -- raise tsserver's heap ceiling (MB) so large repos don't OOM
          typescript = { tsserver = { maxTsServerMemory = 24576 } },
        },
      })

      vim.lsp.config("nixd", {
        cmd = { "nixd" },
        filetypes = { "nix" },
        root_markers = { "flake.nix", ".git" },
        capabilities = lsp_capabilities,
      })

      vim.lsp.enable({ "vtsls", "nixd" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        end,
      })
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

  # Make `docker compose` (the plugin subcommand) resolve to `docker-compose`
  home.file.".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";

  # Ghostty config, generated by Nix → ~/.config/ghostty/config
  home.file.".config/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    theme = TokyoNight
  '';
}
