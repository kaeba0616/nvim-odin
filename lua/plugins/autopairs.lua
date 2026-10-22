-- 괄호/따옴표 자동 완성: { → {}, ( → (), " → "" 등
-- Enter를 누르면 { | } 가 세 줄로 벌어지고, 닫는 괄호를 입력하면 건너뛴다.
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = false,
		map_cr = true,            -- {<CR> → 블록 펼치기
		map_bs = true,            -- 백스페이스로 쌍 함께 삭제
		enable_check_bracket_line = true,
	},
}
