function RPMs = CalcRPM(edgeLengths, operation, particle, fluid, membrane)
% 根据输入颗粒尺寸计算离心分离所需的转速
RPMs = arrayfun(@(x)fzero(@(RPM)CalcFn(RPM,x),1/x), edgeLengths);
% 绘图输出
figure('name','不同颗粒尺寸下的离心脱离转速')
plot(log10(edgeLengths), log10(RPMs), 'ro')
xlabel('$\log_{10}L$ (m)','interpreter','latex')
ylabel('$\log_{10}\Omega$ (RPM)','interpreter','latex')

function Fn = CalcFn(RPM,L)
    operation.Rotation.Speed = RPM;
    [particle,operation] = InitParticle(operation,particle); 
    particle.Volume = L^3;
    particle.Mass = particle.Density*particle.Volume; % 质量（kg）
    particle.EqvSize = (particle.Volume/(4/3*pi))^(1/3); % 等体积球体半径（m）
    particle.Interface = L^2; % 液固界面积（m2）  
    % 计算维持膜面颗粒相对静止的摩擦力系数
    [~,argout] = CalcForce(operation,particle,fluid,membrane,'stationary');
    Fn = (argout.F(5)-argout.F(1)-argout.F(2))*1e6;

end

end
