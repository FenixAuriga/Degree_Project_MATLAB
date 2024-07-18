
%Init

pH7_80 = zeros(1,10);
pH7_40 = zeros(1,10);
pH7_00 = zeros(1,10);
pH6_60 = zeros(1,10);
pH6_20 = zeros(1,10);
Ref = zeros(1,10);

pH7_80CI = zeros(1,10);
pH7_40CI = zeros(1,10);
pH7_00CI = zeros(1,10);
pH6_60CI = zeros(1,10);
pH6_20CI = zeros(1,10);
RefCI = zeros(1,10);

pH = [7.80,7.40,7.00,6.60,6.20];
    
for n = 4:10
   A = readmatrix(strcat('pH',sprintf('%.2f', pH(1)),'/data',num2str(n),'MHz', sprintf('%.2f', pH(1)), 'pH.csv'));
   B = readmatrix(strcat('pH',sprintf('%.2f', pH(2)),'/data',num2str(n),'MHz', sprintf('%.2f', pH(2)), 'pH.csv'));
   C = readmatrix(strcat('pH',sprintf('%.2f', pH(3)),'/data',num2str(n),'MHz', sprintf('%.2f', pH(3)), 'pH.csv'));
   D = readmatrix(strcat('pH',sprintf('%.2f', pH(4)),'/data',num2str(n),'MHz', sprintf('%.2f', pH(4)), 'pH.csv'));
   E = readmatrix(strcat('pH',sprintf('%.2f', pH(5)),'/data',num2str(n),'MHz', sprintf('%.2f', pH(5)), 'pH.csv'));
   R = readmatrix(strcat('Ref/data',num2str(n),'MHzRef.csv'));

   ShiftA = A(2:end,2);	% (2:end,2) -> phase (2:end,3) -> amplitude
   ShiftB = B(2:end,2);
   ShiftC = C(2:end,2);
   ShiftD = D(2:end,2);
   ShiftE = E(2:end,2);
   ShiftR = R(2:end,2);


   N = length(ShiftA);
   sA = sqrt(N/(N-1)* (mean(ShiftA.^2)-mean(ShiftA)^2));
   sB = sqrt(N/(N-1)* (mean(ShiftB.^2)-mean(ShiftB)^2));
   sC = sqrt(N/(N-1)* (mean(ShiftC.^2)-mean(ShiftC)^2));
   sD = sqrt(N/(N-1)* (mean(ShiftD.^2)-mean(ShiftD)^2));
   sE = sqrt(N/(N-1)* (mean(ShiftE.^2)-mean(ShiftE)^2));
   sR = sqrt(N/(N-1)* (mean(ShiftR.^2)-mean(ShiftR)^2));
   
   dof = N - 1; %Depends on the problem but this is standard for a CI around a mean.
   studentst = tinv([.025 0.975],dof); %tinv is the student's t lookup table for the two-tailed 95% CI ...
   %test_field = strcat('CI', num2str(n),'MHzpH7_00')
   
   ShiftA_CI = mean(ShiftA) + studentst.*sA/sqrt(N);
   ShiftB_CI = mean(ShiftB) + studentst.*sB/sqrt(N);
   ShiftC_CI = mean(ShiftC) + studentst.*sC/sqrt(N);
   ShiftD_CI = mean(ShiftD) + studentst.*sD/sqrt(N);
   ShiftE_CI = mean(ShiftE) + studentst.*sE/sqrt(N);
   ShiftR_CI = mean(ShiftR) + studentst.*sR/sqrt(N);

   pH7_80CI(n) = ShiftA_CI(2)-mean(ShiftA);
   pH7_80(n) = mean(ShiftA);

   pH7_40CI(n) = ShiftB_CI(2)-mean(ShiftB);
   pH7_40(n) = mean(ShiftB);

   pH7_00CI(n) = ShiftC_CI(2)-mean(ShiftC);
   pH7_00(n) = mean(ShiftC);

   pH6_60CI(n) = ShiftD_CI(2)-mean(ShiftD);
   pH6_60(n) = mean(ShiftD);

   pH6_20CI(n) = ShiftE_CI(2)-mean(ShiftE);
   pH6_20(n) = mean(ShiftE);

   RefCI(n) = ShiftR_CI(2)-mean(ShiftR);
   Ref(n) = mean(ShiftR);
end

pHlist = [pH7_80; pH7_40; pH7_00; pH6_60; pH6_20];
pHCIlist = [pH7_80CI; pH7_40CI; pH7_00CI; pH6_60CI; pH6_20CI];

%Diff = pH4_01-pH7_00;

temp = cat(1,pH7_80-Ref,pH7_40-Ref,pH7_00-Ref,pH6_60-Ref,pH6_20-Ref,Ref,pH7_80CI,pH7_40CI,pH7_00CI,pH6_60CI,pH6_20CI,RefCI);

Test = array2table(temp, 'RowNames',{'7.8pH','7.4pH','7.0pH','6.6pH','6.2pH','Ref', '7.8pH err','7.4pH err','7.0pH err','6.6pH err','6.2pH err','Ref err'} ,'VariableNames',{'1MHz','2MHz','3MHz','4MHz','5MHz','6MHz','7MHz','8MHz','9MHz','10Mhz'})

%compare = array2table(cat(1,pH7_00,pH4_01,Ref), 'RowNames',{'7pH','6.8pH','4pH','Ref'},'VariableNames',{'1MHz','2MHz','3MHz','4MHz','5MHz','6MHz','7MHz','8MHz','9MHz','10Mhz'});

symbolList = ['o', 'x', 's', 'd','h', '^', 'v', '>', '<', '*','+','p','.'];
symbol = @(k) sprintf('%s-', symbolList(mod(k-1,length(symbolList))+1));
hold on
    for i = 4:10
        errorbar(pH, [pHlist(1,i)-Ref(i), pHlist(2,i)-Ref(i),pHlist(3,i)-Ref(i),pHlist(4,i)-Ref(i),pHlist(5,i)-Ref(i)], [pHCIlist(1,i),pHCIlist(2,i),pHCIlist(3,i),pHCIlist(4,i),pHCIlist(5,i)], symbol(i-3))
        %
    end
    
    xlabel('pH');
    ylabel(['Phase change','(' char(176) ')']);
    legend('4MHz','5MHz','6MHz','7MHz','8MHz','9MHz','10MHz');
hold off


%{
% (G-90 /0.01)
y = [pH7_00(10)-Ref(10), pH4_01(10)-Ref(10)];
%y = [(pH7_00(10)-90)/0.01, (pH4_01(10)-90)/0.01];
x = [pH7_00,pH4_01];
yconf = [(y+pH7_00CI(10)) (y(end:-1:1)-pH7_00CI(10))];
%yconf = [(y+pH7_00CI(10)/0.01) (y(end:-1:1)-pH7_00CI(10)/0.01)];
xconf = [x x(end:-1:1)] ;

figure
p = fill(xconf,yconf,'red');
p.FaceColor = [1 0.8 0.8];      
p.EdgeColor = 'none';           

hold on
plot(x,y,'ro-')
xlabel('pH');
ylabel(['Phase difference','(' char(176) ')']);
hold off
%}

