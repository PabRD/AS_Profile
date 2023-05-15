%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                          NAME: Acceleration-Speed Profiles              %
%                          AUTHOR: PabDawan                               %
%                          DATE: April 2023                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Description: in-Situ acceleration-speed profiles
% Based on Clavel and al. 2023 | Morin and al. 2021
% data dw: https://libm-lab. univ-st-etienne.fr/as-profile/#/home
clear
close all
clc
tic

% Import exemple data
dat = importdata('exampleFile.csv');
data = dat.data;
clearvars dat

% col = cbrewer('div','RdGy',12);
col = [    0.4039         0    0.1216
    0.6980    0.0941    0.1686
    0.8392    0.3765    0.3020
    0.9569    0.6471    0.5098
    0.9922    0.8588    0.7804
    0.9961    0.9569    0.9294
    1.0000    1.0000    1.0000
    0.8784    0.8784    0.8784
    0.7294    0.7294    0.7294
    0.5294    0.5294    0.5294
    0.3020    0.3020    0.3020
    0.1020    0.1020    0.1020];
    
t=data(:,1);
dt = mean(diff(data(:,1)));
fs = 1/dt;                                                                  % "Speed data were collected at a sampling rate of 18 Hz" Morin et al. 2021
% fs = 18; % Hz

%% Our data is already filtered and acceleration is already computed
% Lets imagine it was not the case, we create a new data set with only "raw" speed and time
rng(1)
stretch = 0.3;
shift = 0;
noise = stretch*rand(size(data(:,1))) + shift-stretch/2;                    % Add some uniform noise


f2 = figure;
tiledlayout(2,1,'Padding','compact','TileSpacing','compact')
nexttile
dataSimu  = [data(:,1) data(:,2)+noise];

fc = 1;
[b,a] = butter(2,fc/(fs/2),'low');
vFilt = filtfilt(b,a,dataSimu(:,2));                                        % Zero phase 2nd order lowpass butterworth filtering


plot(data(:,1), dataSimu(:,2),'Color',col(end-3,:),'LineWidth',2); hold on
plot(data(:,1),data(:,2),'Color',col(end,:),'LineWidth',1)
plot(data(:,1),vFilt,'Color',col(3,:),'LineWidth',1)
axis([370.3842  409.2903   -1.0000    9.0000])
legend({'speedOrigin+noise' 'speedOrigin' 'speedFilt'})
nexttile
plot(data(:,1),data(:,3),'Color',col(end-3,:),'LineWidth',2); hold on
accSimu = diff(vFilt)./dt;                                                  % first derivative over time
plot(data(2:end,1),accSimu,'Color',col(3,:),'LineWidth',1)
legend({'accOrigine' 'accFromPos+Filter'})
axis([370.3842  409.2903   -5    5])
set(gcf,'Units','normalized','Position',[0.1,0.1,0.6,0.4])
set(findall(gcf,'-property','Box'),'Box','off') % optional
set(findall(gcf,'-property','Interpreter'),'Interpreter','latex')
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(findall(gcf,'Type','text','-property','FontSize'),'FontSize',13) 
set(findall(gcf,'Type','axes','-property','FontSize'),'FontSize',15)

% Data must contain 3 columns: time, speed, acceleration
data = [data(2:end,1) vFilt(2:end) accSimu];

%% process
col = [0.1922	0.2118	0.5843; 0.9922    0.6824    0.3804];
[a0,s0,r2,dataOut] = accSpeedProfile(data);

figure
tiledlayout(1,2,'TileSpacing','compact','Padding','compact')
nexttile
accSpeedProfile(data);
title('Basic color')
nexttile
accSpeedProfile(data,col);
title('Your colors')
toc

% set(gcf,'Units','centimeters','Position',[10,3,28.7,18.5])

figure(f2)
