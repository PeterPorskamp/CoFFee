function fData = CFF_grid_watercolumn(fData,varargin)
% fData = CFF_grid_watercolumn(fData,varargin)
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


%% get field to grid
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


%% turn L to natural before averaging
L = 10.^(L./20);


%% build the easting norhting and height grids

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

% build the grids
gridEasting  = [0:numE-1].*res + minE;
gridNorthing = [0:numN-1]'.*res + minN;
gridHeight   = [0:numH-1].*res + minH;


%% now grid watercolumn data

% option 1: griddata in 3D (too long, give up on this)
% gridLevel = griddata(E,N,H,L,gridEasting,gridNorthing,gridHeight); 

% option 2: slice by slice

% initialize cubes of values and density
gridLevel   = nan(numN,numE,numH);
gridDensity = nan(numN,numE,numH);

for kk = 1:length(gridHeight)-1
    
    % find all samples in slice
    ind = find( H>gridHeight(kk) & H<gridHeight(kk+1) & ~isnan(L) );
    
    if ~isempty(ind)
        
        % gridding at constant weight
        [tmpgridLevel,tmpgridDensity] = CFF_weightgrid(E(ind),N(ind),L(ind),[minE,res,numE],[minN,res,numN],1);
        
        % add to cubes
        gridLevel(:,:,kk) = tmpgridLevel;
        gridDensity(:,:,kk) = tmpgridDensity;
        
    end
    
end

%% bring gridLevel back in decibels
gridLevel = 20.*log10(gridLevel);

%% saving results
fData.X_1E_gridEasting = gridEasting;
fData.X_N1_gridNorthing = gridNorthing;
fData.X_H_gridHeight = gridHeight;
fData.X_NEH_gridLevel = gridLevel;
fData.X_NEH_gridDensity = gridDensity;

%% how to meshgrid easting and northing, for reference:
% [gridEasting,gridNorthing] = meshgrid(gridEasting,gridNorthing);

%% OR, how to meshgrid easting, northing and height, for reference:
% [gridEasting,gridNorthing,gridHeight] = meshgrid(gridEasting,gridNorthing,gridHeight);
