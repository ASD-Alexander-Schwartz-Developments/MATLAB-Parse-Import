function [data, time, sampleRateAudio ] = PlotUltrasonicSync( filename, dclevel, bit, timeZone )
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
% (after initial "Parse" by VesperStudio) containing audio samples
% Files without end time will be ignored and not imported 
%
% Parameters:
% filename - full path + name of the binary file
% dclevel - DC level of the signal (to remove it) = 94 for all Vesper/Pipistrelle products
% bit - Sampling resolution = 8/12 for 8bit/12bit recording resolution
% timeZone - to calculate local time if timestamps are at UTC time
%
% Returns:
% data - vector containing timeseries samples
% time - vestor containing the time of individual samples
% sampleRateAudio - calculated effective sampling rate

    fid = fopen(filename);
    if bit == 8
        data = fread(fid, inf, '*uint8');
    elseif bit == 12
        data = fread(fid, inf, '*uint16');
    end

    ret = fclose(fid);
    ddata = cast(data, 'double');
    ddata = ddata - dclevel;

    % Use this to apply filter to the raw data
    %[b,a]=butter(4,[0.03, 0.5], 'bandpass');
    %data=filter(b,a,ddata);

    data = ddata;

    % extract time from file name and correct according to time zone
    timeStr = regexp(filename,'(\d*_\d*_*\d_\d*_\d*_\d*_\d*.\d\d.\d*)','match');

    % delete files without end time
    timeStr(cellfun(@length,timeStr) == 1) = [];

    timeStart = datenum(timeStr{1},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;
    timeEnd = datenum(timeStr{2},'yy_mm_dd_HH_MM_SS.FFF')+timeZone/24;

    % correct sample rate by calculating effective sampling rate based on number of samples divided by recording time 
    timeDiffSec = (timeEnd - timeStart)*24*60*60;
    samples = length(data);
    sampleRateAudio = samples/timeDiffSec;
    time = ((0:length(data)-1)' ./sampleRateAudio)/24/60/60 + timeStart;
end

