temp = pHlist-Ref; %run testAnalysis first
x = [7.00,6.80,6.60,6.40,6.20]';
y = temp(:,7); %8 MHz

%x = [7.00,6.80,6.60,6.20]'; % 
%y(4) = []; %9MHZ test "correction"

fitresult = fit(x,y,'poly1');



p = predint(fitresult,x,0.95,'functional','off');


hL = plot(fitresult,x,y), hold on, plot(x,p,'m--'), xlim([6.2 7]), ylim([-4 -0.8])
hL(1).MarkerSize =10;

title('Linear regression for 9 MHz','FontSize',9)
xlabel('pH');
ylabel(['Phase Change','(' char(176) ')']);
legend({'Data','Fitted curve', 'Prediction intervals'},...
       'FontSize',8,'Location','northeast') 


R2 = fitlm(x,y).Rsquared
fitresult