function [Vg] =ParticleGrowth(particle, operation)
load('GD.mat')
x=[0,10,20,30,40,50];
y=GD(:,1);
V=GD(:,2:7);
%% 绘制三维分布图
figure(1);
[x,y]=meshgrid(x,y);
mesh(x,y,V);
xlabel('x');
ylabel('y');
%根据RPM与x得到对应生长速率
xg=operation.Rotation.Speed;
yg=particle.Position(1);
Vg=interp2(x,y,V,xg,yg,'linear');

end
