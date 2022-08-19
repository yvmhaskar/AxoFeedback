function generateMaxVolContraction

% THIS IS THE IP OF THE COMPUTER RUNNING THE TRIGNO CONTROL UTILITY
HOST_IP = '10.8.31.163';

%% Create the required objects

%Define number of sensors
global NUM_SENSORS %#ok<*GVMIS> 
NUM_SENSORS = 6;

% Global variables give warnings but are required to use throughout
% various functions.
% Variables to save raw data:
global plotHandlesEMG
global plotHandlesACC
global RawEMG;
RawEMG = [];
global RawIMU;
RawIMU = [];
% Change the name of file below:
global savefile
Subject_no = "1";
date_key = "081522";
savefile= Subject_no + "max_vol_contraction_" + date_key;

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
t = timer('Period', 3, 'ExecutionMode', 'fixedSpacing', 'TimerFcn', {@updateSave, NUM_SENSORS});
global data_arrayEMG
data_arrayEMG = [];
global data_arrayACC
data_arrayACC = [];

%% Initializing savefile:
axesHandlesEMG = zeros(NUM_SENSORS,1);
axesHandlesACC = zeros(NUM_SENSORS,1);

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
for i=NUM_SENSORS:-1:1
    sensor.ch_num = i;
    channel{i}.sensor = sensor;
    channel{i}.samplerate = 1926;
    channel{i}.muscle = Muscle(i);
    emg_struct.channel = channel;
end
%% Saving file
save(savefile,"emg_struct")

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
    error("Low Sampling rate: Please check sensor configurations")
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
function updateSave(~, ~,  ~)
global data_arrayEMG
global NUM_SENSORS
global rawEMG
global savefile

if size(rawEMG,2) > 5000
    filled = 1;
    rx = size(rawEMG,2);
else
    filled = 0;
end
for i = 1:NUM_SENSORS
    data_ch = data_arrayEMG(i:16:end); 
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

% Arranging EMG data:
if size(rawEMG,2)>10000
    disp("Recording has begun.")
    load(savefile,'emg_struct');
    Muscle = ["Left TA", "Left GAS", "Left SOL","Right TA","Right GAS","Right SOL"];
    for i=size(rawEMG,1):-1:1
        
        sensor = emg_struct.channel{i}.sensor;
        if isfield(sensor,'emg')
        disp("reached here 1")
        emg = sensor.emg;
        else
            emg = [];
        end
        sensor.emg = [emg rawEMG(i,:)];
        disp("reached here 2")
        sensor.ch_num = i;
        channel{i}.sensor = sensor;
        channel{i}.samplerate = 1926;
        channel{i}.muscle = Muscle(i);
    end
    emg_struct.channel = channel;
    save(savefile,"emg_struct")
    rawEMG = [];
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