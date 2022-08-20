# AxoFeedback
The following repo includes all the codes involved in creating a feedback loop between the ankle exoskeleton, EMG muscle sensors and the muscles.

The feedback loop connectivity requires the following software/firmware versions:

-DELSYS Trigno Base Station Version: MA2909

-MATLAB version: R2021b (tcp/ip commands do not work after this updates)

   Would need to update MATLAB code to tcpclient and tcpserver.
   Needs the Signal processing toolbox for MATLAB.
    
-Realterm

-Arduino IDE (1.8.19 or later)

Procedure to conduct testing for the Human-in-the-loop Feedback system with Electromyography sensors and the Ankle Exoskeleton.

Phase 1: Create a MaxVolContraction file for the normalization of EMG sensors.
 1) Open DELSYS-MATLAB/Live-processing/generateMaxVolContraction_V1
      Set the HOST_IP address
      Set the subject number and date_key
 
 2) Pair the EMG sensors using the Trigno Control Utility
      (for help on DELSYS sensors use https://www.delsys.com/downloads/USERSGUIDE/trigno/sdk.pdf) 
 
 3) Don the sensors using the Sensor Placement Protocol below:
      Sensor 1: Left TA: Left Leg Actuator Flag
      Sensor 2: Left GAS
      Sensor 3: Left SOL: Left Leg Gait Cycle Decider
      Sensor 4: Right TA: Right Leg Actuator Flag
      Sensor 5:Right GAS
      Sensor 6: Right SOL: Right Leg Gait Cycle Decider

4) Don the ankle weights.

5) Start the generateMaxVolContraction_V1 and conduct stretching exercises.
   Try to exert the muscles. Try to walk around a bit to use all the muscles.
   The plots that show up are raw EMG and raw IMU data which can be ignored for now ( would be decently noisy)
   After the exercises, close the figures to stop the code.
   A MaxVolContraction file with te subject number and date_key would be generated in the Live-processing folder.

6) Remove ankle weights.
   
Phase 2: Live-processing
1) Make sure the MaxVolContraction file is placed in the Live-processing folder. Open the live_stream_processing_3.m file
   Set the HOST_IP address
   Set the subject number and date_key
   
2) Upload Powered_bbp_Fdbk to the Axo. ( Need to complete testing of the Powered_bbp_Fdbk)

3) Don the Axo after preparing them.

4) Start the MATLAB code
   If output gives an error of Low sampling rate: Do the following steps:
   a) Go to the Trigno Control Utility app, click on "Sensor Information" or Settings under any one sensor and ensure it is at       1926 Hz sampling rate. Click "Apply and Close" and start the MATLAB code.
   b) If the error persists, check the sampling rate of every sensor by checking Sensor Information.
      All sensors should have the following configuration:
      EMG:
         Rate: 1926 Hz
         Range: 11 mV
         Bandwidth: 20-450 Hz
      IMU:
         Accelerometer Range: +/- 16g

5) Click on one of the figures and click any key on the keyboard to start recording.
   Three figures would pop up once the code starts running:
   the first two would be the raw EMG and IMU data plots. These are to ensure the sensors are providing data. This plot        updates every 3 seconds.
   The third plot is the gait cycle averaged EMG data over a 6 second period for different muscles. This plot updates every    6 seconds.
   
6) Take readings as you want. Click on the figure and press another key to stop recording.

7) The data would already be recorded as emg_struct and imu_struct with the subject number and date_key.

Phase 3: Post-processing the data:
1) Make sure the emg_struct, imu_struct and MaxVolContraction files are included in the Post-processing folder

2) Open the postProcessData.m file
   Set up the HOST_IP address
   Set up the subject number and date_key.
   Run the file to get the averaged EMG plots for different muscles throughout the trial.
         
      
      
   
   
