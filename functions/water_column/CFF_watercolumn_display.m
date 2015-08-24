function [h,F] = CFF_watercolumn_display(fData, varargin)
% [h,F] = CFF_watercolumn_display(fData, varargin)
%
% DESCRIPTION
%
% display watercolumn data
%
% INPUT VARIABLES
%
%varargin{1} is a string indicating which data in fData to grab
%'original' or 'L1'. OR the data to display

%varargin{2}: display type 'flat', 'wedge' or 'projected'
%
% varargin{3}: filename for movie creation


% OUTPUT VARIABLES
%
%   h: figure handle
%   F: movie frames
%
% RESEARCH NOTES
%
% NEW FEATURES
%
% - v0.1:
%   - first version.
% EXAMPLES
% % The following are ALL equivalent: display original data, all pings, flat, no bottom detect, no movie
% CFF_watercolumn_display(fData); 
% CFF_watercolumn_display(fData,'original');
% CFF_watercolumn_display(fData,'data','original'); 
% CFF_watercolumn_display(fData,'pings',NaN);
% CFF_watercolumn_display(fData,'data','original','pings',NaN);
% CFF_watercolumn_display(fData,'data','original','pings',NaN,'displayType','flat');
%
% Let's make things a little different: testing all disaply types with
% bottom detect
% CFF_watercolumn_display(fData,'data','L1','displayType','flat','bottomDetectDisplay','yes');
% CFF_watercolumn_display(fData,'data','L1','displayType','wedge','bottomDetectDisplay','yes');
% CFF_watercolumn_display(fData,'data','L1','displayType','projected','bottomDetectDisplay','yes');
%
% % all good now testing movie creation in flat mode
% CFF_watercolumn_display(fData,'data','L1','displayType','flat','bottomDetectDisplay','yes','movieFile','testmovie');
%
% % testing other data:
% otherM = fData.WC_PBS_SampleAmplitudes + 50;
% CFF_watercolumn_display(fData,'otherData',otherM);
%
% % all old display work. Check the old order of inputs work
% [h,F] = CFF_watercolumn_display(fData, 'original','flat','test');
%
% % ok now test the new inputs:
% CFF_watercolumn_display(fData,'data','L1','displayType','projected','bottomDetectDisplay','yes','waterColumnTargets',kelp);
%
%%%
% Alex Schimel, Deakin University
% Version 0.1 (25-Apr-2014)
%%%

%% INPUT PARSER

p = inputParser;

% 'fData', the multibeam data structure (required)
addRequired(p,'fData',@isstruct);

% 'data' (originally varargin{1}) is an optional string indicating which data in
% fData to grab: 'original' (default) or 'L1'. Can be overwritten by
% inputting "otherData". 
arg = 'data';
defaultArg = 'original';
checkArg = @(x) any(validatestring(x,{'original','L1'})); % valid arguments for optional check
addOptional(p,arg,defaultArg,checkArg);

% 'displayType' (originally varargin{2}) is an optional string indicating type of display: 'flat' (default), 'wedge' or 'projected'
arg = 'displayType';
defaultArg = 'flat';
checkArg = @(x) any(validatestring(x,{'flat', 'wedge','projected'})); % valid arguments for optional check
addOptional(p,arg,defaultArg,checkArg);

% 'movieFile' (originally varargin{3}) is an optional string indicating filename for
% movie creation. By default an empty string to mean no movie is to be
% made.
arg = 'movieFile';
defaultArg = '';
checkArg = @(x) ischar(x); % valid arguments for optional check
addOptional(p,arg,defaultArg,checkArg);

% 'otherData' is an optional array of numbers to be displayed instead of
% the original or L1 data. Used in case of tests for new types of
% corrections
arg = 'otherData';
defaultArg = [];
checkArg = @(x) isnumeric(x) && all(size(x)==size(fData.WC_PBS_SampleAmplitudes)); % valid arguments for optional check
addOptional(p,arg,defaultArg,checkArg);

% 'pings' is an optional vector of numbers indicating which pings to be
% displayed. If more than one, the result will be an animation. 
arg = 'pings';
defaultArg = NaN;
checkArg = @(x) isnumeric(x); % valid arguments for optional check
addOptional(p,arg,defaultArg,checkArg);

% 'bottomDetectDisplay' is a string indicating
% wether to display the bottom detect in the data or not: 'no' (default) or 'yes'. 
arg = 'bottomDetectDisplay';
defaultArg = 'no';
checkArg = @(x) any(validatestring(x,{'no', 'yes'})); % valid arguments for optional check
addOptional(p,arg,defaultArg,checkArg);

% 'waterColumnTargets' is an optional array of points to be displayed ontop
% of watercolumn data. Must be a table with Easting, Northing, Height,
% ping, beam, range.
arg = 'waterColumnTargets';
defaultArg = [];
checkArg = @(x) isnumeric(x); % valid arguments for optional check
addOptional(p,arg,defaultArg,checkArg);

% now parse actual inputs
parse(p,fData, varargin{:});

% display contents of the input parser?
...

%% initalize figure
h = figure;

% set figure to full screen if movie requested
if ~isempty(p.Results.movieFile)
    set(h,'Position',get(0,'ScreenSize'))
end


%% grab data
switch p.Results.data
    case 'original'
        M = fData.WC_PBS_SampleAmplitudes;
    case 'L1'
        M = fData.X_PBS_L1;
end
if ~isempty(p.Results.otherData)
    % overwrite with other data
    M = p.Results.otherData;
end

%% main data info
[pathstr, name, ext]= fileparts(fData.MET_MATfilename{1});
fileName = [name ext];
pingCounter = fData.WC_P1_PingCounter;
nPings = size(fData.WC_PBS_SampleAmplitudes,1);


%% display data
switch p.Results.displayType
    
    case 'flat'
        
        % bottom detect
        b = fData.WC_PB_DetectedRangeInSamples;
%         
%         % targets
%         t = 0;
%         
        % data bounds
        maxM = max(max(max(M)));
        minM = min(min(min(M)));
        
        for ii = 1:nPings
            cla
            imagesc(squeeze(M(ii,:,:))')
            colorbar
            hold on
            if strcmp(p.Results.bottomDetectDisplay,'yes')
                plot(b(ii,:),'k.')
            end
%             if strcmp(p.Results.waterColumnTargets,'yes')
%                 plot(t(ii,:),'ko')
%             end
            caxis([minM maxM])
            grid on
            title(sprintf('%s - ping %i (%i/%i)',fileName,pingCounter(ii),ii,nPings),'Interpreter','none')
            xlabel('beam #')
            ylabel('sample #')
            drawnow
            if ~isempty(p.Results.movieFile)
                F(ii) = getframe(gcf);
            end
        end
        
    case 'wedge'
        
        % grab data
        X = fData.X_PBS_sampleAcrossDist;
        Y = fData.X_PBS_sampleUpDist;
        
        % bottom detect
        bX = fData.X_PB_bottomAcrossDist;
        bY = fData.X_PB_bottomUpDist;
        
        % data bounds
        maxX = max(max(max(X)));
        minX = min(min(min(X)));
        maxY = max(max(max(Y)));
        minY = min(min(min(Y)));
        maxM = max(max(max(M)));
        minM = min(min(min(M)));
        
        for ii = 1:nPings
            cla
            pcolor(squeeze(X(ii,:,:)),squeeze(Y(ii,:,:)),squeeze(M(ii,:,:)));
            colorbar
            shading interp
            hold on
            if strcmp(p.Results.bottomDetectDisplay,'yes')
                plot(bX(ii,:),bY(ii,:),'k.')
            end
            axis([minX maxX minY maxY])
            caxis([minM maxM])
            grid on
            axis equal
            title(sprintf('%s - ping %i (%i/%i)',fileName,pingCounter(ii),ii,nPings),'Interpreter','none')
            xlabel('across distance (starboard) (m)')
            ylabel('height above sonar (m)')
            drawnow
            if ~isempty(p.Results.movieFile)
                F(ii) = getframe(gcf);
            end
        end
        
    case 'projected'
        
        % grab data
        Easting = fData.X_PBS_sampleEasting;
        Northing = fData.X_PBS_sampleNorthing;
        Height = fData.X_PBS_sampleHeight;
        
        % bottom detect
        bEasting = fData.X_PB_bottomEasting;
        bNorthing = fData.X_PB_bottomNorthing;
        bHeight = fData.X_PB_bottomHeight;
        
        % data bounds
        maxEasting = max(max(max(Easting)));
        minEasting = min(min(min(Easting)));
        maxNorthing = max(max(max(Northing)));
        minNorthing = min(min(min(Northing)));
        maxHeight = max(max(max(Height)));
        minHeight = min(min(min(Height)));
        maxM = max(max(max(M)));
        minM = min(min(min(M)));
        
        for ii = 1:nPings
            cla
            x = reshape(Easting(ii,:,:),1,[]);
            y = reshape(Northing(ii,:,:),1,[]);
            z = reshape(Height(ii,:,:),1,[]);
            c = reshape(M(ii,:,:),1,[]);
            scatter3(x,y,z,2,c,'.')
            colorbar
            hold on
            if strcmp(p.Results.bottomDetectDisplay,'yes')
                plot3(bEasting(ii,:),bNorthing(ii,:),bHeight(ii,:),'k.')
            end
            if ~isempty(p.Results.waterColumnTargets)
                plot3(p.Results.waterColumnTargets(:,2),p.Results.waterColumnTargets(:,1),p.Results.waterColumnTargets(:,3),'k.')
            end
            axis equal
            axis([minEasting maxEasting minNorthing maxNorthing minHeight maxHeight])
            caxis([minM maxM])
            grid on
            title(sprintf('%s - ping %i (%i/%i)',fileName,pingCounter(ii),ii,nPings),'Interpreter','none')
            xlabel('Easting (m)')
            ylabel('Northing (m)')
            zlabel('Height (m)')
            CFF_nice_easting_northing
            drawnow
            if ~isempty(p.Results.movieFile)
                F(ii) = getframe(gcf);
            end
        end

end

% write movie
if ~isempty(p.Results.movieFile)
    writerObj = VideoWriter(p.Results.movieFile,'MPEG-4');
    set(writerObj,'Quality',100)
    open(writerObj)
    writeVideo(writerObj,F);
    close(writerObj);
end




% figure; plot(SeedsAcrossDist,SeedsDownDist,'.')
% axis equal
% hold on
% for jj = 1:size(M,1)
%     pause(0.1)
%     plot([SeedsAcrossDist(M(jj,1)),SeedsAcrossDist(M(jj,2))],[SeedsDownDist(M(jj,1)),SeedsDownDist(M(jj,2))], 'ro-')
%     drawnow
% end
%
% %figure
% clf
% surf(DownDist,AcrossDist,DATACorr);
% hold on
% shading interp;
% view(90,-90);
% axis equal;
% set(gca,'layer','top')
% axis([-10 0 -20 20])
% set(gca,'Color',[0.8 0.8 0.8],'XLimMode','manual','YLimMode','manual')
% set(gca,'ZDir','reverse')
% hold on
% plot(BottomY(BottomY~=0),BottomX(BottomY~=0),'k.-')
%
% for jj = 1:size(M,1)
%     plot([SeedsDownDist(M(jj,1)),SeedsDownDist(M(jj,2))],[SeedsAcrossDist(M(jj,1)),SeedsAcrossDist(M(jj,2))],'k.-')
% end
%
