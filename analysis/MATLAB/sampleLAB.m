function [lab, rgb, xyY] = sampleLAB(delta, delta_2, rot, onlyL)
    % sampleLAB(delta,rot): Generates a grid of points uniformly spaced in LAB space 
    % which can be mapped to RGB space.
    % Input : delta, rot
    % Output : Nx3 matrix of coordinates in xyY space.
    
    clc;
    % Generate delta spaced points for L (0-100),a(-100 to 100) and b (-100 to 100)
    L = 0:delta:100 ;% length = N
    a = [0-delta:-delta:-100*sqrt(2) 0:delta:100*sqrt(2)];
    
    %b = a;
    
    %L2 = 0:delta_2:100 ;% length = N
    L2 = 88;
    a2 = [0-delta_2:-delta_2:-100*sqrt(2) 0:delta_2:100*sqrt(2)];
    %b2 = a2;
    
%     for i = 1:length(L2)
%        if L2(i)>max(L) || L2(i)<min(L)
%           L= [L,L2(i)];   
%        end
%      end


    for i = 1:length(L2)
       if L2(i)>75 || L2(i)<25
          if ~ismember(L2(i), L)
             L = [L,L2(i)];   
          end
       end
     end


% if onlyL==false
    display('check')
    for i = 1:length(a2)
        if a2(i)>65 || a2(i)<-65
            a = [a,a2(i)];   
        end
    end
% end
a = unique(a);
b = a;

    
 

    lab = (combvec(L,a,b))';
    
    size(lab)
    
    
    labOrig = lab; 
    lab = lab * [ 1 0 0; 0 cosd(rot) sind(rot); 0 -sind(rot) cosd(rot)];
%     Plot
    figure (1) 
    subplot(1,2,1);set(gcf, 'Position', get(0, 'Screensize'));
%     scatter3(lab(:,2),lab(:,3),lab(:,1),1,'k');
%     hold on;
    
    % Every row of the matrix 'lab' is a point in the color space
    % Validate coordinates to exist in RGB space
    %lab = [lab; ]
    rgb = lab2rgb(lab);
    [row,~] = find(rgb > 1+eps | rgb < 0-eps);
    indices = unique(row);
    
    % Get rid of coordinates which do not exist in RGB space
    rgb(indices,:) = [] ;
    lab(indices,:) = [];
    labOrig(indices,:) = [];
    

    % Plot the selected points
    patch([100 100 -100 -100],[-100 100 100 -100],[87.5,87.5,87.5,87.5],'yellow','LineStyle','--','FaceAlpha',.2,'EdgeColor','black')
    
    scatter3(lab(:,2),lab(:,3),lab(:,1),50,rgb,'filled','MarkerEdgeColor','black');
    
%     scatter3(lab(lab(:,1)<88,2),lab(lab(:,1)<88,3),lab(lab(:,1)<88,1),50,rgb(lab(:,1)<88,:),'filled','MarkerEdgeColor','black','MarkerFaceAlpha',.2);
%     hold on
%     scatter3(lab(lab(:,1)>=88,2),lab(lab(:,1)>=88,3),lab(lab(:,1)>=88,1),50,rgb(lab(:,1)>=88,:),'filled','MarkerEdgeColor','black');
%     hold off
    daspect([1 1 1]); axis([-100 100 -100 100 0 100]); grid on;
    patch([100 100 -100 -100],[-100 100 100 -100],[87.5,87.5,87.5,87.5],'yellow','LineStyle','--','FaceAlpha',.2,'EdgeColor','black')
    title(['LAB space with uniformly distributed points for \delta = ',num2str(delta),' \delta 2 =',num2str(delta_2)]);
%     for i = 1: length(lab)
%         text(lab(i,2)+2,lab(i,3)+2,lab(i,1)+2,num2str(i));
%     end
    %legend(["Uniformly distributed points","Selected points existing in RBG space"],'Location','southeast');
    xlabel('a');ylabel('b'); zlabel('L');
    hold off;
    
    % Convert Lab to xyY
    out = colorconvert(lab,'Lab','D65');
    xyY = [out.x out.y out.Y];
    
    
    
    % Plot colors in xyY space
    subplot(1,2,2);set(gcf, 'Position', get(0, 'Screensize'));
    scatter3(xyY(:,1),xyY(:,2),xyY(:,3),70,rgb,'filled','MarkerEdgeColor',[0 0 0]);
    axis([0 1 0 1 0 100]); daspect([0.1 0.1 10]);
    title(['Selected colors in xyY space for \delta = ',num2str(delta),' \delta 2 =',num2str(delta_2)]);
    xlabel('x');ylabel('y'); zlabel('Y');
    txt = ['# Colors: ',num2str(length(rgb(:,1)))];
    col = length(rgb(:,1));
    text(-100,100,0,txt);
    % Save figure
     %savefig(strcat('fig_delta_',num2str(delta),'_',num2str(delta_2),'.fig'));
     
     %savefig(strcat('88Lightness_fig_delta',num2str(delta),'_',num2str(delta_2),'.fig'));
     %csvwrite('88Lab.csv',lab)
     %csvwrite('88RGB.csv',rgb)
     %csvwrite('88xyY.csv',xyY)
%     csvwrite('LabOrig.csv',labOrig)
    
%% FIGURE FROM DIFFERENT ANGLES
    figure (2)
    hold on
    subplot(1,3,1)
    scatter(lab(:,2),lab(:,3),65,rgb,'filled','MarkerEdgeColor','none');
    xlim([-110 110])
    ylim([-110 110])
    daspect([1,1,1])
    xlabel('a*')
    ylabel('b*')
    set(gca,'Color',[.3 .3 .3])
 

    grid on
    
    subplot(1,3,2)
    scatter(lab(:,3),lab(:,1),65,rgb,'filled','MarkerEdgeColor','none');
    xlim([-110 110])
    ylim([-10 110])
    daspect([1,1,1])
    xlabel('b*')
    ylabel('L*')
    set(gca,'Color',[.3 .3 .3])
    grid on
    
    subplot(1,3,3)
    scatter(lab(:,2),lab(:,1),65,rgb,'filled','MarkerEdgeColor','none');
    xlim([-110 110])
    ylim([-10 110])
    daspect([1,1,1])
    xlabel('a*')
    ylabel('L*')
    set(gca,'Color',[.3 .3 .3])
    grid on
    

  
    
    
end