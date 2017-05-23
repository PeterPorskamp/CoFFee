function Proc = CFF_convert_fabc_to_proc(fData)
% INCOMPLETE
% Proc = CFF_convert_fabc_to_proc(fData)
%
% DESCRIPTION
%
% Convert processed multibeam data from the fabc format to MBProcess "Proc"
%
% PROCESSING SUMMARY
%
% This is a summary of the steps in the processing. DELETE THIS LINE IF UNUSED
%
% REQUIRED INPUT ARGUMENTS
%
% - 'argRequired': description of the first required argument. If several, add after this line.
%
% OPTIONAL INPUT ARGUMENTS
%
% - 'XXX': description of the optional arguments with list of valid values and what they do. DELETE THIS LINE IF UNUSED
%
% PARAMETERS INPUT ARGUMENTS
%
% - 'XXX': description of the optional parameter arguments (name-value pair). DELETE THIS LINE IF UNUSED
%
% OUTPUT VARIABLES
%
% - OUT: description of output variables. DELETE THIS LINE IF UNUSED
%
% RESEARCH NOTES
%
% This describes what features are temporary or needed future developments. DELETE THIS LINE IF UNUSED
%
% NEW FEATURES
%
% YYYY-MM-DD: second version. Describes the update. DELETE THIS LINE IF UNUSED
% YYYY-MM-DD: first version.
%
% EXAMPLES
%
% This section contains examples of valid function calls. DELETE THIS LINE IF UNUSED
%
%%%
% Alex Schimel, Deakin University. CHANGE AUTHOR IF NEEDED.
%%%

% contents of a proc file:
%
% variables organized in beam x ping array
% X: [101x650 double] (easting?)
% Y: [101x650 double] (northing?)
% D: [101x650 double] (Depth. negative)
% Phiall: [101x650 double] (what angle?)
% BSIntall: [101x650 double]
% BSMaxall: [101x650 double]
% ThetaCor: [101x650 double] (incident angle? 0 at nadir, high for outer beams)
% SSCI: [101x650 double]
% SSCE: [101x650 double]
% SSCIcomp: [101x650 double]
% SSCEcomp: [101x650 double]

ADCoord: [26x2 double]
% seems to be easting/northing coordinates

AngleDep: [1x1 struct]
        Angle: [77x1 double]
    Intensity: [77x26 double]
       Energy: [77x26 double]
        

BathyParAll: [1x1 struct]
                DecHours: [1x650 double]
               JulianDay: [1x650 double]
                    Year: [1x650 double]
           SoundVelocity: [1x650 double]
                ShipGyro: [1x650 double]
             FixTimeHour: [1x650 double]
           FixTimeMinute: [1x650 double]
           FixTimeSecond: [1x650 double]
          FixTimeHSecond: [1x650 double]
       SensorYcoordinate: [1x650 double]
       SensorXcoordinate: [1x650 double]
           SensorHeading: [1x650 double]
         AttitudeTimeTag: [1x650 double]
      NavFixMilliseconds: [1x650 double]
             packet_type: [1x650 double]
                 latency: [1x650 double]
                 Seconds: [1x650 double]
            Milliseconds: [1x650 double]
             ping_number: [1x650 double]
                sonar_id: [1x650 double]
             sonar_model: [1x650 double]
               frequency: [1x650 double]
                velocity: [1x650 double]
             sample_rate: [1x650 double]
               ping_rate: [1x650 double]
               range_set: [1x650 double]
                   power: [1x650 double]
                    gain: [1x650 double]
             pulse_width: [1x650 double]
              tvg_spread: [1x650 double]
              tvg_absorp: [1x650 double]
          projector_type: [1x650 double]
    projector_beam_width: [1x650 double]
        beam_spacing_num: [1x650 double]
      beam_spacing_denom: [1x650 double]
               min_range: [1x650 double]
               max_range: [1x650 double]
               min_depth: [1x650 double]
               max_depth: [1x650 double]
          filters_active: [1x650 double]
             temperature: [1x650 double]
              beam_count: [1x650 double]
                 quality: [52x650 uint8]
                checksum: [1x650 uint16]
                     dxb: [101x650 double]
                     dyb: [101x650 double]
        
X = fData.