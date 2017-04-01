function [fData] = CFF_filter_WC_bottom_detect(fData,varargin)
% [fData] = CFF_filter_WC_bottom_detect(fData,varargin)
%
% DESCRIPTION
%
% Filter bottom detection in watercolumn data
%
% INPUT VARIABLES
%
% - varargin{1} "method_bot": method for bottom filtering/processing
%   - 0: None
%   - 1: medfilt2 + inpaint_nans (default)
%   - 2:
%
% OUTPUT VARIABLES
%
% - fData
%
% RESEARCH NOTES
%
% NEW FEATURES
%
% - 2016-12-01: Using the new "X_PB_bottomSample" field in fData rather
% than "b1"
% - 2016-11-07: First version. Code taken from CFF_filter_watercolumn.m
%
%%%
% Alex Schimel, Deakin University
%%%


%% Set methods
method_bot = 1; % default
if nargin==1
    % fData only. keep default
elseif nargin==2
    method_bot = varargin{1};
else
    error('wrong number of input variables')
end


%% MAIN PROCESSING SWITCH
switch method_bot
    
    case 0
        
        % keep input bottom detect. Do nothing
        
    case 1
        
        % Extract needed data
        b0 = fData.X_PB_bottomSample;
        b0(b0==0) = NaN; % repace no detects by NaNs
        nPings = size(b0,1);
        nBeams = size(b0,2);
        
        % Apply a median filter (medfilt1 should do about the same)
        filtSize = 7; % filter width in beams
        fS=ceil((filtSize-1)./2);
        b1 = b0;
        for ii=1:nPings
            for jj = 1+fS:nBeams-fS
                tmp = b0(ii,jj-fS:jj+fS);
                tmp = tmp(~isnan(tmp(:)));
                if ~isempty(tmp)
                    b1(ii,jj) = median(tmp);
                end
            end
        end
        
        % interpolate the result
        b1 = round(CFF_inpaint_nans(b1));
        
        % safeguard against inpaint_nans occasionally yielding numbers
        % below zeros in areas where there are a lot of nans:
        b1(b1<1)=2;
        
        % % test display
        % figure;
        % minb=min([b0(:);b1(:)]); maxb=max([b0(:);b1(:)]);
        % subplot(221); imagesc(b0); colorbar; title('range of raw bottom'); caxis([minb maxb])
        % subplot(222); imagesc(b1); colorbar; title('range of filtered bottom'); caxis([minb maxb])
        % subplot(223); imagesc(b1-b0); colorbar; title('filtered-raw')
        
        % Saving result back in fData
        fData.X_PB_bottomSample = b1;
        
        % Re-processing bottom detect
        fData = CFF_process_WC_bottom_detect(fData);
        
    case 2
        
        % to develop. Adapt Amy's?
        %res = 0.8
        %fData = CFF2_WC_bottom_filter(fData,res);
        
    otherwise
        error('method_bot not recognised')
        
end



