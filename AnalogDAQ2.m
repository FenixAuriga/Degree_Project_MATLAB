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
AI.Rate = systemRate/1e3 % 100kHz
VP.Rate = 10  % 10Hz

global data;
data = [];
global phaseshift;
phaseshift = [];
global amplitudeshift;
amplitudeshift = [];
global Idata;
global Qdata;
Idata = [];
Qdata = [];



%ph = [7.16,7.18,7.20,7.22,7.24,7.26,7.28,7.30,7.32, 7.34];
measurement = [0,1,2,3,4,5,6,7,8,9,10];
AI.ScansAvailableFcn = @fetchData; % defined in fetchData.m
aquisition_time = 0.4;


%Set V+ to 3.33 V during data aquisition
% background continuous
vpOutput = (linspace(3.33,3.33,1000)');
preload(VP, vpOutput);
VP.ScansRequiredFcn = @(src, evt) write(src, vpOutput); 
start(VP, "continuous");

pause(0.2)

disp('Calibration');
start(AI, "Duration", seconds(aquisition_time));



% Wait until acquisition is done
while AI.Running
    pause(0.1)
end

f1 =figure;
plot([data.AD3_0_ai0, data.AD3_0_ai1])
xlabel('Time (s)');
ylabel('Voltage (V)');
legend('Q','I');

%+1 connected to Q, +2 connected to I
Q0 = mean(data.AD3_0_ai0);
I0 = mean(data.AD3_0_ai1);
angle0 = angle((I0)+1i*(Q0))*180/pi;
ampli0 = abs((I0)+1i*(Q0));

run = 1;
temp = 1;


while run && temp <= length(measurement)
    data = [];
    disp(['measurement ',num2str(measurement(temp))]);
    run = input("Enter 1 to continue:  ");
    if(run ~= 1)
        break;
    end
    start(AI, "Duration", seconds(aquisition_time));
    %aqusition loop 
    
    %Set V+ to 3.33 V during data aquisition
    write(VP, 3.33 );
    pause(0.5);
    
    % Wait until acquisition is done
    while AI.Running
        pause(0.1)
    end
    
    f1 =figure;
    plot([data.AD3_0_ai0, data.AD3_0_ai1])
    xlabel('Time (s)');
    ylabel('Voltage (V)');
    legend('Q','I');
    
    %+1 connected to Q, +2 connected to I
    Q = mean(data.AD3_0_ai0);
    I = mean(data.AD3_0_ai1);
    disp('phase shift');
    shift = angle((I-I0)+1i*(Q-Q0))*180/pi
    amplitud = abs((I-I0)+1i*(Q-Q0))
    phaseshift(end+1) = shift;
    amplitudeshift(end+1) = amplitud;
    Idata(end+1) = I;
    Qdata(end +1) = Q;
    temp = temp+1;
  
end
stop(VP);
disp("phase change:")
%disp(phaseshift);
matrix = cat(1,measurement, phaseshift,amplitudeshift,Idata,Qdata);
disp(matrix)
mean(matrix(2,:))
mean(matrix(3,:))
%writematrix(matrix, 'data2.csv') %write data to a .csv file 
%writematrix(cat(1,I0,Q0), 'calibration1.csv')

%testcomp = cat(1, test1(2,:)-test1(2,1), test2(2,:)-test2(2,1))5
% khzcomp = cat(1, khzcomp, khztest4(2,:)-khztest4(2,1))

writematrix(transpose(matrix), 'data10MHz5.51pH.csv')
%writematrix(cat(1,I0,Q0), 'calibration10MHzCola.csv')