function [Vg] =ParticleGrowth(particle, operation)
load('GD.mat')
x=[0,10,20,30,40,50];
y=GD(:,1);
V=GD(:,2:7);
%% ������ά�ֲ�ͼ
figure(1);
[x,y]=meshgrid(x,y);
mesh(x,y,V);
xlabel('x');
ylabel('y');
%����RPM��x�õ���Ӧ��������
xg=operation.Rotation.Speed;
yg=particle.Position(1);
Vg=interp2(x,y,V,xg,yg,'linear');

end
