function [end_angle] = CFF_snell_law(start_velocity,end_velocity,start_angle)
%% CFF_snell_law
%
% Application of Snell-Descartes law to determine angle after refraction.
%
%% Help
%
% *USE*
%
% Supposing two vertical strata of velocity start_velocity (top) and
% end_velocity (bottom), and an incident angle in the top strata of angle
% 'start_angle' in degrees refered to the horizontal plane (aka a an
% incident ray that is vertical would have start_angle = 90), this
% functions computes the angle in the bottom strata after refraction.
%
% Note, if total reflection occurs, output end_angle is zero.
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
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-06-01: first version (Alex Schimel)
%
% *EXAMPLE*
%
% c1 = 1500;
% c2 = 1600;
% startAngle = 70; 
% endAngle = CFF_snell_law(c1,c2,startAngle)
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Alexandre Schimel, NIWA.

if start_angle <= acosd(start_velocity./end_velocity)
    warning('Total reflection. No refraction')
    end_angle = 0;
else
    end_angle = acosd( cosd(start_angle).*end_velocity./start_velocity );
end