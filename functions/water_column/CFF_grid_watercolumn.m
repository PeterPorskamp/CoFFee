function [gridEasting,gridNorthing,gridHeight,gridLevel,gridDensity] = CFF_grid_watercolumn(fData,varargin)
% [gridEasting,gridNorthing,gridHeight,gridLevel,gridDensity] = CFF_grid_watercolumn(in,varargin)
%
% DESCRIPTION
%
% INPUT VARIABLES
%
% varargin{1}: data to grid: 'original' or 'L1' or a field of fData of PBS
% size
% varargin{2}: grid resolution in m
%
% OUTPUT VARIABLES
%
% RESEARCH NOTES
%
% EXAMPLES
%
%   [gridEasting,gridNorthing,gridHeight,gridLevel,gridDensity] = CFF_grid_watercolumn(fData,'original',0.1)
%
% NEW FEATURES
%
% - v0.1:
%   - first version.
%
%%%
% Alex Schimel, Deakin University
% Version 0.1 (30-Apr-2014)
%%%


% get field to grid
switch varargin{1}
    case 'original'
        Lfield = 'WC_PBS_SampleAmplitudes';
    case 'L1'
        Lfield = 'X_PBS_L1';
    otherwise
        if isfield(fData,varargin{1})
            Lfield = varargin{1};
        else
            error('field not recognized')
        end
end
expression = ['L = reshape(fData.' Lfield ',1,[]);'];
eval(expression);

% turn L to natural before averaging
L = exp(L./20);

% get grid resolution
res = varargin{2};

% get samples coordinates
E = reshape(fData.X_PBS_sampleEasting,1,[]);
N = reshape(fData.X_PBS_sampleNorthing,1,[]);
H = reshape(fData.X_PBS_sampleHeight,1,[]);

% Use the min easting, northing and height (floored) in all non-NaN
% samples as the first value for grids.
minE = floor(min(E(~isnan(L))));
minN = floor(min(N(~isnan(L))));
minH = floor(min(H(~isnan(L))));

% Idem for the last value to cover:
maxE = ceil(max(E(~isnan(L))));
maxN = ceil(max(N(~isnan(L))));
maxH = ceil(max(H(~isnan(L))));

% define number of elements needed to cover max easting, northing and
% height
numE = ceil((maxE-minE)./res)+1;
numN = ceil((maxN-minN)./res)+1;
numH = ceil((maxH-minH)./res)+1;

% writing the grid parameters in Easting and Northing for the gridding
% function 
gridE_param = [minE,res,numE];
gridN_param = [minN,res,numN];

% For height, just build the grid
gridHeight = [0:numH-1].*res + minH;

% initialize cubes of values and density
gridLevel   = nan(numN,numE,numH);
gridDensity = nan(numN,numE,numH);

% for each hortizontal slice
for kk = 1:length(gridHeight)-1
    
    % find samples in slice
    ind = find( H>gridHeight(kk) & H<gridHeight(kk+1) & ~isnan(L) );
    
    if ~isempty(ind)
        
        % get values
        sE = E(ind);
        sN = N(ind);
        sH = H(ind);
        sL = L(ind);
        
        % gridding at constant weight
        [tmpgridLevel,tmpgridDensity] = CFF_weightgrid(sE,sN,sL,gridE_param,gridN_param,1);
        
        % add to cubes
        gridLevel(:,:,kk) = tmpgridLevel;
        gridDensity(:,:,kk) = tmpgridDensity;
        
    end
    
end

% build the Easting and Northing grids (as meshgrid)
gridEasting = [0:gridE_param(3)-1].*gridE_param(2) + gridE_param(1);
gridNorthing = [0:gridN_param(3)-1].*gridN_param(2) + gridN_param(1);
[gridEasting,gridNorthing] = meshgrid(gridEasting,gridNorthing);

% bring gridLevel back in decibels
gridLevel = 20.*log10(gridLevel);

% % plot for display
% figure
% caxismin = min(gridLevel(:));
% caxismax = max(gridLevel(:));
% for jj=1:10
%     for kk=1:length(gridHeight)-1
%         cla
%         imagesc(gridLevel(:,:,kk));
%         set(gca,'Ydir','normal')
%         caxis([caxismin caxismax])
%         colorbar
%         grid on
%         axis equal square tight
%         drawnow
%     end
% end

