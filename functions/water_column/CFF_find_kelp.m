function kelp = CFF_find_kelp(fData,method,varargin)

% create algorithms to find kelp in the watercolumn here

% method:
%   0: per ping basis
%   1: per horizontal slice

% set the parameters here in varagin
% V = varargin{1};


% basic info on dataset
nPings = size(fData.WC_PBS_SampleAmplitudes,1);
nBeams = size(fData.WC_PBS_SampleAmplitudes,2);
nSamples = size(fData.WC_PBS_SampleAmplitudes,3);

switch method
    
    %% per ping basis. In development....
    case 0
        
        for ii = 1:nPings
            
            % get data
            D = reshape(fData.X_PBS_L1(ii,:,:),nBeams,nSamples);
            sampleUpDist     = reshape(fData.X_PBS_sampleUpDist(ii,:,:),nBeams,nSamples);
            sampleAcrossDist = reshape(fData.X_PBS_sampleAcrossDist(ii,:,:),nBeams,nSamples);
            
            % turn data from dB to natural
            D = exp(D./20);
            
            % test matrices:
            % D=[1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15; 16 17 18 19 20; 21 22 23 24 25];
            % D = rand(5);
            
            % finding local 2D maxima (data points with more amplitude than
            % their direct 8 neighbors)
            % XXX: change this to use extrema2
            
            D1 = D(1:end-2,1:end-2);
            D2 = D(1:end-2,2:end-1);
            D3 = D(1:end-2,3:end);
            
            D4 = D(2:end-1,1:end-2);
            M  = D(2:end-1,2:end-1);
            D5 = D(2:end-1,3:end);
            
            D6 = D(3:end,1:end-2);
            D7 = D(3:end,2:end-1);
            D8 = D(3:end,3:end);
            
            N1 = M>D1 & M>D2 & M>D3 & M>D4 & M>D5 & M>D6 & M>D7 & M>D8;
            N = zeros(size(D));
            N(2:end-1,2:end-1) = N1;
            
            Seeds = logical(N);
            SeedsAmplitude = D(Seeds);
            SeedsDownDist = sampleUpDist(Seeds);
            SeedsAcrossDist = sampleAcrossDist(Seeds);
            
            % next step:
            % Compute combined amplitude and distances between each pair of seeds
            [X,Y]=meshgrid(SeedsAmplitude',SeedsAmplitude);
            CombAmplitude=X+Y;
            [X,Y]=meshgrid(SeedsDownDist',SeedsDownDist);
            CombDownDist=X-Y;
            [X,Y]=meshgrid(SeedsAcrossDist',SeedsAcrossDist);
            CombAcrossDist=X-Y;
            
            % combined amplitude, vertical and horizontal distances are
            % going to be used as criteria. Map these values to a 0 (bad)
            % to 1 (good) coefficient range. We need three parameters for
            % each mapping:
            % - the min value that is associated with 0
            % - the max value that is associated with 1
            % - the function that is mapped onto [0-1]
            
            m = min(CombAmplitude(:));
            M = max(D(:));
            NormCombAmplitude = (CombAmplitude-m)./(M-m);
            
            m = 1; % any vertical distance >= 3m is associated a coeff of 0
            M = 0;
            NormCombDownDist = (abs(CombDownDist)-m)./(M-m);
            NormCombDownDist = min(1,max(0,NormCombDownDist));
            
            m = 0.1; % any horizontal distance >= 0.5m is associated a coeff of 0
            M = 0;
            NormCombAcrossDist = (abs(CombAcrossDist)-m)./(M-m);
            NormCombAcrossDist = min(1,max(0,NormCombAcrossDist));
            
            % combine all criteria:
            Crit = NormCombAmplitude .* NormCombDownDist .* NormCombAcrossDist;
            
            % remove diagonal and the lower half
            Crit = triu(Crit,1);
            [i,j,s] = find(Crit);
            M = [i,j,s];
            M = sortrows(M,-3);
            
            % threshold on full criteria
            thres = 0.2;
            M = M(M(:,3)>thres,:);
            
            % M now holds the indices of the point that have high coeff
            % (ie: high combined amplitude, low distances)
            
            % display
            cla
            pcolor(sampleAcrossDist,sampleUpDist,20.*log10(D));
            colorbar
            shading interp
            hold on
            grid on
            axis equal
            
            hold on
            for jj = 1:size(M,1)
                plot(SeedsAcrossDist(M(jj,1:2)),SeedsDownDist(M(jj,1:2)),'k.-')
            end
            drawnow
            
            % but the idea would really be to "grow" those links
            % recursively. Giving more weight to points which grow
            % linearly... Let's give up this method for now and concentrate
            % on the other one
            
        end
        
        %% per horizontal slice
    case 1
        
        % parameters:
        res = 0.1;  % grid resolution (in m) in the gridding of water column data
        V = -70; % BS level threshold for a local maxima to be considered a man
        thresh = 2; % distance thershold (in grid units) for two men to be considered in a same commapny
        N = 5;     % minimum length of company to be considered kelp
        
        
        %         % all samples too close to sonar head, at outer beams, or under the
        %         % bottom were removed during filtering. Now complete by removing
        %         % samples outside the forest plant?
        %         % - outside a 3m radius arond the horizontal center of the plot?
        %
        %         % get data
        %         PBS_L1 = fData.X_PBS_L1;
        %         PBS_sampleEasting = fData.X_PBS_sampleEasting;
        %         PBS_sampleNorthing = fData.X_PBS_sampleNorthing;
        %
        %         % plot center:
        %         kelpE=629556;
        %         kelpN=5748652;
        %         kelpRadius=5;
        %
        %         % build mask: 1: to conserve, 0: to remove
        %         PBS_distFromKelp = sqrt((PBS_sampleEasting-kelpE).^2 + (PBS_sampleNorthing-kelpN).^2);
        %         PBS_Mask = double(PBS_distFromKelp<=kelpRadius);
        %         PBS_Mask(PBS_Mask==0) = NaN;
        %
        %         % apply mask
        %         fData.X_PBS_L2 = fData.X_PBS_L1.* PBS_Mask;
        
        % for now, stay with L1, ie all data
        
        % step 1. grid water column data
        Lfield = 'X_PBS_L1'; % L2?
        [gridEasting,gridNorthing,gridHeight,gridLevel,gridDensity] = CFF_grid_watercolumn(fData,Lfield,res);
        
        
        %                 % display the gridded data only:
        %                 HH = figure;
        %                 caxismin = min(gridLevel(:));
        %                 caxismax = max(gridLevel(:));
        %                 for kk=1:length(gridHeight)-1
        %                     cla
        %                     xy = gridLevel(:,:,kk);
        %                     h = imagesc(xy);
        %                     %set(h,'alphadata',~isnan(xy))
        %                     set(gca,'Ydir','normal')
        %                     colorbar
        %                     title(sprintf('slice %i/%i: %.2f m',kk,length(gridHeight)-1,gridHeight(kk)))
        %                     caxis([caxismin caxismax])
        %                     grid on
        %                     axis square
        %                     axis equal
        %                     axis tight
        %                     drawnow
        %                 end
        %
        % % other quick display:
        % for ii = 50:120
        %     imagesc(exp(gridLevel(:,:,ii)./20))
        %     axis(x)
        %     caxis([0 0.7])
        %     colorbar
        %     drawnow
        %     pause(0.2)
        % end
        
        % step 2. detect the local maxima above a threshold ("men", after backgammon)
        
        % define the threshold for detection
        
        % V = CFF_invpercentile(gridLevel,99); % 99th percentile in the data? fix the percentile as parameter?
        
        % initialize detect points. 4 columns table:
        % 1. Index in gridNorthing
        % 2. Index in gridEasting
        % 3. Index in gridHeight
        % 4. Level
        numCells = sum(~isnan(gridLevel(:)));
        men = nan( floor(numCells./4) , 4);
        
        % now find men
        mm = 0; % men counter
        for kk = 1:length(gridHeight)-1 % repeat for each slice
            
            % save slice temporarily
            xy = gridLevel(:,:,kk);
            
            % find grid cells that have a higher amplitude than neighboring 8 cells
            [xymax,smax] = extrema2(xy);
            
            % retain only those above threshold
            if ~isempty(smax)
                
                ind = find(xymax>V);
                xymax = xymax(ind);
                smax = smax(ind);
                [iN,iE] = ind2sub(size(xy),smax);
                
                % new men
                newmen = [ iN , iE , ones(length(iE),1).*kk , xymax ];
                
                % add to full list
                men(mm+1:mm+length(xymax),:) = newmen;
                mm = mm+length(xymax);
                
            end
            
        end
        
        % remove extra nan rows
        men(isnan(men(:,1)),:) = [];
        
        % display gridded data and men
        clear F;
        HH = figure;
        caxismin = min(gridLevel(:));
        caxismax = max(gridLevel(:));
        for kk=1:length(gridHeight)-1
            cla;
            xy = gridLevel(:,:,kk);
            h = imagesc(xy);
            %set(h,'alphadata',~isnan(xy))
            set(gca,'Ydir','normal');
            % find men to plot
            ind =(men(:,3)==kk);
            hold on;
            plot(men(ind,2),men(ind,1),'ko')
            colorbar;
            title(sprintf('slice %i/%i: %.2f m',kk,length(gridHeight)-1,gridHeight(kk)))
            caxis([caxismin caxismax]);
            grid on;
            axis square;
            axis equal;
            axis tight;
            drawnow;
            F(kk)=getframe(HH);
        end
        
        
        % step 3. arrange men into companies
        
        % Add a column for "company", ie links of men across severall floor levels.
        % Each man its own company to start with.
        % 1. Index in gridNorthing
        % 2. Index in gridEasting
        % 3. Index in gridHeight
        % 4. Level
        % 5. company
        men(:,5) = [1:size(men,1)]';
        
        % now grow companies
        
        
        %% OPTION 1
        
        % IN DVPT
        
        % trying to improve on the old one above by searching for additional floors
        thresh = 1.5;
        
        % Men are sorted by ascending floor and descending BS level so we're going
        % to go through them ALL, one at a time
        
        for kk = 1:size(men,1)
            
            kk
            
            % find all men at the three next floors above
            ifloorplus = find(men(:,3)>men(kk,3) & men(:,3)<men(kk,3)+4); % men(ifloorplus,:)
            
            % compute horizontal distance between this man and men on next
            % floor
            tt = repmat(men(kk,1:2),length(ifloorplus),1);
            sdist = sqrt(sum((tt - men(ifloorplus,1:2)).^2,2));
            
            % keep only those under thresh
            ifloorplus = ifloorplus(sdist<thresh); % men(ifloorplus,:)
            
            
            if size(ifloorplus,1) == 0
                % if there is none, reloop to next man
                continue
                
            elseif size(ifloorplus,1) == 1
                % if there is one, add to company
                
                % we mean that this man:
                % men(ifloorplus,:)
                % should join the company of this man:
                % men(kk,:)
                men(ifloorplus,5) = men(kk,5);
                
            elseif size(ifloorplus,1) > 1
                % if there is more than one
                
                % retain the ones at the lowest floor
                ifloorplus = ifloorplus(men(ifloorplus,3) == min( men(ifloorplus,3) ));
                
                if size(ifloorplus,1) == 1
                    % if there is only one, add to company
                    men(ifloorplus,5) = men(kk,5);
                elseif size(ifloorplus,1) > 1
                    
                    % if there is more than one, rank by horizontal distance
                    tt = repmat(men(kk,1:2),length(ifloorplus),1);
                    sdist = sqrt(sum((tt - men(ifloorplus,1:2)).^2,2));
                    
                    % take the lowest distance
                    ifloorplus = ifloorplus(sdist == min(sdist));
                    
                    if size(ifloorplus,1) == 1
                        % if there is only one, add to company
                        men(ifloorplus,5) = men(kk,5);
                    elseif size(ifloorplus,1) > 1
                        % if there are more than one, rank by BS level
                        
                        % take the strongest
                        ifloorplus = ifloorplus(men(ifloorplus,4) == max(men(ifloorplus,4)));
                        
                        if size(ifloorplus,1) == 1
                            % if there is only one, add to company
                            men(ifloorplus,5) = men(kk,5);
                        elseif size(ifloorplus,1) > 1
                            % if there are more than one, take the first one
                            ifloorplus = ifloorplus(1);
                        end
                    end
                end
            end
        end
        
        
        
        
        
        
        %         %% OPTION 2
        %
        %         %minkk = min(men(:,3));
        %         %maxkk = max(men(:,3))-1;
        %         for kk = 1:length(gridHeight)-1 % minkk:maxkk
        %
        %             % for each floor, find all men at this floor and at floor
        %             % above.
        %             ifloor = find(men(:,3)==kk); % men(ifloor,:)
        %             ifloorplus = find(men(:,3)==kk+1); % men(ifloorplus,:)
        %
        %             % Men are sorted by ascending floor and descending level.
        %             % For each man at current floor, starting with the highest
        %             % level...
        %             for pp = 1:length(ifloor)
        %
        %                 % men(ifloor(pp),:)
        %
        %                 % calculate distance between this man and all men on above
        %                 % floor (distance measured in cell units)
        %                 tt = repmat(men(ifloor(pp),1:2),length(ifloorplus),1);
        %                 sdist = sqrt(sum((tt - men(ifloorplus,1:2)).^2,2));
        %                 [a,b] = min(sdist);
        %
        %                 % if minimum distance is below threshold, associate man
        %                 % from above floor to company of this man. Note on the
        %                 % threshold: because we're measuring distance between a man
        %                 % at floor N and men at floor N+1, the minimum distance
        %                 % achievable is exactly 1 grid unit. A man on one of the
        %                 % fourth closest cells exactly above will be sqrt(2)=1.41
        %                 % units away. On the diagonals: sqrt(3)=1.73. On the next
        %                 % in line: sqrt(5)=2.23. Next, sqrt(6)=2.49... So if one
        %                 % sets a threshold of 2 for example, we mean companies can
        %                 % only grow if a man is found within the 8 closest
        %                 % neighbours...
        %
        %                 if a<thresh
        %
        %                     % we mean that this man:
        %                     % men(ifloorplus(b),:)
        %                     % should join the company of this man:
        %                     % men(ifloor(pp),:)
        %                     men(ifloorplus(b),5) = men(ifloor(pp),5);
        %
        %                     % we remove this man from the list of men at upper
        %                     % floor so that they cannot be associated with another
        %                     % company.
        %                     ifloorplus(b)=[];
        %
        %                 end
        %
        %                 % possible other development: if we can't find a man at
        %                 % upper floor to link with, maybe find the cell with
        %                 % highest level in the 8-neighborhood above?
        %                 % bing = men(ifloor(pp),1:2);
        %                 % remy = gridLevel(bing(1)-1:bing(1)+1,bing(2)-1:bing(2)+1,kk+1);
        %
        %             end
        %
        %         end
        
        
        
        % next, remove all companies that don't have at least N men
        N = 20;
        men2 = men;
        men2 = sortrows(men2,5); % sort according to company #
        [c,ia] = unique(men2(:,5)); % get unique company numbers and the index of each first man in a company
        ind = diff(ia)>=N; % because everything is ordered by company, find where first man is separate from next one by more than 5.
        Lia = ismember(men2(:,5),c(ind));
        men2 = men2(Lia,:);
        
        
                
        % display gridded data and men
        clear F
        HH = figure
        figure
        caxismin = min(gridLevel(:));
        caxismax = max(gridLevel(:));
        for kk=1:length(gridHeight)-1
            cla
            xy = gridLevel(:,:,kk);
            h = imagesc(xy);
            %set(h,'alphadata',~isnan(xy))
            set(gca,'Ydir','normal')
            % find men to plot
            ind =(men2(:,3)==kk);
            hold on
            plot(men2(ind,2),men2(ind,1),'ko')
            colorbar
            title(sprintf('slice %i/%i: %.2f m',kk,length(gridHeight)-1,gridHeight(kk)))
            caxis([caxismin caxismax])
            grid on
            axis square
            axis equal
            axis tight
            drawnow
            F(kk)=getframe(HH);
        end
        
        
        % display the men only
        HHH = figure;
        M = sortrows(men2,5);
        % sum levels per company:
        C = unique(M(:,5));
        sumlevel=nan(size(C));
        for bb = 1:length(C)
            sumlevel(bb) = sum( M(M(:,5)==C(bb),4));
        end
        C = [C,sumlevel];
        C = sortrows(C,-2);
        cols = ['ymcrgbk'];
        for bb = 1:size(C,1)
            ind = find(M(:,5)==C(bb));
            plot3(M(ind,1),M(ind,2),M(ind,3),'.-','Color',cols(mod(bb,7)+1))
            hold on
            axis tight
            axis equal
            grid on
        end
        
        % rotating view for 3D display
        for ii=1:360
            view(ii,45)
            pause(0.1)
            drawnow
        end
        ylabel('Northing (cm)')
        zlabel('Height (cm)')
        xlabel('Easting (cm)')
        
        
        
        kelp = [gridEasting(1,men2(:,2))', gridNorthing(men2(:,1),1), gridHeight(men2(:,3))', men2(:,4:5)];
        
        % find the closest ping/beam/sample to assoicate each kelp point to
        kelp(:,4:6) = CFF_XYZtoPBS(fData,kelp(:,1:3));
        
        CFF_watercolumn_display(fData,'data','L1','displayType','flat','bottomDetectDisplay','yes','waterColumnTargets',kelp);
        CFF_watercolumn_display(fData,'data','L1','displayType','wedge','bottomDetectDisplay','yes','waterColumnTargets',kelp);
        
        
    otherwise
        
        error
end