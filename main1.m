%% 旋转膜面表面颗粒的受力分析
%
% by Dr. Guoqiang Guan @ SCUT on 2021-1-13

%% 初始化
clear
global COMVars
COMVars.colorID = 1;
COMVars.colors = hsv(1);

%% 定义对象
m1 = membrane('PVDF');
p1 = particle1('NaCl');
f1 = fluid('Water');

% 初始条件
m1.Z0 = 5e-2; % 膜面上缘距离液面的距离（m）
m1.Radium = 20e-3; % 转筒半径（m）
m1.Velocity = [0 0 20*2*pi*m1.Radium/60]; % 膜面旋转速度 Vtheta = 20rpm的线速度
p1.Velocity = m1.Velocity; % 初始颗粒运动速度 = 膜面运动速度，即颗粒与膜面相对静止
p1.Position = [m1.Z0,m1.Radium,0]+p1.Position;
p1.Volume = (10e-6)^3; % 颗粒体积
f1.Velocity = [0 0 0]; % 主流速度

%% 计算颗粒运动变化
tspan = [0 700];
% 计算颗粒运动轨迹（颗粒位置每秒记录一次）
wbCtrl = waitbar(0,'初始化','Name','计算颗粒运动');
Size = 0;
outTab = table;
if tspan(2) > 1
    for iTS = 1:floor(tspan(2))
        [p2s,tab2s] = Trajectory1([tspan(1)+iTS-1,tspan(1)+iTS],m1,p1,f1);
        Particle = p2s(end).Spec; p1 = Particle; Size = Particle.Size;
        outTab = [outTab;[tab2s(end,:),table(Size),table(Particle)]];
        waitbar(iTS/floor(tspan(2)),wbCtrl,sprintf('计算进度（已完成%.f%%）',iTS/floor(tspan(2))*100))
    end
end
close(wbCtrl)

%% 画出轨迹
% 在指定绘图对象中画轨迹
if isempty(findobj('Name','颗粒在膜面滑移的轨迹')) 
    figure('name', '颗粒在膜面滑移的轨迹');
else
    figure(1);
end
plotName = sprintf('%.1f RPM',m1.Velocity(3)/(2*pi*m1.Radium/60));
plot(outTab.Xtheta,outTab.Xz,'ro','DisplayName',plotName,'Color',COMVars.colors(COMVars.colorID,:))
axis([-m1.Width/2, m1.Width/2, 0, m1.Height+m1.Z0])
xlabel('$\theta R$ (m)', 'interpreter', 'latex')
ylabel('$z$ (m)', 'interpreter', 'latex')
hold on
legend;

%% 考查不同转速下静摩擦力系数与颗粒尺寸的关系
% % 颗粒尺寸范围，按正六面体颗粒的边长计算
% edgeLengths = 10.^linspace(-7,-2);
% % 计算考查尺寸范围内颗粒从膜面离心脱离的临界转速
% RPMs = CalcRPM(edgeLengths, operation, particle, fluid, membrane);
% % 转速范围
% speeds = 10.^(1:4);
% % 分别计算各转速下维持颗粒相对膜面静止时，摩擦力系数与颗粒尺寸的关系
% argout1 = effect_RPM_K(speeds, edgeLengths, operation, particle, fluid, membrane);

%% 计算颗粒运动
% % 转速范围
% speeds = 10.^(1:4);
% COMVars.colors = hsv(length(speeds));
% 考查时间跨度
% tspan = [0,1200.0];
% for i = 1:length(speeds)
%     operation.Rotation.Speed = speeds(i);
%     particle = InitParticle(operation,particle);
%     [particles,outTab] = Trajectory(tspan,operation,particle,fluid,membrane);
% end

% % 初始位置
% pos = membrane.H/4*(0:3);
% COMVars.colors = hsv(length(pos));
% for i = 1:length(pos)
%     particle.Position(1) = pos(i);
%     [particles,outTab] = Trajectory(tspan,operation,particle,fluid,membrane);
% end

%% 输出

