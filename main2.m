%% 不同转速下，不同初始位置颗粒附着膜面的最大尺寸
clear
results = struct([]);
% 颗粒初始状态，其中
m2 = membrane('PVDF');
m2.Z0 = 5e-2; % 膜面上缘距离液面的距离（m）
m2.Radium = 20e-3; % 转筒半径（m）
f1 = fluid('Water');
f1.Velocity = [0 0 0]; % 主流速度

Position = linspace(0,m2.Height,5)';
Rotation = logspace(0,3)';
% 计算不同初始位置的最大附着颗粒
for k = 1:length(Position)
    CritSize = zeros(length(Rotation),1);
    EstVolSpan = zeros(length(Rotation),2);
    ResultantForce = zeros(length(Rotation),3);
    ForceComponent = table;
    % 估算各转速下附着膜面的最大颗粒体积
    for i = 1:length(Rotation)
        p2 = particle1('NaCl');
        m2.Velocity = [0 0 Rotation(i)*2*pi*m2.Radium/60]; % 膜面不旋转
        p2.Velocity = m2.Velocity; % 初始颗粒运动速度 = 膜面运动速度，即颗粒与膜面相对静止
        p2.Position = [Position(k) 0 0];
        p2.Position = [m2.Z0,m2.Radium,0]+p2.Position;
        % 计算不同颗粒尺寸下的受力情况
        Volume = (linspace(0.05,21.2)*1e-6).^3';
        RF_tmp = zeros(length(Volume),3);
        Size = zeros(length(Volume),1);
        FC_tmp = table;
        for j = 1:length(Volume)
            p2.Volume = Volume(j);
            Size(j) = p2.Size;
            [RF_tmp(j,:),argout] = CalcForce1(m2,p2,f1);
            FC_tmp = [FC_tmp;argout.F];
        end
        if RF_tmp(1,1) == 0
            idx = find(RF_tmp(:,1),1);
            if isempty(idx)
                error('指定的颗粒尺寸上限太小！')
            end
            EstVolSpan(i,:) = [Volume(idx-1),Volume(idx)];
    %         fprintf('转速为%.1fRPM时，附着膜面的最大颗粒尺寸预计为%.3f微米！\n',Rotation(i),Size(idx)/1e-6)
        else
            error('指定的颗粒尺寸下限过大！')
        end
        clear p2
    end
    % 精算各转速下附着膜面的最大颗粒尺寸
    for i = 1:length(Rotation)
        p2 = particle1('NaCl');
        m2.Velocity = [0 0 Rotation(i)*2*pi*m2.Radium/60]; % 膜面不旋转
        p2.Velocity = m2.Velocity; % 初始颗粒运动速度 = 膜面运动速度，即颗粒与膜面相对静止
        p2.Position = [Position(k) 0 0];
        p2.Position = [m2.Z0,m2.Radium,0]+p2.Position;
        % 计算不同颗粒尺寸下的受力情况
        Volume = linspace(EstVolSpan(i,1),EstVolSpan(i,2));
        RF_tmp = zeros(length(Volume),3);
        Size = zeros(length(Volume),1);
        FC_tmp = table;
        for j = 1:length(Volume)
            p2.Volume = Volume(j);
            Size(j) = p2.Size;
            [RF_tmp(j,:),argout] = CalcForce1(m2,p2,f1);
            FC_tmp = [FC_tmp;argout.F];
        end
        if RF_tmp(1,1) == 0
            idx = find(RF_tmp(:,1),1);
            CritSize(i) = Size(idx);
            ResultantForce(i,:) = RF_tmp(idx,:);
            ForceComponent = [ForceComponent;FC_tmp(idx,:)];
    %         fprintf('转速为%.1fRPM时，附着膜面的最大颗粒尺寸为%.3f微米！\n',Rotation(i),Size(idx)/1e-6)
        else
            error('指定的颗粒尺寸下限过大！')
        end
        clear p2
    end
    % 列表输出
    results(k).Description = sprintf('颗粒初始位于膜面Z=%.3f米处',Position(k));
    results(k).outTab = [table(Rotation,CritSize),ForceComponent];
end

%% 绘图
x = zeros(length(Rotation),length(Position));
y1 = zeros(size(x));
y2 = zeros(size(x));
y3 = zeros(size(x));
for i = 1:length(results)
    x(:,i) = results(i).outTab.Rotation;
    y1(:,i) = results(i).outTab.CritSize;
    y2(:,i) = results(i).outTab.Fd(:,3);
    y3(:,i) = results(i).outTab.Fc;
end
spec = arrayfun(@(x)sprintf('Z_p(0) = %.3f m',x),Position,'UniformOutput',false);
figure(2)
subplot(3,1,1)
semilogx(x,y1)
xlabel('Rotation (RPM)')
ylabel('max. $r_e$','Interpreter','latex')
legend(spec)
subplot(3,1,2)
semilogx(x,y2)
xlabel('Rotation (RPM)')
ylabel('$F_d (N)$','Interpreter','latex')
subplot(3,1,3)
semilogx(x,y3)
xlabel('Rotation (RPM)')
ylabel('$F_c (N)$','Interpreter','latex')
