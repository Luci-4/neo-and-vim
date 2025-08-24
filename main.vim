let s:config_path = split(&runtimepath, ',')[0]
echom s:config_path
execute 'source' s:config_path . '/settings.vim'
execute 'source' s:config_path . '/remaps.vim'
