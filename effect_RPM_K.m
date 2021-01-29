function argout = effect_RPM_K(speeds, edgeLengths, operation, particle, fluid, membrane)
%
i = 1;
operation.Rotation.Speed = speeds(i);
[particle,operation] = InitParticle(operation,particle);
plotName = sprintf('%drpm',speeds(i));
% 计算不同颗粒尺寸的静摩擦力系数
argout = CalcK(edgeLengths, operation, particle, fluid, membrane, plotName);
% 分析所考查转速是否存在颗粒沿膜面法方向运动（离心脱离）
idx = find(isnan([argout.K]),1);
if ~isempty(idx)
    fprintf('边长大于%.4em的颗粒在%dRPM下离心脱离！\n',edgeLengths(idx),speeds(i))
end
argout = repmat(argout,length(speeds),1);
for i = 2:length(speeds)
    operation.Rotation.Speed = speeds(i);
    [particle,operation] = InitParticle(operation,particle);
    plotName = sprintf('%drpm',speeds(i));
    % 计算不同颗粒尺寸的静摩擦力系数
    argout(i,:) = CalcK(edgeLengths, operation, particle, fluid, membrane, plotName);
    % 分析所考查转速是否存在颗粒沿膜面法方向运动（离心脱离）
    idx = find(isnan([argout(i,:).K]),1);
    if ~isempty(idx)
        fprintf('边长大于%.4em的颗粒在%dRPM下将离心脱离！\n',edgeLengths(idx),speeds(i))
    end
end
hold off
