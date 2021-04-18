function [FC,argout] = CalcForce(operation,particle,fluid,membrane,opString)
%CalcForce() 计算颗粒受力（包括维持相对静止和实际受力两种情况）
% I/O参数说明
% 输出：颗粒合力向量FC(z,r,theta)，结果参数集argout，程序计算设定字段opString
% 输入：操作条件（operation）、颗粒性质（particle）、流体性质（fluid）、膜性质（membrane）

%% 输入参数检查
if ~exist('opString','var') % 未指定opString时采用缺省值dynamic
    opString = 'dynamic';
end

%% 膜面旋转法方向的力平衡
% 范德华力（应与膜面外法向相反） << 按Jiang(2019)AIChE J报道值
H = 1e-19; % Hanmaker系数（J）
r = membrane.Roughness; % 膜面粗糙度（m） 
rc = particle.EqvSize; % 当量（与颗粒相同体积球体的）半径（m）
Z0 = 1e-10; % 晶体与膜面的距离（m）
F1 = vanderWaals([H,r,rc,Z0]);
% 流体静压力（应与膜面外法向相反）
rho_l = fluid.Density; % 流体密度（kg/m3）
g = 9.81; % 重力加速度（m/s2） 
Z = operation.Z0+particle.Position(1); % 流体深度（m）
% Ap = pi*rc^2; % 颗粒在膜面法向投影面积（m2） << 按当量球体计算
Ap = particle.Interface; % << 按正六面体计算
F2 = staticPressure([rho_l,g,Z,Ap]);
% 离心力（应与膜面外法向相同）
rho_c = particle.Density; % 膜面颗粒密度（kg/m3） << 按NaCl固体计算
omega = rpm2omega(operation.Rotation.Speed); % 角速度（rad/s或1/s）
R = operation.Rotation.Radium; % 旋转半径（m）
m = particle.Mass; % 颗粒质量（kg）
Fc = centrifugalForce([omega,R,m]);
% 法方向的膜面对其表面颗粒的支撑力（其正方向为膜面外法方向，当Fn为负值时颗粒受法方向反向力作用，该力为克服颗粒滑移提供摩擦力）
Fn = Fc-F1-F2;

%% 膜面旋转周方向的力平衡
% 流体与膜面颗粒相对运动产生的力（方向与膜面旋转方向相反）
h = 2*rc; % 流固作用特征长度（m） << 初设
vtheta = particle.Velocity(3)-fluid.Velocity(3); % 旋转周方向平均流体速度（即线速度，m/s）
mu = fluid.Viscosity; % 流体黏度 << 按水黏度计
F3 = hydraulicForce([rc,h,vtheta,mu]);
% 膜面颗粒在周方向的静摩擦力（方向与膜面旋转方向相同）
Ftheta = -F3;

%% 膜面旋转轴方向的力平衡
% 流体与膜面颗粒相对运动产生的力（方向与流体轴向流动方向相同，假定为坐标系z方向）
vz = particle.Velocity(1)-fluid.Velocity(1); % 旋转轴平均流体速度（即线速度，m/s）
Fz1 = hydraulicForce([rc,h,vz,mu]);
% 浮力（颗粒密度大于流体时，方向为坐标轴z的负方向）
rho_l = fluid.Density; % 流体密度（kg/m3）
rho_c = particle.Density; % 颗粒密度（kg/m3）
V = particle.Volume; % 颗粒体积（m3）
F4 = buoyancy([rho_l,rho_c,g,V]);
% 膜面颗粒在轴向的静摩擦力（正方向为坐标轴z方向）
Fz = -Fz1-F4;

%% 根据程序计算设定字段分别计算
FC = zeros(1,3);
% 颗粒在膜面切方向受的合力大小及方向
Fmag = sqrt(Ftheta^2+Fz^2);
alpha = atan(Ftheta/Fz);
% 维持颗粒相对膜面静止所需的静摩擦力系数
K = Fmag/abs(Fn);
switch opString
    case('stationary')
        % 当膜面对颗粒的支撑力为正值时，颗粒在法方向受离心力作用而脱离膜面
        if Fn>0
            K = nan;
            % 颗粒向膜面法方向运动
            FC(1) = Fz; % 轴向摩擦力为0
            FC(2) = Fn; % 法向合力
            FC(3) = Ftheta; % 周向摩擦力为0
            prompt = sprintf('颗粒在离心力作用下脱离膜面，所受合力为FC[%.4e %.4e %.4e]',FC);
        else        
            FC = [Fz,0,Ftheta];
            prompt = sprintf('颗粒维持相对膜面静止时所受的摩擦力为FC[%.4e %.4e %.4e]',FC);
        end
    case('dynamic') % 颗粒在膜面所受的实际摩擦力
        % 最大静摩擦力
        Fmax = membrane.KS*abs(Fn);
        % 当膜面对颗粒的支撑力为正值时，颗粒在法方向受离心力作用而脱离膜面
        if Fn>0
            K = nan;
            % 颗粒向膜面法方向运动
            FC(1) = Fz; % 轴向摩擦力为0
            FC(2) = Fn; % 法向合力
            FC(3) = Ftheta; % 周向摩擦力为0
            prompt = sprintf('颗粒在离心力作用下脱离膜面，所受合力为FC[%.4e %.4e %.4e]',FC);
        else
            % 合力 - 动摩擦力
            FCmag = Fmag-membrane.KM*abs(Fn);
            FC(1) = FCmag*cos(alpha);
            FC(2) = 0;
            FC(3) = FCmag*sin(alpha);
            prompt = sprintf('颗粒在膜面所受的实际摩擦力为%.4eN大于最大静摩擦力%.4eN：', Fmag, Fmax);
            prompt = sprintf('%s颗粒在膜面所受的力为FC[%.4e %.4e %.4e]',prompt,FC);
            prompt = sprintf('%s，颗粒在膜面运动，当前在膜面位置(%.4f,%.4f)！', prompt, particle.Position(3), particle.Position(1));         
        end
end

% 输出参数
argout.log = prompt;
argout.K = K;
argout.F = [F1,F2,F3,F4,Fc,Fz1]; % 范德华力、流体静压、周向流体曳力、浮力、离心力、轴向流体曳力

end

%% 计算范德华力
function [outputArgs] = vanderWaals(inputArgs)   
    % 输入参数类型为double时转换为cell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % 检查输入参数数目
    if length(inputArgs) ~= 4
        fprintf('【错误】函数vanderWaals()输入参数数目应为4个！\n')
        outputArgs = nan;
        quit
    end
    if all([inputArgs{2:end}] == zeros(1,3))
        fprintf('【错误】函数vanderWaals()输入参数存在除零错误！\n')
        outputArgs = nan;
        quit
    end
    % 参数赋值：Hanmaker系数（J）、膜面粗糙度（m）、当量（与颗粒相同体积球体的）半径（m）、晶体与膜面的距离（m）
    [A,r,rc,Z0] = inputArgs{:};
    % 计算
    F = A/6*(r*rc/(Z0^2*(r+rc))+rc/(Z0+rc)^2);
    % 输出
    outputArgs = F;
end

%% 计算静压力
function [outputArgs] = staticPressure(inputArgs)
    % 输入参数类型为double时转换为cell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % 检查输入参数数目
    if length(inputArgs) ~= 4
        fprintf('【错误】函数staticPressure()输入参数数目应为4个！\n')
        outputArgs = nan;
        quit
    end
    % 参数赋值：流体密度、重力加速度、流体深度、颗粒在膜面法向投影面积
    [rho,g,H,A] = inputArgs{:};
    % 计算
    F = rho*g*H*A;
    % 输出
    outputArgs = F;
end

%% 计算流体流动对颗粒的作用力
function [outputArgs] = hydraulicForce(inputArgs)
    % 输入参数类型为double时转换为cell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % 检查输入参数数目
    if length(inputArgs) ~= 4
        fprintf('【错误】函数hydraulicForce()输入参数数目应为4个！\n')
        outputArgs = nan;
        quit
    end
    if inputArgs{2} == 0
        fprintf('【错误】函数hydraulicForce()输入参数存在除零错误！\n')
        outputArgs = nan;
        quit
    end
    % 参数赋值：当量（与颗粒相同体积球体的）半径、流固作用特征长度、平均流体速度、流体黏度
    [rc,h,v,mu] = inputArgs{:};
    % 计算
    vrc = 3*rc/h*v;
    F = 1.701*6*pi*mu*rc*vrc;
    % 输出
    outputArgs = F;
end

%% 计算浮力
function [outputArgs] = buoyancy(inputArgs)
    % 输入参数类型为double时转换为cell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % 检查输入参数数目
    if length(inputArgs) ~= 4
        fprintf('【错误】函数buoyancy()输入参数数目应为4个！\n')
        outputArgs = nan;
        quit
    end
    % 参数赋值：流体密度（kg/m3）、颗粒密度（kg/m3）、重力加速度（m/s2）、颗粒体积（m3）
    [rho_l,rho_c,g,V] = inputArgs{:};
    % 计算
    F = (rho_l-rho_c)*g*V;
    % 输出
    outputArgs = F;
end

%% 计算离心力（维持颗粒能伴随膜面旋转所需的力）
function [outputArgs] = centrifugalForce(inputArgs)
    % 输入参数类型为double时转换为cell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % 检查输入参数数目
    if length(inputArgs) ~= 3
        fprintf('【错误】函数centrifugalForce()输入参数数目应为4个！\n')
        outputArgs = nan;
        quit
    end
    % 参数赋值：角速度（rad/s或1/s）、旋转半径、颗粒质量
    [omega,r,m] = inputArgs{:};
    % 计算
    a = omega^2*r; % 向心加速度
    F = a*m;
    % 输出
    outputArgs = F;
end

% 转速单位变换
function omega = rpm2omega(rpm)
    omega = rpm*2*pi/60;
end
