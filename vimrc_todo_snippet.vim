" Vim Todo Board mappings
" Designed for a plain-text todo file with a DONE section.

" Mark current line as done:
" - Replace everything before the [project] tag with 'X '
" - Append today's date
" - Move line near the top (under Today header)
nnoremap <leader>x 0/\[<CR>:s/^.*\ze\[/X /<CR>A (<C-R>=strftime("%Y-%m-%d")<CR>)<Esc>:m /^Today/+2<CR>

" Toggle a simple wait marker at the start of the line.
" If the line already starts with (wait:...), remove it; otherwise insert (wait:xx) 
function! ToggleWaitMarker()
    " If line begins with '(wait:... ) ' remove it (and any following spaces)
    if getline('.') =~# '^\s*(wait:[^)]\+)\s\+'
        execute 'silent s/^\s*(wait:[^)]\+)\s\+//'
    else
        execute 'silent s/^/(wait:xx) /'
    endif
endfunction

nnoremap <leader>w :call ToggleWaitMarker()<CR>

" Move current line or visually-selected lines to DONE section
function! MoveToDone() range
    let l:winview = winsaveview()

    silent execute a:firstline . ',' . a:lastline . 'yank'

    if search('^== DONE ===============================', 'w') > 0
        silent put
        silent execute a:firstline . ',' . a:lastline . 'delete _'
        echo "Task(s) moved to DONE section"
    else
        echo "DONE section not found!"
    endif

    call winrestview(l:winview)
endfunction

nnoremap <leader>m :call MoveToDone()<CR>
vnoremap <leader>m :call MoveToDone()<CR>

" Sum numbers in a visual selection (handy for budgeting / time estimates)
function! SumSelectedNumbers()
    normal! gv"ay
    let selected_text = @a
    let numbers = split(selected_text, '\D\+')

    let sum = 0
    for num in numbers
        let sum += str2nr(num)
    endfor

    echo "Sum of selected numbers: " . sum
endfunction

vnoremap <leader>s :call SumSelectedNumbers()<CR>

" Insert a bundle of monthly tasks (customise these)
command! InsertMonthlyTasks read !echo -e \
\">>> [this-project] Update the data for prod this month\n\
\">>> [that-project] Org. monthly meet-up with team\n"

nnoremap <Leader>M :InsertMonthlyTasks<CR>
