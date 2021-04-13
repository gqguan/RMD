function [VG,argout] =ParticleGrowth(particle, operation)
filename=('D:\OneDrive\BYLW\第四章\生长速率 .xlsx');
G=xlsread(filename,'A2:G163');
x=G(:,1);
y=G(:,(operation.Rotation.Speed/10+2));
VG=interp1(x,y,0.02)
end
