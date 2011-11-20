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
