clear;clc;close all;                
A   = 1;                  % amplitude of the signal (+A and -A)
N   = 10;                 % number of random bits to generate
Ts  = 1;                  % time between two bits (bit period) in seconds
Fs  = 100;                % sampling frequency (samples per second)
Nsp = Ts * Fs;            % number of samples inside one bit period
Total = N * Nsp;          % total number of samples in the whole signal

% Generate random bits
data = randi([0 1], 1, N);   % create a random vector of N zeros and ones
t = zeros(1, Total);         % make an empty time vector with Total samples
for i = 1 : Total            % loop from the first to the last sample to calculate the time of each sample
    t(i) = (i - 1) / Fs;     % time of sample i = (i-1) / sampling frequency
end                         

% Encode the bits 
% "half" is the number of samples in the first half of one bit period used by the RZ and Manchester codes.
half = Nsp / 2;              % samples in half a bit period

% Polar NRZ : ('1' -> +A ),('0' -> -A) 
s1 = zeros(1, Total);          % create an empty signal for Polar NRZ
for k = 1 : N                  % loop over every bit  assume bit number 8 
    start = (k - 1) * Nsp + 1; % sample index where bit k begins , start = (8 - 1) * 100 + 1 = 701 
    stop  = k * Nsp;           % sample index where bit k ends   , end = 8 * 100 = 800 
    if data(k) == 1            % if the current bit is a one
        s1(start : stop) = A;  % set all its samples to +A
    else                       % if the current bit is a zero
        s1(start : stop) = -A; % set all its samples to -A
    end                        
end                            

% Inverted Polar NRZ : '1' -> change level, '0' -> keep level 
s2 = zeros(1, Total);        % create an empty signal for Inverted NRZ
level = -A;                  % the level starts at -A
for k = 1 : N                % loop over every bit
    if data(k) == 1          % if the current bit is a one
        level = -level;      % flip the level (+A becomes -A and vice versa)
    end                      % if the bit is zero the level does not change
    start = (k - 1) * Nsp + 1; % sample index where bit k begins
    stop  = k * Nsp;           % sample index where bit k ends
    s2(start : stop) = level;  % fill the bit samples with the current level
end                            

% Polar RZ : '1' -> +A then 0 , '0' -> -A then 0 
s3 = zeros(1, Total);          % create an empty signal for Polar RZ
for k = 1 : N                  % loop over every bit
    start = (k - 1) * Nsp + 1; % sample index where bit k begins
    stop  = k * Nsp;           % sample index where bit k ends
    if data(k) == 1            % if the current bit is a one
        s3(start : start + half - 1) = A;  % first half of the bit becomes +A
    else                       % if the current bit is a zero
        s3(start : start + half - 1) = -A; % first half of the bit becomes -A
    end                        % end of the if statement
    % the second half (start+half to stop) stays 0 (return to zero)
end                           

% Bipolar NRZ : '0' -> 0 , '1' -> alternating +A and -A 
s4 = zeros(1, Total);        % create an empty signal for Bipolar NRZ
sign = 1;                    % sign of the next '1' pulse (starts positive)
for k = 1 : N                % loop over every bit
    if data(k) == 1          % if the current bit is a one
        start = (k - 1) * Nsp + 1;   % sample index where bit k begins
        stop  = k * Nsp;             % sample index where bit k ends
        s4(start : stop) = sign * A; % fill the whole bit with sign*A
        sign = -sign;                % change the sign for the next '1'
    end                        % if the bit is zero it stays 0 (no pulse)
end                            

% Bipolar RZ : same as Bipolar NRZ but only first half 
s5 = zeros(1, Total);        % create an empty signal for Bipolar RZ
sign = 1;                    % sign of the next '1' pulse (starts positive)
for k = 1 : N                % loop over every bit
    if data(k) == 1          % if the current bit is a one
        start = (k - 1) * Nsp + 1; % sample index where bit k begins
        s5(start : start + half - 1) = sign * A; % first half gets sign*A
        sign = -sign;              % change the sign for the next '1'
    end                        % if the bit is zero it stays 0 (no pulse)
end                           

% Manchester : '1' -> +A then -A , '0' -> -A then +A 
s6 = zeros(1, Total);        % create an empty signal for Manchester
for k = 1 : N                % loop over every bit
    start = (k - 1) * Nsp + 1; % sample index where bit k begins
    stop  = k * Nsp;           % sample index where bit k ends
    if data(k) == 1            % if the current bit is a one
        s6(start : start + half - 1) = A;  % first half becomes +A
        s6(start + half : stop)      = -A; % second half becomes -A
    else                       % if the current bit is a zero
        s6(start : start + half - 1) = -A; % first half becomes -A
        s6(start + half : stop)      = A;  % second half becomes +A
    end                        % end of the if statement
end                            % end of the bit loop

% Plot the waveforms
% One subplot for each line code, all in the same figure.
figure('Name', 'Waveforms');   
subplot(6,1,1);                
stairs(t, s1, 'LineWidth', 1.2);
grid on;                       
ylim([-1.2*A 1.2*A]);          
ylabel('Polar NRZ');           
subplot(6,1,2);                
stairs(t, s2, 'LineWidth', 1.2);
grid on;                       
ylim([-1.2*A 1.2*A]);          
ylabel('Inverted NRZ');        
subplot(6,1,3);                
stairs(t, s3, 'LineWidth', 1.2);
grid on;                       
ylim([-1.2*A 1.2*A]);          
ylabel('Polar RZ');            
subplot(6,1,4);                
stairs(t, s4, 'LineWidth', 1.2);
grid on;                       
ylim([-1.2*A 1.2*A]);          
ylabel('Bipolar NRZ');         
subplot(6,1,5);                
stairs(t, s5, 'LineWidth', 1.2);
grid on;                       
ylim([-1.2*A 1.2*A]);          
ylabel('Bipolar RZ');          
subplot(6,1,6);                
stairs(t, s6, 'LineWidth', 1.2);
grid on;                       
ylim([-1.2*A 1.2*A]);          
ylabel('Manchester');          
xlabel('Time (sec)');          
sgtitle('Line code waveforms (same bit period Ts)'); 

% Plot the power spectral densities 
% pwelch is a built-in Matlab function that estimates the PSD of a signal.
figure('Name', 'Power Spectral Density'); % create a new figure window
subplot(6,1,1);                % select the first subplot
[P1,f] = pwelch(s1, [], [], [], Fs); % estimate PSD of Polar NRZ
plot(f, 10*log10(P1), 'LineWidth', 1); % plot PSD in decibels (dB)
grid on;                       
xlim([0 Fs/2]);                
ylabel('Polar NRZ');           
subplot(6,1,2);                
[P2,f] = pwelch(s2, [], [], [], Fs); 
plot(f, 10*log10(P2), 'LineWidth', 1);
grid on;                       
xlim([0 Fs/2]);                
ylabel('Inverted NRZ');        
subplot(6,1,3);                
[P3,f] = pwelch(s3, [], [], [], Fs);
plot(f, 10*log10(P3), 'LineWidth', 1); 
grid on;                       
xlim([0 Fs/2]);                
ylabel('Polar RZ');            
subplot(6,1,4);                
[P4,f] = pwelch(s4, [], [], [], Fs); 
plot(f, 10*log10(P4), 'LineWidth', 1); 
grid on;                      
xlim([0 Fs/2]);               
ylabel('Bipolar NRZ');        
subplot(6,1,5);               
[P5,f] = pwelch(s5, [], [], [], Fs);
plot(f, 10*log10(P5), 'LineWidth', 1); 
grid on;                       
xlim([0 Fs/2]);                
ylabel('Bipolar RZ');          
subplot(6,1,6);                
[P6,f] = pwelch(s6, [], [], [], Fs); 
plot(f, 10*log10(P6), 'LineWidth', 1); 
grid on;                       
xlim([0 Fs/2]);                
ylabel('Manchester');          
xlabel('Frequency (Hz)');      
sgtitle('Power spectral density of the line codes');

disp('Random bits:');    
disp(data);              
