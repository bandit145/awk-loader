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

function gen_module(module_path, name,  rtrn_str,  rc,  cmd){
	rtrn_str = ""
	cmd = "cd "module_path "&& awk -v module_name="name" -f process-module.awk"
	while (cmd | getline line){
		rtrn_str = rtrn_str ""line"\n"
	}
	rc = close(cmd)
	return rtrn_str
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
	split("", requested_modules)
	get_args(args)
	program_file = ""
	avail_modules = get_modules(args["module_path"])
}

$1 == "#module:"{
	requested_modules[length(requested_modules) + 1] = $2
}
{program_file = program_file"\n"$0}

END{
	for (item in requested_modules){
		if (!(match(avail_modules, requested_modules[item]))){
			print "==> "requested_modules[item]" not available in path: "module_path
			exit 1
		}
		module_file = module_file""gen_module(args["module_path"])"\n"

	}
	print module_file""program_file > args["output"]
}