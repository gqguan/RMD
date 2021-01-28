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
y0 = zeros(6,1); % z方向速度、z方向位置、r方向速度、r方向位置、theta方向速度、theta方向位置
y0(2) = particle.Position(1);
y0(4) = particle.Position(2);
y0(6) = particle.Position(3);
[t,y] = ode45(@(t,y) motionEq(t,y,operation,particle,fluid,membrane), [0,1.0], y0);

%% 输出
% 画出轨迹
outTab = table(t,y(:,2),y(:,6),'VariableNames',{'time','z','theta'});
rt = interp1(y(:,2), y(:,6), membrane.H);
fprintf('颗粒滑出膜面经历的时间为%.3e秒！\n', rt)
figure('name', '颗粒在膜面滑移的轨迹')
plot(y(:,6),y(:,2),'ro')
axis([-membrane.W/2, membrane.W/2, 0, membrane.H])
xlabel('$\theta R$ (m)', 'interpreter', 'latex')
ylabel('$z$ (m)', 'interpreter', 'latex')
hold on
% rectangle('Position', [y(1,6), y(1,2), membrane.W, membrane.H])
% hold off

function dy = motionEq(t,y,operation,particle,fluid,membrane)
    % 更新颗粒位置
    particle.Position = [y(1),y(3),y(5)];
    % 计算颗粒受力
    force = CalcForce(operation,particle,fluid,membrane);
    m = particle.Mass;
    dy = zeros(6,1);
    dy(1) = force(1)/m; 
    dy(2) = y(1);
    dy(3) = force(2)/m;
    dy(4) = y(3);
    dy(5) = force(3)/m;
    dy(6) = y(5);
end

