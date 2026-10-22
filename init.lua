-- ===== 기본 옵션 =====
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = false          -- Odin 커뮤니티 스타일: 탭 사용 (odinfmt.json과 동일)
o.smartindent = true
o.termguicolors = true
o.signcolumn = "yes"
o.updatetime = 250
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.undofile = true
o.scrolloff = 8

-- Windows: PowerShell 7을 :terminal / :! 셸로 사용
if vim.fn.has("win32") == 1 and vim.fn.executable("pwsh") == 1 then
	o.shell = "pwsh"
	o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
	o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s"
	o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s"
	o.shellquote = ""
	o.shellxquote = ""
end

-- ===== 파일 탐색기(netrw) =====
vim.g.netrw_banner = 1      -- 상단 배너 표시
vim.g.netrw_liststyle = 0   -- 기본 단순 목록
-- `-` / <leader>pv 는 oil.nvim(lua/plugins/oil.lua)에서 바인딩. netrw는 :Ex 로 열 수 있음

-- ===== 창 이동/닫기 (tmux 스타일) =====
-- Ctrl-h/j/k/l : 왼쪽/아래/위/오른쪽 창으로 이동 (터미널 창 안에서도 바로 동작)
for key, dir in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
	vim.keymap.set("n", "<C-" .. key .. ">", "<C-w>" .. dir, { desc = "창 이동 " .. dir })
	vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><C-w>" .. dir, { desc = "창 이동 " .. dir })
end
-- Esc 두 번 : 터미널 모드에서 빠져나오기
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "터미널 모드 종료" })
-- <leader>x : 현재 창 닫기 (터미널이면 프로세스까지 종료)
local function close_window()
	if vim.bo.buftype == "terminal" then
		vim.cmd("bdelete!")
	elseif #vim.api.nvim_tabpage_list_wins(0) > 1 then
		vim.cmd("close")
	else
		vim.notify("마지막 창입니다. :q 로 종료하세요.", vim.log.levels.INFO)
	end
end
vim.keymap.set("n", "<leader>x", close_window, { desc = "현재 창 닫기" })
vim.keymap.set("t", "<leader>x", function() vim.cmd("stopinsert"); vim.schedule(close_window) end, { desc = "터미널 창 닫기" })
-- 터미널 창: 프로세스가 끝났으면 일반 모드에서 q 로 닫기
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(ev)
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.keymap.set("n", "q", "<cmd>bdelete!<cr>", { buffer = ev.buf, desc = "터미널 닫기" })
	end,
})

-- ===== quickfix 창 토글: <leader>q =====
vim.keymap.set("n", "<leader>q", function()
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			vim.cmd("cclose")
			return
		end
	end
	vim.cmd("botright copen")
end, { desc = "quickfix 창 열기/닫기" })

-- ===== lazy.nvim 부트스트랩 =====
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none", "--branch=stable",
		"https://github.com/folke/lazy.nvim.git", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
	change_detection = { notify = false },
})

-- ===== 진단 표시 =====
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	float = { border = "rounded" },
})

-- ===== LSP 공통 키맵 (ols 포함) =====
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local map = function(keys, fn, desc)
			vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
		end
		map("gd", vim.lsp.buf.definition, "정의로 이동")
		map("gD", vim.lsp.buf.declaration, "선언으로 이동")
		map("gr", vim.lsp.buf.references, "참조 보기")
		map("K", vim.lsp.buf.hover, "호버 문서")
		map("<leader>rn", vim.lsp.buf.rename, "이름 변경")
		map("<leader>ca", vim.lsp.buf.code_action, "코드 액션")
		map("<leader>e", vim.diagnostic.open_float, "진단 보기")
		map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "이전 진단")
		map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "다음 진단")
		map("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
		end, "인레이 힌트 토글")
	end,
})

-- ===== Odin 전용 키맵: <leader>or = 실행, <leader>ob = 빌드, <leader>oc = 체크 =====
vim.api.nvim_create_autocmd("FileType", {
	pattern = "odin",
	callback = function(ev)
		local function run(cmd)
			vim.cmd("write")
			-- 이전 실행 터미널이 남아 있으면 닫고 새로 연다 (창이 쌓이지 않게)
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[buf].buftype == "terminal" and vim.b[buf].odin_run_term then
					pcall(vim.api.nvim_buf_delete, buf, { force = true })
				end
			end
			vim.cmd("botright 15split | terminal " .. cmd)
			vim.b.odin_run_term = true
			vim.cmd("startinsert")
		end
		local map = function(keys, fn, desc)
			vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
		end
		map("<leader>or", function() run("odin run . -debug") end, "Odin: run")
		map("<leader>ob", function() run("odin build . -debug") end, "Odin: build")
		map("<leader>oc", function() run("odin check . -strict-style") end, "Odin: check")
	end,
})
