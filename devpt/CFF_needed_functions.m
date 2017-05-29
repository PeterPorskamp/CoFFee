% INCOMPLETE

%% 

CFF_seafloor_slopes
% DESCRIPTION: estimate seafloor slope for each sounding
% INPUT: accept either bathy profile (vector) or stacks of profiles (array)
% OUTPUT: 
% if bathy profile, produce along track slope (approx 1)
% if PB stack, produce along track and across track slopes. (approx 2).
% Also output maximum slope when we have 2D?

% 2D should work in Northing/Easting too. (approx 3)

%% 
CFF_beam_angle

% Estimate shoot angle from transmit and receive steering. And roll and pitch


% beamwidth in axis, non-steered
Tx_along_beamwdith
Tx_across_beamwdith
Tx_along_beamwdith
Rx_across_beamwdith

% steered angles in transmit (pitch compensation) and receive (roll
% compensation AND beamforming)
Tx_steer_angle
Rx_steer_angle

% for each ping/beam, determine the actual 4 beamwdiths taking into account
% the steering (beamwidth increase in 1/cos(angle))



%% RAY BEDNING

c1 = 1500;
c2 = 1600;
startAngle = 70; 
endAngle = CFF_snell_law(c1,c2,startAngle)

velocity = 1500;
angle = 45;
mode = 'hzdist';
value = 1000;
[range, time, depth, hzdist] = CFF_unit_ray_trace(velocity,angle,mode,value)


% see ray_trace
...
    
% need a clean_up_SVP function

% finally: 
CFF_compute_raybend_tables
%input: SVP, sonar depth, start angle, 
%output: end angle at seafloor

% for any SVP, compute 3D arrays for time/range/depth/


CFF_time_to_slantrange
% samples are recorded in time. R = ct/2 but c changes with depth so in
% theory to find range you must do ray-bending 
% given a SVP profile, a sonar depth and start angle relative to vertical,
% you calculate a one-to-one correspondance table
% time <-> range travelled <-> depth below sonar <-> hrz dist from sonar
% <-> end angle





%%
CFF_incident_angle
% input end angle at seafloor
% input seafloor slope
% output incident angle
% Combine end angle with seafloor slope to get incident angle

%% 
CFF_radiometric_correction
%Implement level correction (TVG and all)




% for each ping/beam, range gives teh "full" range (not slant, aka slant +
% ray bending).

% for each ping/beam figure the angle at seafloor (pair of angles actually)

% for each ping/beam, given the position and orientation of sonar, launch
% angles, ray bending, and bathymetry map, get the sample # in data where
% the bottom detect should have been. How does it compare to the bottom
% detect?