%% ��תĤ������������������
%
% by Dr. Guoqiang Guan @ SCUT on 2021-1-13

%% ��ʼ��
clear
global COMVars
COMVars.colorID = 1;
COMVars.colors = hsv(1);

% �������
m1 = membrane('PVDF');
p1 = particle1('NaCl');
f1 = fluid('Water');

% ��ʼ����
m1.Z0 = 5e-2; % Ĥ����Ե����Һ��ľ��루m��
m1.Radium = 20e-3; % תͲ�뾶��m��
m1.Velocity = [0 0 20*2*pi*m1.Radium/60]; % Ĥ����ת�ٶ� Vtheta = 20rpm�����ٶ�
p1.Velocity = m1.Velocity; % ��ʼ�����˶��ٶ� = Ĥ���˶��ٶȣ���������Ĥ����Ծ�ֹ
p1.Position = [m1.Z0,m1.Radium,0]+p1.Position;
p1.Volume = (10e-6)^3; % �������
f1.Velocity = [0 0 0]; % �����ٶ�

%% ��������˶��仯
tspan = [0 100];
% ��������˶��켣������λ��ÿ���¼һ�Σ�
outTab = table;
if tspan(2) > 1
    for iTS = 1:floor(tspan(2))
        [p2s,tab2s] = Trajectory1([tspan(1)+iTS-1,tspan(1)+iTS],m1,p1,f1);
        Particle = p2s(end).Spec; p1 = Particle;
        outTab = [outTab;[tab2s(end,:),table(Particle)]];
    end
end

%% �����켣
% ��ָ����ͼ�����л��켣
if isempty(findobj('Name','������Ĥ�滬�ƵĹ켣')) 
    figure('name', '������Ĥ�滬�ƵĹ켣');
else
    figure(1);
end
plotName = sprintf('%.1f RPM',m1.Velocity(3)/(2*pi*m1.Radium/60));
plot(outTab.Xtheta,outTab.Xz,'ro','DisplayName',plotName,'Color',COMVars.colors(COMVars.colorID,:))
axis([-m1.Width/2, m1.Width/2, 0, m1.Height+m1.Z0])
xlabel('$\theta R$ (m)', 'interpreter', 'latex')
ylabel('$z$ (m)', 'interpreter', 'latex')
hold on
legend;

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

