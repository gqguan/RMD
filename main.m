%% ��תĤ������������������
%
% by Dr. Guoqiang Guan @ SCUT on 2021-1-13

%% ��ʼ��
clear
% ��������
operation.Rotation.Radium = 10e-3; % תͲ�뾶��m��
operation.Rotation.Speed = 50; % ת�٣�rpm��
operation.Rotation.AngularVelocity = operation.Rotation.Speed/2/pi/60; % ���ٶȣ�rad/s��
operation.Inlet.Velocity = 0; % �������٣���z�����ٶȣ�m/s��
operation.Z0 = 5e-2; 
% ��������
particle.Form = '������';
particle.Density = 2.165e3; % �ܶȣ�kg/m3��
particle.Volume = 1e-6; % �����m3��
particle.Mass = particle.Density*particle.Volume; % ������kg��
particle.EqvSize = (particle.Volume/(4/3*pi))^(1/3); % ���������뾶��m��
particle.Interface = particle.Volume^(2/3); % Һ�̽������m2��
particle.Position = [0,operation.Rotation.Radium,0]; % ����(z,r,theta)

% ��������
fluid.Viscosity = 1e-3;
fluid.Density = 1e3;
% Ĥ������
membrane.Roughness = 1e-8;
membrane.KS = 1e-1; % ��Ħ����ϵ��
membrane.KM = 1e-2; % ��Ħ����ϵ��
membrane.H = 40e-3; % Ĥ��ߴ�H
membrane.W = 2*pi*operation.Rotation.Radium; % Ĥ��ߴ�W

%% ��������˶�
tspan = [0,1.0];
particles = Trajectory(tspan,operation,particle,fluid,membrane);

%% ���
