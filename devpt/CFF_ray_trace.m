function [total_range, total_time, total_vtdist, total_hzdist, end_angle] = CFF_ray_trace(depth_profile,velocity_profile,start_depth,start_angle,limit_variable,limit_value)

% limit_variable/limit_value allows control on the limiting parameter: total time, total
% depth, total range or total hzdist
% depth & velocity must have same size
% start_depth & start_angle must have same size

% check depth velocity is proper, or refromat it
% also check that start_depth is included
% depth profile must be a single vector with first value being positive,
% non-zero and last value must be positive, non-inf, and all values are
% increasing.
% if size(depth_profile) is N, then velocity_profile ,ust have size = N+1,
% where the first value is velocity in the stratum bounded be [0;
% depth_profile(1)] and the last value is the velocity in the stratum
% bounded by [depth_profile(end);inf];
% a first piece of code should check the depth profile and celerity profile
% are the appropriate size.
% another piece of code can be used to merge consecutive strata that have
% same velocity, so that the code doens't loop uselessly
% a last piece of code adds 0 and inf to depth_profile (if they are missing)

depth_profile = [0,1.1,2.2,3.3,inf];
velocity_profile = [1500,1600,1700,1800];
start_depth = 0.5;
start_angle = 45;
limit_variable = 'vtdist';
limit_value = 4;


% have a little function to allow plotting, as a flag
...
    
% 0. Initialize total trace
total_range = 0;
total_time = 0;
total_vtdist = 0;
total_hzdist = 0;

% find first stratum and initialize variables
this_stratum = discretize(start_depth,depth_profile,'IncludedEdge','left');
this_velocity = velocity_profile(this_stratum);
this_angle = start_angle;
this_stratum_thickness = depth_profile(this_stratum+1) - start_depth;

% prepare test string to evaluate at each loop
formatSpec1 = 'flag = total_%s + this_%s >= limit_value;';
flag_test_str = sprintf(formatSpec1,limit_variable,limit_variable);

% initialize flag
flag = 0;

% initialize plot
figure;
plot(0,-start_depth,'go')
hold on


while ~flag
    
    % ray trace in this stratum
    [this_range, this_time, this_vtdist, this_hzdist] = CFF_unit_ray_trace(this_velocity,this_angle,'vtdist',this_stratum_thickness);
    
    % compare to limiting factor if we were to add that new section in full
    eval(flag_test_str);
    
    if ~flag
        % Limiting factor not exceeded
        
        % compute angle for next stratum
        nextStratum = this_stratum + 1;
        nextVelocity = velocity_profile(nextStratum);
        nextAngle = CFF_snell_law(this_velocity,nextVelocity,this_angle);
        
        if nextAngle == 0
            % full reflection! Need to code for that case. In the meantime,
            % set it as an error
            error('full reflection. Not coded yet...')
        else
            % udpate variables for next reloop
            this_stratum = nextStratum;
            this_velocity = nextVelocity;
            this_angle = nextAngle;
            this_stratum_thickness = depth_profile(this_stratum+1) - depth_profile(this_stratum);
        end
        
        % plot
        plot([total_hzdist, total_hzdist+this_hzdist], -start_depth - [total_vtdist,total_vtdist+this_vtdist],'b.-');
        
        % add the results for that stratum to total
        total_range = total_range + this_range;
        total_time = total_time + this_time;
        total_vtdist = total_vtdist + this_vtdist;
        total_hzdist = total_hzdist + this_hzdist;

    else
        
        % Limiting factor exceeded,  re-trace the appropriate portion of
        % the stratum, add these partial results to total, and exit the
        % loop.
        
        % the last trace section should reach the limiting factor
        formatSpec2 = 'last_value = limit_value - total_%s;';
        last_value_str = sprintf(formatSpec2,limit_variable);
        eval(last_value_str);
        
        % retrace in this stratum using this last result
        [this_range, this_time, this_vtdist, this_hzdist] = CFF_unit_ray_trace(this_velocity,this_angle,limit_variable,last_value);
        
        % last angle is end_angle
        end_angle = this_angle;
        
        % plot
        plot([total_hzdist, total_hzdist+this_hzdist], -start_depth - [total_vtdist,total_vtdist+this_vtdist],'b.-');
        
        % add this partial stratum results to total before exiting the loop
        total_range = total_range + this_range;
        total_time = total_time + this_time;
        total_vtdist = total_vtdist + this_vtdist;
        total_hzdist = total_hzdist + this_hzdist;

    end
    
end

% finish up plot

depth_profile(end) = start_depth+total_vtdist;
N = length(velocity_profile);
x = [zeros(1,N); zeros(1,N); total_hzdist.*ones(1,N); total_hzdist.*ones(1,N)];
y = [-depth_profile(1:end-1); -depth_profile(2:end); -depth_profile(2:end); -depth_profile(1:end-1)];
c = velocity_profile;
h = patch(x,y,c,'EdgeColor','none');
uistack(h,'bottom') ;
colorbar
colormap bone
xlim([0 total_hzdist])
ylim([-start_depth-total_vtdist 0])

title('ray tracing')
xlabel('vertical distance (m)')
ylabel('depth (m)')
grid on
axis equal
