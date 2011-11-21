# searchdir
# version 0.2
#
# Copyright (c) 2010, Mark Busby <www.BusbyCreations.com>
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

function fileList([string] $direc = ".", [switch] $recurse = $false, [switch] $allFiles)
{
	#"gathering for $direc" | out-host
	#if ($recurse) { "gathering recursively" | out-host; }
	#read-host
	$files = @();
	$folders = @();
	
	if ($recurse -and $allFiles)
	{
		foreach ($file in ls $direc -Force)
		{
			$name = $file.name
			
			if ($file.psiscontainer) 
			{
				foreach ($fllst in fileList "$direc\$name" -r -a)
				{
					$files += $fllst
				}
			}
			else 
			{
				$files += "$direc\$name";
			}
		}
	}
	elseif ($recurse)
	{
		foreach ($file in ls $direc)
		{
			$name = $file.name
			
			if ($file.psiscontainer) 
			{
				foreach ($fllst in fileList "$direc\$name" -r)
				{
					$files += $fllst
				}
			}
			else 
			{
				$files += "$direc\$name";
			}
		}
	}
	elseif ($allFiles)
	{
		foreach ($file in ls $direc -force)
		{
			$name = $file.name
			
			if ($file.psiscontainer) 
			{
			}
			else 
			{
				$files += "$direc\$name";
			}
		}
	}
	else
	{
		foreach ($file in ls $direc)
		{
			$name = $file.name
			
			if ($file.psiscontainer) 
			{
			}
			else 
			{
				$files += "$direc\$name";
			}
		}
	}
	
	return $files;
}

function searchdir([string] $pattern, [switch] $recurse = $false, [switch] $allFiles = $false, [switch] $namesOnly = $false) 
{
	$list = @();
	
	if ($pattern -eq "")
	{
		echo "Usage: searchdir pattern [-recurse] [-allFiles]"
		return;
	}
	
	if ($recurse -and $allFiles)
	{
		$list = filelist -r -a
		echo "Searching all files (including hidden files) recursively for $pattern..."
	}
	elseif ($recurse)
	{
		$list = filelist -r
		echo "Searching recursively for $pattern..."
	}
	elseif ($allFiles)
	{
		$list = filelist -a
		echo "Searching all files (including hidden files) for $pattern..."
	}
	else
	{
		$list = filelist
		echo "Searching for $pattern..."
	}
	
	if ($namesOnly -eq $true)
	{
		echo "    only looking at file names..."
	}
	
	foreach ($file in $list) 
	{
		$inName = $file | select-string -pattern $pattern -CaseSensitive -quiet
		if ($inName) { write-host -foregroundcolor white -backgroundcolor black "$file"; }
		
		if ($namesOnly -eq $false)
		{
			$result = cat $file | select-string -pattern $pattern -CaseSensitive; 
			if ($result) 
			{
				if ($inName) { }
				else { write-host -foregroundcolor white -backgroundcolor black "$file"; }
				$result; 
				echo "";
			}
		}
	}
}
