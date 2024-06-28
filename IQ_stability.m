% This example uses the two scope channels, one AWG channel, one power
daqreset;
AI = daq("digilent") % DAQ session for the scope channels1
VP = daq("digilent") % DAQ session for the V+ power supply

% add scope input channels
addinput(AI, "AD3_0", "ai0", "Voltage")
addinput(AI, "AD3_0", "ai1", "Voltage")

% add Positive Power Supply channel
addoutput(VP, "AD3_0", "V+", "Voltage")

% Configure rate of subsystems (DIO is fixed at 100MHz)
systemRate = 1e8; %100Mhz
AI.Rate = 10 % 1000Hz
VP.Rate = 10  % 10Hz

global data;
data = [];

AI.ScansAvailableFcn = @fetchData; % defined in fetchData.m
aquisition_time = 3600*1.5; % 1 1/2 hours


%Set V+ to 3.33 V during data aquisition
% background continuous
vpOutput = (linspace(3.33,3.33,1000)');
preload(VP, vpOutput);
VP.ScansRequiredFcn = @(src, evt) write(src, vpOutput); 
start(VP, "continuous");

pause(0.2)

start(AI, "Duration", seconds(aquisition_time));



% Wait until acquisition is done
while AI.Running
    pause(0.1)
end

f1 =figure;
plot(data.Time, [data.AD3_0_ai0, data.AD3_0_ai1])
xlabel('Time (min)');
xticks(minutes([0,15,30,45,60,75,90]));
xtickformat('m');
ylabel('Voltage (V)');
legend('Q','I')

saveas(f1, 'IQ_stab_figure','pdf');
writetimetable(data, 'IQstab.csv');
