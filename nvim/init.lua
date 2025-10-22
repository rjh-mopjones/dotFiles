-- Neovim configuration with Java and Go support, debugging, and Gruvbox theme
-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Basic settings
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300

-- Terminal settings
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")  -- Auto enter insert mode
  end,
})

-- Plugin configuration
require("lazy").setup({
  -- Gruvbox theme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
      })
      vim.cmd([[colorscheme gruvbox]])
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Java LSP
  {
    "mfussenegger/nvim-jdtls",
  },

  -- DAP (Debug Adapter Protocol)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
  },

  -- Java DAP
  {
    "microsoft/java-debug",
    build = "./mvnw clean install",
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Telescope fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Octo - GitHub integration
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup()
    end,
  },

  -- Statusline with git branch
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "gruvbox",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { { "mode", color = { gui = "bold" } } },
          lualine_b = {
            { "branch", icon = "", color = { fg = "#b8bb26", gui = "bold" } },
            { "diff", colored = true },
          },
          lualine_c = {
            { "filename", color = { fg = "#83a598" }, symbols = { modified = " ●", readonly = " " } },
          },
          lualine_x = {
            { "diagnostics", colored = true },
            { "filetype", colored = true, icon_only = false },
          },
          lualine_y = { { "progress", color = { fg = "#fe8019" } } },
          lualine_z = { { "location", color = { gui = "bold" } } },
        },
      })
    end,
  },

  -- Git signs and blame
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
          untracked    = { text = "┆" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 300,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- Keymaps
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true })

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true })

          -- Actions
          map("n", "<leader>gb", gs.toggle_current_line_blame)
          map("n", "<leader>gd", gs.diffthis)
          map("n", "<leader>gp", gs.preview_hunk)
          map("n", "<leader>gr", gs.reset_hunk)
        end,
      })
    end,
  },
})

-- Load configuration modules
require("config.mason")
require("config.completion")
require("config.treesitter")
require("config.dap")
require("config.dap-go")
require("config.keymaps")
require("config.nvim-tree")

-- Mode-based window highlighting
vim.opt.cursorline = true

-- Define mode colors (Gruvbox palette)
local mode_colors = {
  n = "#458588",  -- Normal: blue
  i = "#b8bb26",  -- Insert: green
  v = "#d3869b",  -- Visual: purple
  V = "#d3869b",  -- Visual Line: purple
  ["\22"] = "#d3869b",  -- Visual Block: purple
  c = "#fe8019",  -- Command: orange
  R = "#fb4934",  -- Replace: red
  t = "#8ec07c",  -- Terminal: aqua
}

-- Function to update cursorline color based on mode
local function update_cursorline_color()
  local mode = vim.fn.mode()
  local color = mode_colors[mode] or mode_colors.n

  -- Use a subtle background blend
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE", underline = false })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = color, bold = true, bg = "NONE" })
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#7c6f64" })
end

-- Set up autocommands for mode changes
vim.api.nvim_create_autocmd({ "ModeChanged", "VimEnter" }, {
  pattern = "*",
  callback = update_cursorline_color,
})

-- Initial color
update_cursorline_color()
