#!/usr/bin/env awk -f
function get_modules(module_path,  rtrn_str,  rc,  cmd){
	rtrn_str = ""
	cmd = "find "module_path" -mindepth 1"
	while (cmd | getline line){
		rtrn_str = rtrn_str" "line
	}
	rc = close(cmd)
	return rtrn_str
}

function gen_module(module_path, name, rtrn_str,  rc,  cmd){
	rtrn_str = ""
	cmd = "cd "module_path"&& awk -v module_name="name" -f "args["coms_dir"]"/process-module.awk "name".awk"
	while (cmd | getline line){
		rtrn_str = rtrn_str ""line"\n"
	}
	rc = close(cmd)
	return rtrn_str
}

function get_sub_mods(requested_modules, module_path, split_line,  req_list,  new_mods,  line,  item){
	new_mods = ""
	split(requested_modules, req_list, " ")
	for (item in req_list){
		while( "cat "module_path"/"req_list[item]".awk" | getline line ){
			split(line, split_line, " ")
			if ( !(split_line[1] ~ "#")){
				break
			}
			if (split_line[1] == "#module:"){
				# check for looping dependencies
				if ( !(index(requested_modules, split_line[2]))){
					requested_modules = requested_modules""split_line[2]" "
					new_mods = requested_modules
				}
			}	
		}
		close(module_path"/"req_list[item]".awk")
	}
	if (length(new_mods) > 0){
		new_mods = new_mods""get_sub_mods(new_mods, module_path)
	}
	return new_mods
}

function get_args(args){
	for (arg in ARGV){
		if (ARGV[arg] == "-m"){
			args["module_path"] = ARGV[arg + 1] 
		}
		if (ARGV[arg] == "-v"){
			args["verbose"] = 1
		}
		else{
			args["verbose"] = 0
		}
		if (ARGV[arg] == "-o"){
			args["output"] = ARGV[arg + 1]
		}
		args["coms_dir"] = ENVIRON["subcommands_dir"]
	}
	for (arg in ARGV){
		if (arg !=1){
			delete ARGV[arg]
		}
	}
}

BEGIN{
	module_file = ""
	split("", args)
	split("", module_arr)
	requested_modules = ""
	get_args(args)
	program_file = ""
	avail_modules = get_modules(args["module_path"])
}

$1 == "#module:"{
	requested_modules = requested_modules$2" "
}
{program_file = program_file"\n"$0}

END{
	requested_modules = get_sub_mods(requested_modules, args["module_path"], accum)
	print "accum: "requested_modules
	split(requested_modules, req_list, " ")
	for (item in req_list){
		if (!(match(avail_modules, req_list[item]))){
			print "==> "req_list[item]" not available in path: "module_path
			exit 1
		}
		module_file = module_file""gen_module(args["module_path"], req_list[item])"\n"

	}
	# generate runnable awk program with included function
	print module_file""program_file > args["output"]
}