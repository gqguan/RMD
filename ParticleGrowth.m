function [dV] = ParticleGrowth(particle, operation)
load('GD.mat','GD') % ¦����ṩ�Ŀ���������������
x=[0,10,20,30,40,50]; 
y=GD(:,1);                                                                                 
V=GD(:,2:7);
%����RPM��x�õ���Ӧ��������
xg=operation.Rotation.Speed;
yg=particle.Position(1);
dd=interp2(x,y,V,xg,yg,'linear'); % �����ߴ磨���������ֱ��������λ��m/s
% �����������仯�ʣ���λ��m3/s
dV = pi/6*dd^3; 
end
