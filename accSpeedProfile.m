function [A0,V0,r2,dataOut] = accSpeedProfile(data,col)
% data = [time speed acc]
if nargin==1
    col = [    0.1020    0.1020    0.1020
    0.5294    0.5294    0.5294];

end
if nargout==0
    direction = 1;
else
    direction = 0;
end

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
accCompute = cell2mat(max2th);
speedCompute = cell2mat(speedMax);

%% first fit
f_AccSpeed = @(A0,S0,speed) A0.*(1-(speed./S0));

fit_TC = fittype(f_AccSpeed,'dependent',{'acc'},'independent',{'speed'},'coefficients',{'A0', 'S0'});
Start=[7 7];
[fitobject,~,~]  = fit(speedCompute,accCompute,fit_TC,'StartPoint',Start);

%% residuals confidence interval

ci = confint(fitobject,0.95);
int = abs(fitobject.A0-ci(1));
predictFirstFit = f_AccSpeed(fitobject.A0,fitobject.S0,speedCompute);

boolOutlier = and(accCompute>=predictFirstFit-int,accCompute<=predictFirstFit+int);
% outliers = ~boolOutlier;


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
% ci = confint(fitobject2);

A0 = C2(1);
V0 = C2(2);

acc = accSansOutlier;
speed = speedSansOutlier;
dataOut = table(acc,speed);
r2 = rSquared;


switch direction
    case 1
        xq = linspace(0,V0,1000);
        scatter(vSorted,accSorted,7,col(1,:),'filled',...
            'MarkerFaceAlpha',0.8); hold on
        
        scatter(dataPlus(dataPlus(:,2)<3,2),dataPlus(dataPlus(:,2)<3,3),...
            7,col(1,:)+0.7.*(1-col(1,:)),'filled','MarkerFaceAlpha',0.5)      

        scatter(speedCompute,accCompute,50,col(2,:),'filled',...
            'markerfacealpha',1,'markeredgecolor',col(2,:) - 0.42.*col(2,:))

        scatter(speedSansOutlier,accSansOutlier,50,col(2,:),...
            'filled','markerfacealpha',1,...
            'markeredgecolor',col(2,:) - 0.72.*col(2,:),'LineWidth',1.5)
        
        plot(xq,fitobject2(xq),'LineStyle','-',...
            'Color',col(2,:),...
            'LineWidth',1.5,...
            'MarkerFaceColor',col(2,:) - 0.42.*col(2,:),...
            'HandleVisibility','off');
        xlim([0 V0+2])
        ylim([0 A0+1])
        
        str = {sprintf('$A_0$= %1.2f',A0) sprintf('$S_0$= %1.2f',V0)};
        text([0.2;V0],[A0;0.3],str)
        ylabel('Acceleration ($m.s^{-2}$)')
        xlabel('Speed ($m.s^{-1}$)')
        legend('')
        
        title('A-S profile','Interpreter','latex')
        strTitle = sprintf('$R^2$= %1.2f',rSquared);
        
        hfig= gcf;
        set(findall(gca,'Type','text','-property','FontSize'),'FontSize',13) % adjust fontsize to your document
        set(findall(gca,'Type','axes','-property','FontSize'),'FontSize',17) % adjust fontsize to your document
        set(findall(hfig,'-property','Box'),'Box','off') % optional
        set(findall(hfig,'-property','Interpreter'),'Interpreter','latex')
        set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
        
        subtitle(strTitle,'FontSize',13,'Interpreter','latex')
        set(gca,'TickDir','out');
end

end