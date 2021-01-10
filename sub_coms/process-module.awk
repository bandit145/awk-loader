## REQUIRES module_name VARIABLE TO BE PASSED FOR RENAME

$1 ~ "#"{next}
$1 == "function"{
	split($0, func_sig, " ")
	func_sig[2] = module_name"_"func_sig[2]
	print func_sig[1]" "func_sig[2]
	next
}
$1 != "function"{print $0}
{next}