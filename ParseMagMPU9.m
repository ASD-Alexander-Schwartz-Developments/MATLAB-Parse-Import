function [ x, y, z, time, sampleRate ] = ParseMagMPU9( filename, timeZone )
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
% MPU9 9DoF motion sensor's Magnetometer.
% 
% Files without end time will be ignored and not imported 
%
% Parameters:
% filename - full path + name of the binary file
% timeZone - to calculate local time if timestamps are at UTC time
%
% Returns:
% x,y,z - vectors containing timeseries samples of the Magnetometer
% (x,y,z)
% time - vestor containing the time of individual samples
% sampleRate - calculated effective sampling rate

    fid = fopen(filename);
    fseek(fid, 14, 'bof');
    data = fread(fid, [3, inf], '3*int16=>double', 26, 'ieee-le');
    fseek(fid, 24, 'bof');
    cal = fread(fid, [3, inf], '3*int16=>double', 26, 'ieee-le');
    fclose(fid);

    [b,a]=butter(4,0.9);

    xdata = data(1,:);
    ydata = data(2,:);
    zdata = data(3,:);

    % filtered data
    x=filter(b,a,xdata)';
    y=filter(b,a,ydata)';
    z=filter(b,a,zdata)';

    % extract time from file name and correct according to time zone
    timeStr = regexp(filename,'(\d*_\d*_*\d_\d*_\d*_\d*_\d*.\d\d.\d*)','match');
    % delete files without end time
    timeStr(cellfun(@length,timeStr) == 1) = [];

    timeStart = datenum(timeStr{1},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;
    timeEnd = datenum(timeStr{2},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;

    % correct sample rate
    timeDiffSec = (timeEnd - timeStart)*24*60*60;
    samples = length(x);
    sampleRate = samples/timeDiffSec;
    time = ((0:length(x)-1)' ./sampleRate)/24/60/60 + timeStart;
end

