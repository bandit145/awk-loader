## REQUIRES module_name VARIABLE TO BE PASSED FOR RENAME

function join(array,  rt_string){
	rt_string = ""
	for (item in array){
		if (item == 1){
			rt_string = array[item]
		}
		else{
			rt_string = rt_string" "array[item]
		}
	}
	return rt_string
}


$1 ~ "#"{next}
$1 == "function"{
	split($0, func_sig, " ")
	func_sig[2] = module_name"_"func_sig[2]
	print join(func_sig)
	next
}
$1 != "function"{print $0}
{next}