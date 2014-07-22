" ======================================================================================
" File         : excscope.vim
" Author       : Wu Jie 
" Last Change  : 10/18/2008 | 18:56:31 PM | Saturday,October
" Description  : 
" ======================================================================================

" variables {{{1
let s:title = "-Cscope-" 
let s:confirm_at = -1

let s:zoom_in = 0
let s:keymap = {}

let s:help_open = 0
let s:help_text_short = [
            \ '" Press <F1> for help',
            \ '',
            \ ]
let s:help_text = s:help_text_short

let s:cscope_list = []
let s:cscope = ''
let s:last_line_nr = -1

" check if plugin loaded
if exists('loaded_excscope') || &cp
    finish
endif

let loaded_excscope=1

" ======================================================== 
" local variable initialization
" ======================================================== 

" ------------------------------------------------------------------ 
" Desc: titles
" ------------------------------------------------------------------ 

let s:exCS_select_title = '__exCS_SelectWindow__'
let s:exCS_quick_view_title = '__exCS_QuickViewWindow__'
let s:exCS_short_title = 'Select'

" ------------------------------------------------------------------ 
" Desc: general
" ------------------------------------------------------------------ 

let s:exCS_fold_start = '<<<<<<'
let s:exCS_fold_end = '>>>>>>'
let s:exCS_ignore_case = 1
let s:exCS_need_search_again = 0

" ------------------------------------------------------------------ 
" Desc: select variable
" ------------------------------------------------------------------ 

let s:exCS_select_idx = 1

" ------------------------------------------------------------------ 
" Desc: quick view variable
" ------------------------------------------------------------------ 

let s:exCS_quick_view_idx = 1
let s:exCS_picked_search_result = []
let s:exCS_quick_view_search_pattern = ''

"/////////////////////////////////////////////////////////////////////////////
" function defines
"/////////////////////////////////////////////////////////////////////////////

" ======================================================== 
"  gerneral functions
" ======================================================== 

" ------------------------------------------------------------------ 
" Desc: Open exGlobalSearch window 
" ------------------------------------------------------------------ 
"
" function s:exCS_OpenWindow( short_title ) " <<<
    " if a:short_title != ''
        " let s:exCS_short_title = a:short_title
    " endif
    " let title = '__exCS_' . s:exCS_short_title . 'Window__'
    " " open window
    " if g:exCS_use_vertical_window
        " call exUtility#OpenWindow( title, g:exCS_window_direction, g:exCS_window_width, g:exCS_use_vertical_window, g:exCS_edit_mode, 1, 'g:exCS_Init'.s:exCS_short_title.'Window', 'g:exCS_Update'.s:exCS_short_title.'Window' )
    " else
        " call exUtility#OpenWindow( title, g:exCS_window_direction, g:exCS_window_height, g:exCS_use_vertical_window, g:exCS_edit_mode, 1, 'g:exCS_Init'.s:exCS_short_title.'Window', 'g:exCS_Update'.s:exCS_short_title.'Window' )
    " endif
" endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: Resize the window use the increase value
" ------------------------------------------------------------------ 

" function s:exCS_ResizeWindow() " <<<
    " if g:exCS_use_vertical_window
        " call exUtility#ResizeWindow( g:exCS_use_vertical_window, g:exCS_window_width, g:exCS_window_width_increment )
    " else
        " call exUtility#ResizeWindow( g:exCS_use_vertical_window, g:exCS_window_height, g:exCS_window_height_increment )
    " endif
" endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: Toggle the window
" ------------------------------------------------------------------ 

" function s:exCS_ToggleWindow( short_title ) " <<<
    " " if need switch window
    " if a:short_title != ''
        " if s:exCS_short_title != a:short_title
            " if bufwinnr('__exCS_' . s:exCS_short_title . 'Window__') != -1
                " call exUtility#CloseWindow('__exCS_' . s:exCS_short_title . 'Window__')
            " endif
            " let s:exCS_short_title = a:short_title
        " endif
    " endif

    " " toggle exCS window
    " let title = '__exCS_' . s:exCS_short_title . 'Window__'
    " if g:exCS_use_vertical_window
        " call exUtility#ToggleWindow( title, g:exCS_window_direction, g:exCS_window_width, g:exCS_use_vertical_window, 'none', 0, 'g:exCS_Init'.s:exCS_short_title.'Window', 'g:exCS_Update'.s:exCS_short_title.'Window' )
    " else
        " call exUtility#ToggleWindow( title, g:exCS_window_direction, g:exCS_window_height, g:exCS_use_vertical_window, 'none', 0, 'g:exCS_Init'.s:exCS_short_title.'Window', 'g:exCS_Update'.s:exCS_short_title.'Window' )
    " endif
" endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: 
" ------------------------------------------------------------------ 
function excscope#SwitchWindow( short_title ) " <<<
    let title = '__exCS_' . a:short_title . 'Window__'
    if bufwinnr(title) == -1
        " save the old height & width
        let old_height = g:exCS_window_height
        let old_width = g:exCS_window_width

        " use the width & height of current window if it is same plugin window.
        if bufname ('%') ==# s:title || bufname ('%') ==# s:exCS_quick_view_title 
            let g:exCS_window_height = winheight('.')
            let g:exCS_window_width = winwidth('.')
        endif

        " switch to the new plugin window
        " call excscope#ToggleWindow(a:short_title)
        call excscope#toggle_window()

        " recover the width and height
        let g:exCS_window_height = old_height
        let g:exCS_window_width = old_width
    endif
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: 
" ------------------------------------------------------------------ 

function g:exCS_ConnectCscopeFile() " <<<
    " don't show any message
	setlocal nocsverb
    " connect cscope files
    silent exec "cscope add " . g:exES_Cscope
	silent! setlocal cscopequickfix=s-,c-,d-,i-,t-,e-
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: goto select line
" ------------------------------------------------------------------ 

function excscope#Goto() " <<<
    " check if the line can jump
    let line = getline('.')

    " process jump
    if line =~ '^ \[\d\+\]' " quickfix list jump
        " get the quick fix idx and item
        let start_idx = stridx(line,"[")+1
        let end_idx = stridx(line,"]")
        let qf_idx = str2nr( strpart(line, start_idx, end_idx-start_idx) )
        let qf_list = getqflist()
        let qf_item = qf_list[qf_idx]

        " start jump
        call ex#window#goto_edit_window()
        if bufnr('%') != qf_item.bufnr
            exe 'silent e ' . bufname(qf_item.bufnr)
        endif
        call cursor( qf_item.lnum, qf_item.col )
    elseif line =~ '^\S\+:\d\+:\s<<\S\+>>' " g method jump
        " get elements in location line ( file name, line )
        let line = getline('.')
        let elements = split ( line, ':' )

        " start jump
        if !empty(elements)
            call ex#window#goto_edit_window()
            exe 'silent e ' . elements[0]
            exec 'call cursor(elements[1], 1)'
        endif
    else
        call ex#warning("could not jump")
        return 0
    endif

    " go back if needed
    let winnum = bufwinnr(s:title)
    call ex#window#operate( winnum, g:exCS_close_when_selected, g:exCS_backto_editbuf, 1 )

    return 1
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: 
" ------------------------------------------------------------------ 

function excscope#GoDirect( search_method ) " <<<
    let search_text = ''
    if a:search_method ==# 'i' " including file
        let search_text = expand("<cfile>".":t")
    else
        let search_text = expand("<cword>")
    endif

    call excscope#GetSearchResult(search_text, a:search_method)
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: 
" ------------------------------------------------------------------ 

function excscope#ShowQuickFixResult( search_method, g_method_result_list ) " <<<
    " processing search result
    let result_list = getqflist()
    if !empty(a:g_method_result_list) 
        let result_list = a:g_method_result_list
    endif

    " processing result
    if a:search_method ==# 'da' " all called function
        let last_bufnr = -1
        let qf_idx = 0
        for item in result_list
            if last_bufnr != item.bufnr
                let convert_file_name = ex#ConvertFileName( bufname(item.bufnr) )
                silent put = convert_file_name 
                let last_bufnr = item.bufnr
            endif
            let start_idx = stridx( item.text, "<<")+2
            let end_idx = stridx( item.text, ">>")
            let len = end_idx - start_idx
            let text_line = printf(" [%03d] %-40s | <%04d> %s", qf_idx, strpart( item.text, start_idx, len ), item.lnum, strpart( item.text, end_idx+2 ) )
            silent put = text_line 
            let qf_idx += 1
        endfor
    elseif a:search_method ==# 'ds' " select called function
        " TODO: " ::\S\+\_s\+(
 
       let cur_bufnr = ex#window#last_edit_bufnr()
        let qf_idx = 0
        for item in result_list
            if cur_bufnr == item.bufnr
                let start_idx = stridx( item.text, "<<")+2
                let end_idx = stridx( item.text, ">>")
                let len = end_idx - start_idx
                let text_line = printf(" [%03d] %-40s | <%04d> %s", qf_idx, strpart( item.text, start_idx, len ), item.lnum, strpart( item.text, end_idx+2 ) )
                silent put = text_line 
            endif
            let qf_idx += 1
        endfor
    elseif a:search_method ==# 'c' " calling function
        let qf_idx = 0
        for item in result_list
            let start_idx = stridx( item.text, "<<")+2
            let end_idx = stridx( item.text, ">>")
            let len = end_idx - start_idx
            let text_line = printf(" [%03d] %s:%d: <<%s>> %s", qf_idx, bufname(item.bufnr), item.lnum, strpart( item.text, start_idx, len ), strpart( item.text, end_idx+2 ) )
            silent put = text_line 
            let qf_idx += 1
        endfor
    elseif a:search_method ==# 'i' " including file
        let qf_idx = 0
        for item in result_list
            let convert_file_name = ex#ConvertFileName( bufname(item.bufnr) )
            let start_idx = stridx( convert_file_name, "(")
            let short_name = strpart( convert_file_name, 0, start_idx )
            let path_name = strpart( convert_file_name, start_idx )
            let text_line = printf(" [%03d] %-36s <%02d> %s", qf_idx, short_name, item.lnum, path_name )
            silent put = text_line 
            let qf_idx += 1
        endfor
    elseif a:search_method ==# 's' " C symbol
        let qf_idx = 0
        for item in result_list
            let start_idx = stridx( item.text, "<<")+2
            let end_idx = stridx( item.text, ">>")
            let len = end_idx - start_idx
            let text_line = printf(" [%03d] %s:%d: <<%s>> %s", qf_idx, bufname(item.bufnr), item.lnum, strpart( item.text, start_idx, len ), strpart( item.text, end_idx+3 ) )
            silent put = text_line 
            let qf_idx += 1
        endfor
    elseif a:search_method ==# 'g' " definition
        let text = ''
        for item in result_list
            if item =~# '^\S\+' || item =~# '^\s\+\#\s\+line\s\+filename \/ context \/ line'
                continue
            endif

            " if this is a location line
            if item =~# '^\s\+\d\+\s\+\d\+\s\+\S\+\s\+<<\S\+>>'
                let elements = split ( item, '\s\+' )
                if len(elements) == 4  
                    let text = elements[2].':'.elements[1].':'.' '.elements[3]
                else
                    call ex#warning ('invalid line')
                endif
                continue
            endif

            " put context line
            let context = strpart( item, match(item, '\S') )
            silent put = text . ' ' . context 
        endfor
    elseif a:search_method ==# 'e' " egrep
        let qf_idx = 0
        for item in result_list
            let end_idx = stridx( item.text, ">>")
            let text_line = printf(" [%03d] %s:%d: %s", qf_idx, bufname(item.bufnr), item.lnum, strpart( item.text, end_idx+3 ) )
            silent put = text_line 
            let qf_idx += 1
        endfor
    else
        call ex#warning("Wrong search method")
        return
    endif
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: 
" ------------------------------------------------------------------ 

function excscope#ParseFunction() " <<<
    " if we have taglist use it
    if exists(':Tlist')
        silent exec "TlistUpdate"
        let search_text = Tlist_Get_Tagname_By_Line()
        if search_text == ""
            call ex#warning("pattern not found, you're not in a function")
            return
        endif
    else
        let search_text = expand("<cword>")
    endif
    call excscope#GetSearchResult(search_text, 'ds')
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: 
" ------------------------------------------------------------------ 

function excscope#MapPickupResultKeys() " <<<
    nnoremap <buffer> <silent> <C-Right>   :call <SID>exCS_SwitchWindow('Select')<CR>
    nnoremap <buffer> <silent> <C-Left>   :call <SID>exCS_SwitchWindow('QuickView')<CR>

    nnoremap <buffer> <silent> <Leader>r :call <SID>exCS_ShowPickedResultNormalMode('', 'replace', 'pattern', 0)<CR>
    nnoremap <buffer> <silent> <Leader>d :call <SID>exCS_ShowPickedResultNormalMode('', 'replace', 'pattern', 1)<CR>
    " DISABLE { 
    " nnoremap <buffer> <silent> <Leader>ar :call <SID>exCS_ShowPickedResultNormalMode('', 'append', 'pattern', 0)<CR>
    " nnoremap <buffer> <silent> <Leader>ad :call <SID>exCS_ShowPickedResultNormalMode('', 'append', 'pattern', 1)<CR>
    " vnoremap <buffer> <silent> <Leader>r <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'replace', 'pattern', 0)<CR>
    " vnoremap <buffer> <silent> <Leader>d <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'replace', 'pattern', 1)<CR>
    " vnoremap <buffer> <silent> <Leader>ar <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'append', 'pattern', 0)<CR>
    " vnoremap <buffer> <silent> <Leader>ad <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'append', 'pattern', 1)<CR>

    " nnoremap <buffer> <silent> <Leader>fr :call <SID>exCS_ShowPickedResultNormalMode('', 'replace', 'file', 0)<CR>
    " nnoremap <buffer> <silent> <Leader>fd :call <SID>exCS_ShowPickedResultNormalMode('', 'replace', 'file', 1)<CR>
    " nnoremap <buffer> <silent> <Leader>far :call <SID>exCS_ShowPickedResultNormalMode('', 'append', 'file', 0)<CR>
    " nnoremap <buffer> <silent> <Leader>fad :call <SID>exCS_ShowPickedResultNormalMode('', 'append', 'file', 1)<CR>
    " vnoremap <buffer> <silent> <Leader>fr <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'replace', 'file', 0)<CR>
    " vnoremap <buffer> <silent> <Leader>fd <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'replace', 'file', 1)<CR>
    " vnoremap <buffer> <silent> <Leader>far <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'append', 'file', 0)<CR>
    " vnoremap <buffer> <silent> <Leader>fad <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'append', 'file', 1)<CR>

    " nnoremap <buffer> <silent> <Leader>gr :call <SID>exCS_ShowPickedResultNormalMode('', 'replace', '', 0)<CR>
    " nnoremap <buffer> <silent> <Leader>gd :call <SID>exCS_ShowPickedResultNormalMode('', 'replace', '', 1)<CR>
    " nnoremap <buffer> <silent> <Leader>gar :call <SID>exCS_ShowPickedResultNormalMode('', 'append', '', 0)<CR>
    " nnoremap <buffer> <silent> <Leader>gad :call <SID>exCS_ShowPickedResultNormalMode('', 'append', '', 1)<CR>
    " vnoremap <buffer> <silent> <Leader>gr <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'replace', '', 0)<CR>
    " vnoremap <buffer> <silent> <Leader>gd <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'replace', '', 1)<CR>
    " vnoremap <buffer> <silent> <Leader>gar <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'append', '', 0)<CR>
    " vnoremap <buffer> <silent> <Leader>gad <ESC>:call <SID>exCS_ShowPickedResultVisualMode('', 'append', '', 1)<CR>
    " } DISABLE end 
endfunction " >>>

" ======================================================== 
" select window functions
" ======================================================== 

" ------------------------------------------------------------------ 
" Desc: Init exGlobalSearch window
" ------------------------------------------------------------------ 

function g:exCS_InitSelectWindow() " <<<
    silent! setlocal nonumber
    
    " if no scope connect yet, connect it
    if !exists('g:exES_Cscope')
        let g:exES_Cscope = ' '.g:exvim_folder.'/cscope.out'
    endif
    if cscope_connection(4, "cscope.out", g:exES_Cscope ) == 0
        call g:exCS_ConnectCscopeFile()
    endif

    " code highlight
    " if g:exCS_highlight_result
        " " this will load the syntax highlight as cpp for search result
        " silent exec "so $VIM/vimfiles/after/syntax/exUtility.vim"
    " endif

    " syntax highlights
    syntax region ex_SynSearchPattern start="^----------" end="----------"

    " syntax for pattern [qf_nr] preview <<line>> | context
    syntax region exCS_SynDummy start='^ \[\d\+\]\s' end='<\d\+>' oneline keepend contains=exCS_SynQfNumber,ex_SynLineNr
    syntax match exCS_SynQfNumber '^ \[\d\+\]' contained
    syntax match ex_SynLineNr '<\d\+>' contained

    " syntax for pattern [qf_nr] file_name:line: <<fn>> context
    syntax match exCS_SynDummy '^\S\+:\d\+:\s<<\S\+>>' contains=exCS_SynLineNr2,ex_SynFileName,exCS_DefType
    syntax match exCS_SynDummy '^ \[\d\+\]\s\S\+:\d\+:\(\s<<\S\+>>\)*' contains=exCS_SynQfNumber,exCS_SynLineNr2,exCS_SynFileName2,exCS_DefType
    syntax match exCS_SynLineNr2 '\d\+:' contained
    syntax region ex_SynFileName start="^[^:]*" end=":" keepend oneline contained
    syntax region exCS_SynFileName2 start="^ \[\d\+\]\s[^:]*" end=":" keepend oneline contained contains=exCS_SynQfNumber
    syntax match exCS_DefType '<<\S\+>>' contained

    "
    hi link exCS_SynFileName2 ex_SynFileName
    hi link exCS_SynLineNr2 ex_SynLineNr
    hi link exCS_DefType Special

    " key map
    silent exec "nnoremap <buffer> <silent> " . g:ex_keymap_close . " :call <SID>exCS_ToggleWindow('Select')<CR>"
    silent exec "nnoremap <buffer> <silent> " . g:ex_keymap_resize . " :call <SID>exCS_ResizeWindow()<CR>"
    silent exec "nnoremap <buffer> <silent> " . g:ex_keymap_confirm . " \\|:call <SID>exCS_GotoInSelectWindow()<CR>"
    nnoremap <buffer> <silent> <2-LeftMouse>   \|:call <SID>exCS_GotoInSelectWindow()<CR>

    "
    call excscope#MapPickupResultKeys()


    " TODO: shrink text for d method

    " autocmd
    au CursorMoved <buffer> :call ex#hl#select_line()
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: goto select line
" ------------------------------------------------------------------ 

function excscope#GotoInSelectWindow() " <<<
    let s:exCS_select_idx = line(".")
    let s:confirm_at = line('.')
    call ex#hl#confirm_line(s:confirm_at)
    call excscope#Goto()
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: Update exGlobalSearch window 
" ------------------------------------------------------------------ 

function g:exCS_UpdateSelectWindow() " <<<
    silent call cursor(s:exCS_select_idx, 1)
    let s:confirm_at = line('.')
    call ex#hl#confirm_line(s:confirm_at)
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: Get Global Search Result
" search_pattern = ''
" search_method = -s / -r / -w
" ------------------------------------------------------------------ 

function excscope#GetSearchResult(search_pattern, search_method) " <<<
    " if cscope file not connect, connect it
    if cscope_connection(4, "cscope.out", g:exES_Cscope ) == 0
        call g:exCS_ConnectCscopeFile()
    endif

    " jump back to edit buffer first
    call ex#window#goto_edit_window()

    " change window for suitable search method
    let search_result = ''
    let g:exCS_use_vertical_window = 0
    let g:exCS_window_direction = 'bel'

    if a:search_method =~# '\(d\|i\)'
        let g:exCS_use_vertical_window = 1
        let g:exCS_window_direction = 'botright'
    elseif a:search_method ==# 'g' " NOTE: the defination result not go into quickfix list
        silent redir =>search_result
    endif

    " start processing cscope
    let search_cmd = 'cscope find ' . a:search_method . ' ' . a:search_pattern
    try
        silent exec search_cmd
    catch /^Vim\%((\a\+)\)\=:E259/
        "call ex#warning("no matches found for " . a:search_pattern )
        echohl WarningMsg
        echon "no matches found for " . a:search_pattern . "\r"
        echohl None
        return
    endtry

    " finish redir if it is method 'g'
    let result_list = []
    if a:search_method ==# 'g' 
        silent redir END
        let result_list = split( search_result, "\n" ) 

        " NOTE: in cscope find g, if there is no search result, that means it
        "       only have one result, and it will perform a jump directly
        if len(result_list) == 1
            return
        endif
    else
        " go back 
        silent exec "normal! \<c-o>"
    endif

    " open and goto search window first
    let cs_winnr = bufwinnr(s:title)
    if cs_winnr != -1
        call excscope#close_window()
    endif
    " call excscope#ToggleWindow('Select')
    call excscope#toggle_window()

    " clear screen and put new result
    silent exec '1,$d _'

    " add online help 
    if g:ex_cscope_enable_help
        silent call append ( 0, s:help_text )
        silent exec '$d'
        let start_line = len(s:help_text)
    else
        let start_line = 0
    endif

    let s:confirm_at = line('.')
    call ex#hl#confirm_line(s:confirm_at)

    " processing search result
    let search_method_text = 'unknown'
    if a:search_method ==# 'da' " all called function
        let search_method_text = '(called functions all)'
    elseif a:search_method ==# 'ds' " select called function
        let search_method_text = '(called functions current)'
    elseif a:search_method ==# 'c' " calling function
        let search_method_text = '(calling functions)'
    elseif a:search_method ==# 'i' " including file
        let search_method_text = '(including files)'
    elseif a:search_method ==# 's' " C symbol
        let search_method_text = '(C symbols)'
    elseif a:search_method ==# 'g' " definition
        let search_method_text = '(definitions)'
    elseif a:search_method ==# 'e' " egrep
        let search_method_text = '(egrep results)'
    endif

    let pattern_title = '----------' . a:search_pattern . ' ' . search_method_text . '----------'
    silent put = pattern_title 
    call excscope#ShowQuickFixResult( a:search_method, result_list )

    " Init search state
    silent normal gg
    let line_num = search(pattern_title)
    let s:exCS_select_idx = line_num+1
    silent call cursor( s:exCS_select_idx, 1 )
    silent normal zz
endfunction " >>>

" ======================================================== 
"  quick view window part
" ======================================================== 

" ------------------------------------------------------------------ 
" Desc: Init exGlobalSearch select window
" ------------------------------------------------------------------ 

function g:exCS_InitQuickViewWindow() " <<<
    silent! setlocal nonumber
    setlocal foldmethod=marker foldmarker=<<<<<<,>>>>>> foldlevel=1

    " syntax highlights
    syntax match ex_SynFold '<<<<<<'
    syntax match ex_SynFold '>>>>>>'
    syntax region ex_SynSearchPattern start="^----------" end="----------"

    " syntax for pattern [qf_nr] preview <<line>> | context
    syntax region exCS_SynDummy start='^ \[\d\+\]\s' end='<\d\+>' oneline keepend contains=exCS_SynQfNumber,ex_SynLineNr
    syntax match exCS_SynQfNumber '^ \[\d\+\]' contained
    syntax match ex_SynLineNr '<\d\+>' contained

    " syntax for pattern [qf_nr] file_name:line: <<fn>> context
    syntax match exCS_SynDummy '^\S\+:\d\+:\s<<\S\+>>' contains=exCS_SynLineNr2,ex_SynFileName,exCS_DefType
    syntax match exCS_SynDummy '^ \[\d\+\]\s\S\+:\d\+:\(\s<<\S\+>>\)*' contains=exCS_SynQfNumber,exCS_SynLineNr2,exCS_SynFileName2,exCS_DefType
    syntax match exCS_SynLineNr2 '\d\+:' contained
    syntax region ex_SynFileName start="^[^:]*" end=":" oneline contained
    syntax region exCS_SynFileName2 start=" [^:]*" end=":" oneline contained contains=exCS_SynQfNumber
    syntax match exCS_DefType '<<\S\+>>' contained

    "
    hi link exCS_SynFileName2 ex_SynFileName
    hi link exCS_SynLineNr2 ex_SynLineNr
    hi link exCS_DefType Special

    " key map
    silent exec "nnoremap <buffer> <silent> " . g:ex_keymap_close . " :call <SID>exCS_ToggleWindow('QuickView')<CR>"
    silent exec "nnoremap <buffer> <silent> " . g:ex_keymap_resize . " :call <SID>exCS_ResizeWindow()<CR>"
    silent exec "nnoremap <buffer> <silent> " . g:ex_keymap_confirm . " \\|:call <SID>exCS_GotoInQuickViewWindow()<CR>"
    nnoremap <buffer> <silent> <2-LeftMouse>   \|:call <SID>exCS_GotoInQuickViewWindow()<CR>

    "
    call excscope#MapPickupResultKeys()

    " autocmd
    au CursorMoved <buffer> :call ex#hl#select_line()
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: Update exGlobalSearch QuickView window 
" ------------------------------------------------------------------ 

function g:exCS_UpdateQuickViewWindow() " <<<
    silent call cursor(s:exCS_quick_view_idx, 1)
    let s:confirm_at = line('.')
    call ex#hl#confirm_line(s:confirm_at)
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: goto select line
" ------------------------------------------------------------------ 

function excscope#GotoInQuickViewWindow() " <<<
    let s:exCS_quick_view_idx = line(".")
    let s:confirm_at = line('.')
    call ex#hl#confirm_line(s:confirm_at)
    call excscope#Goto()
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: copy the quick view result with search pattern
" ------------------------------------------------------------------ 

function excscope#CopyPickedLine( search_pattern, line_start, line_end, search_method, inverse_search ) " <<<
    if a:search_pattern == ''
        let search_pattern = @/
    else
        let search_pattern = a:search_pattern
    endif
    if search_pattern == ''
        let s:exCS_quick_view_search_pattern = ''
        call ex#warning('search pattern not exists')
        return
    else
        let s:exCS_quick_view_search_pattern = '----------' . search_pattern . '----------'
        let full_search_pattern = search_pattern
        " DISABLE { 
        " if a:search_method == 'pattern'
        "     let full_search_pattern = '^ \[\d\+\]\S\+<\d\+>.*\zs' . search_pattern
        " elseif a:search_method == 'file'
        "     let full_search_pattern = '\(.\+<\d\+>\)\&' . search_pattern
        " endif
        " } DISABLE end 
        " save current cursor position
        let save_cursor = getpos(".")
        " clear down lines
        if a:line_end < line('$')
            silent call cursor( a:line_end, 1 )
            silent exec 'normal! j"_dG'
        endif
        " clear up lines
        if a:line_start > 1
            silent call cursor( a:line_start, 1 )
            silent exec 'normal! k"_dgg'
        endif
        silent call cursor( 1, 1 )

        " clear the last search result
        if !empty( s:exCS_picked_search_result )
            silent call remove( s:exCS_picked_search_result, 0, len(s:exCS_picked_search_result)-1 )
        endif

        " if inverse search, we first filter out not pattern line, then
        " then filter pattern
        if a:inverse_search
            " DISABLE: let search_results = '\(.\+<\d\+>\).*'
            let search_results = '\S\+'
            silent exec 'v/' . search_results . '/d'
            silent exec 'g/' . full_search_pattern . '/d'
        else
            silent exec 'v/' . full_search_pattern . '/d'
        endif

        " clear pattern result
        while search('----------.\+----------', 'w') != 0
            silent exec 'normal! "_dd'
        endwhile

        " copy picked result
        let s:exCS_picked_search_result = getline(1,'$')

        " recover
        silent exec 'normal! u'

        " go back to the original position
        silent call setpos(".", save_cursor)
    endif
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: show the picked result in the quick view window
" ------------------------------------------------------------------ 

function excscope#ShowPickedResult( search_pattern, line_start, line_end, edit_mode, search_method, inverse_search ) " <<<
    call excscope#CopyPickedLine( a:search_pattern, a:line_start, a:line_end, a:search_method, a:inverse_search )
    " call excscope#SwitchWindow('QuickView')
    call excscope#open_window()
    if a:edit_mode == 'replace'
        silent exec '1,$d _'
        let s:exCS_quick_view_idx = 1
        let s:confirm_at = line('.')
        call ex#hl#confirm_line(s:confirm_at)

        silent put = s:exCS_quick_view_search_pattern
        silent put = s:exCS_fold_start
        silent put = s:exCS_picked_search_result
        silent put = s:exCS_fold_end
        silent call search('<<<<<<', 'w')
    elseif a:edit_mode == 'append'
        silent exec 'normal! G'
        silent put = ''
        silent put = s:exCS_quick_view_search_pattern
        silent put = s:exCS_fold_start
        silent put = s:exCS_picked_search_result
        silent put = s:exCS_fold_end
    endif
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: show the picked result in the quick view window
" ------------------------------------------------------------------ 

function excscope#ShowPickedResultNormalMode( search_pattern, edit_mode, search_method, inverse_search ) " <<<
    let line_start = 1
    let line_end = line('$')
    call excscope#ShowPickedResult( a:search_pattern, line_start, line_end, a:edit_mode, a:search_method, a:inverse_search )
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: show the picked result in the quick view window
" ------------------------------------------------------------------ 

function excscope#ShowPickedResultVisualMode( search_pattern, edit_mode, search_method, inverse_search ) " <<<
    let line_start = 3
    let line_end = line('$')

    let tmp_start = line("'<")
    let tmp_end = line("'>")
    if line_start < tmp_start
        let line_start = tmp_start
    endif
    if line_end > tmp_end
        let line_end = tmp_end
    endif

    call excscope#ShowPickedResult( a:search_pattern, line_start, line_end, a:edit_mode, a:search_method, a:inverse_search )
endfunction " >>>





" }}}

" functions {{{1
" excscope#bind_mappings {{{2
function excscope#bind_mappings()
    call ex#keymap#bind( s:keymap )
endfunction

" excscope#register_hotkey {{{2
function excscope#register_hotkey( priority, local, key, action, desc )
    call ex#keymap#register( s:keymap, a:priority, a:local, a:key, a:action, a:desc )
endfunction

" excscope#toggle_help {{{2
" s:update_help_text {{{2
function s:update_help_text()
    if s:help_open
        let s:help_text = ex#keymap#helptext(s:keymap)
    else
        let s:help_text = s:help_text_short
    endif
endfunction

function excscope#toggle_help()
    if !g:ex_cscope_enable_help
        return
    endif

    let s:help_open = !s:help_open
    silent exec '1,' . len(s:help_text) . 'd _'
    call s:update_help_text()
    silent call append ( 0, s:help_text )
    silent keepjumps normal! gg
    call ex#hl#clear_confirm()
endfunction

" excscope#open_window {{{2

function excscope#init_buffer()
    set filetype=excscope
    au! BufWinLeave <buffer> call <SID>on_close()

    if line('$') <= 1 && g:ex_cscope_enable_help
        silent call append ( 0, s:help_text )
        silent exec '$d'
    endif
endfunction

function s:on_close()
    let s:zoom_in = 0
    let s:help_open = 0

    " go back to edit buffer
    call ex#window#goto_edit_window()
    call ex#hl#clear_target()
endfunction

function excscope#open_window()
    let winnr = winnr()
    if ex#window#check_if_autoclose(winnr)
        call ex#window#close(winnr)
    endif
    call ex#window#goto_edit_window()

    let winnr = bufwinnr(s:title)
    if winnr == -1
        call ex#window#open( 
                    \ s:title, 
                    \ g:ex_cscope_winsize,
                    \ g:ex_cscope_winpos,
                    \ 1,
                    \ 1,
                    \ function('excscope#init_buffer')
                    \ )
        if s:confirm_at != -1
            call ex#hl#confirm_line(s:confirm_at)
        endif
    else
        exe winnr . 'wincmd w'
    endif
endfunction

" excscope#toggle_window {{{2
function excscope#toggle_window()
    let result = excscope#close_window()
    if result == 0
        call excscope#open_window()
    endif
endfunction

" excscope#close_window {{{2
function excscope#close_window()
    let winnr = bufwinnr(s:title)
    if winnr != -1
        call ex#window#close(winnr)
        return 1
    endif
    return 0
endfunction

" excscope#toggle_zoom {{{2
function excscope#toggle_zoom()
    let winnr = bufwinnr(s:title)
    if winnr != -1
        if s:zoom_in == 0
            let s:zoom_in = 1
            call ex#window#resize( winnr, g:ex_cscope_winpos, g:ex_cscope_winsize_zoom )
        else
            let s:zoom_in = 0
            call ex#window#resize( winnr, g:ex_cscope_winpos, g:ex_cscope_winsize )
        endif
    endif
endfunction

" excscope#cursor_moved {{{2
function excscope#cursor_moved()
    let line_num = line('.')
    if line_num == s:last_line_nr
        return
    endif

    while match(getline('.'), '^\s\+\d\+:') == -1
        if line_num > s:last_line_nr
            if line('.') == line('$')
                break
            endif
            silent exec 'normal! j'
        else
            if line('.') == 1
                silent exec 'normal! 2j'
                let s:last_line_nr = line_num - 1
            endif
            silent exec 'normal! k'
        endif
    endwhile

    let s:last_line_nr = line('.')
endfunction

" excscope#confirm_select {{{2
" modifier: '' or 'shift'
function excscope#confirm_select(modifier)
    let s:exCS_select_idx = line(".")
    let s:confirm_at = line('.')
    call ex#hl#confirm_line(s:confirm_at)
    call excscope#Goto()
endfunction

" excscope#select {{{2

function s:convert_filename(filename)
    return fnamemodify( a:filename, ':t' ) . ' (' . fnamemodify( a:filename, ':h' ) . ')'    
endfunction

" function s:put_taglist()

    " " if empty tag_list, put the error result
    " if empty(s:tag_list)
        " silent put = 'Error: tag not found => ' . s:tag
        " silent put = ''
        " return
    " endif

    " " Init variable
    " let idx = 1
    " let pre_tag_name = s:tag_list[0].name
    " let pre_file_name = s:tag_list[0].filename
    " " put different file name at first
    " silent put = pre_tag_name
    " silent put = s:convert_filename(pre_file_name)
    " " put search result
    " for tag_info in s:tag_list
        " if tag_info.name !=# pre_tag_name
            " silent put = ''
            " silent put = tag_info.name
            " silent put = s:convert_filename(tag_info.filename)
        " elseif tag_info.filename !=# pre_file_name
            " silent put = s:convert_filename(tag_info.filename)
        " endif
        " " put search patterns
        " let quick_view = ''
        " if tag_info.cmd =~# '^\/\^' 
            " let quick_view = strpart( tag_info.cmd, 2, strlen(tag_info.cmd)-4 )
            " let quick_view = strpart( quick_view, match(quick_view, '\S') )
        " elseif tag_info.cmd =~# '^\d\+'
            " try
                " let file_list = readfile( fnamemodify(tag_info.filename,":p") )
                " let line_num = eval(tag_info.cmd) - 1 
                " let quick_view = file_list[line_num]
                " let quick_view = strpart( quick_view, match(quick_view, '\S') )
            " catch /^Vim\%((\a\+)\)\=:E/
                " let quick_view = "ERROR: can't get the preview from file!"
            " endtry
        " endif
        " " this will change the \/\/ to //
        " let quick_view = substitute( quick_view, '\\/', '/', "g" )
        " silent put = '        ' . idx . ': ' . quick_view
        " let idx += 1
        " let pre_tag_name = tag_info.name
        " let pre_file_name = tag_info.filename
    " endfor

    " " find the first item
    " silent normal gg
    " call search( '^\s*1:', 'w')
    " let s:last_line_nr = line('.')
" endfunction

" function excscope#select( tag )
    " " strip white space.
    " let in_tag = substitute (a:tag, '\s\+', '', 'g')
    " if match(in_tag, '^\(\t\|\s\)') != -1
        " return
    " endif

    " " get taglist
    " " NOTE: we use \s\* which allowed the tag have white space at the end.
    " "       this is useful for lua. In current version of cTags(5.8), it
    " "       will parse the lua function with space if you define the function
    " "       as: functon foobar () instead of functoin foobar(). 
    " if g:ex_tags_ignore_case && (match(in_tag, '\u') == -1)
        " let in_tag = substitute( in_tag, '\', '\\\', "g" )
        " echomsg 'parsing ' . in_tag . '...(ignore case)'
        " let tag_list = taglist('\V\^'.in_tag.'\s\*\$')
    " else
        " let in_tag = substitute( in_tag, '\', '\\\', "g" )
        " echomsg 'parsing ' . in_tag . '...(no ignore case)'
        " let tag_list = taglist('\V\^\C'.in_tag.'\s\*\$')
    " endif

    " let s:confirm_at = -1
    " let s:tag = a:tag
    " let s:tag_list = tag_list

    " " open the global search window
    " call extags#open_window()

    " " clear screen and put new result
    " silent exec '1,$d _'

    " " add online help 
    " if g:ex_tags_enable_help
        " silent call append ( 0, s:help_text )
        " silent exec '$d'
        " let start_line = len(s:help_text)
    " else
        " let start_line = 0
    " endif

    " "
    " call s:put_taglist ()
" endfunction

" }}}1

" vim: set foldmethod=marker foldmarker=<<<,>>> foldlevel=9999:
