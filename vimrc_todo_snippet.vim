" Vim Todo Board mappings
" Designed for a plain-text todo file with a DONE section.

" Move the current line under the '|| Today ||' header (after the separator line).
function! TodoMoveToToday()
    let l:winview = winsaveview()

    let l:cur = line('.')
    let l:today = search('^|| Today ||$', 'nw')

    if l:today > 0
        " +2 aims to put the task under:
        "   || Today ||
        "   -----------
        execute l:cur . 'move ' . (l:today + 2)
    else
        echo "Today header not found: '|| Today ||'"
    endif

    call winrestview(l:winview)
endfunction

" Mark current line as done:
" - Replace everything before the [project] tag with 'X '
" - Append today's date
" - Move line under the '|| Today ||' header
nnoremap <leader>x 0/\[<CR>:s/^.*\ze\[/X /<CR>A (<C-R>=strftime("%Y-%m-%d")<CR>)<Esc>:call TodoMoveToToday()<CR>

" Toggle a simple wait marker at the start of the line.
" If the line already starts with (wait:...), remove it; otherwise insert (wait:xx)
function! ToggleWaitMarker()
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

" Insert a bundle of monthly tasks (customise these)
" Avoids calling the shell (which can choke on >>> in some shells/configs).
function! TodoInsertMonthlyTasks()
    let l:lines = [
                \ '>>> [this-project] Update data for this month',
                \ '>> [other-project] Org monthly meeting for team',
                \ ]

    call append(line('.'), l:lines)
endfunction

command! InsertMonthlyTasks call TodoInsertMonthlyTasks()

nnoremap <Leader>M :InsertMonthlyTasks<CR>
