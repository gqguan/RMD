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
[particle,operation] = InitParticle(operation,particle); % 颗粒初始附着于膜面，随膜面旋转（正方向为右手系）
% 流体性质
fluid.Viscosity = 1e-3;
fluid.Density = 1e3;
fluid.Velocity = [0,0,0]; % 流体初始为静止
% 膜面性质
membrane.Roughness = 1e-8;
membrane.KS = 0.2e-3; % 静摩擦力系数
membrane.KM = 1e-5; % 动摩擦力系数
membrane.H = 40e-3; % 膜面尺寸H
membrane.W = 2*pi*operation.Rotation.Radium; % 膜面尺寸W

%% 考查不同转速下静摩擦力系数与颗粒尺寸的关系
% 颗粒尺寸范围，按正六面体颗粒的边长计算
edgeLengths = 10.^linspace(-7,-2);
% 计算考查尺寸范围内颗粒从膜面离心脱离的临界转速
RPMs = CalcRPM(edgeLengths, operation, particle, fluid, membrane);
% 转速范围
speeds = 10.^(1:4);
% 分别计算各转速下维持颗粒相对膜面静止时，摩擦力系数与颗粒尺寸的关系
argout1 = effect_RPM_K(speeds, edgeLengths, operation, particle, fluid, membrane);

%% 计算颗粒运动
% % 转速范围
% speeds = 10.^(1:4);
% % 考查时间跨度
% tspan = [0,1.0];
% for i = 1:length(speeds)
%     operation.Rotation.Speed = speeds(i);
%     particle = InitParticle(operation,particle);
%     [particles,outTab] = Trajectory(tspan,operation,particle,fluid,membrane);
% end

%% 输出

