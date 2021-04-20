%% ��תĤ������������������
%
% by Dr. Guoqiang Guan @ SCUT on 2021-1-13

%% ��ʼ��
clear
global COMVars
COMVars.colorID = 0;

% �������
m1 = membrane('PVDF');
p1 = particle1('NaCl');
f1 = fluid('Water');

% ��ʼ����
m1.Z0 = 5e-2; % Ĥ����Ե����Һ��ľ��루m��
m1.Radium = 10e-3; % תͲ�뾶��m��
m1.Velocity = [0 0 50*2*pi*m1.Radium]; % Ĥ����ת�ٶ� Vtheta = 50rpm�����ٶ�
p1.Velocity = m1.Velocity; % ��ʼ�����˶��ٶ� = Ĥ���˶��ٶȣ���������Ĥ����Ծ�ֹ
p1.Position = [m1.Z0,m1.Radium,0]+p1.Position;
p1.Volume = (10e-6)^3; % �������
f1.Velocity = [0 0 0]; % �����ٶ�

%% ��������˶��仯
tspan = [0 1];
% �����˶��켣
[particles,outTab] = Trajectory1(tspan,m1,p1,f1);

% % ��������
% particle.Form = '������';
% particle.Density = 2.165e3; % �ܶȣ�kg/m3��
% particle.Volume = (10e-6)^3; % �����m3��
% particle.Mass = particle.Density*particle.Volume; % ������kg��
% particle.EqvSize = (particle.Volume/(4/3*pi))^(1/3); % ���������뾶��m��
% particle.Interface = particle.Volume^(2/3); % Һ�̽������m2��
% particle.Position = [0,operation.Rotation.Radium,0]; % ����(z,r,theta)
% [particle,operation] = InitParticle(operation,particle); % ������ʼ������Ĥ�棬��Ĥ����ת��������Ϊ����ϵ��
% % ��������
% fluid.Viscosity = 1e-3;
% fluid.Density = 1e3;
% fluid.Velocity = [0,0,0]; % �����ʼΪ��ֹ
% % Ĥ������
% membrane.Roughness = 1e-8;
% membrane.KS = 0.2e-3; % ��Ħ����ϵ��
% membrane.KM = 1e-5; % ��Ħ����ϵ��
% membrane.H = 40e-3; % Ĥ��ߴ�H
% membrane.W = 2*pi*operation.Rotation.Radium; % Ĥ��ߴ�W

%% ���鲻ͬת���¾�Ħ����ϵ��������ߴ�Ĺ�ϵ
% % �����ߴ緶Χ����������������ı߳�����
% edgeLengths = 10.^linspace(-7,-2);
% % ���㿼��ߴ緶Χ�ڿ�����Ĥ������������ٽ�ת��
% RPMs = CalcRPM(edgeLengths, operation, particle, fluid, membrane);
% % ת�ٷ�Χ
% speeds = 10.^(1:4);
% % �ֱ�����ת����ά�ֿ������Ĥ�澲ֹʱ��Ħ����ϵ��������ߴ�Ĺ�ϵ
% argout1 = effect_RPM_K(speeds, edgeLengths, operation, particle, fluid, membrane);

%% ��������˶�
% % ת�ٷ�Χ
% speeds = 10.^(1:4);
% COMVars.colors = hsv(length(speeds));
% ����ʱ����
% tspan = [0,1200.0];
% for i = 1:length(speeds)
%     operation.Rotation.Speed = speeds(i);
%     particle = InitParticle(operation,particle);
%     [particles,outTab] = Trajectory(tspan,operation,particle,fluid,membrane);
% end

% % ��ʼλ��
% pos = membrane.H/4*(0:3);
% COMVars.colors = hsv(length(pos));
% for i = 1:length(pos)
%     particle.Position(1) = pos(i);
%     [particles,outTab] = Trajectory(tspan,operation,particle,fluid,membrane);
% end

%% ���

