install:
	cp awk-loader.awk /usr/bin/awk-loader
	chmod +x /usr/bin/awk-loader
	cp sub_coms/process-module.awk $(subcommands_dir)
	chmod +x $(subcommands_dir)/process-module.awk