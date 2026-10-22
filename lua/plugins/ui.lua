return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			transparent = true, -- 배경 투명 (터미널 배경이 비치게)
			styles = { sidebars = "transparent", floats = "transparent" },
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = { options = { theme = "tokyonight", globalstatus = true } },
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "파일 찾기" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "텍스트 검색 (ripgrep 필요)" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "버퍼 목록" },
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "문서 심볼" },
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},
}
