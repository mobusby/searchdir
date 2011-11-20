#!/bin/bash

# searchdir
# version 0.2
#
# Copyright (c) 2010, Mark Busby <www.BusbyFreelance.com>
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.
#
# This software is provided without cost.  If you like it, pass it on!
# Donations are appreciated, but are not required or expected.
#
# To use this script, just place this file in your personal bin directory
# (usually $HOME/bin), or your system bin directory (usually /usr/bin).
# Make sure the file is executable: 
#     $ chmod a+x searchdir.bash
# Optionally, remove the extension from the file to make execution easier
#     $ mv searchdir.bash searchdir
#


simpleIFS="	
"
complexIFS=" 	
"

clearline() {
	echo -n -e "\r                                                                                \r$@"
}

programUsage() {
	echo -n "Usage: "
	echo -n "$1" | sed 's|.*/||'
	echo " [-r] [-n] [-d N] [-?] [search dir] pattern"
	echo "    Where pattern may be any regular expression recognized by grep -e"
	echo "    -r = recursive search through all subdirectories"
	echo "    -n = look at file names only (do not look at file contents)"
	echo "    -d = only look N levels deep (implies -r, N > 0 required)"
	echo "    -f = print file names only (don't print file contents)"
}

recursive="false"
namesOnly="false"
contentsOff="false"
maxDepth=0

#echo "\$1 = $1"
cloptions="true"
while [ "$cloptions" = "true" ]; do
	case "$1" in
		"-r")
			recursive="true"
			shift
			;;
		"-n")
			namesOnly="true"
			shift
			;;
		"-d")
			tempVar=$2
			if [ $(( tempVar )) -gt 0 ]; then
				maxDepth="$(( tempVar ))"
				recursive="true"
				shift 2
			else
				echo "expected an integer > 0 after -d, but got $2 instead."
				programUsage $0
				exit
			fi
			unset tempVar
			;;
		"-f")
			contentsOff="true"
			shift
			;;
		"-?")
			programUsage $0
			exit;
			;;
		""  )
			echo "No pattern specified"
			programUsage $0
			exit;
			;;
		*   )
			cloptions="false"
			;;
	esac
 done

#echo "$2"
if [ "" = "$2" ]; then 
	searchdir="."
	pattern="$1"
else 
	searchdir="$1"
	pattern="$2"
fi

if [ "${searchdir: ${#searchdir} - 1 : ${#searchdir}}" = "/" ]; then
	searchDir="${searchdir: 0 : ${#searchdir} - 1}"
else
	searchDir="$searchdir"
fi

# print action details (ui)
if [ "$recursive" = "true" ]; then
	echo -n "Doing recursive search in"
else
	echo -n "Searching"
fi

echo -en " $searchdir for \"$pattern\" "

if [ "$namesOnly" = "true" ]; then
	echo -en "in file names"
else
	echo -en "in file names and contents"
fi

if [ $((maxDepth)) -gt 1 ]; then
	echo -en ", $maxDepth levels deep"
elif [ $((maxDepth)) -gt 0 ]; then
	echo -en ", 1 level deep"
fi

echo -en "\n\nCollecting directory list... "

# run find
if [ $((maxDepth)) -gt 0 ]; then
	searchString=`find "$searchdir" -maxdepth $maxDepth -printf '%p\n'`
elif [ "$recursive" = "true" ]; then
	searchString=`find "$searchdir" -printf '%p\n'`
else
	searchString=`find "$searchdir" -maxdepth 1 -printf '%p\n'`
fi

clearline

if [ "$namesOnly" = "true" ]; then
	echo "$searchString" | grep -e $pattern
	exit
fi

linePrefix="file: "
remainingLineLength=$((80 - ${#linePrefix}))
longLinePrefix="${linePrefix}${searchDir}/... "
remainingLongLineLength=$((80 - ${#longLinePrefix}))

IFS="$simpleIFS"
numResults=$((0));
for file in $searchString; do
	if [ "$gotResult" = "true" ]; then 
		echo "";
	fi
	
	gotResult="false"
	
	# print the name of the file which is being searched
	clearline "file: "
	if [ ${#file} -gt $remainingLineLength ]; then
		# take out the search directory (at start of file name)
		printing="${file: ${#searchDir} + 1 : ${#file}}"
		printing="${printing: -$remainingLongLineLength : ${#printing}}"
		echo -ne "${printPrefix}${printing}"
	else
		echo -n "$file"
	fi
	
	# look for the search term in the file name
	stringInFileName=`echo -n "$file" | perl -pe "s/.*\///g;" | grep -e $pattern`
	if [ "$stringInFileName" ]; then
		haveResult="true"
		# print the full name of the file
		clearline "$file\n"
		gotResult="true"
	fi
	
	# look for the search term in the file contents
	if [ "$namesOnly" = "false" ]; then
		if [ ! -d $file ]; then
			if [ -r $file ]; then 
				tempResultA=`echo "$file" | grep -E "([.]iso)$|([.]avi)$|([.]exe)$"`
				tempResultEXIF=`echo "$file" | grep -E "([.]jpg)$|([.]JPG)$|([.]JPEG)$|([.]jpeg)$|([.]TIFF)$|([.]tiff)$|([.]TIF)$|([.]tif)$|([.]PNG)$|([.]png)$"`
				if [ "$tempResultA" ]; then 
					continue;
				elif [ "$tempResultEXIF" ]; then
					if [ "`which exiv2`" ]; then
						output=`exiv2 -u pr "$file"  2>&1 | grep -n -T -e "$pattern"`
					else
						continue
					fi
				else
					output=`cat "$file" | grep -n -T -e $pattern`
				fi
				
				if [ "" != "$output" ]; then
					if [ "Binary file (standard input) matches" != "$output" ]; then
						haveResult="true"
						clearline
						if [ "$gotResult" = "false" ]; then 
							clearline "$file\n"; 
						fi
						if [ "$contentsOff" = "false" ]; then echo "$output"; fi
						gotResult="true"
					fi
				fi
			fi
		fi
	fi
	
	stringInFileName=""
	
	if [ "$gotResult" = "true" ]; then
		for num in 1 2 3 4; do echo -en "*******************"; done
		echo ""
		numResults=$((numResults + 1))
	fi
done
IFS="$complexIFS"

if [ ! "$haveResult" = "true" ]; then
	clearline "No results found\n"
else
	if [ $numResults -eq 1 ]; then
		clearline "Found 1 result\n"
	else
		clearline "Found $numResults results\n"
	fi
fi


# Changelog:
# 0.2:
#    - added option to supress output of file contents, print only file names.
#    - don't search contents of files ending with .iso, .exe, .avi
# 0.1:
#    - initial release
