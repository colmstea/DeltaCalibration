function [t_err, r_err, t_m_err, r_m_err] = genTestCal(N,angle,noise)
clc;
A = RandomTransform6D(3.14159, .5)';

%N = 10;
max_delta_angle = angle / 180 * pi;
max_delta_translation = 0.2;
noise_angular = (1.0 *noise) / 180 * pi;
noise_translation = 0.01 * noise;

A1 = [0 0 0 0 0 0 0 0];
A1I = [];
A2 = [0 0 0 0 0 0 0 0];
A2I = [];
V1 = [1000 1000 1000 1000 1000 1000];
V2 = [1000 1000 1000 1000 1000 1000];
T1 = [0 0 0 0 0 0];
T2 = [0 0 0 0 0 0];
empty = [1 1 1 1 1 1];
variance = [0 0 0 0 0 0];
var = [noise_angular noise_angular noise_angular noise_translation noise_translation noise_translation];
last_t1 = [0 0 0 0 0 0];
last_t2 = [0 0 0 0 0 0];
time = [0];
count = 0;
for i=1:N
  a1 = RandomTransform6D(max_delta_angle, max_delta_translation)'
  tr1 = rotm2aa(aa2rotm(a1(1:3)') * aa2rotm(last_t1(1:3)'));
  tt1 = a1(4:6) + last_t1(4:6)
  t1 = [tr1 tt1]
  a1 = AddNoiseToTransform6D(a1', noise_angular, noise_translation)'
  a1 = [a1 0 0];
  A1 = [A1; a1 ];
  a2 = A1toA2(A', a1');
  a2 = AddNoiseToTransform6D(a2', noise_angular, noise_translation)';
  a2 = [a2 0 0];
  tr2 = rotm2aa(aa2rotm(a2(1:3)') * aa2rotm(last_t2(1:3)'));
  tt2 = a2(4:6) + last_t2(4:6);
  t2 = [tr2 tt2];
  T1 = [T1; t1];
  T2 = [T2; t2];
  A2 = [A2; a2];
  last_t1 = t1;
  last_t2 = t2;
  V1 = [V1; var];
  V2 = [V2; var];
  time = [time; count + 1];
end

%% ===========================================
% Test Calibration Math with generated data.
C0 = [A1 A2]
A1
A2
% kinectData = struct('folder', '', 'files', [], 'time', time, 'type', 'kinect', 'T_Skm1_Sk', A1(:,1:6), 'T_S1_Sk', T1, 'T_Var_Skm1_Sk', V1, 'T_Var_S1_Sk', V2);
% save('multi-array-calib/storedTforms/GenKinectData.mat', 'kinectData');
% odomData = struct('folder', '', 'files', [], 'time', time, 'type', 'nav', 'T_Skm1_Sk', A2(:,1:6), 'T_S1_Sk', T2, 'T_Var_Skm1_Sk', V2, 'T_Var_S1_Sk', V2);
% save('multi-array-calib/storedTforms/GenNavData.mat', 'odomData');
size(C0)
dlmwrite('generated_deltas.txt', C0, ' ');

A
% B_cal = Test3KinectNav();

A_cal = calibrate_data(C0);
% A_multiCal = [B_cal.rot B_cal.tran];
A_cal
A
% A_multiCal = A_multiCal(2,:)
% Compute angular error
error_aa = rotm2aa(inv(aa2rotm(A(1:3)')) * aa2rotm(A_cal(1:3)'));
r_err = norm(error_aa) / pi * 180
% error_aa_multical = rotm2aa(inv(aa2rotm(A(1:3)')) * aa2rotm(A_multiCal(1:3)'));
% r_m_err = norm(error_aa_multical) / pi * 180
% Compute translation error
t_err = norm(A(4:6) - A_cal(4:6))
% t_m_err = norm(A(4:6) - A_multiCal(4:6))
