%% The Solution of Problem 4 
%  Author: Matsuyama
%  Time: 2019-09-25
%

%% Initialization
clear ; close all; clc

%% =============== Part 1: The root locus method is used to draw and Analyze the system stability ================

fprintf('Creating the function ...\n');

% Create the system function
G = tf(1, [conv([1, 1], [1, 2]), 0]);
rlocus(G, 'b'), title('Root Locus Plot of G(s) = K/[s(s+1)(s+2)]'), ;
hold on;
rlocus(-G, 'r'), title('Root Locus Plot of -G(s) = -K/[s(s+1)(s+2)]');

% System Stability Analysis
fprintf('Analyzing the system ...\n');
fprintf('When K > 0, First: Please select the point by Clicking, K > 0 is Blue Curve.\n');
[K, P] = rlocfind(G);
fprintf('When K > 0, the range of K can stabilize the system is: [0, %d]\n\n', K);
fprintf('\nWhen K < 0, Second: Please select the point by Clicking, K < 0 is Red Curve.\n');
[K, P] = rlocfind(-G);
fprintf('When K < 0, the range of K can stabilize the system is: [%d, 0]\n\n', K);


%% =============== Part 2: Design series calibration device for the system ================

fprintf('\nChecking whether the system need revise ...\n');

% Check the phase Angle stability margin and amplitude stability margin of the system before correction
k = 10;
G1 = tf(k, [1 3 2 0]);

%h0 is magnitude margin, gamma0 is phase margin
[h0, gamma0, wx, wc] = margin(G1);

flag = 0;
if gamma0 <= 45 || h0 <= 12
	fprintf('The system need revise\n');
	flag = 1;
% elseif k0 ~= 10
% 	fprintf('The system need revise\n');
% 	flag = 1;
else
	fprintf('The system neednt revise\n');
	fprintf('Program paused. Press enter to continue.\n');
	pause;
end

% Design calibrator
if flag
	w=0.001:0.001:100;
	[mag, phase]=bode(G1,w); 
	for t=1:1:100000 
		if(mag(1,1,t)-1<=0.00001)
			break;
		end 
		wct=t+1;
	end 
	gamma=180+phase(1,1,wct);
	for t=1:1:100000
		if(phase(1,1,t)+180<=0.00001)
			break
		end 
		wgt=t+1;
	end 
	h=-20*log10(mag(1,1,wgt));
	wc=wct/1000;
	wg=wgt/1000;
    gammal=40;
	delta=6;
	phim =gammal-gamma+delta;
	alpha=(1+sin(phim*pi/180))/(1-sin(phim*pi/180));
	magdb=20*log10(mag);
	wc=0; 
	for w=1:1:100000
		if(magdb(1,1,w)+10*log10(alpha)<=0.0001)
			break;
		end
		wc = w+1;
	end
	wcc = wc/1000;
	w3 = wcc/sqrt(alpha);
	w4 = sqrt(alpha)*wcc;
	numc1 = [1/w3, 1];
	denc1 = [1/w4, 1];
	Gc1 = tf(numc1, denc1);
	w1 = wcc/10;
	w2 = w1/alpha;
	numc2 = [1/w1, 1];
	denc2 = [1/w2, 1];
	Gc2 = tf(numc2, denc2);
	Gc12 = Gc1 * Gc2;
	Gk = Gc12 * G1;
	[h, r, wx, wc] = margin(Gk);
end

%% =============== Part 3: Give the transfer function of the calibration device ================

fprintf('Printing ...\n');
fprintf('The revised system function: ');

% Print
Gk

%% =============== Part 4: Amplitude-frequency characteristics before, after and after calibration ================
figure(2), margin(G1), title('Bode Diagram Before Revising');
figure(3), margin(Gk), title('Bode Diagram After Revising');


%% =============== Part 5: The crossing frequency, phase Angle margin and amplitude margin of the corrected system ================
fprintf('\nPrinting the data of the revised system ...\n');
fprintf('\nPhase Angle crossing frequency: %f\n', wc);
fprintf('\nAmplitude Angle crossing frequency: %f\n', wx);
fprintf('\nPhase margin: %f\n', r);
fprintf('\nAmplitude margin: %f\n\n', h);

%% =============== Part 6: Nyquist diagram of an open-loop system before and after system correction ================

% Nyquist Curve before Revising
fprintf('\n\nStarting plotting Nyquist Curve before Revising ...\n');
figure(4), nyquist(G), title('Nyquist Diagram Before Revising');
fprintf('\nThe closed loop of the system is unstable.\n');
fprintf('\nEnd plotting Nyquist Curve before Revising ...\n');


% Nyquist Curve after Revising
fprintf('\n\nStarting plotting Nyquist Curve after Revising ...\n');
figure(5), nyquist(Gk),title('Nyquist Diagram After Revising');
fprintf('\nThe closed loop of the system is stable.\n');
fprintf('\nEnd plotting Nyquist Curve after Revising ...\n');


fprintf('\n\nProgram paused. Press enter to continue.\n');
% pause;