let s:config_path = fnamemodify($MYVIMRC, ':h')

execute 'source' s:config_path . '/settings.vim'
execute 'source' s:config_path . '/remaps.vim'
