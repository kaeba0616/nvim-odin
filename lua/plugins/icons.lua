return {
	-- 파일 타입 아이콘 (lualine, telescope 등에서 자동 사용). Nerd Font 필요.
	{
		"nvim-tree/nvim-web-devicons",
		lazy = false,
		opts = {
			override_by_extension = {
				odin = { icon = "\u{f06f8}", color = "#3b82f6", name = "Odin" },
			},
		},
	},
	-- netrw 목록에 아이콘 표시
	{
		"prichrd/netrw.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			use_devicons = true,
			-- 글자 깨짐 방지를 위해 유니코드 코드포인트로 지정 (Nerd Font 글리프)
			icons = { symlink = "\u{f481}", directory = "\u{f07b}", file = "\u{f15b}" },
		},
		config = function(_, opts)
			require("netrw").setup(opts)
			-- netrw.nvim은 OptionSet(modified) 이벤트에만 반응하는데, `nvim 폴더`처럼
			-- 시작 시 바로 폴더를 열면 그 이벤트가 발생하지 않아 아이콘이 안 그려진다.
			-- netrw가 목록을 다시 그릴 때 발생하는 이벤트에서 직접 아이콘을 그려준다.
			local group = vim.api.nvim_create_augroup("netrw_icons_fix", { clear = true })
			vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "BufModifiedSet", "BufWinEnter" }, {
				group = group,
				callback = function(a)
					if vim.bo[a.buf].filetype ~= "netrw" then return end
					vim.schedule(function()
						if not vim.api.nvim_buf_is_valid(a.buf) or vim.bo[a.buf].filetype ~= "netrw" then return end
						local ls = vim.b[a.buf].netrw_liststyle
						if ls ~= 0 and ls ~= 1 and ls ~= 3 then return end
						vim.api.nvim_buf_call(a.buf, function()
							vim.opt_local.signcolumn = "yes"
							require("netrw.ui").embelish(a.buf)
							require("netrw.actions").bind(a.buf)
						end)
					end)
				end,
			})
		end,
	},
}
