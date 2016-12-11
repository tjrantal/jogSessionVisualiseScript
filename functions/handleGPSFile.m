function returnVal = handleGPSFile(fileIn)
  
	data = dlmread(fileIn,',',1,1); %ignore the time stamps. 1 lat, 2 lon
 	
 	%Read time stamps
	fh  = fopen(fileIn,'r');
	
  nextLine = fgets(fh); %Get the header line
  headerLine = strsplit(nextLine,',','COLLAPSEDELIMITERS',false);
  timeInd = find(cellfun(@isempty,cellfun(@(x) strfind(x,'time'),headerLine,'uniformoutput',false)) == 0,1,'first');
  providerInd = find(cellfun(@isempty,cellfun(@(x) strfind(x,'provider'),headerLine,'uniformoutput',false)) == 0,1,'first');
  tStamps = {};
  provider = {};	%Filter out non-gps provided data
  nextLine = fgets(fh); %the first line of data
	while nextLine ~= -1
		split = strsplit(nextLine,',','COLLAPSEDELIMITERS',false);
		if isempty(tStamps)
			tStamps{1} = split{timeInd};
			provider{1} = split{providerInd};
		else
			tStamps{end+1} = split{timeInd};
			provider{end+1} = split{providerInd};
		end
    nextLine = fgets(fh); %Ignore the header line
	end
	fclose(fh);
	gpsIndices = find(cellfun(@isempty,cellfun(@(x) strfind(x,'gps'),provider,'uniformoutput',false)) == 0);
  timeStamps = datenum(tStamps(gpsIndices),'yyyy-mm-ddTHH:MM:SSZ');
  timeStampsS = timeStamps*24*60*60;
  %Resample gps data to uniform 1 Hz sample rate
  reTSamps = timeStampsS(1):1:timeStampsS(end);
  uniLon = interp1(timeStampsS,data(gpsIndices,2),reTSamps,'pchip');
  uniLat = interp1(timeStampsS,data(gpsIndices,1),reTSamps,'pchip');
  
  %filter the coordinates
  [fb,fa] = butter(2,0.05/0.5);
  fLon = filtfilt(fb,fa,uniLon);
  fLat = filtfilt(fb,fa,uniLat);
  
  %Calculate velocities with the haversine distance calculations
  %http://www.movable-type.co.uk/scripts/latlong.html
	R = 6371; %km earth radius
	phi1 = fLat(1:end-1)./180*pi;	%starting points in radians
	phi2 = fLat(2:end)./180*pi;	%ending points in radians
	dPhi = phi2-phi1;
	dLambda = diff(fLon)./180*pi;
	a = sin(dPhi./2).^2+cos(phi1).*cos(phi2).*sin(dLambda/2).^2;
	c = 2*atan2(sqrt(a),sqrt(1-a));
	d = [0, R.*c.*1000];	%displacement in m
  [fb,fa] = butter(2,0.05/0.5);
  filtd = filtfilt(fb,fa,d);
  totalDistance = sum(filtd);
	disp(sprintf('Total distance %d m',int32(totalDistance))); 
	velocity = filtd./[1, diff(reTSamps)];
  returnVal = struct();
  returnVal.dateStamps = 11/24+reTSamps./(24*60*60); %added 11 h for GMT+10 + daylight
  returnVal.velocity = velocity;
  returnVal.lat = fLat;
  returnVal.lon = fLon;