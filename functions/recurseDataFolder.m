function recurseDataFolder(folderToCheck,pathStem,constants)
	%disp(['Listing folder ' pathStem folderToCheck]);
	fList = dir([pathStem folderToCheck]);
	for f = 1:length(fList)
		if isempty(strfind(fList(f).name(1),'.')) && isempty(strfind(fList(f).name(1:2),'..'))
			if fList(f).isdir
				%Handle folders
				%disp(['Checking folder ' folderToCheck]);
				recurseDataFolder(fList(f).name,[pathStem folderToCheck '/'],constants);
				
			else
				%File found, two files per data folder expected. Return after...
				handleDataFolder(folderToCheck,pathStem,constants);
				return;	%This folder does not require further consideration, do not recurse further
			end
		end
		
	end
