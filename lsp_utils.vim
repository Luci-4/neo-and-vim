function! FormatSymbolForBreadcrumbs(name, kind) abort
    " Namespace
    if a:kind == 3
        if a:name ==# '(anonymous namespace)'
            let display = '{} namespace'
        else
            let display = '{} ' . a:name
        endif

        " Class
    elseif a:kind == 5
        let display = 'Cls ' . a:name

        " Struct
    elseif a:kind == 23
        let display = 'Str ' . a:name

        " Method
    elseif a:kind == 6
        let display = '∙ƒ ' . a:name

        " Function
    elseif a:kind == 12
        let display = 'ƒ ' . a:name

        " Property / Field
    elseif a:kind == 7 || a:kind == 8
        let display = '∙' . a:name

        " Constructor
    elseif a:kind == 9
        let display = '∙ƒ! ' . a:name

        " Enum
    elseif a:kind == 10
        let display = '∈ ' . a:name

        " EnumMember
    elseif a:kind == 22
        let display = '∙' . a:name

        " Constant / Macro
    elseif a:kind == 14
        let display = '≡ ' . a:name

        " Variable
    elseif a:kind == 13
        let display = 'var ' . a:name

        " Default fallback
    else
        let display = a:name
    endif

    return display
endfunction

