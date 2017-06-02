
%% basics

%% convert one or several raw Kongsberg files to mat, conserving formatting

%% extract desired data from one or several mat files

%% extrapolate all nav and attitude data to ping time
% Roll; Pitch; Heave; Heading; Height; Latitude; Longitude; Speed;
   
%% get easting & northing from lat long. Also correct heading for grid convergence

%% translate ENH position to sonar acoustic center, for each ping
% using lever arm?

%% translate attitude angles (pitch, roll, heading) to sonar head, for ping time
% using sonar setup angles?

%% compute depression (down) and azimuth (ref to north) of sonar acoustic axis at each ping
% from pitch, roll, heading 

%% compute depression/azimuth of each beam (start angle)
% given that of sonar and transmit steer angle for each ping + receive steer
% angle for each beam

%% ray bend each beam to get slant range, vertical distance (down), hz dist, and angle for each sample
% given a SVP, the sonar depth for each ping and the start angle for each
% beam

%% compute the XYZ location of each sample in a geo frame.
% from the depth and horizontal distance for each sample, as well as the
% azimuth angle for each beam, and the XYZ location of the sonar


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

% a function purely to compute refraction CFF_snell_law
% a function to measure the total propagation in a stratum CFF_unit_ray_trace
% and a function combining the two above to do ray bending CFF_ray_trace

% now I need a new version of that function that output the results for
% various limit values...

% next a function that computes 3D raybending tables, aka total range,
% hzdist, vtdist and angle as a function of time, start angle, and sonar
% depth.

[range, hzdist, vtdist, angle] = CFF_compute_raybend_tables(depth_profile, velocity_profile, start_depth, start_angle, time);

% it would perhaps need a function that compute the max start_depth,
% start_angle and time in a give dataset, in order to generate tables valid
% for an entire dataset.

CFF_seafloor_slopes
% DESCRIPTION: estimate seafloor slope for each sounding
% INPUT: accept either bathy profile (vector) or stacks of profiles (array)
% OUTPUT: 
% if bathy profile, produce along track slope (approx 1)
% if PB stack, produce along track and across track slopes. (approx 2).
% Also output maximum slope when we have 2D?

% 2D should work in Northing/Easting too. (approx 3)



%% INCIDENT ANGLE

% with the ray bending tables created above, for a given dataset, I should
% be able to get the incident angle at seafloor for all samples in the
% dataset

% now I need a function

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