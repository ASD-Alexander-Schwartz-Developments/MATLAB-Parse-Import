function [time,sampleRate,xACC,yACC,zACC,temperature,xGyro,yGyro,zGyro,xMag,yMag,zMag,Pressure] = ParseIMU10_Sync(filename, timeZone)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright 2022 A.S.D - Alexander Schwartz Developments
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use this function to import timestamped CSV file 
% (after "Parse" by VesperStudio) containing samples of 
% IMU10 Inertial motion 10DoF sensor addon board.
% Files without end time will be ignored and not imported 
%
% Parameters:
% filename - full path + name of the binary file
% timeZone - to calculate local time if timestamps are at UTC time
%
% Returns:
% time - vector containing the time of individual samples
% sampleRate - calculated effective sampling rate
% xACC - vector containing timeseries samples of Accelerometer X Axis
% yACC - vector containing timeseries samples of Accelerometer Y Axis
% zACC - vector containing timeseries samples of Accelerometer Z Axis
% temperature - vector containing timeseries samples of Barometer temperature sensor
% xGyro - vector containing timeseries samples of Gyro X Axis
% yGyro - vector containing timeseries samples of Gyro Y Axis
% zGyro - vector containing timeseries samples of Gyro Z Axis
% xMag - vector containing timeseries samples of Magnetometer X Axis
% yMag - vector containing timeseries samples of Magnetometer Y Axis
% zMag - vector containing timeseries samples of Magnetometer Z Axis
% Pressure - vector containing timeseries samples of Barometer sensor

    % read data from CSV formatted file
    data = readtable(filename);

    % extract time from file name and correct according to time zone
    timeStr = regexp(filename,'(\d*_\d*_*\d_\d*_\d*_\d*_\d*.\d\d.\d*)','match');
    % delete files without end time
    timeStr(cellfun(@length,timeStr) == 1) = [];

    timeStart = datenum(timeStr{1},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;
    timeEnd = datenum(timeStr{2},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;

    % correct sample rate
    timeDiffSec = (timeEnd - timeStart)*24*60*60;
    samples = height(data);
    sampleRate = samples/timeDiffSec;
    time = ((0:height(data)-1)' ./sampleRate)/24/60/60 + timeStart;

    xACC = data.AccelerometerX;
    yACC = data.AccelerometerY;
    zACC = data.AccelerometerZ;
    temperature = data.Temperature;
    xGyro = data.GyroscopeX;    
    yGyro = data.GyroscopeY;
    zGyro = data.GyroscopeZ;
    xMag = data.MagnometerX;
    yMag = data.MagnometerY;
    zMag = data.MagnometerZ;
    Pressure = data.Pressure;
end

