function [range, time, depth, hzdist] = CFF_unit_ray_trace(velocity,angle,mode,value)
%% CFF_unit_ray_trace
%
% Ray-tracing in a single stratum with sound velocity 'velocity' and start
% angle 'angle'. 
%
%% Help
%
% *USE*
%
% The pair mode/value gives control over the limiting factor: either the
% thickness of the stratum ('depth'), the total ray range ('range') or
% the total ray time ('time')
%
% *INPUT VARIABLES*
%
% * |input_variable_1|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |output_variable_1|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Alexandre Schimel, NIWA.

switch mode
    case 'range'
        % value is total range
        range  = value;
        depth  = range.*sind(angle);
        hzdist = range.*cosd(angle);
        time   = range./velocity;
    case 'time'
        % value is total time
        time  = value;
        range = time.*velocity;
        depth  = range.*sind(angle);
        hzdist = range.*cosd(angle);
    case 'depth'
        % value is total depth
        depth  = value;
        range  = depth./sind(angle);
        hzdist = range.*cosd(angle);
        time   = range./velocity;
    case 'hzdist'
        % value is horizontal distance
        hzdist = value;
        range  = hzdist./cosd(angle);
        depth  = range.*sind(angle);
        time   = range./velocity;
    otherwise
        error('invalid mode. Mode should be ''range'', ''time'', ''depth'', or ''hzdist''')
end
