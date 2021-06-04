function [dV] = ParticleGrowth(particle, membrane)
load('GD.mat','GD') % 娄瀚文提供的颗粒生长速率数据
RPM = [0,10,20,30,40,50]; 
Z = GD(:,1);                                                                                 
V = GD(:,2:7);
%根据RPM与x得到对应生长速率
xg = membrane.Velocity(3)/(2*pi*membrane.Radium)*60;
yg = particle.Position(1)-membrane.Z0; % 以膜面左上点为原点转换为膜面位置
if yg < min(Z) || yg > max(Z)
    dd = 0;
else
    dd = interp2(RPM,Z,V,xg,yg,'spline'); % 颗粒尺寸（等球体积的直径），单位：m/s
    if dd < 0
    %     warning('ParticleGrowth()计算得颗粒生长速率为负值，重置为零')
        dd = 0;
    end
end
% 输出颗粒体积变化率，单位：m3/s
dV = pi/6*dd^3; 
