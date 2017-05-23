%% preliminary information
%
% - create FileList for XTF files
% - convert files to ALL format
% - modify soundings data in the ALL file with sonar head angles setup
% - correct Z for heave
% - correcting for navigation latency
% - projecting vessel position
% - matching position and heading data with ping time
% - correcting soundings for heading and grid convergence
% - add vessel position to obtain soundings in the projection
% - correct for tide
% - gridding bathymetry


clear all
close all

%% FIRST PRINT
txt = sprintf('*** Processing begins...\n');
fprintf(txt);


%% CREATE FILELIST

% set XTF data directory
XTFdirectory = '../DATA/TAPUAE/XTF/';

% intialize FileList
clear FileList

% POPULATE XTF, SVP AND TIDE FILENAMES

jj = 0;

XTFfolder = [XTFdirectory 'DAY4'];
XTFfolderContent = dir(XTFfolder);
for ii = 1:length(XTFfolderContent)
    f = XTFfolderContent(ii).name;
    if length(f)>3 & strcmp(f(end-2:end),'XTF')
        jj = jj+1;
        FileList(jj).XTFfilename = [XTFfolder '/' f];
        FileList(jj).SVPfilename = '../DATA/TAPUAE/SVP/07FEB081.SVP reconstructed PuSvpU.txt';
        FileList(jj).TIDEfilename = '../DATA/TAPUAE/TIDE/final/TAPUAE_tide_NewtonKing_UTC_HPRO.txt';
        FileList(jj).TIDEfiletype = 2; % hydropro
    end
end

XTFfolder = [XTFdirectory 'DAY5'];
XTFfolderContent = dir(XTFfolder);
for ii = 1:length(XTFfolderContent)
    f = XTFfolderContent(ii).name;
    if length(f)>3 & strcmp(f(end-2:end),'XTF')
        jj = jj+1;
        FileList(jj).XTFfilename = [XTFfolder '/' f];
        FileList(jj).SVPfilename = '../DATA/TAPUAE/SVP/08FEB081.SVP reconstructed PuSvpU.txt';
        FileList(jj).TIDEfilename = '../DATA/TAPUAE/TIDE/final/TAPUAE_tide_NewtonKing_UTC_HPRO.txt';
        FileList(jj).TIDEfiletype = 2; % hydropro
    end
end

XTFfolder = [XTFdirectory 'DAY6'];
XTFfolderContent = dir(XTFfolder);
for ii = 1:length(XTFfolderContent)
    f = XTFfolderContent(ii).name;
    if length(f)>3 & strcmp(f(end-2:end),'XTF')
        jj = jj+1;
        FileList(jj).XTFfilename = [XTFfolder '/' f];
        FileList(jj).SVPfilename = '../DATA/TAPUAE/SVP/09FEB081.SVP reconstructed PuSvpU.txt';
        FileList(jj).TIDEfilename = '../DATA/TAPUAE/TIDE/final/TAPUAE_tide_NewtonKing_UTC_HPRO.txt';
        FileList(jj).TIDEfiletype = 2; % hydropro
    end
end

XTFfolder = [XTFdirectory 'DAY7'];
XTFfolderContent = dir(XTFfolder);
for ii = 1:length(XTFfolderContent)
    f = XTFfolderContent(ii).name;
    if length(f)>3 & strcmp(f(end-2:end),'XTF')
        jj = jj+1;
        FileList(jj).XTFfilename = [XTFfolder '/' f];
        FileList(jj).SVPfilename = '../DATA/TAPUAE/SVP/13FEB082.SVP PuSvpU.txt';
        FileList(jj).TIDEfilename = '../DATA/TAPUAE/TIDE/final/TAPUAE_tide_NewtonKing_UTC_HPRO.txt';
        FileList(jj).TIDEfiletype = 2; % hydropro        
    end
end

% POPULATE SURVEY

for ii = 1:length(FileList)
    FileList(ii).SurveyName = 'Tapuae';
end

% POPULATE TAGS

for ii = 1:201
    FileList(ii).Tag = 'MR';
end
for ii = [1 2 70 96 119 120 139 162]
    FileList(ii).Tag = 'trash';
end
for ii = [64 65 68 72:74 76 95 98:108]
    FileList(ii).Tag = 'seal_rock';
end
for ii = 109:115
    FileList(ii).Tag = 'patch_test';
end
for ii = [116:118 121:138 140:149]
    FileList(ii).Tag = 'reefs';
end
for ii = [150:161 163]
    FileList(ii).Tag = 'breakwater';
end
for ii = [164 165 192:201]
    FileList(ii).Tag = 'port';
end
for ii = [35 77 91:93 175 182 184 186 187 191]
    FileList(ii).Tag = 'Xline';
end

% POPULATE ZONE

for ii = [15:25 28 29 32 33 37:39 42:52 63 66 67 69 71 75 90 94 97 178:180 190]
    FileList(ii).Zone = 'N';
end
for ii = [3:14 26 27 30 31 34 36 40 41 53 56 57 60:62 78 89 177 181 188 189]
    FileList(ii).Zone = 'C';
end
for ii = [54 55 58 59 79:88 166:174 176 183 185]
    FileList(ii).Zone = 'S';
end

% POPULATE ORIENTATION

for ii = [4 6 8 10 12 14 15 17 19 22 24 27 28 31 32 36 37 38 41 42 45 47 49 55 56 59 60 62 63 67 69 80 81 83 85 87:90 167 169 171 173 176:178 185 188:190]
    FileList(ii).Orientation = 'NE';
end
for ii = [3 5 7 9 11 13 16 18 20 21 23 25 26 29 30 33 34 39 40 43 44 46 48 50:54 57 58 61 66 71 75 78 79 82 84 86 94 97 166 168 170 172 174 179:181 183]
    FileList(ii).Orientation = 'SW';
end

% POPULATE LINE NUMBER

for ii = 1:length(FileList)
    FileList(ii).LineNumber = NaN;
end

yo = [3:34 36:63 66 67 69 71 75 78:90 94 97 166:174 176:181 183 185 188:190 ;
     14 16 18 20 22 24 26 28 23 25 27 29 29 27 25 23 21 20 20 24 26 28 30 30 32 32 35 35 ...
     38 38 41 41 31 31 31 34 34 36 36 34 0 2 4 6 8 10 12 12 12 12 12 8 8 4 4 0 0 2 6 14 ... 
     15 16 14 16 18 10 16 20 20 24 28 32 30 26 31 31 37 37 18 14 2 6 10 14 18 22 23 ...
     27 29 34 39 39 43 43 43 36 -1 45 45 45];

for ii = 1:length(yo)
    FileList(yo(1,ii)).LineNumber = yo(2,ii);
end

% Create FileListContents (for information)
clear FileListContents
FileListContents(:,1) = {FileList.XTFfilename};
FileListContents(:,2) = {FileList.Tag};
FileListContents(:,3) = {FileList.Zone};
FileListContents(:,4) = {FileList.Orientation};
FileListContents(:,5) = {FileList.LineNumber};
FileListContents(:,6) = {FileList.SVPfilename};
FileListContents(:,7) = {FileList.TIDEfilename};
FileListContents(:,8) = {FileList.TIDEfiletype};
FileListContents = [{'XTFfilename','Tag','Zone','Orientation','LineNumber','SVPfilename','TIDEfilename','TIDEfiletype'}; FileListContents];


%% CONVERT XTF TO .ALL AND .MAT

% SET RESULTS DIRECTORIES
ALLdirectory         = './RESULTS/SURVEY FILES - ALL/';
ALLmoddirectory      = './RESULTS/SURVEY FILES - ALLmod/';
MATdirectory         = './RESULTS/SURVEY FILES - MAT/';

% SET PROCESSING PARAMETERS
phi       = 0.95; % roll offset in degrees
theta     = -1.2; % pitch offset in degrees
psi       = 1.2;  % yaw offset in degrees
newSVPRes = 0.1;  % SVP layering resolution in meters

% CONVERSION. This process may take some time.
txt = sprintf('- Converting MAT files to FABC and process them...\n');
fprintf(txt);
for ii = 1:length(FileList)
    
    tic
    
    % GET FILENAME:
    
    index = max([strfind(FileList(ii).XTFfilename,'/'), strfind(FileList(ii).XTFfilename,'\')])+1;
    filename = FileList(ii).XTFfilename(index:end-4);
    XTFfilename = FileList(ii).XTFfilename;
    SVPfilename = FileList(ii).SVPfilename;

    % print
    txt = sprintf('-- File %i / %i (''%s'')\n', ii, length(FileList), filename);
    fprintf(txt);
    
    % CONVERT XTF TO ALL:
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') converting XTF to ALL...\n', ii, length(FileList), filename);
    fprintf(txt);
    
    ALLfilename = [ALLdirectory filename '.all'];
    convxtf2all(XTFfilename, SVPfilename, ALLfilename); % comment this line if file already created
    
    % MODIFY ALL:
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') modifying ALL...\n', ii, length(FileList), filename);
    fprintf(txt);
    
    ALLmodfilename = [ALLmoddirectory filename 'mod.all'];
    modifyall(ALLfilename, theta, phi, psi, ALLmodfilename, newSVPRes); % comment this line if file already created
    
    % CONVERT ALL TO MAT:
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') converting ALL to MAT...\n', ii, length(FileList), filename);
    fprintf(txt);
    
    MATfilename = [MATdirectory filename '.mat'];
    convall2mat(ALLmodfilename, MATfilename); % comment this line if file already created
    
    % UPDATE FILELIST:
    
    FileList(ii).ALLfilename = ALLfilename;
    FileList(ii).ALLmodfilename = ALLmodfilename;
    FileList(ii).MATfilename = MATfilename;
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') done (%g sec)\n', ii, length(FileList), filename, toc);
    fprintf(txt);
    
end

% save processing log
save([ALLmoddirectory 'FileList.mat'], 'FileList'); % comment this line if file already created
save([MATdirectory 'FileList.mat'], 'FileList'); % comment this line if file already created


%% FILES PROCESSING

% SET RESULTS DIRECTORIES
ALLdirectory    = './RESULTS/SURVEY FILES - ALL/';
ALLmoddirectory = './RESULTS/SURVEY FILES - ALLmod/';
MATdirectory    = './RESULTS/SURVEY FILES - MAT/';
FABCdirectory   = './RESULTS/SURVEY FILES - FABC/';

% SET PROCESSING PARAMETERS
navLat = 0;   % navigation latency in milliseconds
ellips = 'wgs84'; % data ellipsoid
tmproj = 'utm59S'; % projection
gridResolution = 1; % grid resolution
gridMode = 'soundings-quality'; % grid method

% LOAD FILELIST
load([MATdirectory 'FileList.mat']);

% KEEP ONLY MARINE RESERVE AND SEAL ROCK
ind = [];
for ii = 1:length(FileList)   
    if strcmp(FileList(ii).Tag,'MR') || strcmp(FileList(ii).Tag,'seal_rock')       
        ind = [ind; ii];
    end
end
FileList = FileList(ind);

% Create FileListContents (for information)
clear FileListContents
FileListContents(:,1) = {FileList.XTFfilename};
FileListContents(:,2) = {FileList.Tag};
FileListContents(:,3) = {FileList.Zone};
FileListContents(:,4) = {FileList.Orientation};
FileListContents(:,5) = {FileList.LineNumber};
FileListContents(:,6) = {FileList.SVPfilename};
FileListContents(:,7) = {FileList.TIDEfilename};
FileListContents(:,8) = {FileList.TIDEfiletype};
FileListContents = [{'XTFfilename','Tag','Zone','Orientation','LineNumber','SVPfilename','TIDEfilename','TIDEfiletype'}; FileListContents];

% PROCESSING. This process may take some time.
txt = sprintf('- Converting MAT files to FABC and process them...\n');
fprintf(txt);
for ii = 1:length(FileList)   

    tic
    
    % GET FILENAME:
    
    index = max([strfind(FileList(ii).MATfilename,'/'), strfind(FileList(ii).MATfilename,'\')])+1;
    filename = FileList(ii).MATfilename(index:end-4);
    
    % print
    txt = sprintf('-- File %i / %i (''%s'')\n', ii, length(FileList), filename);
    fprintf(txt);
    
    % OPEN MAT FILE AND CONVERT TO FABC FORMAT:
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') converting MAT to FABC...\n', ii, length(FileList), filename);
    fprintf(txt);
    
    % convert
    File = convmat2fabc(FileList(ii).MATfilename);

    % ADD METADA:
    
    File.MET_XTFfilename   = FileList(ii).XTFfilename;
    File.MET_ALLfilename   = FileList(ii).ALLfilename;
    File.MET_ALLmodfilename= FileList(ii).ALLmodfilename;
    File.MET_MATfilename   = FileList(ii).MATfilename;
    File.MET_SVPfilename   = FileList(ii).SVPfilename;
    File.MET_SurveyName    = FileList(ii).SurveyName;
    File.MET_Tag           = FileList(ii).Tag;
    File.MET_Zone          = FileList(ii).Zone;
    File.MET_Orientation   = FileList(ii).Orientation;
    File.MET_LineNumber    = FileList(ii).LineNumber;
    
    % EXTRACT XYZ AND CORRECT FOR SONAR HEAVE:
    
    X     = File.De_PB_AlongtrackDistanceX./100;     % in m
    Y     = File.De_PB_AcrosstrackDistanceY./100;    % in m
    Z     = File.De_PB_DepthZ./100;                  % in m
    Heave = File.De_P1_TransmitTransducerDepth./100; % in m   
    Z     = Z + Heave*ones(1,128);                   % correct for heave
   
    % COMPUTE ROLL AND HEAVE RESIDUALS FROM DATA AND CORRECT THEM:

    % Roll and Heave are supposed to be corrected in real-time but some
    % artifacts remain. They are particularly visible on flat seafloor.
    % Here, we apply a technique derived from Crawford (2003) to remove
    % them: For each ping, we fit a line through (Y,Z) with a least-squares
    % linear regression. The high-frequency variations of slope and
    % intercept of the fit are estimates of roll and heave residuals
    % respectively.

    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') computing and removing roll and heave residuals...\n', ii, length(FileList), filename);
    fprintf(txt);

    clear pfit

    for jj = 1:size(Y,1)
        % across track and depth vectors. We only keep inner beams because
        % outer beams are unreliable
        tempY = Y(jj,10:size(Y,2)-10);
        tempY = tempY(~isnan(tempY));
        tempZ = Z(jj,10:size(Z,2)-10);
        tempZ = tempZ(~isnan(tempZ));
        pfit(jj,:) = polyfit(tempY,tempZ,1);
    end

    % for each profile, the linear fit as for equation:
    % y = x.*pfit(:,1)+pfit(:,2).
    % pfit(:,2) represents the depth/heave and pfit(:,1) represents the
    % slope/roll. With a low-pass filter, we try to separate the seafloor 
    % signal (depth, slope, low frequency) from the vessel movement signal
    % (heave, roll, high frequency). Here, we're using a 5th order
    % Butterworth filter, but other filter types can be chosen (ex:
    % elliptic, chebychev). The cut-off frequency could be adjusted from
    % the expected frequency of vessel movement, but for the moment we just
    % set it up subjectively at 0.01. 

    [b,a] = butter(5,0.01); 

    DataHeave = pfit(:,2) - filtfilt(b,a, pfit(:,2)); % in meters
    DataRoll = atan( pfit(:,1) - filtfilt(b,a, pfit(:,1)) ); % in radians

    % Now choose what we want to remove. we can remove residual roll and
    % heave, or heave alone if we consider roll movements are not
    % significant in our data. Also on a test file, I found more
    % complicated to separate Roll from seafloor slope.

    % remove residual roll
    [THETA, RHO] = cart2pol(Y,Z);
    [Y, Z] = pol2cart(THETA - DataRoll*ones(1,128), RHO);
    clear THETA RHO

    % remove residual heave
    Z = Z - DataHeave*ones(1,128);
    
    % save
    File.X_PB_X2 = X;
    File.X_PB_Y2 = Y;
    File.X_PB_Z2 = Z;
    
    % FORMAT PING TIME:
    
    % create ping time vectors in serial date number (SDN, for tide
    % matching) and TimeSinceMidnightInMilliseconds (TSM, for Position and
    % Heading matching). Add a "2" to indicate time as been compensated for
    % navigation Latency. navLat must be in milliseconds
    
    PingTimeTSM  = File.De_P1_TimeSinceMidnightInMilliseconds;
    PingTimeTSM2 = PingTimeTSM + navLat;

    date   = num2str(File.De_P1_Date);
    year   = str2num(date(:,1:4));
    month  = str2num(date(:,5:6));
    day    = str2num(date(:,7:8));
    second = File.De_P1_TimeSinceMidnightInMilliseconds./1000;

    PingTimeSDN  = datenum(year, month, day, 0, 0, second);
    PingTimeSDN2 = PingTimeSDN + navLat./(1000.*60.*60.*24);
    
    % save
    File.MET_NavigationLatencyMs = navLat;
    File.X_P1_PingTimeTSM  = PingTimeTSM;
    File.X_P1_PingTimeTSM2 = PingTimeTSM2;
    File.X_P1_PingTimeSDN  = PingTimeSDN;
    File.X_P1_PingTimeSDN2 = PingTimeSDN2;
 
    % PROCESS NAVIGATION AND HEADING:

    % Position and heading were recorded at the sensors time so we need to
    % interpolate them at the same time to match ping time.
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') processing navigation and heading...\n', ii, length(FileList), filename);
    fprintf(txt);
    
    % convert latitude/longitude to easting/northing/grid convergence:
    latitude = File.Po_D1_Latitude./20000000; % in decimal degrees
    longitude = File.Po_D1_Longitude./10000000; % in decimal degrees
    [PosE, PosN, PosGridConv] = ll2nztm(longitude, latitude, ellips, tmproj);

    % convert heading to degrees and allow heading values superior to
    % 360 or inferior to 0 (because every time the vessel crossed the NS
    % line, the heading jumps from 0 to 360 (or from 360 to 0) and this
    % causes a problem for following interpolation):
    PosHead = File.Po_D1_HeadingOfVessel./100; % in degrees
    posJump = find(diff(PosHead)>300);
    negJump = find(diff(PosHead)<-300);
    jumps   = zeros(length(PosHead),1);
    if ~isempty(posJump)
        for jj=1:length(posJump)
            jumps(posJump(jj)+1:end) = jumps(posJump(jj)+1:end) - 1;
        end
    end
    if ~isempty(negJump)
        for jj=1:length(negJump)
            jumps(negJump(jj)+1:end) = jumps(negJump(jj)+1:end) + 1;
        end
    end
    PosHead = PosHead + jumps.*360;

    % extract position and ping time
    PosTime  = File.Po_D1_TimeSinceMidnightInMilliseconds;
    PingTime = File.X_P1_PingTimeTSM2;

    % initialize new vectors
    PingE        = nan(size(PingTime));
    PingN        = nan(size(PingTime));
    PingGridConv = nan(size(PingTime));
    PingHead     = nan(size(PingTime));

    % interpolate
    for jj = 1:length(PingTime)
        A = PosTime-PingTime(jj);
        iA = find (A == 0);
        if A > 0
            % the ping time is older than any navigation time,
            % extrapolate from the first items in navigation array.
            PingE(jj) = PosE(2) + (PosE(2)-PosE(1)).*(PingTime(jj)-PosTime(2))./(PosTime(2)-PosTime(1));
            PingN(jj) = PosN(2) + (PosN(2)-PosN(1)).*(PingTime(jj)-PosTime(2))./(PosTime(2)-PosTime(1));
            PingGridConv(jj) = PosGridConv(2) + (PosGridConv(2)-PosGridConv(1)).*(PingTime(jj)-PosTime(2))./(PosTime(2)-PosTime(1));
            PingHead(jj) = PosHead(2) + (PosHead(2)-PosHead(1)).*(PingTime(jj)-PosTime(2))./(PosTime(2)-PosTime(1));
        elseif A < 0
            % the ping time is more recent than any navigation time,
            % extrapolate from the last items in navigation array.
            PingE(jj) = PosE(end) + (PosE(end)-PosE(end-1)).*(PingTime(jj)-PosTime(end))./(PosTime(end)-PosTime(end-1));
            PingN(jj) = PosN(end) + (PosN(end)-PosN(end-1)).*(PingTime(jj)-PosTime(end))./(PosTime(end)-PosTime(end-1));
            PingGridConv(jj) = PosGridConv(end) + (PosGridConv(end)-PosGridConv(end-1)).*(PingTime(jj)-PosTime(end))./(PosTime(end)-PosTime(end-1));
            PingHead(jj) = PosHead(end) + (PosHead(end)-PosHead(end-1)).*(PingTime(jj)-PosTime(end))./(PosTime(end)-PosTime(end-1));
        elseif ~isempty(iA)
            % the ping time corresponds to an existing navigation time, get
            % easting and northing from it. 
            PingE(jj) = PosE(iA);
            PingN(jj) = PosN(iA);
            PingGridConv(jj) = PosGridConv(iA);
            PingHead(jj) = PosHead(iA);
        else
            % the ping time is within the limits of the navigation time array
            % but doesn't correspond to any value in it, interpolate from
            % nearest values
            iNegA = find(A<0);
            [temp,iMax] = max(A(iNegA));
            iA(1) = iNegA(iMax); % index of navigation time just older than ping time        
            iPosA = find(A>0);
            [temp,iMin] = min(A(iPosA));
            iA(2) = iPosA(iMin); % index of navigation time just more recent ping time 
            % now extrapolate easting and northing
            PingE(jj) = PosE(iA(2)) + (PosE(iA(2))-PosE(iA(1))).*(PingTime(jj)-PosTime(iA(2)))./(PosTime(iA(2))-PosTime(iA(1)));
            PingN(jj) = PosN(iA(2)) + (PosN(iA(2))-PosN(iA(1))).*(PingTime(jj)-PosTime(iA(2)))./(PosTime(iA(2))-PosTime(iA(1)));
            PingGridConv(jj) = PosGridConv(iA(2)) + (PosGridConv(iA(2))-PosGridConv(iA(1))).*(PingTime(jj)-PosTime(iA(2)))./(PosTime(iA(2))-PosTime(iA(1)));
            PingHead(jj) = PosHead(iA(2)) + (PosHead(iA(2))-PosHead(iA(1))).*(PingTime(jj)-PosTime(iA(2)))./(PosTime(iA(2))-PosTime(iA(1))); 
        end
    end

    % save
    File.MET_ellips        = ellips;
    File.MET_tmproj        = tmproj;
    File.X_D1_PosTimeTSM   = PosTime;
    File.X_D1_PosE         = PosE;
    File.X_D1_PosN         = PosN;
    File.X_D1_PosGridConv  = PosGridConv;
    File.X_D1_PosHead      = PosHead - jumps.*360; % come back into the interval [0 360]
    File.X_P1_PingE        = PingE;
    File.X_P1_PingN        = PingN;
    File.X_P1_PingGridConv = PingGridConv;
    File.X_P1_PingHead     = mod(PingHead,360); % come back into the interval [0 360]

    % COMPUTE SOUNDINGS POSITION AND PROCESS TIDE:
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') computing soundings position and processing tide...\n', ii, length(FileList), filename);
    fprintf(txt);
    
    % convert XY in easting northing ref vessel thanks to heading and
    % griconvergence. Each sounding we have is a point M whose coordinates
    % [Y,X] in the vessel plane (O,Y,X) are known (Y=acrosstrack,
    % X=alongtrack). What we want is the coordinates of M in the map plane
    % (O,Eing,Ning).  The Matlab function cart2pol can give us the polar
    % angle of M in the vessel plane cart2pol(Y,X) = [<Y,OM>,rho] and,
    % similarly, the inverse function pol2cart can give us the cartesian
    % coordinates in the map plane from the polar angle of M in the map
    % plane: pol2cart(<Eing,OM>,rho) = [Eing,Ning]. Therefore, we turn the
    % (Y,X) vectors into polar and correct for heading and grid convergence
    % (angle between true North and grid North <N,Ning> or  <E,Eing> ):
    % <Eing,OM> = <Eing,E>  + <E,N> + <N,X>    + <X,Y> + <Y,OM>
    %           = -gridConv + pi/2  + -heading + -pi/2 + cart2pol(Y,X)
    %           = cart2pol(Y,X) - heading - gridConv
    % then we return to cartesian coordinates:
    % [Eing,Ning] = pol2cart(<Eing,OM>)

    % get data into matrices
    X2           = File.X_PB_X2;
    Y2           = File.X_PB_Y2;
    PingHead     = File.X_P1_PingHead*ones(1,128);
    PingGridConv = File.X_P1_PingGridConv*ones(1,128);
    PingE        = File.X_P1_PingE*ones(1,128);
    PingN        = File.X_P1_PingN*ones(1,128);

    [THETA,RHO] = cart2pol(Y2,X2); 
    THETA = THETA - PingHead.*pi/180 - PingGridConv.*pi./180;
    [SoundEasting,SoundNorthing] = pol2cart(THETA,RHO);
    Easting  = PingE + SoundEasting;
    Northing = PingN + SoundNorthing;
    clear THETA RHO

    Easting  = 0.01.*round(Easting.*100);
    Northing = 0.01.*round(Northing.*100);

    % save
    File.X_PB_Easting = Easting;
    File.X_PB_Northing = Northing;
    
    % now processing tide
    Z2 = File.X_PB_Z2;
            
    TIDEfilename = FileList(ii).TIDEfilename;
    TIDEfiletype = FileList(ii).TIDEfiletype;
    
    if ~isempty(TIDEfilename)
        
        % import tide file and create tide time and elevation vectors
        [TideTimeSDN, TideElevation] = readtide(TIDEfilename, TIDEfiletype);
        
        % check time
        PingTime = File.X_P1_PingTimeSDN2;
        if (min(PingTime) < min(TideTimeSDN)) | (max(PingTime) > max(TideTimeSDN))
            error('tide time does not include ping time')
        end
        
        % interpolate tide to match ping time
        PingTideElevation = interp1(TideTimeSDN,TideElevation,PingTime);

        % apply tide offset to Z
        Depth = 0.01.*round( (Z2 - PingTideElevation*ones(1,128)).*100 );
        
        % saving
        File.MET_TIDEfilename = TIDEfilename;
        File.MET_TIDEfiletype = TIDEfiletype;
        File.X_P1_PingTideElevation = PingTideElevation; 
        File.X_PB_Depth = Depth;
        
    else
        
        Depth = 0.01.*round( Z2.*100 );
        
        % saving
        File.MET_TIDEfilename = 'NA';
        File.MET_TIDEfiletype = 'NA';
        File.X_P1_PingTideElevation = []; 
        File.X_PB_Depth = Depth;

    end
    
    % PROCESS REFLECTIVITY:

    % divide reflectivity by 2 (in dB)
    File.X_PB_Reflectivity = File.De_PB_ReflectivityBS./2;
    
    % GRIDDING DEPTH:
    
    % print    
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') mosaicing...\n', ii, length(FileList), filename);
    fprintf(txt);
    
    % variables
    Northing = File.X_PB_Northing;
    Easting  = File.X_PB_Easting;
    Depth    = File.X_PB_Depth;
    
    switch gridMode
    
        case 'average'
            % each sounding has equal weight (method identical to simple
            % average gridding)
            Weight = zeros(size(Depth));
            Weight(~isnan(Depth)) = 1;
            
        case 'angle-weight'
            % beams closest to nadir have higher weight
            Nbeams = size(File.De_PB_BeamNumber,2);
            Weight = ( Nbeams./2 - abs(File.De_PB_BeamNumber-Nbeams./2))./Nbeams./2;
            
        case 'soundings-quality'  
            % each sounding has a weight associated to the detection method
            % and its quality factors. We define a weighting function that
            % is maximum until the most recurrent value in the data (mode)
            % and then decreases exponentially with soundings quality. We
            % added a -3 factor to decrease the importance of soundings
            % obtained from cross-phase detection in comparison to
            % soundings obtained from amplitude. This methodology and
            % parameters are completely subjective an may be tweaked.
            
            % extract quality data
            Q = File.De_PB_QualityFactor;
            Dec_Pha1_Quality = Q;
            Dec_Pha1_Quality(Q<192) = NaN;
            Dec_Pha1_Quality = Dec_Pha1_Quality-192;
            Dec_Pha2_Quality = Q;
            Dec_Pha2_Quality(Q<128) = NaN;
            Dec_Pha2_Quality(Q>191) = NaN;
            Dec_Pha2_Quality = Dec_Pha2_Quality-128;
            Dec_Amp_NbSamples = Q;
            Dec_Amp_NbSamples(Q>127) = NaN;
            
            % compute weights
            methdiff = 3;
            Dec_Pha1_Weigth = exp(-0.008.*(Dec_Pha1_Quality - mode(Dec_Pha1_Quality(:))+methdiff).^2);
            Dec_Pha1_Weigth(Dec_Pha1_Quality<=mode(Dec_Pha1_Quality(:))-methdiff) = 1;
            Dec_Pha2_Weigth = exp(-0.008.*(Dec_Pha2_Quality - mode(Dec_Pha2_Quality(:))+methdiff).^2);
            Dec_Pha2_Weigth(Dec_Pha2_Quality<=mode(Dec_Pha2_Quality(:))-methdiff) = 1;
            Dec_Amp_Weigth = exp(-0.008.*(Dec_Amp_NbSamples - mode(Dec_Amp_NbSamples(:))).^2);
            Dec_Amp_Weigth(Dec_Amp_NbSamples<=mode(Dec_Amp_NbSamples(:))) = 1;
            
            % combine weights
            Dec_Pha1_Weigth(isnan(Dec_Pha1_Weigth)) = 0;
            Dec_Pha2_Weigth(isnan(Dec_Pha2_Weigth)) = 0;
            Dec_Amp_Weigth(isnan(Dec_Amp_Weigth))   = 0;
            Weight = Dec_Pha1_Weigth + Dec_Pha2_Weigth + Dec_Amp_Weigth;

    end
            
    % grid boundaries
    minN = min(min(Northing));
    maxN = max(max(Northing));
    minE = min(min(Easting));
    maxE = max(max(Easting));

    gridEasting  = [floor(minE):gridResolution:ceil(maxE)];
    gridNorthing = [floor(minN):gridResolution:ceil(maxN)]';

    % initialize arrays
    gridDepth  = -999.*ones( length(gridNorthing) , length(gridEasting) ); % remove NaNs to allow averaging
    gridWeight = zeros( length(gridNorthing) , length(gridEasting) );
    
    % weight gridding
    for jP = 1:size(Easting,1)     % number of pings
        for jB = 1:size(Easting,2) % number of beams

            if ~isnan(Easting(jP,jB))

                pointEasting = Easting(jP,jB);
                pointNorthing = Northing(jP,jB);
                pointDepth = Depth(jP,jB);
                pointWeight = Weight(jP,jB);

                iR = round(((pointNorthing-gridNorthing(1))./gridResolution)+1);
                iC = round(((pointEasting-gridEasting(1))./gridResolution)+1);
                
                % add new point to grid
                gridDepth(iR,iC)  = ((gridDepth(iR,iC).*gridWeight(iR,iC))+pointDepth.*pointWeight)./(gridWeight(iR,iC)+pointWeight);
                gridWeight(iR,iC) = gridWeight(iR,iC)+pointWeight; 

            end

        end
    end
    
    % put NaNs back
    gridDepth(gridDepth==-999) = NaN;
    
    % save
    File.MET_gridResolution = gridResolution;
    File.MET_gridMode       = gridMode;
    File.X_1E_gridEasting   = gridEasting;
    File.X_N1_gridNorthing  = gridNorthing;
    File.X_NE_gridDepth     = gridDepth;
    File.X_NE_gridWeight    = gridWeight;
    
    % FINAL STUFF
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') saving...\n', ii, length(FileList), filename);
    fprintf(txt);

    % save FABC file
    FABCfilename = [FABCdirectory 'fabc' filename '.mat'];
    save(FABCfilename,'File');

    % update FileList
    FileList(ii).FABCfilename        = FABCfilename;
    FileList(ii).NavigationLatencyMs = File.MET_NavigationLatencyMs;
    FileList(ii).ellips              = File.MET_ellips;
    FileList(ii).tmproj              = File.MET_tmproj;
    FileList(ii).PingE               = File.X_P1_PingE;
    FileList(ii).PingN               = File.X_P1_PingN;
    FileList(ii).gridResolution      = File.MET_gridResolution;
    FileList(ii).gridMode            = File.MET_gridMode;
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') done (%g sec)\n', ii, length(FileList), filename, toc);
    fprintf(txt);
    
    save('temp.mat','FileList','ii','FABCdirectory','navLat','ellips','tmproj','gridResolution','gridMode') 
    clear all
    load('temp.mat')
    delete('temp.mat')

end

% save processing log
save([FABCdirectory 'FileList.mat'], 'FileList');


%% CREATE DTM

load([FABCdirectory 'FileList.mat']);

% intitialize boundaries
DTMminN = NaN;
DTMmaxN = NaN;
DTMminE = NaN;
DTMmaxE = NaN;
gridResolution = [];

% print
txt = sprintf('- Finding grid boundaries...\n');
fprintf(txt);

% find boundaries and resolution
for ii = 1:length(FileList)
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('- Finding grid boundaries... (file %i / %i)\n', ii, length(FileList));
    fprintf(txt);
    
    load(FileList(ii).FABCfilename);
    
    gridEasting        = File.X_1E_gridEasting;
    gridNorthing       = File.X_N1_gridNorthing;
    gridResolution(ii) = File.MET_gridResolution;

    DTMminN = min( DTMminN, min(gridNorthing) );
    DTMmaxN = max( DTMmaxN, max(gridNorthing) );
    DTMminE = min( DTMminE, min(gridEasting) );
    DTMmaxE = max( DTMmaxE, max(gridEasting) );  

end

% check consistency in resolution
if min(gridResolution)~=max(gridResolution)
    error('resolution not consistent');
else
    gridResolution = gridResolution(1);
end
    
% intialize DTM
DTMeasting   = DTMminE:gridResolution:DTMmaxE;
DTMnorthing  = [DTMminN:gridResolution:DTMmaxN]';
DTMdepth     = NaN( length(DTMnorthing) , length(DTMeasting) );
DTMWeight    = zeros( length(DTMnorthing) , length(DTMeasting) );

% print
txt = sprintf('- Adding individual files to DTM...\n');
fprintf(txt);

% fill DTM
for ii = 1:length(FileList)
    
    tic
    
    % get filename
    index = max([strfind(FileList(ii).FABCfilename,'/'), strfind(FileList(ii).FABCfilename,'\')])+1;
    filename = FileList(ii).FABCfilename(index:end-4);
    
    % print
    txt = sprintf('-- File %i / %i (''%s'') ...\n', ii, length(FileList), filename);
    fprintf(txt);
    
    % load
    load(FileList(ii).FABCfilename);
    
    gridEasting   = File.X_1E_gridEasting;
    gridNorthing  = File.X_N1_gridNorthing;
    gridDepth     = File.X_NE_gridDepth;
    gridWeight    = File.X_NE_gridWeight;
    
    miniR = round(((min(gridNorthing)-DTMnorthing(1))./gridResolution)+1);
    miniC = round(((min(gridEasting)-DTMeasting(1))./gridResolution)+1);
    maxiR = round(((max(gridNorthing)-DTMnorthing(1))./gridResolution)+1);
    maxiC = round(((max(gridEasting)-DTMeasting(1))./gridResolution)+1);
    
    % patch of full grid corresponding to new file grid extent
    patchDepth  = DTMdepth(miniR:maxiR,miniC:maxiC);
    patchWeight = DTMWeight(miniR:maxiR,miniC:maxiC);
    
    % remove NaNs to allow averaging
    patchDepth(isnan(patchDepth)) = -999;
    gridDepth(isnan(gridDepth)) = -999;
    
    % combine the runline grid and the patch of main grid
    newWeight = gridWeight + patchWeight;
    newWeight(newWeight == 0) = NaN;
    newDepth = (gridDepth.*gridWeight + patchDepth.*patchWeight)./newWeight;
    newWeight(isnan(newWeight)) = 0;
    
    % store the result in full grid
    DTMdepth(miniR:maxiR,miniC:maxiC)  = newDepth;
    DTMWeight(miniR:maxiR,miniC:maxiC) = newWeight;
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('-- File %i / %i (''%s'') done (%g sec)\n', ii, length(FileList), filename, toc);
    fprintf(txt);
    
end

% save
save([FABCdirectory 'Results.mat'], 'FileList', 'DTMeasting', 'DTMnorthing', 'DTMdepth', 'DTMWeight')

% clear some memory space
clear gridWeight gridDepth gridEasting gridNorthing newWeight newDepth patchWeight patchDepth
   

%% INTERPOLATE DTM
% Using inpaint_nans (from John d'Erico, found on Mathworks).
% Using separation in small datasets as designed for Yvonne's work

% small grids parameters
nNo = 10;   % number of northing (rows) splits
nEa = 10;   % number of easting (columns) splits
extra = 10; % number of rows and columns of data we add to the split values
            % this allows the extrapolation process to take into account
            % extra data on the boundaries although the results past the
            % boundaries will be later discarded
            
% create the arrays containing the indices of each small grids
% (DTMminE, DTMmaxE, DTMminN, DTMmaxN):
clear fine

N = ceil(length(DTMnorthing)./nNo);
temp = [1:N:length(DTMnorthing)]';
temp = temp*ones(1,nEa);
fine(:,1) = reshape(temp', size(temp,1).*size(temp,2),1);

temp = [1:N:length(DTMnorthing)]'+N-1;
temp(end) = length(DTMnorthing);
temp = temp*ones(1,nEa);
fine(:,2) = reshape(temp', size(temp,1).*size(temp,2),1);

E = ceil(length(DTMeasting)./nEa);
temp = [1:E:length(DTMeasting)]';
temp = temp*ones(1,nNo);
fine(:,3) = reshape(temp, size(temp,1).*size(temp,2),1);

temp = [1:E:length(DTMeasting)]'+E-1;
temp(end) = length(DTMeasting);
temp = temp*ones(1,nNo);
fine(:,4) = reshape(temp, size(temp,1).*size(temp,2),1);

% create the arrays containing the indices of each small grids + extra for
% the Interpolation
fine2 = fine;
fine2(:,1) = fine(:,1)-extra;
fine2(:,2) = fine(:,2)+extra;
fine2(:,3) = fine(:,3)-extra;
fine2(:,4) = fine(:,4)+extra;

fine2(fine2<1) = 1;
fine2(fine2(:,1)>length(DTMnorthing),1) = length(DTMnorthing);
fine2(fine2(:,2)>length(DTMnorthing),2) = length(DTMnorthing);
fine2(fine2(:,3)>length(DTMeasting),3) = length(DTMeasting);
fine2(fine2(:,4)>length(DTMeasting),4) = length(DTMeasting);

% initialize interpolated DTM:
DTMdepth2 = nan(size(DTMdepth));

% print
txt = sprintf('- Interpolating small grids...\n');
fprintf(txt)

% interpolate small grids separately
for ii = 1:size(fine,1)
    
    % print
    fprintf([char(8).*ones(1,length(txt)) '']); % erase previous text
    txt = sprintf('- Interpolating small grids... (%i / %i)\n', ii, size(fine,1));
    fprintf(txt);
    
    % extract original data (patch+extra)
    patch = DTMdepth(fine2(ii,1):fine2(ii,2),fine2(ii,3):fine2(ii,4));
        
    a = find(sum(~isnan(patch)) ~=0);  % list of non-empty columns
    b = find(sum(~isnan(patch')) ~=0); % list of non-empty rows  
    
    % interpolate
    if ~isempty(a)
        % do only if patch is not completely empty
        
        indexcol = [a(1):a(end)];
        indexrow = [b(1):b(end)];

        temp = patch(indexrow,indexcol); % remove empty boundaries in patch
        InterpPatch = inpaint_nans(temp,4); % interpolate that, use method specified
        temp = -999.*ones(size(patch));
        temp(indexrow,indexcol) = InterpPatch;
        InterpPatch = temp; % reintroduce the empty boundaries              

    else
        % if patch was empty, just fill it with -999. Not NaNs because
        % after Interpolation, we have no NaNs left usually.
        InterpPatch = -999.*ones(size(patch));

    end
        
    % remove extra
    InterpPatch(:,end-(fine2(ii,4)-fine(ii,4))+1:end) = [];
    InterpPatch(:,1:fine(ii,3)-fine2(ii,3)) = [];
    InterpPatch(end-(fine2(ii,2)-fine(ii,2))+1:end,:) = [];
    InterpPatch(1:fine(ii,1)-fine2(ii,1),:) = [];
    
    % replace in new dataset
    DTMdepth2(fine(ii,1):fine(ii,2),fine(ii,3):fine(ii,4)) = InterpPatch;
    
end    

% remove -999 values
DTMdepth2(find(DTMdepth2==-999)) = NaN;


%% MASK EXTRAPOLATION

% we use the "closing" morphological image processing operation to create a
% mask to remove the extrapolation of the previous processing step.

% print
txt = sprintf('- Masking extrapolation...\n');
fprintf(txt)

% adapt the structuring element to the size of the gaps to close
se = strel('square',20); % structuring element

Mask = DTMdepth;
Mask(~isnan(Mask)) = 1;
Mask(isnan(Mask)) = 0;

% clear some memory space
clear DTMdepth DTMdepth2 DTMWeight

% close
NewMask = imclose(Mask,se);

NewMask(find(NewMask == 0)) = NaN;

% apply Mask to interpolated DTM:
DTMdepth3 = DTMdepth2.*NewMask;

% reload DTMdepth and DTMweight
load ([FABCdirectory 'Results.mat']);

% save
save([FABCdirectory 'Results.mat'], 'FileList', 'DTMeasting', 'DTMnorthing', 'DTMdepth', 'DTMWeight','DTMdepth2', 'DTMdepth3')


%% COMPUTE SLOPE

% print
txt = sprintf('- Computing slope...\n');
fprintf(txt);
fprintf([char(8) '']); % erase one character

% parameters
scale = 1;

% intialize array
DTMslope = NaN(size(DTMdepth3));
nrows = size(DTMdepth3,1);
ncols = size(DTMdepth3,2);

% plane vectors
[X Y] = meshgrid([-scale:scale],[scale:-1:-scale]');

% reshape in column vectors
pixNb = (2.*scale+1).^2;
X = reshape(X,pixNb,1);
Y = reshape(Y,pixNb,1);

tic

for ii = scale+1:nrows-scale
    
    % compute slope
    for jj = scale+1:ncols-scale

        A = DTMdepth3(ii-scale:ii+scale,jj-scale:jj+scale); % bathymetry pixels to consider for slope computation
        A = reshape(A,pixNb,1);
        coef = [ones(pixNb,1), X, Y]\A; % plane coefficients

        DTMslopeRad = atan( sqrt( coef(2).^2 + coef(3).^2 ) ); % in radians
        DTMslope(ii,jj) = 180/pi * DTMslopeRad;                % in degrees

    end

    % print the state of process every 10 rows
    if ii./10 == round(ii./10)
        % print
        fprintf([char(8).*ones(1,length(txt)-1) '']); % erase previous text
        txt = sprintf('- Computing slope... (%g%%%% - estimated time remaining: %i min)\n', 0.1.*round(1000.*ii./(nrows-scale)), floor(((nrows-scale)-ii-1).*(toc./ii)./60) );
        fprintf(txt);
    end

end

% print
fprintf([char(8).*ones(1,length(txt)-1) '']); % erase previous text
txt = sprintf('- Computing slope... done\n');
fprintf(txt);

% SAVING RESULTS
save([FABCdirectory 'Results.mat'], 'FileList', 'DTMeasting', 'DTMnorthing', 'DTMdepth','DTMWeight','DTMdepth2', 'DTMdepth3','DTMslope')


%% save in ESRI ASCII grid file

DATA = -DTMdepth3; % bathy must be negative for Geocoder
DATA = flipud(DATA);
DATA(find(isnan(DATA))) = 0; % Geocoder considers 0 as no data, even though it is specified -9999 in header

Header = sprintf('ncols %d\nnrows %d\nxllcenter %d\nyllcenter %d\ncellsize %d\nnodata_value %d\n' ...
            , size(DATA,2), size(DATA,1), min(DTMeasting), min(DTMnorthing), 1, -9999);

dlmwrite('temp.txt', DATA, 'delimiter', ' ')
fid = fopen('temp.txt'); F = fread(fid); fclose(fid);
fid = fopen([FABCdirectory 'Bathymetry.asc'],'w');
fwrite(fid, Header); fwrite(fid, F); fclose(fid);
delete('temp.txt')


%% DISPLAY RESULTS

X = DTMeasting;
Y = DTMnorthing;

slope = DTMslope;
slopemin = 0;
slopemax = max(DTMslope(:))./2;

bathy = DTMdepth3;
bathymin = min(DTMdepth3(:));
bathymax = max(DTMdepth3(:));

figure;

% define a colormap that uses the gray colormap and the jet colormap and
% assign it as the Figure's colormap.  
m = 64;  % 64-elements is each colormap
colormap([flipud(gray(64));flipud(jet(64))]);

% set slope as backgrond
h(1) = image(X,Y,slope);
hold on
colorbar
axis equal

% adapt its CData to the first part of colorbar
C1 = min(m,round((m-1)*(slope-slopemin)/(slopemax-slopemin))+1); 
C1(isnan(slope)) = 0;
set(h(1),'CData',C1);

% superimpose bathy, with transparency
h(2) = image(X,Y,bathy);
set(h(2),'AlphaData',0.7);

% adapt its CData to the second part of colorbar
C2 = 64 + min(m,round((m-1)*(bathy-bathymin)/(bathymax-bathymin))+1); 
C2(isnan(bathy)) = 0;
set(h(2),'CData',C2);

% change the CLim property of axes so that it spans the CDatas of both
% objects.
caxis([min(C1(:)) max(C2(:))])
colorbar off

set(gca,'YDir','normal')

%% FINAL PRINT
txt = sprintf('*** Processing ends\n');
fprintf(txt);


