let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/main.vim'    
if has('nvim')
    lua require('git_gutter').setup{}
endif
