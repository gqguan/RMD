function [particles,outTab] = Trajectory1(tspan,membrane,particle,fluid)
global COMVars
COMVars.colorID = COMVars.colorID+1;
y0 = zeros(6,1); % z�����ٶȡ�z����λ�á�r�����ٶȡ�r����λ�á�theta�����ٶȡ�theta����λ��
y0(2) = particle.Position(1);
y0(4) = particle.Position(2);
y0(6) = particle.Position(3);
y0(1) = particle.Velocity(1);
y0(3) = particle.Velocity(2);
y0(5) = particle.Velocity(3);
y0(7) = particle.Volume;
[t,y] = ode45(@(t,y) motionEq(t,y,membrane,particle,fluid), tspan, y0);
% ��������켣
particles = struct;
for i = 1:length(t)
    particles(i).Time = t(i);
    particle.Position = [y(i,2),y(i,4),y(i,6)];
    particle.Velocity = [y(i,1),y(i,3),y(i,5)];
    particle.Volume = y(i,7);
    particles(i).Spec = particle;
end

% �б�������
outTab = table(t,y(:,2),y(:,4),y(:,6),'VariableNames',{'time','Xz','Xr','Xtheta'});
outTab = [outTab,table(y(:,1),y(:,3),y(:,5),'VariableNames',{'Vz','Vr','Vtheta'})];
% % ���㵱ǰ����ʱ���ڿ����Ƿ�����Ĥ�沢������ֵ���������ʱ��
% if max(y(:,2))>membrane.H
%     % ��ֵ����Ҫ���ѯ����Ϊ���ظ������������ظ���Ҫ��ſ�Ϊ������0��
%     idx = (y(:,2) ~= 0 & ~isnan(y(:,2)) & ~isinf(y(:,2))); 
%     rt = interp1(y(idx,2), t(idx), membrane.H);
%     fprintf('ת��Ϊ%dRPMʱ��������Ĥ�澭����ʱ��Ϊ%.3e�룡\n', operation.Rotation.Speed, rt)
% else
%     fprintf('ת��Ϊ%dRPMʱ�ڿ���ʱ���ڿ���δ����Ĥ�棡\n', operation.Rotation.Speed)
% end
% % �����켣
% if isempty(findobj('Name','������Ĥ�滬�ƵĹ켣')) 
%     figure('name', '������Ĥ�滬�ƵĹ켣');
% else
%     figure(1);
% end
% plotName = sprintf('%dRPM',operation.Rotation.Speed);
% plot(y(:,6),y(:,2),'ro','DisplayName',plotName,'Color',COMVars.colors(COMVars.colorID,:))
% axis([-membrane.W/2, membrane.W/2, 0, membrane.H])
% xlabel('$\theta R$ (m)', 'interpreter', 'latex')
% ylabel('$z$ (m)', 'interpreter', 'latex')
% hold on
% legend;
% 
% % �����س������仯
% FCs = arrayfun(@(x)CalcForce(operation,x,fluid,membrane),[particles.Spec],'UniformOutput',false);
% FCs = reshape(FCs,length(FCs),1); % ȷ����������
% Fz = cellfun(@(x)x(1),FCs);
% Fr = cellfun(@(x)x(2),FCs);
% Ftheta = cellfun(@(x)x(3),FCs);
% % �б����
% outTab = [outTab,table(Fz,Fr,Ftheta)];
% % ��ͼ���
% figName = sprintf('ת��Ϊ%dRPMʱ������Ĥ�滬�Ƶ��������',operation.Rotation.Speed);
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
    % ���¿���λ��
    particle.Position = [y(2),y(4),y(6)];
    % ���¿����ٶ�
    particle.Velocity = [y(1),y(3),y(5)];
    % ���¿������
    particle.Volume = y(7);
    % �����������
    force = CalcForce1(membrane,particle,fluid);
    m = particle.Mass;
    dy = zeros(6,1);
    dy(1) = force(1)/m; 
    dy(2) = y(1);
    dy(3) = force(2)/m;
    dy(4) = y(3);
    dy(5) = force(3)/m;
    dy(6) = y(5);
    dy(7) = 0;
end