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
%
%%%
% Alex Schimel, Deakin University
% Version 0.1 (25-Apr-2014)
%%%

%% initalize figure and frames
h = figure;

if nargin>3 & ischar(varargin{3})
    % request for movie file
    
    % set figure to full screen
    set(h,'Position',get(0,'ScreenSize'))
    
    % flag for movie creation
    createmovie = 1;
    
    moviefile = varargin{3};
    
    clear F
    
else
    createmovie = 0;
end

%% grab data
if ischar(varargin{1})
    % varargin{1} is a string indicating which data in fData to grab
    switch varargin{1}
        case 'original'
            M = fData.WC_PBS_SampleAmplitudes;
        case 'L1'
            M = fData.X_PBS_L1;
        otherwise
            error
    end
elseif isnumeric(varargin{1}) && all(size(varargin{1})==size(fData.WC_PBS_SampleAmplitudes))
    % varargin{1} is the data to display (for tests inside functions)
    M = varargin{1};
end


%% display data
switch varargin{2}
    
    case 'flat'
        
        % grab data
        [pathstr, name, ext]= fileparts(fData.MET_MATfilename{1});
        fileName = [name ext];
        pingCounter = fData.WC_P1_PingCounter;
        nPings = size(M,1);
        b = fData.WC_PB_DetectedRangeInSamples;
        
        % bounds
        maxM = max(max(max(M)));
        minM = min(min(min(M)));
        
        for ii = 1:nPings
            cla
            imagesc(squeeze(M(ii,:,:))')
            colorbar
            hold on
            plot(b(ii,:),'k.')
            caxis([minM maxM])
            grid on
            title(sprintf('%s - ping %i (%i/%i)',fileName,pingCounter(ii),ii,nPings),'Interpreter','none')
            xlabel('beam #')
            ylabel('sample #')
            drawnow
            if createmovie
                F(ii) = getframe(gcf);
            end
        end
        
    case 'wedge'
        
        % grab data
        [pathstr, name, ext]= fileparts(fData.MET_MATfilename{1});
        fileName = [name ext];
        pingCounter = fData.WC_P1_PingCounter;
        nPings = size(fData.WC_PBS_SampleAmplitudes,1);
        X = fData.X_PBS_sampleAcrossDist;
        Y = fData.X_PBS_sampleUpDist;
        bX = fData.X_PB_bottomAcrossDist;
        bY = fData.X_PB_bottomUpDist;
        
        % bounds
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
            plot(bX(ii,:),bY(ii,:),'k.')
            axis([minX maxX minY maxY])
            caxis([minM maxM])
            grid on
            axis equal
            title(sprintf('%s - ping %i (%i/%i)',fileName,pingCounter(ii),ii,nPings),'Interpreter','none')
            xlabel('across distance (starboard) (m)')
            ylabel('height above sonar (m)')
            drawnow
            if createmovie
                F(ii) = getframe(gcf);
            end
        end
        
    case 'projected'
        
        % grab data
        [pathstr, name, ext]= fileparts(fData.MET_MATfilename{1});
        fileName = [name ext];
        pingCounter = fData.WC_P1_PingCounter;
        nPings = size(fData.WC_PBS_SampleAmplitudes,1);
        Easting = fData.X_PBS_sampleEasting;
        Northing = fData.X_PBS_sampleNorthing;
        Height = fData.X_PBS_sampleHeight;
        bEasting = fData.X_PB_bottomEasting;
        bNorthing = fData.X_PB_bottomNorthing;
        bHeight = fData.X_PB_bottomHeight;
        
        % bounds
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
            plot3(bEasting(ii,:),bNorthing(ii,:),bHeight(ii,:),'k.')
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
            if createmovie
                F(ii) = getframe(gcf);
            end
        end
        
    otherwise
        error
end

if createmovie
    writerObj = VideoWriter(moviefile,'MPEG-4');
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
%
%
%
