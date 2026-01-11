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
vim.opt.swapfile = false  -- Disable swap files

-- Prevent nvim-jdtls from setting up its problematic BufReadCmd autocommands
-- We'll set up our own handlers that don't cause errors
vim.g.nvim_jdtls = 1

-- Java class file handlers (registered early, before any plugin can interfere)
local jdtls_classfile_group = vim.api.nvim_create_augroup("jdtls_classfile", { clear = true })

-- Handle .class files
vim.api.nvim_create_autocmd('BufReadCmd', {
  group = jdtls_classfile_group,
  pattern = '*.class',
  callback = function(ev)
    local fname = ev.match
    vim.bo[ev.buf].buftype = 'nofile'
    vim.bo[ev.buf].swapfile = false
    vim.bo[ev.buf].modifiable = true

    -- Check if this is a jdt:// URI
    if vim.startswith(fname, "jdt://") then
      local clients = vim.lsp.get_clients({ name = 'jdtls' })
      if #clients > 0 then
        clients[1].request('java/classFileContents', { uri = fname }, function(err, content)
          if content then
            vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, vim.split(content, '\n', { plain = true }))
          end
          vim.bo[ev.buf].filetype = 'java'
          vim.bo[ev.buf].modifiable = false
        end, ev.buf)
        return
      end
    end

    -- Regular .class file or no jdtls client - show placeholder
    vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, {
      '// Compiled .class file',
      '// Use "gd" on a class name in a .java file to view decompiled source',
    })
    vim.bo[ev.buf].filetype = 'java'
    vim.bo[ev.buf].modifiable = false
  end,
})

-- Handle jdt:// URIs (decompiled sources from "go to definition")
vim.api.nvim_create_autocmd('BufReadCmd', {
  group = jdtls_classfile_group,
  pattern = 'jdt://*',
  callback = function(ev)
    local uri = ev.file
    local buf = ev.buf

    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true

    local clients = vim.lsp.get_clients({ name = 'jdtls' })
    if #clients == 0 then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '// jdtls not running - open a .java file first' })
      vim.bo[buf].filetype = 'java'
      vim.bo[buf].modifiable = false
      return
    end

    clients[1].request('java/classFileContents', { uri = uri }, function(err, content)
      if err or not content then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '// Failed to decompile class' })
      else
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, '\n', { plain = true }))
      end
      vim.bo[buf].filetype = 'java'
      vim.bo[buf].modifiable = false
    end, buf)
  end,
})

-- Re-add the jdtls LspAttach handler (since we disabled the plugin's default setup)
vim.api.nvim_create_autocmd("LspAttach", {
  group = jdtls_classfile_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "jdtls" then
      require("jdtls")
      pcall(require("jdtls.setup")._on_attach, client, args.buf)
    end
  end
})

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
    config = function()
      require("telescope").setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
          file_ignore_patterns = {
            "%.class$", "%.jar$", "%.war$", "%.ear$",  -- Java binaries
            "%.o$", "%.a$", "%.so$", "%.dylib$",      -- C/C++ binaries
            "%.exe$", "%.dll$", "%.bin$",             -- Windows/generic binaries
            "%.pyc$", "%.pyo$",                       -- Python bytecode
            "%.zip$", "%.tar$", "%.gz$", "%.rar$",    -- Archives
            "%.png$", "%.jpg$", "%.jpeg$", "%.gif$", "%.ico$", "%.webp$",  -- Images
            "%.pdf$", "%.doc$", "%.docx$",            -- Documents
            "node_modules/", "%.git/", "target/", "build/", "dist/",
          },
        },
        pickers = {
          find_files = {
            -- Only match on filename, not the path
            path_display = { "tail" },
            -- Sort by filename match only
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
          },
        },
      })
    end,
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

  -- LeetCode
  {
    dir = "/Users/roryhedderman/lua-projects/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      lang = "python3",
    },
    config = function(_, opts)
      require("leetcode").setup(opts)

      -- Custom command to show favorited problems
      vim.api.nvim_create_user_command("LeetFavorites", function()
        local ok, problemlist = pcall(require, "leetcode.cache.problemlist")
        if not ok then
          vim.notify("LeetCode not initialized. Run :Leet first", vim.log.levels.WARN)
          return
        end

        local problems = problemlist.get()
        local favorites = vim.tbl_filter(function(p)
          return p.starred == true
        end, problems)

        if #favorites == 0 then
          vim.notify("No favorited problems found", vim.log.levels.INFO)
          return
        end

        local picker = require("leetcode.picker")
        picker.question(favorites, {})
      end, { desc = "Show LeetCode favorites" })
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
