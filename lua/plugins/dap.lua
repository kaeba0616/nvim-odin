-- 디버깅: nvim-dap + codelldb (+ dap-ui, 변수값 인라인 표시)
-- codelldb 위치: <nvim-data>/codelldb/extension/adapter/codelldb(.exe)
--   설치: https://github.com/vadimcn/codelldb/releases 에서 OS에 맞는 .vsix를 받아
--   <nvim-data>/codelldb 에 압축 해제 (README 참고). PATH에 codelldb가 있으면 그것을 사용.

local is_win = vim.fn.has("win32") == 1

local function codelldb_path()
	if vim.fn.executable("codelldb") == 1 then return "codelldb" end
	local exe = vim.fn.stdpath("data") .. "/codelldb/extension/adapter/codelldb" .. (is_win and ".exe" or "")
	return exe
end

-- 현재 작업 폴더(cwd)를 `odin build . -debug` 로 빌드하고 실행 파일 경로를 돌려준다.
-- 실패하면 오류를 quickfix 에 담고 nil 을 돌려준다.
local function odin_build_debug()
	vim.cmd("silent! wall")
	local cwd = vim.fn.getcwd()
	local name = vim.fn.fnamemodify(cwd, ":t")
	local exe = cwd .. "/" .. name .. (is_win and ".exe" or "")
	vim.notify("odin build . -debug ...", vim.log.levels.INFO)
	local out = vim.fn.systemlist({ "odin", "build", ".", "-debug", "-out:" .. exe })
	if vim.v.shell_error ~= 0 then
		vim.fn.setqflist({}, " ", { title = "odin build", lines = out })
		vim.cmd("botright copen")
		vim.notify("빌드 실패: quickfix 를 확인하세요", vim.log.levels.ERROR)
		return nil
	end
	return exe
end

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		cmd = { "DapNew", "DapContinue", "DapToggleBreakpoint", "DapTerminate", "DapEval", "DapToggleRepl" },
		keys = {
			{ "<F5>", function()
				local dap = require("dap")
				if dap.session() then return dap.continue() end
				if vim.bo.filetype == "odin" then
					-- Odin: 빌드 후 바로 디버깅 시작
					local exe = odin_build_debug()
					if not exe then return end
					dap.run(vim.tbl_extend("force", dap.configurations.odin[1], { program = exe }))
				else
					dap.continue()
				end
			end, desc = "디버그: 시작(빌드)/계속" },
			{ "<S-F5>", function() require("dap").terminate() end, desc = "디버그: 종료" },
			{ "<F9>", function() require("dap").toggle_breakpoint() end, desc = "디버그: 중단점 토글" },
			{ "<F10>", function() require("dap").step_over() end, desc = "디버그: 다음 줄" },
			{ "<F11>", function() require("dap").step_into() end, desc = "디버그: 함수 안으로" },
			{ "<S-F11>", function() require("dap").step_out() end, desc = "디버그: 함수 밖으로" },
			-- F 키가 터미널에서 안 먹을 때를 위한 <leader>d 계열
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "중단점 토글" },
			{ "<leader>dB", function()
				require("dap").set_breakpoint(vim.fn.input("조건: "))
			end, desc = "조건부 중단점" },
			{ "<leader>dc", function() vim.api.nvim_feedkeys(vim.keycode("<F5>"), "m", false) end, desc = "시작(빌드)/계속" },
			{ "<leader>dn", function() require("dap").step_over() end, desc = "다음 줄" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "함수 안으로" },
			{ "<leader>do", function() require("dap").step_out() end, desc = "함수 밖으로" },
			{ "<leader>dC", function() require("dap").run_to_cursor() end, desc = "커서까지 실행" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "디버그 종료" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "마지막 디버그 다시 실행" },
			{ "<leader>dX", function() require("dap").clear_breakpoints() end, desc = "중단점 모두 삭제" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "디버그 UI 토글" },
			{ "<leader>de", function() require("dapui").eval() end, mode = { "n", "x" }, desc = "값 보기 (커서/선택)" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "디버그 REPL" },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = codelldb_path(),
					args = { "--port", "${port}" },
					detached = not is_win,
				},
			}

			dap.configurations.odin = {
				{
					name = "Odin: build & debug (cwd)",
					type = "codelldb",
					request = "launch",
					program = function() return odin_build_debug() or dap.ABORT end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
				{
					name = "Odin: 실행 파일 직접 선택",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("실행 파일: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			dapui.setup()
			require("nvim-dap-virtual-text").setup({})

			-- 디버깅이 시작되면 UI 열기, 끝나면 닫기
			dap.listeners.before.attach.dapui_config = function() dapui.open() end
			dap.listeners.before.launch.dapui_config = function() dapui.open() end
			dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
			dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

			-- 중단점 표시
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
		end,
	},
}
