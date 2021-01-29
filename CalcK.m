function argout = CalcK(edgeLengths,operation,particle,fluid,membrane,plotName)
%% 检查输入参数
if ~exist('plotName','var')
    plotName = 'Unnamed';
end
%% 考查不同颗粒尺寸的静摩擦力系数
% edgeLengths = 10.^linspace(-7,-3); % 正六面体颗粒的边长
% edgeLengths = 100e-6;
argout = arrayfun(@(x) setParticleSize(x), edgeLengths);
% 绘图输出
% 每次调用CalcK()都检查是否已有名为'摩擦力系数随颗粒尺寸的变化曲线'的figure对象，
% 若无则新建该对象。由此防止在多个同名但序号不同的figure中分别绘制摩擦力系数随颗粒
% 尺寸的变化曲线
if isempty(findobj('Name','摩擦力系数随颗粒尺寸的变化曲线')) 
    figure('name', '摩擦力系数随颗粒尺寸的变化曲线')
end
plot(edgeLengths,[argout.K],'DisplayName',plotName)
xlabel('$L$ (m)','interpreter','latex');
ylabel('$K$ (dimensionless)','interpreter','latex');
if ~strcmp(plotName,'Unnamed')
    legend boxoff;
end
hold on

function argout = setParticleSize(L)
    particle.Volume = L^3;
    particle.Mass = particle.Density*particle.Volume; % 质量（kg）
    particle.EqvSize = (particle.Volume/(4/3*pi))^(1/3); % 等体积球体半径（m）
    particle.Interface = L^2; % 液固界面积（m2）
    % 计算维持膜面颗粒相对静止的摩擦力系数
    [~,argout] = CalcForce(operation,particle,fluid,membrane,'stationary');
end

end