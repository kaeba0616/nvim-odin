return {
	-- 파일 탐색기를 일반 버퍼처럼 편집: yy/p 로 파일 복사, dd 로 삭제, 이름 수정 후 :w 로 반영
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Oil 파일 탐색기 열기" },
			{ "<leader>pv", "<cmd>Oil<cr>", desc = "현재 파일 폴더의 Oil 열기" },
		},
		opts = {
			default_file_explorer = true, -- nvim . / nvim 폴더 로 열면 netrw 대신 Oil 사용
			delete_to_trash = true,        -- dd 삭제 시 휴지통으로
			skip_confirm_for_simple_edits = true,
			view_options = { show_hidden = true },
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-v>"] = { "actions.select", opts = { vertical = true } },
				["<C-s>"] = { "actions.select", opts = { horizontal = true } },
				["<C-p>"] = "actions.preview",
				["<C-l>"] = false, -- 창 이동 키맵과 충돌 방지
				["<C-h>"] = false,
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["gs"] = "actions.change_sort",
				["g."] = "actions.toggle_hidden",
				["q"] = "actions.close",
			},
		},
	},
}
