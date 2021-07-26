%% Unit tests for moving_avg (streaming moving average function)
function tests = movingAvgTest
    tests = functiontests(localfunctions);
end

function setup(testCase)
    % clear the function so persistent variables don't persist across test cases
    clear moving_avg
end

function testOnes(testCase)
    window_size = 123;
    x = ones(5000, 1);
    avg = zeros(5000, 1);

    for i = 1:numel(x)
        avg(i) = moving_avg(x(i), window_size);
    end

    expected_avg = movmean(x, [window_size - 1, 0]);

    assertEqual(testCase, avg, expected_avg);
end

function testZeros(testCase)
    window_size = 123;
    x = zeros(5000, 1);
    avg = zeros(5000, 1);

    for i = 1:numel(x)
        avg(i) = moving_avg(x(i), window_size);
    end

    expected_avg = movmean(x, [window_size - 1, 0]);

    assertEqual(testCase, avg, expected_avg);
end

function testWindowSizeEqual0(testCase)
    window_size = 0;
    x = rand(100, 1);
    avg = zeros(100, 1);

    fatalAssertError(testCase, @() moving_avg(x(1), window_size), 'MATLAB:validators:mustBePositive');

end

function testWindowSizeNotInteger(testCase)
    window_size = 4.5;
    x = rand(100, 1);
    avg = zeros(100, 1);

    fatalAssertError(testCase, @() moving_avg(x(1), window_size), 'MATLAB:validators:mustBeInteger');
end

function testWindowSizeEqual1(testCase)
    window_size = 1;
    x = 5*ones(100, 1);
    avg = zeros(100, 1);

    for i = 1:numel(x)
        avg(i) = moving_avg(x(i), window_size);
    end

    expected_avg = movmean(x, [window_size - 1, 0]);

    assertEqual(testCase, avg, expected_avg);
end

function testInts(testCase)
    window_size = 3;
    x = [4 8 6 -1 -2 -3 -1 3 4 5];
    expected_avg = movmean(x, [window_size - 1 0]);

    avg = zeros(size(x));

    for i = 1:numel(x)
        avg(i) = moving_avg(x(i), window_size);
    end

    assertEqual(testCase, avg, expected_avg, 'AbsTol', 15*eps(class(x)));
end

function testRand1(testCase)
    window_size = 7;
    x = rand(500, 1);
    avg = zeros(500, 1);

    for i = 1:numel(x)
        avg(i) = moving_avg(x(i), window_size);
    end

    expected_avg = movmean(x, [window_size - 1, 0]);

    assertEqual(testCase, avg, expected_avg, 'AbsTol', 15*eps(class(x)));
end

function testRand2(testCase)
    window_size = 67;
    x = 10*rand(821730, 1);
    avg = zeros(821730, 1);

    for i = 1:numel(x)
        avg(i) = moving_avg(x(i), window_size);
    end

    expected_avg = movmean(x, [window_size - 1, 0]);

    % Longer vectors result in larger floating point errors due to cascading;
    % 1000 * eps is still plenty reasonable for doubles: 2.2204e-13
    assertEqual(testCase, avg, expected_avg, 'AbsTol', 1000*eps(class(x)));
end

function testRand3(testCase)
    window_size = 7;
    x = randi(10, 20, 1);
    avg = zeros(20, 1);

    for i = 1:numel(x)
        avg(i) = moving_avg(x(i), window_size);
    end

    expected_avg = movmean(x, [window_size - 1, 0]);

    assertEqual(testCase, avg, expected_avg, 'AbsTol', 15*eps(class(x)));
end