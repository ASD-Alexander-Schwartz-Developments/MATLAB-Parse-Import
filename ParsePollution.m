function [nox, red, time, sampleRatePM25] = ParsePollution(filename, timeZone)
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
% MICS-4514 Carbon Monoxide Nitrogen Oxygen Sensor
% The sensor should be connected via VT01-DAQ24 analog DAQ board
% NOX - Channel1
% RED - Channel2
% Files without end time will be ignored and not imported 
%
% Parameters:
% filename - full path + name of the binary file
% timeZone - to calculate local time if timestamps are at UTC time
%
% Returns:
% nox - vector containing timeseries samples of the nox channel
% red - vector containing timeseries samples of the red channel
% time - vestor containing the time of individual samples
% sampleRatePM25 - calculated effective sampling rate

    fid = fopen(filename);
	data_ch1 = fread(fid, inf, 'uint16', 2, 'ieee-le');
	fseek(fid, 2, 'bof');
	data_ch2 = fread(fid, inf, 'uint16', 2, 'ieee-le');
%	fseek(fid, 4, 'bof');
%	data_ch3 = fread(fid, inf, 'uint16', 2, 'ieee-le');
%	fseek(fid, 6, 'bof');
%	data_ch4 = fread(fid, inf, 'uint16', 2, 'ieee-le');

	fclose(fid);

    data_ch1 = cast(data_ch1, 'double');
    nox = ((data_ch1/32768*4.096)); 

    data_ch2 = cast(data_ch2, 'double');
    red = ((data_ch2/32768*4.096)); 
	
%    ch3 not used % data_ch3 = cast(data_ch3, 'double');
%    ch3 not used % norm_data_ch3 = data_ch3/32768*4.096;
	
%    ch4 not used % data_ch4 = cast(data_ch4, 'double');
%    ch4 not used % norm_data_ch4 = data_ch4/32768*4.096;
    
	% put here convertion to physical units


    % extract time from file name and correct according to time zone
    timeStr = regexp(filename,'(\d*_\d*_*\d_\d*_\d*_\d*_\d*.\d\d.\d*)','match');
    % delete files without end time
    timeStr(cellfun(@length,timeStr) == 1) = [];

    timeStart = datenum(timeStr{1},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;
    timeEnd = datenum(timeStr{2},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;

    % correct sample rate
    timeDiffSec = (timeEnd - timeStart)*24*60*60;
    samples = length(red);
    sampleRatePM25 = samples/timeDiffSec;
    time = ((0:length(red)-1)' ./sampleRatePM25)/24/60/60 + timeStart;
end

