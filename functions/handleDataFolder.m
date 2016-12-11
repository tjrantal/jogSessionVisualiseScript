function handleDataFolder(folderToCheck,pathStem,constants)
	fList = dir([pathStem folderToCheck '/*.txt']);
  madFile = cellfun(@isempty,cellfun(@(x) strfind(x,'MaD'),{fList(:).name},'uniformoutput',false));
  madData = handleMadFile([pathStem folderToCheck '/' fList(find(madFile == 0,1,'first')).name]);
	gpsData = handleGPSFile([pathStem folderToCheck '/' fList(find(madFile == 1,1,'first')).name]);
  commonDateStampLims = [max([min(madData.dateStamps),min(gpsData.dateStamps)]), ...
                      min([max(madData.dateStamps),max(gpsData.dateStamps)])];
  figure('position',[10 10 900 500]);
	
	%Plot the MADs
	subplot(2,1,1)
	indices = find(madData.dateStamps >= commonDateStampLims(1) & madData.dateStamps <= commonDateStampLims(2)) ;
	plot(madData.mad(indices));
	tickMarks = round(linspace(indices(1),indices(end),5));
	set(gca,'xtick',tickMarks-tickMarks(1)+1,'xticklabel',datestr(madData.dateStamps(tickMarks)));
	title('MAD [g]');
	set(gca,'ylim',[0 1.5],'xlim',[1 tickMarks(end)-tickMarks(1)+1]);
	%Plot the GPS velocities
	subplot(2,1,2)
  indices = find(gpsData.dateStamps >= commonDateStampLims(1) & gpsData.dateStamps <= commonDateStampLims(2)) ;
	plot(gpsData.velocity(indices));
	tickMarks = round(linspace(indices(1),indices(end),5));
	set(gca,'xtick',tickMarks-tickMarks(1)+1,'xticklabel',datestr(gpsData.dateStamps(tickMarks)));
	title('vecocity [m/s]');
	set(gca,'ylim',[0 10],'xlim',[1 tickMarks(end)-tickMarks(1)+1]);
 