function [DODmean,DODstd,DOD,X,Y,DODsixheightperc,DODmin,DODmax] = CFF_reference_DOD_analysis(DEM1,DEM2,polygon,display_flag)
% [DODmean,DODstd,DOD,X,Y,DODsixheightperc,DODmin,DODmax] = CFF_reference_DOD_analysis(DEM1,DEM2,polygon)
%
% DESCRIPTION
%
% Read DEM files DEM1 and DEM2 (tiff format), clip them to polygon,
% compute DOD and calculate mean and standard deviation.
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

% coregister grids
[Z1,Z2,X,Y] = CFF_coregister_rasters(Z1,Z1_easting,Z1_northing,Z2,Z2_easting,Z2_northing);

% create dod from grids 
DOD = CFF_calculate_DOD(Z1,Z2);

% get mean and standard deviation of DOD over reference area
[DODmean,DODstd] = CFF_nanstat3(DOD(:),1);

% std is a good estimate of deviation around the mean, corresponding to
% 68.2% of the population being between -1 sigma and +1sigma. But if the
% population is heavily skewed, the standard deviation is much larger than
% that. Use the invpercentile function to get a better estimate of
% deviation. In our DOD, 68.2% of the population is contains within +- of:
DODsixheightperc = CFF_invpercentile(abs(DOD(:)),68);

DODmin = min(DOD(:));
DODmax = max(DOD(:));


% display and print
if display_flag>0
    figure
    hist(DOD(:),500)
    set(gca,'YTick',[]);
    grid on
    if display_flag>1
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperPosition', [0.25 0.25 12 8]);
        print('-dpng','-r1000','hist.png')
    end
end