function [end_range, end_time, end_vtdist, end_hzdist, end_angle, end_depth] = CFF_ray_trace(depth_profile,velocity_profile,start_depth,start_angle,limit_variable,limit_value, display_flag)
%% CFF_ray_trace
%
% Compute ray bending / ray tracing in the water-column given sound
% velocity profile, initial conditions (depth & angle), and the limiting
% factor (range, time, vertical distance, horizontal distance).
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
% * |start_velocity|: TODO: write description and info on variable
% * |end_velocity|: TODO: write description and info on variable
% * |start_angle|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |end_angle|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% need to add varargin checks:
% - start_depth & start_angle must have same size. Program is built to accept
% only one value so far, but maybe modify later to accept vectors, or even,
% arrays. all output values have same size as these two inputs.
% - check depth velocity is proper, or reformat it
% depth profile must be a single vector with first value being positive,
% non-zero and last value must be positive, non-inf, and all values are
% increasing.
% if size(depth_profile) is N, then velocity_profile ,ust have size = N+1,
% where the first value is velocity in the stratum bounded be [0;
% depth_profile(1)] and the last value is the velocity in the stratum
% bounded by [depth_profile(end);inf];
% a first piece of code should check the depth profile and celerity profile
% are the appropriate size.
% - also check that start_depth is included in depth_profile bounds
% another piece of code can be used to merge consecutive strata that have
% same velocity, so that the code doens't loop uselessly
% a last piece of code adds 0 and inf to depth_profile (if they are missing)
% maybe all of this could be done in a separate function CFF_clean_up_SVP
% or something
%
% *NEW FEATURES*
%
% * 2017-06-01: first version (Alex Schimel)
%
% *EXAMPLE*
%
% depth_profile = [0,[1:1:50],inf];
% velocity_profile = linspace(1500,2700,51);
% start_depth = 2;
% start_angle = 45;
% limit_variable = 'range';
% limit_value = 100;
% display_flag = 1;
% [end_range, end_time, end_vtdist, end_hzdist, end_angle, end_depth] = CFF_ray_trace(depth_profile,velocity_profile,start_depth,start_angle,limit_variable,limit_value, display_flag)
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Alexandre Schimel, NIWA.

% Initialize cumulative calculations:
cumulative_range = 0;
cumulative_time = 0;
cumulative_vtdist = 0;
cumulative_hzdist = 0;

% find first stratum
try this_stratum = discretize(start_depth,depth_profile,'IncludedEdge','left');
catch
    % 'discretize' function was only introduced in R2015a
    this_stratum = find(depth_profile-start_depth>0,1)-1;
end

% initialize variables for first stratum
this_velocity = velocity_profile(this_stratum);
this_angle = start_angle;
this_stratum_thickness = depth_profile(this_stratum+1) - start_depth;

% prepare the string to be evaluated at each loop to see if we overshot the limit value
formatSpec1 = 'flag = cumulative_%s + this_%s >= limit_value;';
flag_test_str = sprintf(formatSpec1,limit_variable,limit_variable);

% initialize plot
if display_flag
    figure;
    plot(0,-start_depth,'bo')
    hold on
end

% initialize flag
flag = 0;

while ~flag
    
    % ray trace in this stratum
    [this_range, this_time, this_vtdist, this_hzdist] = CFF_unit_ray_trace(this_velocity,this_angle,'vtdist',this_stratum_thickness);
    
    % compare to limiting factor if we were to add that new section in full
    eval(flag_test_str);
    
    if ~flag
        % Limiting factor not exceeded
        
        % compute angle for next stratum
        next_stratum = this_stratum + 1;
        next_velocity = velocity_profile(next_stratum);
        next_angle = CFF_snell_law(this_velocity,next_velocity,this_angle);
        
        if next_angle == 0
            % full reflection! Need to code for that case. In the meantime, set it as an error
            error('full reflection. Not coded yet...')
        else
            % udpate variables for next reloop
            this_stratum = next_stratum;
            this_velocity = next_velocity;
            this_angle = next_angle;
            this_stratum_thickness = depth_profile(this_stratum+1) - depth_profile(this_stratum);
        end
        
        % plot
        if display_flag
            plot([cumulative_hzdist, cumulative_hzdist+this_hzdist], -start_depth - [cumulative_vtdist,cumulative_vtdist+this_vtdist],'b.-');
        end
        
        % add the results for that stratum to total
        cumulative_range = cumulative_range + this_range;
        cumulative_time = cumulative_time + this_time;
        cumulative_vtdist = cumulative_vtdist + this_vtdist;
        cumulative_hzdist = cumulative_hzdist + this_hzdist;
        
    else
        
        % Limiting factor exceeded,  re-trace the appropriate portion of
        % the stratum, add these partial results to total, and exit the
        % loop.
        
        % the last trace section should reach the limiting factor
        formatSpec2 = 'last_value = limit_value - cumulative_%s;';
        last_value_str = sprintf(formatSpec2,limit_variable);
        eval(last_value_str);
        
        % retrace in this stratum using this last result
        [this_range, this_time, this_vtdist, this_hzdist] = CFF_unit_ray_trace(this_velocity,this_angle,limit_variable,last_value);
        
        % plot
        if display_flag
            plot([cumulative_hzdist, cumulative_hzdist+this_hzdist], -start_depth - [cumulative_vtdist,cumulative_vtdist+this_vtdist],'b.-');
        end
        
        % add this partial stratum results to total before exiting the loop
        cumulative_range = cumulative_range + this_range;
        cumulative_time = cumulative_time + this_time;
        cumulative_vtdist = cumulative_vtdist + this_vtdist;
        cumulative_hzdist = cumulative_hzdist + this_hzdist;
        
    end
    
end

% finalise
end_range  = cumulative_range;
end_time   = cumulative_time;
end_hzdist = cumulative_hzdist;
end_vtdist = cumulative_vtdist;
end_angle  = this_angle; % last angle is end_angle
end_depth  = end_vtdist + start_depth;

% finish up plot
if display_flag
    
    % add strata colour-coded by velocity
    N = length(velocity_profile); % total number of strata
    if end_hzdist>0
        x = [zeros(1,N); zeros(1,N); end_hzdist.*ones(1,N); end_hzdist.*ones(1,N)];
    else
        x = [zeros(1,N); zeros(1,N); end_depth.*ones(1,N); end_depth.*ones(1,N)];
    end
    y = [-depth_profile(1:end-1); -[depth_profile(2:end-1),end_depth]; -[depth_profile(2:end-1),end_depth]; -depth_profile(1:end-1)];
    h = patch(x,y,velocity_profile,'EdgeColor','none','FaceAlpha',0.3);
    uistack(h,'bottom') ;
    colorbar
    colormap gray
    
    % and then the details
    title('ray tracing')
    xlabel('vertical distance (m)')
    ylabel('depth (m)')
    grid on
    axis equal
    if end_hzdist>0
        xlim([0 end_hzdist])
    else
        xlim([0 end_depth])
    end
    ylim([-end_depth 0])
    
end


