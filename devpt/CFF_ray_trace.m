function [totalRange, totalTime, totalDepth, totalHzdist,endAngle] = CFF_ray_trace(depthProfile,velocityProfile,startDepth,startAngle,limitVariable,limitValue)

% limitVariable/limitValue allows control on the limiting parameter: total time, total
% depth, total range or total hzdist
% depth & velocity must have same size
% startDepth & startAngle must have same size

% check depth velocity is proper, or refromat it
% also check that startDepth is included

% depthProfile = [0:999];
% velocityProfile = linspace(1500,2200,1000);
% startDepth = 0;
% startAngle = 45;
% limitVariable = 'depth';
% limitValue = 1000;



% have a little function to allow plotting, as a flag
...
    
% 0. Initialize total trace
totalRange = 0;
totalTime = 0;
totalDepth = 0;
totalHzdist = 0;

% find first stratum and initialize variables
thisStratum = discretize(startDepth,depthProfile,'IncludedEdge','left');
thisVelocity = velocityProfile(thisStratum);
thisAngle = startAngle;
thisStratumThickness = depthProfile(thisStratum+1) - startDepth;

% initialize flag
flag = 0;

figure;
plot(0,0,'g.')
hold on

while ~flag
    
    % ray trace in this stratum
    [thisRange, thisTime, thisDepth, thisHzdist] = CFF_unit_ray_trace(thisVelocity,thisAngle,'depth',thisStratumThickness);
    
    % compare to limiting factor if we were to add that new section in full
    flag = totalDepth + thisDepth > limitValue;

    if flag
        % Limiting factor exceeded,  re-trace the appropriate portion of
        % the stratum, add these partial results to total, and exit the
        % loop.
        
        % the last trace section should reach the limiting factor
        lastDepth = limitValue - totalDepth;
        
        % retrace in this stratum using this last result
        [thisRange, thisTime, thisDepth, thisHzdist] = CFF_unit_ray_trace(thisVelocity,thisAngle,limitVariable,lastDepth);
        
        % add this partial stratum results to total before exiting the loop
        totalRange = totalRange + thisRange;
        totalTime = totalTime + thisTime;
        totalDepth = totalDepth + thisDepth;
        totalHzdist = totalHzdist + thisHzdist;
        
        % Last angle is endAngle
        endAngle = thisAngle;
        
        plot(totalHzdist,-totalDepth,'ro')
        
    else
        % Limiting factor not exceeded, add the results to total, compute
        % next angle, and update variables for next stratum

        % add the results to total
        totalRange = totalRange + thisRange;
        totalTime = totalTime + thisTime;
        totalDepth = totalDepth + thisDepth;
        totalHzdist = totalHzdist + thisHzdist;
        
        % compute next angle
        nextStratum = thisStratum + 1;
        nextVelocity = velocityProfile(nextStratum);
        nextAngle = CFF_snell_law(thisVelocity,nextVelocity,thisAngle);

        if nextAngle == 0
            % full reflection! Need to code for that case. In the meantime,
            % set it as an error
            error('full reflection. Not coded yet...')
        else
            % udpate variables for next reloop
            thisStratum = nextStratum;
            thisVelocity = nextVelocity;
            thisAngle = nextAngle;
            thisStratumThickness = depthProfile(thisStratum+1) - depthProfile(thisStratum);
        end
  
        plot(totalHzdist,-totalDepth,'b.')
        
    end
    
end


