function [dV] = ParticleGrowth(particle, operation)
load('GD.mat','GD') % 娄瀚文提供的颗粒生长速率数据
x=[0,10,20,30,40,50]; 
y=GD(:,1);                                                                                 
V=GD(:,2:7);
%根据RPM与x得到对应生长速率
xg=operation.Rotation.Speed;
yg=particle.Position(1);
dd=interp2(x,y,V,xg,yg,'linear'); % 颗粒尺寸（等球体积的直径），单位：m/s
% 输出颗粒体积变化率，单位：m3/s
dV = pi/6*dd^3; 
end
