function volumes = CFF_volume_interval_analysis(DEM1,DEM2,polygon,intervals,display_flag)
% volumes = CFF_volume_interval_analysis(DEM1,DEM2,polygon,intervals,display_flag)
%
% DESCRIPTION
%
% calculate volumes from the difference between two DEMs, per interval as
% specified.
%
% USE
%
% ...
%
% PROCESSING SUMMARY
%
% - ...
% - ...
% - ...
%
% INPUT VARIABLES
%
% - varagin
%
% OUTPUT VARIABLES
%
% - NA
%
% RESEARCH NOTES
%
% ...
%
% NEW FEATURES
%
% YYYY-MM-DD: second version.
% YYYY-MM-DD: first version.
%
% EXAMPLE
%
%%%
% Alex Schimel, Deakin University
%%%

% load DEM1 and DEM2
[Z1,Z1_easting,Z1_northing] = CFF_load_raster(DEM1);
[Z2,Z2_easting,Z2_northing] = CFF_load_raster(DEM2);

% load polygon and clip DEMs to polygon
if ~isempty(polygon)
    
    xv = polygon(:,1);
    yv = polygon(:,2);
    
    % clip grids to polygon
    [Z1,Z1_easting,Z1_northing] = CFF_clip_raster(Z1,Z1_easting,Z1_northing,xv,yv);
    [Z2,Z2_easting,Z2_northing] = CFF_clip_raster(Z2,Z2_easting,Z2_northing,xv,yv);
    
end

% co-register grids
[Z1,Z2,X,Y] = CFF_coregister_rasters(Z1,Z1_easting,Z1_northing,Z2,Z2_easting,Z2_northing);

% create dod
DOD = CFF_calculate_DOD(Z1,Z2);

% initialise volume per interval
volumeInInterval = nan(size(intervals));
areaInInterval = nan(size(intervals));

% for each interval
for ii = 1:length(intervals)-1
    
    % mask the data to the interval
    DOD_mask = DOD>=intervals(ii) & DOD<intervals(ii+1);
    
    % calculate volume and area
    volumeInInterval(ii)  = CFF_nansum3(CFF_nansum3(DOD .* DOD_mask)).*0.5.^2;
    areaInInterval(ii)   = sum(sum(double(DOD_mask))).*0.5.^2;
    
    % other approach, using CFF_LOD_volumes
    tempDOD = DOD;
    tempDOD(tempDOD<intervals(ii)) = NaN;
    tempDOD(tempDOD>=intervals(ii+1)) = NaN;
    
    volumes(ii) = CFF_LOD_volumes(tempDOD,X,Y,0,0);
    
end

% display
if display_flag>0
    
    volumeInInterval = [volumes(:).volumeNetChange];
    areaInInterval = [volumes(:).areaTotalChange];
    intervals(end) = [];
        
    figure;
    
    % volumes per interval
    h1 = bar(intervals(intervals>=0),volumeInInterval(intervals>=0),'histc');
    hold on
    h2 = bar(abs(intervals(intervals<0))-0.01,volumeInInterval(intervals<0),'histc');
    
    h1.EdgeColor = 'none';
    h2.EdgeColor = 'none';
    h1.FaceColor = [0.4 0.4 0.4];
    h2.FaceColor = [0.7 0.7 0.7];
    
    grid on
    set(gca,'layer','top')
    xlabel('absolute depth change (m)')
    ylabel('erosion (m^3)                     deposition (m^3)')
    xlim([0 intervals(end)])
    ylim([-max(abs(volumeInInterval)) max(abs(volumeInInterval))])
    title(['Volumes per depth change interval'])
    
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0.25 0.25 30 20]);
    
    if display_flag>1
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0.25 0.25 30 20]);
        CFF_nice_easting_northing(5)
        print('-dpng','-r600','volumePerInterval.png')
    end
    
    figure;
    
    % area per interval
    h1 = bar(intervals(intervals>=0),areaInInterval(intervals>=0),'histc');
    hold on
    h2 = bar(abs(intervals(intervals<0))-0.01,-areaInInterval(intervals<0),'histc');
    
    h1.EdgeColor = 'none';
    h2.EdgeColor = 'none';
    h1.FaceColor = [0.4 0.4 0.4];
    h2.FaceColor = [0.7 0.7 0.7];
    
    grid on
    set(gca,'layer','top')
    xlabel('absolute depth change (m)')
    ylabel('erosion (m^2)                     deposition (m^2)')
    xlim([0 intervals(end)])
    ylim([-max(abs(areaInInterval)) max(abs(areaInInterval))])
    title(['Area per depth change interval'])
    
    if display_flag>1
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0.25 0.25 30 20]);
        CFF_nice_easting_northing(5)
        print('-dpng','-r600','areaPerInterval.png')
    end
    
end