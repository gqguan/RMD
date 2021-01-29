function argout = effect_RPM_K(speeds, edgeLengths, operation, particle, fluid, membrane)
i = 1;
operation.Rotation.Speed = speeds(i);
operation.Rotation.AngularVelocity = operation.Rotation.Speed/2/pi/60;
plotName = sprintf('%drpm',speeds(i));
% 计算不同颗粒尺寸的静摩擦力系数
argout = CalcK(edgeLengths, operation, particle, fluid, membrane, plotName);
argout = repmat(argout,length(speeds),1);
for i = 2:length(speeds)
    operation.Rotation.Speed = speeds(i);
    operation.Rotation.AngularVelocity = operation.Rotation.Speed/2/pi/60;
    plotName = sprintf('%drpm',speeds(i));
    % 计算不同颗粒尺寸的静摩擦力系数
    argout(i,:) = CalcK(edgeLengths, operation, particle, fluid, membrane, plotName);
end
hold off
