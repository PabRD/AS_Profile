%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                          NAME: Acceleration-Speed Profiles              %
%                          AUTHOR: PabDawan                               %
%                          DATE: April 2023                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Description: in-Situ acceleration-speed profiles
% Based on Clavel and al. 2023 | Morin and al. 2021
% data dw: https://libm-lab. univ-st-etienne.fr/as-profile/#/hom
clear
close all
clc
tic
% Import data
dat = importdata('exampleFile.csv');
headers  = dat.textdata;
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
    
% Pre process
% stem(diff(data(:,1)))
t=data(:,1);
dt = mean(diff(data(:,1)));
fs = 1/dt;                                                                  % "Speed data were collected at a sampling rate of 18 Hz" Morin et al. 2021
% fs = 18; % Hz

%% process
figure

% only positive acc
maskPositif = data(:,3)>0;
dataPlus = data(maskPositif,:);
% scatter(dataPlus(:,2),dataPlus(:,3),'k.')

% threshold at 3 m/s
vThresh = 3;
maskVelocity = dataPlus(:,2)>=vThresh;
dataThresh = dataPlus(maskVelocity,:);
% scatter(dataThresh(:,2),dataThresh(:,3),'k.')

% the two max values of acceleration performed for each 0.2 m/s subintervals were selected for further analysis
[vSorted,indSort]  = sort(dataThresh(:,2));
accSorted = dataThresh(indSort,3);
scatter(vSorted,accSorted,7,col(end,:),'filled',...
    'MarkerFaceAlpha',0.8); hold on
scatter(dataPlus(dataPlus(:,2)<3,2),dataPlus(dataPlus(:,2)<3,3),...
    7,col(end-3,:),'filled','MarkerFaceAlpha',0.5)

vMax = max(vSorted);
[max2th,indMax,speedMax] = deal(cell(numel(vThresh:0.2:vMax),1));

index = 1;
for vRange = vThresh:0.2:vMax
    range = vSorted>=vRange & vSorted<=vRange+0.2;
    [max2th{index},indMax{index}] = maxk(accSorted(range),2);
    vEquiv = vSorted(range);
    speedMax{index} = vEquiv(indMax{index});
    index = index+1;
end
hold on
accCompute = cell2mat(max2th);
speedCompute = cell2mat(speedMax);


scatter(speedCompute,accCompute,50,col(end-2,:),'filled',...
    'markerfacealpha',1,'markeredgecolor',col(end-1,:))

%% first fit
f_AccSpeed = @(A0,S0,speed) A0.*(1-(speed./S0));

fit_TC = fittype(f_AccSpeed,'dependent',{'acc'},'independent',{'speed'},'coefficients',{'A0', 'S0'});
Start=[7 7];
[fitobject,~,output]  = fit(speedCompute,accCompute,fit_TC,'StartPoint',Start);

%% residuals confidence interval

ci = confint(fitobject,0.95);
int = abs(fitobject.A0-ci(1));
predictFirstFit = f_AccSpeed(fitobject.A0,fitobject.S0,speedCompute);

boolOutlier = and(accCompute>=predictFirstFit-int,accCompute<=predictFirstFit+int);
outliers = ~boolOutlier;


% ciResidus = computeCI(output.residuals,0.95)
% boolOutlier = or(output.residuals<ciResidus(1),output.residuals>ciResidus(2));
% outliers = boolOutlier;

% pl = plot(fitobject,'-');
% set(pl,'Color',col(3,:),'LineWidth',1.5,'HandleVisibility','off')
% plot(speedCompute,confInterval,'linestyle','--','color',col(3,:),'LineWidth',1.5)

%% final fit
speedSansOutlier = speedCompute(boolOutlier);
accSansOutlier = accCompute(boolOutlier);

[fitobject2,gof,~]  = fit(speedSansOutlier,accSansOutlier,fit_TC,...
    'StartPoint',coeffvalues(fitobject));
C2 = coeffvalues(fitobject2);
rSquared = gof.rsquare;
ci = confint(fitobject2);

A0 = C2(1);
V0 = C2(2);
scatter(speedSansOutlier,accSansOutlier,50,col(end-2,:),...
    'filled','markerfacealpha',1,...
    'markeredgecolor',col(end,:),'LineWidth',1.5)

xq = linspace(0,V0,1000);
p = plot(xq,fitobject2(xq),'LineStyle','-',...
                            'Color',col(end-3,:),...
                            'LineWidth',1.5,...
                            'MarkerFaceColor',col(end-2,:),...
                            'HandleVisibility','off');
xlim([0 V0+2])
ylim([0 A0+1])

str = {sprintf('$A_0$= %1.2f',A0) sprintf('$S_0$= %1.2f',V0)};
text([0.2;V0],[A0;0.3],str,'Interpreter','latex')
ylabel('Acceleration ($m.s^{-2}$)')
xlabel('Speed ($m.s^{-1}$)')
legend('')

title('A-S profile')
strTitle = sprintf('$R^2$= %1.2f',rSquared);

hfig= gcf;
picturewidth = 18; % set this parameter and keep it forever
hw_ratio = .8333; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex')
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])

subtitle(strTitle,'FontSize',13,'Interpreter','latex')
set(gca,'TickDir','out');


toc

