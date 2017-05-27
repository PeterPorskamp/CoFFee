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
% factor: either the total ray range ('range'), the total ray time
% ('time'), the thickness of the stratum or the desired vertical
% propagation distance ('vtdist') or the desired horizontal propagation
% distance ('hzdist').
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
