let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/settings.vim'
execute 'source' s:config_path . '/remaps.vim'
