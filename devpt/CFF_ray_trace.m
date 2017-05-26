function [totalRange, totalTime, totalDepth, totalHzdist,endAngle] = CFF_ray_trace(depthProfile,velocityProfile,startDepth,startAngle,mode,value)

% mode/value allows control on the limiting parameter: total time, total
% depth, total range or total hzdist
% depth & velocity must have same size
% startDepth & startAngle must have same size

% check depth velocity is proper, or refromat it
% also check that startDepth is included
depthProfile = [0;1;3;5;6;9;1000];
velocityProfile = [1500;1600;1700;1800;1900;2000;2100];

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

while ~flag
    
    % ray trace in this stratum
    [thisRange, thisTime, thisDepth, thisHzdist] = CFF_unit_ray_trace(thisVelocity,thisAngle,'depth',thisStratumThickness);
    
    % compare to limiting factor if we were to add that new section in full
    flag = totalDepth + thisDepth > value;
    
    if flag
        
        % Limiting factor exceeded! We need to re-trace the appropriate
        % portion of the stratum.
        
        % the last trace section should reach the limiting factor
        lastDepth = value - totalDepth;
        
        % retrace in this stratum using this last result
        [thisRange, thisTime, thisDepth, thisHzdist] = CFF_unit_ray_trace(thisVelocity,thisAngle,mode,lastDepth);
        
    end
    
    % add this full/partial stratum results to total
    totalRange = totalRange + range;
    totalTime = totalTime + time;
    totalDepth = totalDepth + depth;
    totalHzdist = totalHzdist + hzdist;
    
    if ~flag
        % compute next angle
        nextStratum = idS + 1;
        nextVelocity = velocityProfile(nextStratum);
        nextAngle = CFF_snell_law(thisVelocity,nextVelocity,thisAngle);
        
        % udpate variables for next reloop
        thisStratum = nextStratum;
        thisVelocity = nextVelocity;
        thisAngle = nextAngle;
        thisStratumThickness = depthProfile(thisStratum+1) - startDepth;
    end
    
end
