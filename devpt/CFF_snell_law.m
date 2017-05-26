function [endAngle] = CFF_snell_law(c1,c2,startAngle)
%% CFF_snell_law
%
% Application of Snell-Descartes law to determine angle after refraction.
%
%% Help
%
% *USE*
%
% Supposing two vertical strata of velocity c1 (top) and c2 (bottom), and
% an incident angle in the top strata of angle 'startAngle' in degrees and
% refered to the vertical plane (aka a vertical ray has startAngle = 90),
% this functions computes 
%
% *INPUT VARIABLES*
%
% * |c1|: TODO: write description and info on variable
% * |c2|: TODO: write description and info on variable
% * |startAngle|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |endAngle|: TODO: write description and info on variable
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

if startAngle <= acosd(c1./c2)
    warning('Total reflection. No refraction')
    endAngle = 0;
else
    endAngle = acosd( cosd(startAngle).*c2./c1 );
end