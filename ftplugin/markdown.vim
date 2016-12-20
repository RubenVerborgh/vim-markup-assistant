ruby require Vim.evaluate('expand("<sfile>:p:h")') + '/markdown'

nmap <silent> <F7> :ruby Markdown::toggle_emphasis_at_cursor<CR>
nmap <silent> <F8> :ruby Markdown::toggle_strong_at_cursor<CR>
