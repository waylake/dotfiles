-- Local overrides (gitignored upstream).
-- `sf`: restore the previous telescope-file-browser UI instead of oil float.

local gh = function(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	{ src = gh("nvim-lua/plenary.nvim") },
	{ src = gh("nvim-telescope/telescope.nvim") },
	{ src = gh("nvim-telescope/telescope-file-browser.nvim") },
})

local telescope = require("telescope")
local actions = require("telescope.actions")
local fb_actions = telescope.extensions.file_browser.actions

telescope.setup({
	defaults = {
		wrap_results = true,
		layout_strategy = "horizontal",
		layout_config = { prompt_position = "top" },
		sorting_strategy = "ascending",
		winblend = 0,
	},
	extensions = {
		file_browser = {
			theme = "dropdown",
			hijack_netrw = false, -- oil handles directory buffers
			mappings = {
				["n"] = {
					["N"] = fb_actions.create,
					["h"] = fb_actions.goto_parent_dir,
					["/"] = function()
						vim.cmd("startinsert")
					end,
					["<C-u>"] = function(prompt_bufnr)
						for _ = 1, 10 do
							actions.move_selection_previous(prompt_bufnr)
						end
					end,
					["<C-d>"] = function(prompt_bufnr)
						for _ = 1, 10 do
							actions.move_selection_next(prompt_bufnr)
						end
					end,
					["<PageUp>"] = actions.preview_scrolling_up,
					["<PageDown>"] = actions.preview_scrolling_down,
				},
			},
		},
	},
})
telescope.load_extension("file_browser")

local function file_browser()
	telescope.extensions.file_browser.file_browser({
		path = "%:p:h",
		cwd = vim.fn.expand("%:p:h"),
		respect_gitignore = false,
		hidden = true,
		grouped = true,
		previewer = false,
		initial_mode = "normal",
		layout_config = { height = 40 },
	})
end

-- keymaps.lua (loaded after this file) binds `sf` to oil; rebind once startup is done.
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.keymap.set("n", "sf", file_browser, { desc = "Open File Browser with the path of the current buffer" })
	end,
})

-- Steady cursor: same shapes as upstream options.lua, without blinking.
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkon0-Cursor/lCursor"
