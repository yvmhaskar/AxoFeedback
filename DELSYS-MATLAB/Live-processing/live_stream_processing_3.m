
function live_stream_processing_3

% THIS IS THE IP OF THE COMPUTER RUNNING THE TRIGNO CONTROL UTILITY
HOST_IP = '10.8.31.163';

%% Create the required objects

%Define number of sensors
NUM_SENSORS = 6;

% Global variables give warnings but are required to use throughout
% various functions.

%handles to all plots
global plotHandlesEMG; %#ok<*GVMIS> 
plotHandlesEMG = zeros(NUM_SENSORS,1);
global plotHandlesACC;
plotHandlesACC = zeros(NUM_SENSORS*3, 1);
global rateAdjustedEmgBytesToRead;
global plotHandlesGaits;
plotHandlesGaits = zeros(NUM_SENSORS,1);


% Variables to save raw data
global RawEMG;
RawEMG = [];
global RawIMU;
RawIMU = [];

% Flags to switch recorder on/off
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
global recorder
recorder = 0;


%% Connections to DELSYS Ports
%TCPIP Connection to stream EMG Data
interfaceObjectEMG = tcpip(HOST_IP,50041); %#ok<*TCPC> 
interfaceObjectEMG.InputBufferSize = 6400;
%TCPIP Connection to stream ACC Data
interfaceObjectACC = tcpip(HOST_IP,50042);
interfaceObjectACC.InputBufferSize = 6400;
%TCPIP Connection to communicate with SDK, send/receive commands
global commObject;
commObject = tcpip(HOST_IP,50040);

%Timer object for drawing plots.
t = timer('Period', 3, 'ExecutionMode', 'fixedSpacing', 'TimerFcn', {@updatePlots, plotHandlesEMG});
global data_arrayEMG
data_arrayEMG = [];
global data_arrayACC
data_arrayACC = [];

%% Set up the plots

axesHandlesEMG = zeros(NUM_SENSORS,1);
axesHandlesACC = zeros(NUM_SENSORS,1);
axesHandlesGaits = zeros(NUM_SENSORS,1);
% Initiate the EMG figure
plotRawEMG = 1;
if plotRawEMG
    figureHandleEMG = figure('Name', 'EMG Data','Numbertitle', 'off',  'CloseRequestFcn', {@localCloseFigure, interfaceObjectEMG, interfaceObjectACC, commObject, t});
    set(figureHandleEMG, 'position', [40 100 700 650])
    for i = 1:NUM_SENSORS
        axesHandlesEMG(i) = subplot(2,3,i);
        plotHandlesEMG(i) = plot(axesHandlesEMG(i),0,'-y','LineWidth',1);
        set(axesHandlesEMG(i),'YGrid','on');
        set(axesHandlesEMG(i),'XGrid','on');
        set(axesHandlesEMG(i),'Color',[.15 .15 .15]);
        set(axesHandlesEMG(i),'YLim', [-.025 .025]);
        set(axesHandlesEMG(i),'YLimMode', 'auto');
        set(axesHandlesEMG(i),'XLim', [0 2000]);
        set(axesHandlesEMG(i),'XLimMode', 'manual');
        if(mod(i, 3) == 1)
            ylabel(axesHandlesEMG(i),'V');
        else
            set(axesHandlesEMG(i), 'YTickLabel', '')
        end
        
        if(i >12)
            xlabel(axesHandlesEMG(i),'Samples');
        else
            set(axesHandlesEMG(i), 'XTickLabel', '')
        end
        title(sprintf('EMG %i', i))
    end
end

% Initiate the ACC figure
plotRawACC = 1;
if plotRawACC
    figureHandleACC = figure('Name', 'ACC Data', 'Numbertitle', 'off', 'CloseRequestFcn', {@localCloseFigure, interfaceObjectEMG, interfaceObjectACC, commObject, t});
    set(figureHandleACC, 'position', [750 100 700 650]);
    for i= 1:NUM_SENSORS
        axesHandlesACC(i) = subplot(2, 3, i);
        hold on
        plotHandlesACC(i*3-2) = plot(axesHandlesACC(i), 0, '-y', 'LineWidth', 1);    
        plotHandlesACC(i*3-1) = plot(axesHandlesACC(i), 0, '-y', 'LineWidth', 1);   
        plotHandlesACC(i*3) = plot(axesHandlesACC(i), 0, '-y', 'LineWidth', 1);
        hold off 
        set(plotHandlesACC(i*3-2), 'Color', 'r')
        set(plotHandlesACC(i*3-1), 'Color', 'b')
        set(plotHandlesACC(i*3), 'Color', 'g')    
        set(axesHandlesACC(i),'YGrid','on');
        set(axesHandlesACC(i),'XGrid','on');
        set(axesHandlesACC(i),'Color',[.15 .15 .15]);
        set(axesHandlesACC(i),'YLim', [-3 1]);
        set(axesHandlesACC(i),'YLimMode', 'auto');
        set(axesHandlesACC(i),'XLim', [0 2000/13.5]);
        set(axesHandlesACC(i),'XLimMode', 'manual');
        if(i > 12)
            xlabel(axesHandlesACC(i),'Samples');
        else
            set(axesHandlesACC(i), 'XTickLabel', '');
        end
        
        if(mod(i, 3) == 1)
            ylabel(axesHandlesACC(i),'g');
        else
            set(axesHandlesACC(i) ,'YTickLabel', '')
        end
        title(sprintf('ACC %i', i)) 
    end
end

Muscle = ["Left TA", "Left GAS", "Left SOL","Right TA","Right GAS","Right SOL"];
% Initiate the Gait Cycle figure
plotGaitCycles = 1;
if plotGaitCycles
    figureHandleGaits = figure('Name', 'Averaged Gait Cycles', 'Numbertitle', 'off', 'CloseRequestFcn', {@localCloseFigure, interfaceObjectEMG, interfaceObjectACC, commObject, t});
    set(figureHandleGaits,'position', [200 150 1200 550]);
    for i = 1:NUM_SENSORS
        axesHandlesGaits(i) = subplot(1,6,i);
        plotHandlesGaits(i) = plot(axesHandlesGaits(i),0, Color=[0.8500 0.3250 0.0980],LineWidth=2);
        set(axesHandlesGaits(i),'YGrid','on');
        set(axesHandlesGaits(i),'XGrid','on');
        set(axesHandlesGaits(i),'Color',[.15 .15 .15]);
        set(axesHandlesGaits(i),'YLim', [-5 5]);
        set(axesHandlesGaits(i),'YLimMode', 'auto');
        set(axesHandlesGaits(i),'XLim', [0 100]);
        set(axesHandlesGaits(i),'XLimMode', 'manual');
        ax = gca;
        ax.GridColor = [0.9,0.9,0.9];
        if(mod(i, 3) == 1)
            ylabel(axesHandlesGaits(i),'Muscle Activity (V)');
        else
            set(axesHandlesGaits(i), 'YTickLabel', '')
        end
        
        if(i >12)
            xlabel(axesHandlesGaits(i),'Samples');
        end
        title(sprintf(Muscle(i), i))
    end
end

%% Open the COM interface, determine RATE

fopen(commObject);
pause(1);
fread(commObject,commObject.BytesAvailable);
fprintf(commObject, sprintf('RATE 2000\r\n\r'));
pause(1);
fread(commObject,commObject.BytesAvailable);
fprintf(commObject, sprintf('SENSOR 1 CHANNEL 1 RATE?\r\n\r'));
pause(1)
data = fread(commObject,commObject.BytesAvailable);
emgRate = strtrim(char(data'));
if(strcmp(emgRate, '1925.926'))
    rateAdjustedEmgBytesToRead=4800;
else 
    rateAdjustedEmgBytesToRead=4864;
end
pause(1)
if 1900<str2double(emgRate)
    disp("High Sampling rate")
elseif 1200<str2double(emgRate)
    disp(emgRate)
    warning("Low Sampling rate: Please check sensor configurations")
    return;
end

%% Setup interface object to read chunks of data
% Define a callback function to be executed when desired number of bytes
% are available in the input buffer

 bytesToReadEMG = rateAdjustedEmgBytesToRead;
 interfaceObjectEMG.BytesAvailableFcn = {@localReadAndPlotMultiplexedEMG,plotHandlesEMG,bytesToReadEMG};
 interfaceObjectEMG.BytesAvailableFcnMode = 'byte';
 interfaceObjectEMG.BytesAvailableFcnCount = bytesToReadEMG;
 
 bytesToReadACC = 384;
interfaceObjectACC.BytesAvailableFcn = {@localReadAnPlotMultiplexedACC, plotHandlesACC, bytesToReadACC};
interfaceObjectACC.BytesAvailableFcnMode = 'byte';
interfaceObjectACC.BytesAvailableFcnCount = bytesToReadACC;
drawnow
start(t);
 
% Open the interface object
try
    fopen(interfaceObjectEMG);
    fopen(interfaceObjectACC);
catch
    localCloseFigure(figureHandleACC,1 ,interfaceObjectACC, interfaceObjectEMG, commObject, t);
    delete(figureHandleEMG);
    error('CONNECTION ERROR: Please start the Delsys Trigno Control Application and try again');
end
%% Send the commands to start data streaming
fprintf(commObject, sprintf('MASTER\r\n\r'));
pause(1)
fprintf(commObject, sprintf('START\r\n\r'));

% Display the plot
 snapnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Implement the bytes available callback
%The localReadandPlotMultiplexed functions check the input buffers for the
%amount of available data, mod this amount to be a suitable multiple.
%Because of differences in sampling frequency between EMG and ACC data, the
%ratio of EMG samples to ACC samples is 13.5:1
%We use a ratio of 27:2 in order to keep a whole number of samples.  
%The EMG buffer is read in numbers of bytes that are divisible by 1728 by the
%formula (27 samples)*(4 bytes/sample)*(16 channels)
%The ACC buffer is read in numbers of bytes that are divisible by 384 by
%the formula (2 samples)*(4 bytes/sample)*(48 channels)
%Reading data in these amounts ensures that full packets are read.  The 
%size limits on the dataArray buffers is to ensure that there is always one second of
%data for all 16 sensors (EMG and ACC) in the dataArray buffers

function localReadAndPlotMultiplexedEMG(interfaceObjectEMG, ~,~,~, ~)
global rateAdjustedEmgBytesToRead;
bytesReady = interfaceObjectEMG.BytesAvailable;
bytesReady = bytesReady - mod(bytesReady, rateAdjustedEmgBytesToRead);%%1664
if (bytesReady == 0)
    return
end
global data_arrayEMG
data = cast(fread(interfaceObjectEMG,bytesReady), 'uint8');
data = typecast(data, 'single');
if(size(data_arrayEMG, 1) < rateAdjustedEmgBytesToRead*19) 
    data_arrayEMG = [data_arrayEMG; data];
else
    data_arrayEMG = [data_arrayEMG(size(data,1) + 1:size(data_arrayEMG, 1));data];
end
%%
function localReadAnPlotMultiplexedACC(interfaceObjectACC, ~, ~, ~, ~)
bytesReady = interfaceObjectACC.BytesAvailable;
bytesReady = bytesReady - mod(bytesReady, 384);
if(bytesReady == 0)
    return
end
global data_arrayACC
data = cast(fread(interfaceObjectACC, bytesReady), 'uint8');
data = typecast(data, 'single');
if(size(data_arrayACC, 1) < 21312)
    data_arrayACC = [data_arrayACC; data];
else
    data_arrayACC = [data_arrayACC(size(data, 1) + 1:size(data_arrayACC, 1)); data];
end

%% Update the plots
%This timer callback function is called on every tick of the timer t.  It
%demuxes the dataArray buffers and assigns that channel to its respective
%plot.
function updatePlots(~, ~,  ~)
global data_arrayEMG
global plotHandlesEMG
global rawEMG
global data_arrayACC
global plotHandlesACC
global rawIMU
global KEY_IS_PRESSED
global recorder
global n
global plotHandlesGaits
if size(rawEMG,2) > 5000
    filled = 1;
    rx = size(rawEMG,2);
else
    filled = 0;
end
for i = 1:size(plotHandlesEMG, 1)

% Plotting EMG plot
    data_ch = data_arrayEMG(i:16:end);
    set(plotHandlesEMG(i), 'Ydata', data_ch)
        
% Extracting EMG raw data(Unmultiplexing data)
    if size(data_ch,1) > 5000
        if filled
            rawEMG(i,1:(rx+size(data_ch,1)))=[rawEMG(i,1:rx) data_ch'];
        else
            rawEMG(i,1:size(data_ch,1))=data_ch';
        end
    else
        rawEMG = [];
    end
end


rI = size(rawIMU,2);
for i = 1:size(plotHandlesACC, 1)

% Plotting ACC plot
    data_ch = data_arrayACC(i:48:end);
    set(plotHandlesACC(i), 'Ydata', data_ch)
% Extracting IMU raw data (Unmultiplexing data)
    if size(data_ch,1) > 400
        if filled
            rawIMU(i,1:(rI+size(data_ch,1))) =[rawIMU(i,1:rI) data_ch'];
        else
            rawIMU(i,1:size(data_ch,1)) =data_ch';
        end
       
    end
 end
drawnow

%% Recorder on/off

set(gcf, 'KeyPressFcn',@myKeyPressFcn)

if KEY_IS_PRESSED == 1 && recorder == 0
    recorder = 1;
    disp("Recording")
    n = 1;
elseif KEY_IS_PRESSED == 1 && recorder == 1
    recorder = 0;
    disp("Recording stopped")
end
KEY_IS_PRESSED = 0;

if recorder == 1
        save('data_ArrayEMG.mat','data_arrayEMG')
        save('data_ArrayACC.mat','data_arrayACC')
end
%%
% Label the muscles over here:
Muscle = ["Left TA", "Left GAS", "Left SOL","Right TA","Right GAS","Right SOL"];

% Arranging EMG data:
if size(rawEMG,2)>10000
    disp("rawEMG hits 10000")
    for i=size(rawEMG,1):-1:1
        emgData{i}.raw_emg = rawEMG(i,1:end);
        emgData{i}.samplerate = 1926;
        emgData{i}.muscle = Muscle(i);
        emg_struct.channel = emgData;
       
    end
    rawEMG = [];
    
%% Filtering EMG Data
    
    emg_setting.band.flag = 1;
    emg_setting.band.bandrange = [20,500];
    emg_setting.rectify = 1;
    emg_setting.linear_env.flag = 1;
    emg_setting.linear_env.butterorder = 2;
    emg_setting.linear_env.fc = 5;
    emg_struct = preprocessEMG(emg_struct,emg_setting);

    if size(rawIMU,2)>800
        disp("rawIMU hits 800")
        
        for i=size(rawIMU,1):-1:1
            
            IMUData{i}.raw_imu = rawIMU(i,1:end);
            IMUData{i}.samplerate = 148;
            imu_struct.channel = IMUData;
                   
        end
        rawIMU = [];
%% Filtering IMU Data
       
        imu_setting.band = 0;
        imu_setting.calibrate = 1;
        imu_setting.linear_env.flag = 1;
        imu_setting.linear_env.butterorder = 1;
        imu_setting.linear_env.fc = 1;
        imu_setting.integrate = 0;
        imu_setting.flip = 1;
        imu_struct = preprocessIMU(imu_struct,imu_setting);


%% find max voluntart contraction for normalization
% Change the pathname to the normalizing file
        maxfname = '12_3_max_vol_contraction';
        pathname ='C:\Users\mhask\Desktop\AMBER Lab\AxoFeedback\DELSYS-MATLAB\EMG data\';
        
        emg_setting.band.flag = 1;
        emg_setting.band.bandrange = [20,500];
        emg_setting.rectify = 1;
        emg_setting.linear_env.flag = 1;
        emg_setting.linear_env.butterorder = 2;
        emg_setting.linear_env.fc = 5;
        emg_setting.max_avg_flag = 1;
        max_emg_struct = findMaxVolContraction(maxfname,pathname,emg_setting);
        
%% extract heel strikes
        hs_setting.sensorL = 3;
        hs_setting.sensorR = 6;
        hs_setting.min_separation = [0.9,1.3,1.3];
        emg_struct = heelStrikeIMU(imu_struct,emg_struct,hs_setting);

%% use extracted heel strikes to identify steps
        if size(emg_struct.hs.tR,2)>=2
            step_setting.time_last_step = [0,0,0,0];
            emg_step_struct = findGaitCycle(emg_struct,step_setting);


%% remove outlier steps

            plotbool = 0;
            emg_step_struct = removeDurationOutlier(emg_step_struct,plotbool);

%% normalize/interpolate data using max voluntary contraction

            max_ch_order = [1,2,3,4,5,6];%[1,3,5,6,2,4];%[1,2,3,4,6,5];
            no_max_flag = 0;  %set this to 0 if there's no corresponding max file for this experiment
            emg_step_struct = normalizeEMG(emg_step_struct,max_emg_struct,max_ch_order,no_max_flag);

%% Averaging and finding peaks
            
ch_num = size(emg_step_struct.channel,2);

            for ch = 1:ch_num/2
                    avg_dataL = squeeze(mean(emg_step_struct.interpL.data,2));
                    leftT = linspace(0,100,size(avg_dataL(ch,:),2));
                    set(plotHandlesGaits(ch), 'Ydata', avg_dataL(ch,:));
                    set(plotHandlesGaits(ch), 'Xdata', leftT);
            end
            disp("reached here 1")
            for ch = 1:ch_num/2
                ch2 = ch + ch_num/2;
                    avg_dataR = squeeze(mean(emg_step_struct.interpR.data,2));
                    rightT = linspace(0,100,size(avg_dataR(ch,:),2));
                    set(plotHandlesGaits(ch2), 'Ydata', avg_dataR(ch,:));
                    set(plotHandlesGaits(ch2), 'Xdata', rightT);
            end
            disp("reached here 2")
            [~, index] = max(avg_dataL(1,:));
            leftT_max = leftT(index);
            disp("Left leg actuation should be at"+leftT_max+"% Gait Cycle")
            [~, index] = max(avg_dataR(1,:));
            rightT_max = rightT(index);
            disp("Right leg actuation should be at"+rightT_max+"% Gait Cycle")
            
%             TeensyCom(leftT_max,rightT_max);
        end
    end
end

%% Implement the close figure callback
%This function is called whenever either figure is closed in order to close
%off all open connections.  It will close the EMG interface, ACC interface,
%commands interface, and timer object
function localCloseFigure(figureHandle,~,interfaceObject1, interfaceObject2, commObject, t)
%% 
% Clean up the network objects
if isvalid(interfaceObject1)
    fclose(interfaceObject1);
    delete(interfaceObject1);
    clear interfaceObject1;
end
if isvalid(interfaceObject2)
    fclose(interfaceObject2);
    delete(interfaceObject2);
    clear interfaceObject2;
end
if isvalid(t)
   stop(t);
   delete(t);
end
if isvalid(commObject)
    fclose(commObject);
    delete(commObject);
    clear commObject;
end
%% 
% Close the figure window
delete(figureHandle);

    
function myKeyPressFcn(~, ~)
global KEY_IS_PRESSED   
KEY_IS_PRESSED  = 1;
    disp('key is pressed')

