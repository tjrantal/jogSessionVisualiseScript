function returnVal = handleMadFile(fileIn)
	data = dlmread(fileIn,'\t',1,0);
	returnVal = struct();
  returnVal.mad = data(:,2);
  returnVal.dateStamps = data(:,1)/(1000*60*60*24)+datenum('1970-1-1');
  