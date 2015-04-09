function CFF_multi_LOD_analysis(Z1_file,Z2_file,polygon,U1_file,U2_file)
% CFF_multi_LOD_analysis(Z1_file,Z2_file,polygon,U1_file,U2_file)
%
% DESCRIPTION
%
% use as template for a new function
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

% get polygons vertices:
if ~isempty(polygon)
xv = polygon(:,1);
yv = polygon(:,2);
end

% read grid tif files:
[Z1,Z1_easting,Z1_northing] = CFF_read_tif(Z1_file);
[Z2,Z2_easting,Z2_northing] = CFF_read_tif(Z2_file);


if ~isempty(polygon)
% clip grids to polygon
[Z1,Z1_easting,Z1_northing] = CFF_clip_raster(Z1,Z1_easting,Z1_northing,xv,yv);
[Z2,Z2_easting,Z2_northing] = CFF_clip_raster(Z2,Z2_easting,Z2_northing,xv,yv);
end

% coregister grids
[Z1,Z2,X,Y] = CFF_coregister_rasters(Z1,Z1_easting,Z1_northing,Z2,Z2_easting,Z2_northing);

% create dod from grids 
DOD = CFF_calculate_DOD(Z1,Z2);

% read uncertainty tif files:
[U1,U1_easting,U1_northing] = CFF_read_tif(U1_file,Z1_file);
[U2,U2_easting,U2_northing] = CFF_read_tif(U2_file,Z2_file);

if ~isempty(polygon)
% clip uncertainty grids to polygon
[U1,U1_easting,U1_northing] = CFF_clip_raster(U1,U1_easting,U1_northing,xv,yv);
[U2,U2_easting,U2_northing] = CFF_clip_raster(U2,U2_easting,U2_northing,xv,yv);
end

% coregister grids
[U1,U2,UX,UY] = CFF_coregister_rasters(U1,U1_easting,U1_northing,U2,U2_easting,U2_northing);


% create propagated uncertainty grid
DPU = CFF_calculate_DPU(U1,U2);

% DOD and DPU should be co-registered, but just in case of:
[DOD,DPU,X,Y] = CFF_coregister_rasters(DOD,X,Y,DPU,UX,UY);

% now run multi-LOD analysis
factors = [0:0.1:5];

for i = 1:length(factors)
    
    % two options:
    
    % first we threshold at a constant value, a factor of the std of a reference area:
%     uncertainty = 0.14;
%     threshold = sigma(i).*uncertainty;
%     volumes_v1(i) = CFF_LOD_volumes(DOD,X,Y,threshold,uncertainty);

    % second, we threshold at a spatially variable value, a factor of the
    % grid std, propagated in quadrature from the individual grids.
    LOD = factors(i).*DPU;
    volumes(i) = CFF_LOD_volumes(DOD,X,Y,LOD,DPU);
   
end







volumeNetChange = [volumes(:).volumeNetChange];
volumeEroded = [volumes(:).volumeEroded];
volumeDeposited = [volumes(:).volumeDeposited];
uncertaintyVolumeEroded_sum = [volumes(:).uncertaintyVolumeEroded_sum];
uncertaintyVolumeDeposited_sum = [volumes(:).uncertaintyVolumeDeposited_sum];
uncertaintyVolumeEroded_propagated = [volumes(:).uncertaintyVolumeEroded_propagated];
uncertaintyVolumeDeposited_propagated = [volumes(:).uncertaintyVolumeDeposited_propagated];
areaEroded = [volumes(:).areaEroded];
areaDeposited = [volumes(:).areaDeposited];
areaTotalChange = [volumes(:).areaTotalChange];
areaTotal = [volumes(:).areaTotal];

LOD = factors;

figure;

plot(LOD, volumeDeposited, 'Color',[0.4 0.4 0.4],'LineWidth',2)
hold on
%plot(LOD, volumeNetChange, 'Color',[0 0 0],'LineWidth',2)
plot(LOD, volumeEroded,    'Color',[0.7 0.7 0.7],'LineWidth',2)
legend('deposition','erosion')

% erosion uncertainty
plot(LOD, volumeEroded - uncertaintyVolumeEroded_sum,'--','Color',[0.7 0.7 0.7],'LineWidth',2)
uncertaintyVolumeEroded_sum(volumeEroded + uncertaintyVolumeEroded_sum > 0) = NaN;
plot(LOD, volumeEroded + uncertaintyVolumeEroded_sum,'--','Color',[0.7 0.7 0.7],'LineWidth',2)

% deposition uncertainty
plot(LOD,volumeDeposited + uncertaintyVolumeDeposited_sum,'--','Color',[0.4 0.4 0.4],'LineWidth',2)
uncertaintyVolumeDeposited_sum(volumeDeposited - uncertaintyVolumeDeposited_sum < 0) = NaN;
plot(LOD,volumeDeposited - uncertaintyVolumeDeposited_sum,'--','Color',[0.4 0.4 0.4],'LineWidth',2)

% value at uncertainty level
vmax = max([max(abs(volumeEroded-uncertaintyVolumeEroded_sum)), max(abs(volumeDeposited+uncertaintyVolumeDeposited_sum))]);
stem([uncertainty,uncertainty],[-vmax,vmax],'k.','LineWidth',2)

grid on
xlabel('sigma factor')
ylabel('erosion (m^3)                     deposition (m^3)')
title(['Volumes above threshold'])
ylim([-vmax vmax])

    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0.25 0.25 15 10]);
    print('-dpng','-r600','volumeAboveLOD.png')

    
    
    


% display
figure;

plot(sigma,v_dep,'Color',[0.4 0.4 0.4],'LineWidth',2)
hold on
plot(sigma,v_bud,'Color',[0 0 0],'LineWidth',2)
plot(sigma,v_ero,'Color',[0.7 0.7 0.7],'LineWidth',2)
legend('deposition','net','erosion')

plot(sigma,v_ero-us_v_ero,'--','Color',[0.7 0.7 0.7],'LineWidth',2)
plot(sigma,v_dep+us_v_dep,'--','Color',[0.4 0.4 0.4],'LineWidth',2)
us_v_ero(v_ero+us_v_ero > 0) = NaN;
plot(sigma,v_ero+us_v_ero,'--','Color',[0.7 0.7 0.7],'LineWidth',2)
us_v_dep(v_dep-us_v_dep < 0) = NaN;
plot(sigma,v_dep-us_v_dep,'--','Color',[0.4 0.4 0.4],'LineWidth',2)

vmax = max([max(abs(v_ero-us_v_ero)), max(abs(v_dep+us_v_dep))]);
stem([0.14,0.14],[-vmax,vmax],'k.','LineWidth',2)

grid on

xlabel('sigma (m)')
ylabel('erosion (m^3)                     deposition (m^3)')
title(['Volumes above threshold for ' bathyDiffLabel ' on ' bathyMaskLabel ' area'])
ylim([-vmax vmax])

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0.25 0.25 30 20]);
CFF_nice_easting_northing(5)
%print('-dpng','-r600',[bathyDiffLabel '_' bathyMaskLabel '_volumeAboveThreshold.png'])




% bathy intervals to compute interval volumes
interval = [-1:0.01:1]; %m

