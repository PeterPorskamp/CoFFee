function [fData] = CFF_process_watercolumn(fData)
% [fData] = CFF_process_watercolumn(fData)
%
% DESCRIPTION
%
% calculates XY positions for each sample in the swathe frame, and XYZ in
% the grographical frame. Do the same for bottom detection. 
%
% new developments needed:
% using the info on sonar location (E,N,H) and
% orientation (azimuth, depression, heading) at time of ping, find exact
% E,N,H of each sample in the data.
%
%
% INPUT VARIABLES
%
% - 
%
% OUTPUT VARIABLES
%
% - 
% RESEARCH NOTES
%
% -
%
% NEW FEATURES
%
% - v0.1:
%   - first version. Code adapted from old processing scripts
%
%%%
% Alex Schimel, Deakin University
% Version 0.1 (26-Feb-2014)
%%%




%% Extract needed data

% dimensions:
nPings = size(fData.WC_PBS_SampleAmplitudes,1);
nBeams = size(fData.WC_PBS_SampleAmplitudes,2);
nSamples = size(fData.WC_PBS_SampleAmplitudes,3);

% ping info
P_soundSpeed = fData.WC_P1_SoundSpeed.*0.1; %m/s
P_samplingFrequency = fData.WC_P1_SamplingFrequency.*0.01; %Hz
P_sonarHeight = fData.X_P1_pingH; %m
P_sonarEasting = fData.X_P1_pingE; %m
P_sonarNorthing = fData.X_P1_pingN; %m
P_gridConvergence = fData.X_P1_pingGridConv; %deg
P_vesselHeading = fData.X_P1_pingHeading; %deg
P_sonarHeadingOffset = fData.IP_ASCIIparameters.S1H; %deg

% beam info
PB_beamPointingAngleDeg = fData.WC_PB_BeamPointingAngle.*0.01; %deg
PB_startRangeSampleNumber = fData.WC_PB_StartRangeSampleNumber;
PB_detectedRange = fData.WC_PB_DetectedRangeInSamples; %in sample number

% turn P vectors into PB arrays and PB arrays into PBS arrays if needed
PB_soundSpeed = repmat(P_soundSpeed ,[1 nBeams]);
PB_samplingFrequency = repmat(P_samplingFrequency ,[1 nBeams]);
PB_sonarEasting = repmat(P_sonarEasting ,[1 nBeams]);
PB_sonarNorthing = repmat(P_sonarNorthing ,[1 nBeams]);
PB_sonarHeight = repmat(P_sonarHeight ,[1 nBeams]);
PBS_sonarEasting = repmat(P_sonarEasting,[1 nBeams nSamples]);
PBS_sonarNorthing = repmat(P_sonarNorthing,[1 nBeams nSamples]);
PBS_sonarHeight = repmat(P_sonarHeight,[1 nBeams nSamples]);
PBS_startRangeSampleNumber = repmat(PB_startRangeSampleNumber,[1 1 nSamples]);



%% Compute samples coordinates in the swath frame

% Compute OWTT distance traveled in one sample
P_oneSampleDistance = P_soundSpeed./(P_samplingFrequency.*2);
PB_oneSampleDistance = repmat(P_oneSampleDistance ,[1 nBeams]);
PBS_oneSampleDistance = repmat(P_oneSampleDistance,[1 nBeams nSamples]);

% Build a 3D PBS array containging sample index (starting with zero)
PBS_indices = ones(1,1,nSamples);
PBS_indices(1,1,:) = 0:nSamples-1;
PBS_indices = repmat(PBS_indices,[nPings nBeams 1]);

% Compute range for each sample and bottom detections
PBS_sampleRange = (PBS_indices+PBS_startRangeSampleNumber) .* PBS_oneSampleDistance;
PB_bottomRange  =                         PB_detectedRange .* PB_oneSampleDistance;
PB_bottomRange(PB_bottomRange==0) = NaN;

% Compute angles in radins
PB_beamPointingAngleRad = PB_beamPointingAngleDeg.*pi./180; % in radians
PBS_beamPointingAngleRad = repmat(PB_beamPointingAngleRad,[1 1 nSamples]);

% Cartesian coordinates in the swath frame:
% - origin: sonar face
% - Xs: across distance (positive ~starboard)
% - Ys: always zero (positive ~forward)
% - Zs: up distance (positive up)

% for samples:
PBS_sampleUpDist     = -PBS_sampleRange .* cos(PBS_beamPointingAngleRad);
PBS_sampleAcrossDist =  PBS_sampleRange .* sin(PBS_beamPointingAngleRad);

% for bottom detection:
PB_bottomUpDist     = -PB_bottomRange .* cos(PB_beamPointingAngleRad);
PB_bottomAcrossDist =  PB_bottomRange .* sin(PB_beamPointingAngleRad);



%% Now transform into projected coordinates:
% - origin: the (0,0) Easting/Northing projection reference and datum reference
% - Xp: Easting (positive East)
% - Yp: Northing (grid North, positive North)
% - Zp: Elevation/Height (positive up)

% In THEORY, real-time compensation of roll and pitch means the Z for the
% swath frame is exactly the same as Z for elevation, so that we only need
% to rotate in the horizontal frame. In effect, we may want to recompute
% the true up pointing angle for the swath. For now, we'll make it simple:

% caculate the horizontal rotation angle between the swath frame (Ys
% forward and Yp northing)
P_theta = - mod(P_gridConvergence+P_vesselHeading+P_sonarHeadingOffset,360);
P_thetaRad = P_theta.*pi./180;
PB_thetaRad = repmat(P_thetaRad,[1 nBeams]);
PBS_thetaRad = repmat(P_thetaRad,[1 nBeams nSamples]);

% for samples:
PBS_sampleEasting  = PBS_sonarEasting  + PBS_sampleAcrossDist.*cos(PBS_thetaRad);
PBS_sampleNorthing = PBS_sonarNorthing + PBS_sampleAcrossDist.*sin(PBS_thetaRad);
PBS_sampleHeight   = PBS_sonarHeight   + PBS_sampleUpDist;

% for bottom detection:
PB_bottomEasting  = PB_sonarEasting  + PB_bottomAcrossDist.*cos(PB_thetaRad);
PB_bottomNorthing = PB_sonarNorthing + PB_bottomAcrossDist.*sin(PB_thetaRad);
PB_bottomHeight   = PB_sonarHeight   + PB_bottomUpDist;


%% Save back in fData

fData.X_P_oneSampleDistance = P_oneSampleDistance;
fData.X_PBS_sampleRange = PBS_sampleRange;
fData.X_PBS_beamPointingAngleRad = PBS_beamPointingAngleRad;
fData.X_PBS_sampleUpDist = PBS_sampleUpDist;
fData.X_PBS_sampleAcrossDist = PBS_sampleAcrossDist;
fData.X_PBS_sampleEasting = PBS_sampleEasting;
fData.X_PBS_sampleNorthing = PBS_sampleNorthing;
fData.X_PBS_sampleHeight = PBS_sampleHeight;

fData.X_PB_bottomRange = PB_bottomRange;
fData.X_PB_beamPointingAngleRad = PB_beamPointingAngleRad;
fData.X_PB_bottomUpDist = PB_bottomUpDist;
fData.X_PB_bottomAcrossDist = PB_bottomAcrossDist;
fData.X_PB_bottomEasting = PB_bottomEasting;
fData.X_PB_bottomNorthing = PB_bottomNorthing;
fData.X_PB_bottomHeight = PB_bottomHeight;


