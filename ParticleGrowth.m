function [dV] = ParticleGrowth(particle, membrane)
load('GD.mat','GD') % ¦����ṩ�Ŀ���������������
RPM = [0,10,20,30,40,50]; 
Z = GD(:,1);                                                                                 
V = GD(:,2:7);
%����RPM��x�õ���Ӧ��������
xg = membrane.Velocity(3)/(2*pi*membrane.Radium)*60;
yg = particle.Position(1)-membrane.Z0; % ��Ĥ�����ϵ�Ϊԭ��ת��ΪĤ��λ��
dd = interp2(RPM,Z,V,xg,yg,'spline'); % �����ߴ磨���������ֱ��������λ��m/s
if dd < 0
%     warning('ParticleGrowth()����ÿ�����������Ϊ��ֵ������Ϊ��')
    dd = 0;
end
% �����������仯�ʣ���λ��m3/s
dV = pi/6*dd^3; 
