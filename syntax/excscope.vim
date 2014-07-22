if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" syntax highlight
" syntax match ex_cs_help #^".*# contains=ex_cs_help_key
" syntax match ex_cs_help_key '^" \S\+:'hs=s+2,he=e-1 contained contains=ex_cs_help_comma
" syntax match ex_cs_help_comma ':' contained

" syntax match ex_cs_header '^[^" ]\+'
" syntax match ex_cs_filename '^\S\+\s(.\+)$'
" syntax match ex_cs_nr '^        \d\+:'
" syntax match ex_cs_normal '^        \S.*$' contains=ex_cs_nr
" syntax match ex_cs_error '^Error:.*'


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


hi default link ex_SynFileName Statement
hi default link ex_SynLineNr LineNr

hi default ex_SynSearchPattern gui=bold guifg=Blue guibg=LightGray term=bold cterm=bold ctermfg=Blue ctermbg=LightGray


hi default exCS_SynQfNumber gui=none guifg=Red term=none cterm=none ctermfg=Red

"
hi link exCS_SynFileName2 ex_SynFileName
hi link exCS_SynLineNr2 ex_SynLineNr
hi link exCS_DefType Special


syntax match ex_cs_help #^".*# contains=ex_cs_help_key
syntax match ex_cs_help_key '^" \S\+:'hs=s+2,he=e-1 contained contains=ex_cs_help_comma
syntax match ex_cs_help_comma ':' contained

syntax region ex_cs_header start="^----------" end="----------"
syntax region ex_cs_filename start="^[^"][^:]*" end=":" oneline
syntax match ex_cs_linenr '\d\+:'


hi default link ex_cs_help Comment
hi default link ex_cs_help_key Label
hi default link ex_cs_help_comma Special

hi default link ex_cs_header SpecialKey
hi default link ex_cs_filename Directory
hi default link ex_cs_nr Special
hi default link ex_cs_normal Normal
hi default link ex_cs_error Error

let b:current_syntax = "excscope"

" vim:ts=4:sw=4:sts=4 et fdm=marker:
