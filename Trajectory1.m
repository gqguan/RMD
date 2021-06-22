function [particles,outTab] = Trajectory1(tspan,membrane,particle,fluid)
% global COMVars
% COMVars.colorID = COMVars.colorID+1;
y0 = zeros(6,1); % z方向速度、z方向位置、r方向速度、r方向位置、theta方向速度、theta方向位置
y0(2) = particle.Position(1);
y0(4) = particle.Position(2);
y0(6) = particle.Position(3);
y0(1) = particle.Velocity(1);
y0(3) = particle.Velocity(2);
y0(5) = particle.Velocity(3);
y0(7) = particle.Volume;
opts = odeset('RelTol',1e-10,'AbsTol',1e-20);
[t,y] = ode15s(@(t,y) motionEq(t,y,membrane,particle,fluid), tspan, y0, opts);
% 输出颗粒轨迹
particles = struct;
for i = 1:length(t)
    particles(i).Time = t(i);
    particle.Position = [y(i,2),y(i,4),y(i,6)];
    particle.Velocity = [y(i,1),y(i,3),y(i,5)];
    particle.Volume = y(i,7);
    particles(i).Spec = copyobj(particle);
end

% 列表输出结果
outTab = table(t,y(:,2),y(:,4),y(:,6),'VariableNames',{'time','Xz','Xr','Xtheta'});
outTab = [outTab,table(y(:,1),y(:,3),y(:,5),'VariableNames',{'Vz','Vr','Vtheta'})];
% % 计算当前考查时间内颗粒是否脱离膜面并进而插值计算的脱离时间
% if max(y(:,2))>membrane.H
%     % 插值计算要求查询序列为不重复的有理数（重复性要求放宽为不等于0）
%     idx = (y(:,2) ~= 0 & ~isnan(y(:,2)) & ~isinf(y(:,2))); 
%     rt = interp1(y(idx,2), t(idx), membrane.H);
%     fprintf('转速为%dRPM时颗粒滑出膜面经历的时间为%.3e秒！\n', operation.Rotation.Speed, rt)
% else
%     fprintf('转速为%dRPM时在考查时间内颗粒未滑出膜面！\n', operation.Rotation.Speed)
% end
% 画出轨迹
% if isempty(findobj('Name','颗粒在膜面滑移的轨迹')) 
%     figure('name', '颗粒在膜面滑移的轨迹');
% else
%     figure(1);
% end
% plotName = sprintf('%dRPM',membrane.Velocity(3)/(2*pi*membrane.Radium/60));
% plot(y(:,6),y(:,2),'ro','DisplayName',plotName,'Color',COMVars.colors(COMVars.colorID,:))
% axis([-membrane.Width/2, membrane.Width/2, 0, membrane.Height])
% xlabel('$\theta R$ (m)', 'interpreter', 'latex')
% ylabel('$z$ (m)', 'interpreter', 'latex')
% hold on
% legend;
% 
% % 颗粒沿程受力变化
% FCs = arrayfun(@(x)CalcForce(operation,x,fluid,membrane),[particles.Spec],'UniformOutput',false);
% FCs = reshape(FCs,length(FCs),1); % 确保以列向量
% Fz = cellfun(@(x)x(1),FCs);
% Fr = cellfun(@(x)x(2),FCs);
% Ftheta = cellfun(@(x)x(3),FCs);
% % 列表输出
% outTab = [outTab,table(Fz,Fr,Ftheta)];
% % 绘图输出
% figName = sprintf('转速为%dRPM时颗粒在膜面滑移的受力情况',operation.Rotation.Speed);
% figure('name', figName);
% subplot(3,1,1)
% plot([particles.Time],Fz,'Color',COMVars.colors(COMVars.colorID,:))
% xlabel('$t$ (s)','interpreter','latex')
% ylabel('$F_z$ (N)','interpreter','latex')
% subplot(3,1,2)
% plot([particles.Time],Fr,'Color',COMVars.colors(COMVars.colorID,:))
% xlabel('$t$ (s)','interpreter','latex')
% ylabel('$F_r$ (N)','interpreter','latex')
% subplot(3,1,3)
% plot([particles.Time],Ftheta,'Color',COMVars.colors(COMVars.colorID,:))
% xlabel('$t$ (s)','interpreter','latex')
% ylabel('$F_{\theta}$ (N)','interpreter','latex')

end

function dy = motionEq(t,y,membrane,particle,fluid)
    % 更新颗粒位置
    particle.Position = [y(2),y(4),y(6)];
    % 更新颗粒速度
    particle.Velocity = [y(1),y(3),y(5)];
    % 更新颗粒体积
    particle.Volume = y(7);
    % 计算颗粒受力
    force = CalcForce1(membrane,particle,fluid);
    m = particle.Mass;
    dy = zeros(6,1);
    dy(1) = force(1)/m; 
    dy(2) = y(1);
    dy(3) = force(2)/m;
    dy(4) = y(3);
    dy(5) = force(3)/m;
    dy(6) = y(5);
    dy(7) = ParticleGrowth(particle,membrane);
end