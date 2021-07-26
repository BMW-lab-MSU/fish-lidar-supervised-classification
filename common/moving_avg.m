function avg = moving_avg(x, window_size)
% moving_avg Compute a streaming moving average
%
%   avg = moving_avg(x, window_size) computes a moving average of window_size
%   points given the new point x. If moving_avg has not seen window_size points
%   yet, avg is the cumulative moving average of the points seen so far.
%
%   moving_avg is intended for causal, streaming settings where new points come 
%   in one at a time. It does this by using persistent variables to keep track
%   of previous points and averages. This function needs to be cleared from the
%   workspace before being used on a new data stream.

% Copyright (c) 2021 Trevor Vannoy
% SPDX-ID: BSD-3-Clause

arguments
    x (1,1) {mustBeNumeric}
    window_size (1,1) {mustBeInteger, mustBePositive}
end

persistent x_buf
persistent avg_prev
persistent N

% Initialize persistent variables on first call.
if isempty(x_buf)
    x_buf = zeros(window_size, 1);
end
if isempty(avg_prev)
    avg_prev = x;
end
if isempty(N)
    N = 0;
end


if N >= 1 && N < window_size
    % Compute the cumulative moving average: 
    % https://en.wikipedia.org/wiki/Moving_average#Cumulative_moving_average
    avg = avg_prev + (x - avg_prev)/(N + 1);
elseif N >= window_size
    % Compute the simple moving average:
    % https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average
    avg = avg_prev + 1/window_size * (x - x_buf(window_size));
else
    % Average for the first data point
    avg = avg_prev;
end

% Push new data into the buffer and remove old data
x_buf = [x; x_buf(1:window_size - 1)];

N = N + 1;
avg_prev = avg;