function T = CFF_rotate_frame(roll, pitch, yaw)


% PRELIMINARY NOTES:
% - All frames in the following are following right-hand convention (XYZ).
% - All angles are measured from an axis to the vector of interest,
% following the right-hand conventions for rotations (i.e. positive X
% towards Y, Y towards Z and Z towards X). 
% - All angles are in degrees and will be stored in data in degrees. To be
% used in trigonometric equations, they will be converted on the spot in
% radians and appended with the suffix "_rad" 
%
% FRAMES OF REFERENCE:
%
% Consider the sonar frame:
% reference: center of sonar face
% S_X: sonar forward
% S_Y: sonar right
% S_Z: acoustic axis, also known as broadside, normal to the sonar face
% plane XY

% a sounding is referenced originally in the sonar frame, either in
% cartesian (x,y,z), polar () or spherical ().

% To compute a sounding position, the sonar needs to do ray bending but to
% do that it needs to figure out the launch angle to the vertical. So we
% need to change frame. 
% 
%
% the next frame will be that of the vessel
% reference: center of sonar face
% V_X: vessel forward axis (aft to bow)
% V_Y: vessel starboard axis
% V_Z: vessel down axis (NOT vertical)

% to go from S to V, one includes the sonar setup angles

% the next frame will be that of the LEVELED vessel, that is, picturing the
% sonar centre still at the same place, the frame tha twould be the
% vessel's if there was no roll or pitch

% L_X / AlongTrackDistReSonar: along the vessel track
% L_Y / AcrossTrackDistReSonar: to the right of the vessel track
% L_Z / DownDistReSonar: vertical down

% to go from V to L, we include the roll and pitch angle.

% finally the final frame simply rotate the previous along the vertical
% axis to line it up with the Grid north. It's is the geographical frame

% G_X / North
% G_Y / East
% G_Z / Down

% ray bending can be done in the L or G frame regardless, since water is
% vertically stratified and the Z axis is the same in both frames

% How do we get a vector with coordinates in the S frame known
% (X_S,Y_S,Z_S) into the V frame? We need rotation matrices

% Consider a vessel rolling by 10 degrees (positive port up, Y->Z) and a
% sonar setup so that the roll offset is 10 degrees (positive when left
% handside of the sonar goes up, Y -> Z). Then the total roll angle is 20
% degrees. The angle that goes from Z_V back to Z_S is -20 degrees.


% rotation matrices for frame transformation. Ie, to calculate the
% coordiantes (x',y',z') of a point M in a frame F' when its coordinates
% (x,y,z) in a frame F are known.

% get the vessel motion here
roll_mov = 45;
pitch_mov = ;
yaw_mov = 0;

% and the sonar setup here
roll_setup = 
pitch_setup = ;
yaw_setup = ;

alpha_rad = (-roll_mov - roll_setup).*pi./180;
beta_rad  = (-pitch_mov - pitch_setup).*pi./180;
gamma_rad = (-yaw_mov - yaw_setup).*pi./180;

%% definition of rotation matrices

% considering a X,Y,Z frame following the right-hand rule convention:
% * an angle theta about the Z axis is positive from X towards Y 
% * an angle theta about the X axis is positive from Y towards Z 
% * an angle theta about the Y axis is positive from Z towards X 

% the matrices for the rotation of the FRAME about each axis
% are:

% rotation about the X axis
Rx = @(theta) [ [ 1       0           0      ]; ...
                [ 0   cos(theta) sin(theta) ]; ...
                [ 0  -sin(theta) cos(theta) ] ];     

% rotation about the Y axis
Ry = @(theta) [ [ cos(theta) 0 -sin(theta) ]; ...
              [        0     1     0       ]; ...
              [   sin(theta) 0  cos(theta) ] ]; 

% rotation about the Z axis
Rz = @(theta) [ [ cos(theta) sin(theta) 0 ]; ...
              [  -sin(theta) cos(theta) 0 ]; ...
              [      0           0      1 ] ];     

% and the full frame transformation is given by:
T = @(alpha,beta,gamma) Rz(alpha)*Ry(beta)*Rx(gamma);   

% let's run some examples:
% a point on the X axis should not change coordinates when rotating the
% frame around the X axis.
M  = [1;0;0];
M2 = Rx(pi/3)*M
M2 = Rx(pi)*M
M2 = Rx(9000)*M

% likewise a point on the Z axis for a rotation around Z, or a a point on
% the Y axis for a rotation around Y:
Ry(9000)*[0;9;0]
Rz(-435)*[0;0;2713]

% let's try something barely more complex: a point on the Y axis and a
% rotation about the Z axis of +90deg should find itself with the same
% coordinate but on the new X axis 
Rz(pi/2)*[0;1;0]

% equivalent results should be obtained for:
% a point on the Z axis and a rotation about the X axis of +90deg, should
% fint itself on Y
Rx(pi/2)*[0;0;1]
% a point on the X axis and a rotation about the Y axis of +90deg, should
% fint itself on Z
Ry(pi/2)*[1;0;0]

% last of the basic tests: a point in the XY plane at 45 deg between X and
% Y, should, after a rotation of the frame about the Z axis of 180 deg find
% itself at the same coordinates but in -X and -Y
Rz(pi)*[3;3;0]


%% APPLICATIONS IN OUR CASE

% considering a sounding in the sonar frame described above, defined by
% its being at a 10m range at a beam pointing angle of +45 degrees (on
% starboard side):
range = [10 10 10 10 10];
beamPointingAngle = [90 45 0 -45 -90];
beamPointingAngleRad = beamPointingAngle.*pi./180;

% its cartesian coordinates in the sonar frame are:
[sonarAxis,sonarStarboard,sonarForward] = pol2cart(beamPointingAngleRad,range,0)

% Let's rewrite it in the form of a function

    function [sonarForward,sonarStarboard,sonarAxis] = rangeAndBeamAngle_to_sonarFwdStbAx(beamPointingAngle,range)
        
        
        
        sonarForward = zeros(size(range));
        sonarStarboard = range.*sin(beamPointingAngle.*pi./180);
        sonarAxis = range.*cos(beamPointingAngle.*pi./180);
        
        
        % tilt is a positive rotation of coordinates about the Y axis
        Rtilt = @(theta) [ [ cos(theta.*pi./180) 0 sin(theta.*pi./180) ]; ...
                         [        0     1     0       ]; ...
                         [   -sin(theta.*pi./180) 0  cos(theta.*pi./180) ] ];
        
        % beam pointing is a negative rotation of coordinates about the
        % X axis
        Rbeam = @(theta) [ [ 1               0                    0       ]; ...
                           [ 0   cos(-theta.*pi./180) -sin(-theta.*pi./180) ]; ...
                           [ 0   sin(-theta.*pi./180)  cos(-theta.*pi./180) ] ];    
        
        
        % the original sounding is just range on the acoustic axis, which
        % is Z:
        M = [0;0;10];
        % beam steering with no tilt:
        Rbeam(0)*M
        Rbeam(45)*M
        Rbeam(60)*M
        Rbeam(90)*M
        Rbeam(-60)*M
        % tilting with no beam steering:
        Rtilt(0)*M
        Rtilt(45)*M
        Rtilt(60)*M
        Rtilt(90)*M
        Rtilt(-60)*M
        
        % steering and tilting:
        Rtilt(45)*Rbeam(45)*M
        Rbeam(45)*Rtilt(45)*M
        
        test = @(theta) Rbeam(ii)*Rtilt(10)*M;
        
        kk=0;
        for ii=-90:1:90
            kk=kk+1;
            M2(:,kk)=Rtilt(10)*Rbeam(ii)*M;
        end

        
        
        
        
        
    end







% so imagine a point that was measured 10m in the acoustic axis of the sonar:
M=[0;0;10];

% its position in the vessel frame is actually:
T*M
% -7m on the acrosstrack axis a 7m on the vertical axis

% imagine a vessel pitching (nose up) by 45 deg, the result is 
% 7m on the along track axis, 7m on the vertical

end