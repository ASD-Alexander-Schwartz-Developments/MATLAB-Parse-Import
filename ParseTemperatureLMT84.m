function [ temperature, time, sampleRateTemp ] = ParseTemperatureLMT84( filename, timeZone )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2022 A.S.D - Alexander Schwartz Developments
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use this function to import timestamped binary file 
% (after initial "Parse" by VesperStudio) containing samples of 
% LMT84 temperature sensor.
% The sensor should be connected via VT01-DAQ24 analog DAQ board
% LMT84/OUT - Channel1
% 
% Files without end time will be ignored and not imported 
%
% Parameters:
% filename - full path + name of the binary file
% timeZone - to calculate local time if timestamps are at UTC time
%
% Returns:
% temperature - vector containing timeseries samples of the temperature` channel
% time - vestor containing the time of individual samples
% sampleRateTemp - calculated effective sampling rate

    fid = fopen(filename);
    data = fread(fid, inf, '*uint16', 'l');
    fclose(fid);
    data = cast(data, 'double');
    temp = data/32768*4.096;
    temp1 = (temp - 1.035)/(-0.0055);
    
    temperature = temp1;

    % extract time from file name and correct according to time zone
    timeStr = regexp(filename,'(\d*_\d*_*\d_\d*_\d*_\d*_\d*.\d\d.\d*)','match');
    % delete files without end time
    timeStr(cellfun(@length,timeStr) == 1) = [];

    timeStart = datenum(timeStr{1},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;
    timeEnd = datenum(timeStr{2},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;

    % correct sample rate
    timeDiffSec = (timeEnd - timeStart)*24*60*60;
    samples = length(temperature);
    sampleRateTemp = samples/timeDiffSec;
    time = ((0:length(temperature)-1)' ./sampleRate)/24/60/60 + timeStart;

end

