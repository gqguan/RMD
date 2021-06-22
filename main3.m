%% 计算颗粒尺寸分布的演变
%
% by Dr. Guan Guoqiang @ SCUT on 2021/6/16

%% 初始化
clear
out = struct([]);
% 并行计算
poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    poolsize = 0;
else
    poolsize = poolobj.NumWorkers;
end
%
% NP = 100*poolsize; % 颗粒数目
NP = 500;
mu = 0.85e-6; % 正方体颗粒边长（颗粒平均尺寸，米）
sigma = 0.15*mu; % 颗粒标准差
tend = 1;
tspan = linspace(0,tend,100); % 计算时间（秒）

%% 初始颗粒分布
% 膜
m = membrane('PVDF');
m.Z0 = 5e-2; % 膜面上缘距离液面的距离（m）
m.Radium = 20e-3; % 转筒半径（m）
m.Velocity = [0 0 20*2*pi*m.Radium/60]; % 膜面旋转速度 Vtheta = 20rpm的线速度
% 流体
f = fluid('Water');
f.Velocity = [0 0 0]; % 主流速度

% 颗粒群
PChord = sigma*randn(1,NP)+mu;
PPos = rand(1,NP)*m.Height;
hbar = parfor_progressbar(NP,'计算颗粒群运动'); % 进度条初始化
parfor iP = 1:NP
    p0 = particle1(sprintf('NaCl#%d',iP));
    p0.Velocity = m.Velocity; % 初始颗粒运动速度 = 膜面运动速度，即颗粒与膜面相对静止
    p0.Position = [m.Z0,m.Radium,0]+[PPos(iP),0,0];
    p0.Volume = PChord(iP)^3;
    out(iP).p0 = copyobj(p0);
    % 颗粒在膜面运动变化
    try % 为防止部分颗粒在求解轨迹时出错而造成终止计算
        trajOK = true; 
        p1s = Trajectory1(tspan,m,p0,f);
    catch ME
        trajOK = false;
        if (strcmp(ME.identifier,'MATLAB:griddedInterpolant:ComplexDataPointErrId'))
            warning(ME.message)
        end
    end
    if trajOK
        Time = [p1s.Time]';
        Position = cell2mat(arrayfun(@(x)x.Spec.Position,p1s','UniformOutput',false));
        RelPos = Position-m.Velocity.*[p1s.Time]'-[m.Z0,0,0];
        Size = cell2mat(arrayfun(@(x)x.Spec.Size,p1s','UniformOutput',false));
        Velocity = cell2mat(arrayfun(@(x)x.Spec.Velocity,p1s','UniformOutput',false));
        RelVelocity = Velocity-m.Velocity;
        out(iP).SlipTime = slipTime(p1s,m);
        out(iP).traj = table(Time,Size,RelPos,RelVelocity);
    end
    hbar.iterate(1); % 每次迭代更新进度条
end
close(hbar); % 清除进度条

%% 数据存盘
load('saveData.mat','results')
var = datestr(now,'mmmdd_HHMMSS');
spec.NP = NP;
spec.mu = mu;
spec.sigma = sigma;
spec.tspan = tspan;
spec.membrane = m;
spec.fluid = f;
results.(var).spec = spec;
results.(var).out = out;
save('saveData.mat','results')

%% 颗粒尺寸分布
% 初始分布
figure(1)
PSize0 = arrayfun(@(x)x.p0.Size,out);
histogram(PSize0,15,'Normalization','probability')
hold on
% 检查是否存在未求解的颗粒
idx = arrayfun(@(x)isempty(x.traj),out);
if any(idx)
    warning('部分颗粒求解有误')
    out(idx) = [];
end
% tspan时间后的颗粒尺寸
PSize1 = arrayfun(@(x)x.traj.Size(end),out);
histogram(PSize1,15,'Normalization','probability')
xlabel('Equiv. Radium (m)');
ylabel('Probability');

%% 膜面颗粒脱离时间
% 膜面静止颗粒
fprintf('相对膜面静止的颗粒数量为%d（占比为%.2f%%）\n',sum(isnan([out.SlipTime])),sum(isnan([out.SlipTime]))/length(out)*100)
% 颗粒脱离膜面的时间统计
figure(2)
histogram([out.SlipTime],'Normalization','probability')
xlabel('Time (s)')
ylabel('Probability')

%% 计算颗粒滑出膜面的时间
function st = slipTime(ps,m)
    % 输入参数校核
    if all(cellfun(@(x)any(strcmp(x,fieldnames(ps))),{'Time','Spec'}))
        bZ = m.Z0+m.Height;
        t = [ps.Time]';
        pos = cell2mat(arrayfun(@(x)[x.Spec.Position'],ps,'UniformOutput',false))';
        [posZ,ia] = unique(pos(:,1),'sorted');
        tZ = t(ia);
        if length(tZ) > 1
            st = interp1(posZ,tZ,bZ);
        else
            fprintf('%s颗粒静止!\n',ps(1).Spec.Id)
            st = nan;
        end
    else
        warning('函数slipTime()输入参数有误')
    end
end