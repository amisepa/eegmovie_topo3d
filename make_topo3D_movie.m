% Make 2D and 3D movies of 64-channel ERP data. 
% Sample data was bandpassed filtered [1 45 Hz] with a minimum-phase causal 
% filter, cleaned, epoched [-200 to 1000 ms], and current-source density
% transformed to increase spatial resolution and local dynamics 
% (i.e. Surface Laplacian).
% 
% Copyright (C) - Cedric Cannard, 2022

clear; close all; clc
eeglab; close;

my_path = 'C:\Users\Tracy\Documents\MATLAB\eegmovie_topo3d'; cd(my_path)

% Load sample data
EEG = pop_loadset('filename','sample_data.set','filepath',my_path);

% Install plugin if not already installed
if ~exist('eegmovie','file')
    plugin_askinstall('eegmovie','eegmovie', 0);
end

% Plot ERP all channels
figure; pop_timtopo(EEG, [-150 900], NaN);

% Keep only the window [-50 to 500 ms] and average across trials
pnts1 = round(eeg_lat2point(-0.05, 1, EEG.srate, [EEG.xmin EEG.xmax]));
pnts2 = round(eeg_lat2point(0.5, 1, EEG.srate, [EEG.xmin EEG.xmax]));
meanERP = mean(EEG.data(:,pnts1:pnts2),3);
% meanERP = mean(EEG.data,3);

% Smooth data
% for iChan = 1:size(meanERP,1)
%     meanERP(iChan,:) = conv(meanERP(iChan,:), ones(1,5)/5, 'same');
% end

% Create 2-D movie
figure; 
[Movie,Colormap] = eegmovie(meanERP, EEG.srate, EEG.chanlocs,'framenum','off', ...
    'timecourse','on','vert',0,'startsec',-0.05,'topoplotopt',{'numcontour' 0});

% play movie
seemovie(Movie,-5,Colormap);

%% 3-D movie

% Use the graphic interface to coregister the head model with electrode positions
headplotparams1 = { 'meshfile','mheadnew.mat','transform', ...
    [0.664455     -3.39403     -14.2521  -0.00241453     0.015519     -1.55584           11      10.1455           12] };
headplotparams2 = { 'meshfile','colin27headmesh.mat','transform', ...
    [0          -13            0          0.1            0        -1.57         11.7         12.5           12] };

headplotparams  = headplotparams2; % switch here between 1 and 2

% set up the spline file
headplot('setup', EEG.chanlocs, 'spline.spl', headplotparams{:}); close
 
% Check scalp topo and head topo
% figure; headplot(meanERP(:,end-50), 'spline.spl', headplotparams{:}, 'maplimits', 'absmax', 'lighting', 'on');
figure('color','w'); 
[Movie,Colormap] = eegmovie(meanERP, EEG.srate,EEG.chanlocs,'framenum','off',...
    'vert',0,'startsec',-0.1,'mode','3d','minmax',0, ...
    'headplotopt',[headplotparams(:)', {'material'}, {'metal'}], 'camerapath', [-127 2 30 0]); 

% Play movie 
seemovie(Movie,-5,Colormap);

% save movie
vidObj = VideoWriter('ERP_video_3D.mp4','MPEG-4');
open(vidObj);
writeVideo(vidObj, Movie);
close(vidObj);
