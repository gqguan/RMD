function [dV] = ParticleGrowth(particle, membrane)
load('GD.mat','GD') % ¦����ṩ�Ŀ���������������
RPM = [0,10,20,30,40,50]; 
Z = GD(:,1);                                                                                 
V = GD(:,2:7);
%����RPM��x�õ���Ӧ��������
xg = membrane.Velocity(3)/(2*pi*membrane.Radium)*60;
yg = particle.Position(1)-membrane.Z0; % ��Ĥ�����ϵ�Ϊԭ��ת��ΪĤ��λ��
de = particle.Size*2;
if yg < min(Z) || yg > max(Z)
    dd = 0;
else
    dd = interp2(RPM,Z,V,xg,yg,'spline'); % �����ߴ磨���������ֱ��������λ��m/s
    if dd < 0
    %     warning('ParticleGrowth()����ÿ�����������Ϊ��ֵ������Ϊ��')
        dd = 0;
    end
end
% �����������仯�ʣ���λ��m3/s
dV = pi/2*de^2*dd; 
% dV = pi/6*dd^3;

% Naillon A, et al. http://dx.doi.org/10.1016/j.jcrysgro.2015.04.010
% dL/dt = Kcr*(S-1)^gcr, where Kcr = Ccr*exp(-Ea/R/T), Ccr = 1.14e4 m/s, Ea =
% 58180 J/mol, and gcr = 1