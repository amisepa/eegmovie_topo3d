
clear; close all; clc;
folder = 'G:\My Drive\BIAL_documentary\mediumship';
cd(folder); eeglab; close;

%% clean file and resave

% EEG = pop_loadset('filename','FT104.1_channel1.set','filepath', 'G:\Shared drives\Grants\Post Award Grants\(736) Bial Full-trance 2017\Research\Data\EEG\FTC_EEG\FT104');
EEG = pop_loadset('filename','MD01_ERP.set','filepath', 'G:\Shared drives\Grants\Post Award Grants\CLOSED PROJECTS\(737) Bial Mediumship 2017\Research\Data\MD_EEG\MD01');
for iEpoch = 1:size(EEG.data,3)
    epoch_sd(iEpoch) = mean(std(EEG.data(:,:,iEpoch)));
end
bad_epochs = epoch_sd > mean(epoch_sd.*2);
EEG = pop_rejepoch(EEG,find(bad_epochs),0); 
EEG = csd_transform(EEG);
% data_rank = sum(eig(cov(double(EEG.data(:,:)'))) > 1E-7);
% EEG = eeg_checkset(EEG);
% EEG = pop_runica(EEG,'icatype','runica','extended',1,'pca',-(EEG.nbchan-data_rank));
% EEG = pop_iclabel(EEG,'default');
% EEG = pop_icflag(EEG, [NaN NaN; .9 1; .9 1; .9 1; .9 1; .9 1; NaN NaN]); %brain; muscle; eye; heart; line noise; channel noise; other
% bad_ic = find(EEG.reject.gcompreject)   %tag bad components
% pop_selectcomps(EEG, 1:30);
% EEG = pop_subcomp(EEG, bad_ic);         %remove bad components from data
% EEG = eeg_checkset(EEG);
% oriEEG = pop_biosig('G:\Shared drives\Grants\Post Award Grants\(736) Bial Full-trance 2017\Research\Data\EEG\BDF_files\subj04_1.bdf');
oriEEG = pop_biosig('G:\Shared drives\Grants\Post Award Grants\CLOSED PROJECTS\(737) Bial Mediumship 2017\Research\Data\MD_EEG\MD01\MD01.bdf');
oriEEG = pop_select(oriEEG,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8','GSR1','GSR2','Erg1','Erg2','Resp','Plet','Temp'});
oriEEG = pop_chanedit(oriEEG,'lookup','C:\\Users\\IONSLAB\\Documents\\MATLAB\\eeglab\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc');
EEG = pop_interp(EEG, oriEEG.chanlocs, 'spherical');
EEG = eeg_checkset(EEG);
% EEG = eeg_regepochs(EEG);
figure; pop_timtopo(EEG, [-300 1000], NaN);
EEG = pop_saveset(EEG,'data_mediumship.set');

%% Simple 2-D movie

% Above, convert latencies in ms to data point indices
pnts1 = round(eeg_lat2point(-150/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
pnts2 = round(eeg_lat2point(750/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
scalpERP = mean(EEG.data(:,pnts1:pnts2),3);

% Smooth data
for iChan = 1:size(scalpERP,1)
    scalpERP(iChan,:) = conv(scalpERP(iChan,:), ones(1,5)/5, 'same');
end

% % 2-D movie
% figure; 
% [Movie,Colormap] = eegmovie(scalpERP, EEG.srate, EEG.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.5, 'topoplotopt', {'numcontour' 0});
% seemovie(Movie,-5,Colormap);

% 3-D movie
% Use the graphic interface to coregister the head model with electrode positions
headplotparams1 = { 'meshfile','mheadnew.mat','transform', ...
    [0.664455     -3.39403     -14.2521  -0.00241453     0.015519     -1.55584           11      10.1455           12] };
headplotparams2 = { 'meshfile','colin27headmesh.mat','transform', ...
    [0          -13            0          0.1            0        -1.57         11.7         12.5           12] };
headplotparams  = headplotparams1; % switch here between 1 and 2

% set up the spline file
headplot('setup', EEG.chanlocs, 'STUDY_headplot.spl', headplotparams{:}); close
 
% check scalp topo and head topo
% figure; headplot(scalpERP(:,end-50), 'STUDY_headplot.spl', headplotparams{:}, 'maplimits', 'absmax', 'lighting', 'on');
% figure; topoplot(scalpERP(:,end-50), EEG.chanlocs);
figure('color', 'k'); %set(gca,'Color','k')
[Movie,Colormap] = eegmovie(scalpERP, EEG.srate,EEG.chanlocs,'framenum','off',...
    'vert',0,'startsec',0.1,'mode','3d','headplotopt',{headplotparams{:}, 'material', 'metal'}, ...
    'camerapath', [-127 2 30 0]); 
% seemovie(Movie,-5,Colormap);

% save movie
vidObj = VideoWriter('topo3D_mediumship.mp4','MPEG-4');
open(vidObj);
writeVideo(vidObj, Movie);
close(vidObj);
