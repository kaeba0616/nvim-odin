-- OLS (Odin Language Server) 설정
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- ols.exe 위치: PATH에 있으면 "ols", 아니면 D:\dev\ols\ols.exe 직접 지정
			local ols_cmd = vim.fn.executable("ols") == 1 and "ols" or "D:/dev/ols/ols.exe"

			vim.lsp.config("ols", {
				cmd = { ols_cmd },
				capabilities = capabilities,
				-- 프로젝트 루트: ols.json 이 있으면 그곳, 없으면 .git, 그것도 없으면 현재 파일 폴더
				root_markers = { "ols.json", ".git" },
				init_options = {
					checker_args = "-strict-style",
					enable_semantic_tokens = true,
					enable_document_symbols = true,
					enable_hover = true,
					enable_snippets = true,
					enable_inlay_hints = true,
					enable_references = true,
					enable_rename = true,
					enable_format = true,
				},
			})
			vim.lsp.enable("ols")
		end,
	},

	-- 자동완성
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "super-tab", -- Tab: 선택 항목 입력(스니펫이면 다음 자리로), S-Tab: 이전 자리
				["<CR>"] = { "accept", "fallback" }, -- Enter로도 입력 가능 (메뉴 없을 땐 줄바꿈)
				["<C-n>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
			},
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			fuzzy = { implementation = "prefer_rust_with_warning" },
			signature = { enabled = true },
		},
	},

	-- 저장 시 odinfmt 포맷
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		opts = {
			notify_on_error = false,
			formatters = {
				odinfmt = {
					command = vim.fn.executable("odinfmt") == 1 and "odinfmt" or "D:/dev/ols/odinfmt.exe",
					args = { "-stdin" },
					stdin = true,
				},
			},
			formatters_by_ft = { odin = { "odinfmt" } },
			format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
		},
	},
}
