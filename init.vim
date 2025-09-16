let s:config_path = split(&runtimepath, ',')[0]
lua require('spectroscope')
execute 'source' s:config_path . '/main.vim'    
