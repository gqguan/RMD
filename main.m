%% 旋转膜面表面颗粒的受力分析
%
% by Dr. Guoqiang Guan @ SCUT on 2021-1-13

%% 初始化
clear
% 操作条件
operation.Rotation.Radium = 10e-3; % 转筒半径（m）
operation.Rotation.Speed = 50; % 转速（rpm）
operation.Rotation.AngularVelocity = operation.Rotation.Speed/2/pi/60; % 角速度（rad/s）
operation.Inlet.Velocity = 0; % 进料流速（即z方向速度，m/s）
operation.Z0 = 5e-2; 
% 颗粒性质
particle.Form = '立方体';
particle.Density = 2.165e3; % 密度（kg/m3）
particle.Volume = 1e-6; % 体积（m3）
particle.Mass = particle.Density*particle.Volume; % 质量（kg）
particle.EqvSize = (particle.Volume/(4/3*pi))^(1/3); % 等体积球体半径（m）
particle.Interface = particle.Volume^(2/3); % 液固界面积（m2）
particle.Position = [0,operation.Rotation.Radium,0]; % 坐标(z,r,theta)

% 流体性质
fluid.Viscosity = 1e-3;
fluid.Density = 1e3;
% 膜面性质
membrane.Roughness = 1e-8;
membrane.KS = 1e-1; % 静摩擦力系数
membrane.KM = 1e-2; % 动摩擦力系数
membrane.H = 40e-3; % 膜面尺寸H
membrane.W = 2*pi*operation.Rotation.Radium; % 膜面尺寸W

%% 计算颗粒运动
tspan = [0,1.0];
particles = Trajectory(tspan,operation,particle,fluid,membrane);

%% 输出

