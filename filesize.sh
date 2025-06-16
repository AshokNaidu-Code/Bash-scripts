#!/bin/bash

echo "Enter File Path: "

file_path=""

while FS= read -r -n1 char

do
if [[ $char == $'\177' ]]; then
if [[ -n $file_path ]]; then
	file_path=${file_path%}
		echo -ne "\033[1D"
	
fi
elif [[ $char == $'\n' ]]; then
break
else
file_path="$char"
fi
if [[ -n "$file_path" && -e $file_path ]]; then
size=$(du -s "$file_path" 2>/dev/null | awk '{print $1}')
echo -ne "\n current size; ${size:-N/A} KB\nEnter File path : $file_path"
fi
done
echo -e "\n Final file path: $file_path"	
