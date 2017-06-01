function [range, time, vtdist, hzdist] = CFF_unit_ray_trace(velocity,angle,limit_variable,limit_value)
%% CFF_unit_ray_trace
%
% Ray-tracing in a single stratum with sound velocity 'velocity' and start
% angle 'angle'. 
%
%% Help
%
% *USE*
%
% The pair (limit_variable,limit_value) allows control over the limiting
% factor, either:
% * The total ray range ('range') with value in m,
% * The total ray time ('time') with value in seconds,
% * The desired vertical propagation distance ('vtdist') with value in m,
% * The desired horizontal propagation distance ('hzdist') with value in m.
%
% *INPUT VARIABLES*
%
% * |velocity|: TODO: write description and info on variable
% * |angle|: TODO: write description and info on variable
% * |limit_variable|: TODO: write description and info on variable
% * |limit_value|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |range|: TODO: write description and info on variable
% * |time|: TODO: write description and info on variable
% * |vtdist|: TODO: write description and info on variable
% * |hzdist|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-06-01: first version (Alex Schimel)
%
% *EXAMPLE*
%
% velocity = 1500;
% angle = 45;
% limit_variable = 'hzdist';
% limit_value = 1000;
% [range, time, vtdist, hzdist] = CFF_unit_ray_trace(velocity,angle,limit_variable,limit_value)
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Alexandre Schimel, NIWA.

switch limit_variable
    case 'range'
        % limit_value is total range
        range  = limit_value;
        vtdist  = range.*sind(angle);
        hzdist = range.*cosd(angle);
        time   = range./velocity;
    case 'time'
        % limit_value is total time
        time  = limit_value;
        range = time.*velocity;
        vtdist  = range.*sind(angle);
        hzdist = range.*cosd(angle);
    case 'vtdist'
        % limit_value is total vtdist
        vtdist  = limit_value;
        range  = vtdist./sind(angle);
        hzdist = range.*cosd(angle);
        time   = range./velocity;
    case 'hzdist'
        % limit_value is horizontal distance
        hzdist = limit_value;
        range  = hzdist./cosd(angle);
        vtdist  = range.*sind(angle);
        time   = range./velocity;
    otherwise
        error('invalid limit_variable. Mode should be ''range'', ''time'', ''vtdist'', or ''hzdist''')
end
