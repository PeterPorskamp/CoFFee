% INCOMPLETE

CFF_seafloor_slopes
% DESCRIPTION: estimate seafloor slope for each sounding
% INPUT: accept either bathy profile (vector) or stacks of profiles (array)
% OUTPUT: 
% if bathy profile, produce along track slope (approx 1)
% if PB stack, produce along track and across track slopes. (approx 2).
% Also output maximum slope when we have 2D?

% 2D should work in Northing/Easting too. (approx 3)

CFF_beam_angle

% Estimate shoot angle from transmit and receive steering. And roll and pitch

CFF_ray_bend

%input start angle, SVP, depth
%output end angle at seafloor

CFF_incident_angle
% input end angle at seafloor
% input seafloor slope
% output incident angle
% Combine end angle with seafloor slope to get incident angle

CFF_radiometric_correction
%Implement level correction (TVG and all)