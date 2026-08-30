%%% This script can 
%%% (1) compute weight matrices for approximating the right singular
%%% vectors of color-concept association matrices based on colorometric
%%% properties of the colors both in a hold-one-out fashion and for intact
%%% matrices. 
%%% (2) compute the predicted right singular vectors based on colorimetric
%%% properties
%%% (3) generate dandelion plots for the weights on the first and second
%%% hue harmonics and barplots for the weights on chroma and lightness

%clear all

%%% 1 is holdout, 0 is no holdout
mode = 0;
num_pc = 10;
cc_temp = readmatrix('waterMeanAssoc.csv')
color_coords = cc_temp(:,[4:6]);
color_coords2 = readmatrix('../../data/UW71lab.csv'); %%file with all color coordinates xyy Lab ch
%color_coords2 = color_coords2(:,[4:6]);
col = colorconvert( color_coords, 'Lab', 'D65');


filename_ = strcat('waterMeanAssoc.csv');
targets = readmatrix(filename_);


figure(1);
 
C = cell(40,1); y = cell(40,1);  % 40 = upper bound on number of expts
A = cell(30,1); L = cell(30,1);  % 30 = upper bound on number of models
d = 1;
r=0;
c=0;
l=1;
L_weights=[];
C_weights=[];
r=0;
ndatasets = 1;
C = col;
data = targets(:,2); %%% select the nth right singular vector (out of 8)
ndatasets = 1;

y = data; %%% we are predicting the singular vector values so they are our targets
expt_name = string(1);
On = ones(size(y,1),1); %% intercepts
achrom = zeros(size(y,1),1); %% 
achrom(23:27) = 1;
i=1;
% regressors used (constant, L, 1st harmonic, 2nd harmonic, and Cab)

A{i}=[ On C.L cosd(C.hab) sind(C.hab) cosd(2*C.hab) sind(2*C.hab) C.Cab];

L{i}= 'LChab polar, 2nd'; 
i=i+1;
%% evaluate each model
nmodels = i-1;
[ncolors,nsubjects] = size(y);
% compute weights for this set of regressors.
for i = 1:nmodels
    weights = A{i}\y;
end

cor =  corrcoef(y,(A{1}*weights));

%cors = [cors,cor(1,2)];
%cors(r, c) = cor(1,2);
L_weights = [L_weights,weights(2)];
C_weights = [C_weights,weights(7)];
all_weights = weights;

%% convert weights into dominant hue angles

% hue angle is given by cos and sin. Convert to angle + magnitude
hangle = mod( atan2d( weights(4,:), weights(3,:) ), 360 )';
rho = sqrt(sum(weights(3:4,:).^2,1))';

% same thing for second harmonic. Take angle as well as angle+180.
hangle2 = mod( [ atan2d( weights(6,:), weights(5,:) )'/2;
                 atan2d( weights(6,:), weights(5,:) )'/2 + 180], 360 );
rho2 = sqrt(sum(weights(5:6,:).^2,1))'; rho2 = [rho2;rho2];

% convert hue angles to RGB so we can color the plots.

FIT = colorconvert( [78+14*sind(hangle) 60*ones(nsubjects,1) hangle], 'LChab', 'D65', 'D65' );
[R,G,B] = Lab2RGB( FIT.L, FIT.a, FIT.b );
cols = [R G B];

FIT2 = colorconvert( [78+14*sind(hangle2) 60*ones(2*nsubjects,1) hangle2], 'LChab', 'D65', 'D65' );
[R2,G2,B2] = Lab2RGB( FIT2.L, FIT2.a, FIT2.b );
cols2 = [R2 G2 B2];


predictions = transpose(A{1}*weights)

fig = figure(30);
f_ = subplot(2,1,l);
%plot([-2 2],L_weights, 'Marker','.','MarkerSize',20);
bar(L_weights);
ylim([-0.005 0.005]);
title([strcat('PC',string(1), '\_lightness'),''])
ylabel('Weight')
xlabel('')
xticks('')
hold on;




f_ = subplot(2,1,1+l);
%plot([-2 2],C_weights, 'Marker','.','MarkerSize',20);
bar(C_weights);
ylim([-0.005 0.005]);
title([strcat('PC',string(1), '\_chroma'),''])
ylabel('Weight')
xlabel('')
xticks('')
hold on;



