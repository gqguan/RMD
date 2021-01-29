function [particles,outTab] = Trajectory(tspan,operation,particle,fluid,membrane)

y0 = zeros(6,1); % z方向速度、z方向位置、r方向速度、r方向位置、theta方向速度、theta方向位置
y0(2) = particle.Position(1);
y0(4) = particle.Position(2);
y0(6) = particle.Position(3);
y0(1) = particle.Velocity(1);
y0(3) = particle.Velocity(2);
y0(5) = particle.Velocity(3);
[t,y] = ode45(@(t,y) motionEq(t,y,operation,particle,fluid,membrane), tspan, y0);
% 输出颗粒轨迹
particles = struct;
for i = 1:length(t)
    particles(i).Time = t(i);
    particle.Position(1) = y(2);
    particle.Position(2) = y(4);
    particle.Position(3) = y(6);
    particles(i).Spec = particle;
end

% 画出轨迹
outTab = table(t,y(:,2),y(:,6),'VariableNames',{'time','z','theta'});
if max(y(:,2))>membrane.H
    rt = interp1(y(:,2), t, membrane.H);
    fprintf('颗粒滑出膜面经历的时间为%.3e秒！\n', rt)
    figure('name', '颗粒在膜面滑移的轨迹')
    plot(y(:,6),y(:,2),'ro')
    axis([-membrane.W/2, membrane.W/2, 0, membrane.H])
    xlabel('$\theta R$ (m)', 'interpreter', 'latex')
    ylabel('$z$ (m)', 'interpreter', 'latex')
else
    fprintf('在考查时间内颗粒未滑出膜面！\n')
end


end

function dy = motionEq(t,y,operation,particle,fluid,membrane)
    % 更新颗粒位置
    particle.Position = [y(1),y(3),y(5)];
    % 更新颗粒速度
    particle.Velocity = [y(2),y(4),y(6)];
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