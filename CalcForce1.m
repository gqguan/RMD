function [FC,argout] = CalcForce1(membrane,particle,fluid)
%CalcForce1() 计算膜面颗粒受力
% I/O参数说明
% 输出：颗粒合力向量FC(z,r,theta)，结果参数集argout
% 输入：膜（membrane）、颗粒（particle）、流体（fluid）

%% 输入参数检查
if exist('membrane','var')
    if ~isequal(class(membrane),'membrane')
        error('CalcForce1()第一个输入参数类型应为membrane')
    end
end
if exist('particle','var')
    if ~isequal(class(particle),'particle1')
        error('CalcForce1()第二个输入参数类型应为particle')
    end
end
if exist('fluid','var')
    if ~isequal(class(fluid),'fluid')
        error('CalcForce1()第三个输入参数类型应为fluid')
    end
end

%% 膜面旋转法方向的力平衡（外法线方向为正方向）
% 范德华力（应与膜面外法向相反） << 按Jiang(2019)AIChE J报道值
H = 1e-19; % Hanmaker系数（J）
r = membrane.Roughness; % 膜面粗糙度（m） 
rc = particle.Size; % 当量（与颗粒相同体积球体的）半径（m）
Z0 = 1e-10; % 晶体与膜面的距离（m）
F1 = -vanderWaals(H,r,rc,Z0); % 颗粒在膜曲面外侧，故受膜面作用力方向与外法线方向相反
% 流体静压力（应与膜面外法向相反）
rho_l = fluid.Density; % 流体密度（kg/m3）
g = 9.81; % 重力加速度（m/s2） 
Z = particle.Position(1); % 流体深度（m）
% Ap = pi*rc^2; % 颗粒在膜面法向投影面积（m2） << 按当量球体计算
Ap = particle.Interface; % << 按正六面体计算
F2 = -staticPressure(rho_l,g,Z,Ap); % 颗粒在膜曲面外侧，故受膜面静压力方向沿外法线反方向
% 离心力（应与膜面外法向相同）
rho_c = particle.Density; % 膜面颗粒密度（kg/m3） << 按NaCl固体计算
R = membrane.Radium; % 旋转半径（m）
omega = particle.Velocity(3)/(2*pi*membrane.Radium); % 角速度（rad/s或1/s）
m = particle.Mass; % 颗粒质量（kg）
Fc = centrifugalForce(omega,R,m);
% 法方向的膜面对其表面颗粒的支撑力
Fn = Fc+F1+F2;

%% 流体对颗粒的曳力（颗粒与流体相互作用）
% 颗粒与流体的相对速度
relV_FS = fluid.Velocity-particle.Velocity;
% 边界层修正的流体速度
relV_FS1 = velocityBC(rc,2*R,relV_FS,fluid);

if any(relV_FS1) % 颗粒相对流体运动
    h = 2*rc; % 流固作用特征长度（m） << 初设
    mu = fluid.Viscosity; % 流体黏度 << 按水黏度计
    Fd = hydraulicForce(rc,h,relV_FS1,mu);
else
    Fd = [0 0 0];
end

%% 重力与浮力的合力
rho_l = fluid.Density; % 流体密度（kg/m3）
rho_c = particle.Density; % 颗粒密度（kg/m3）
V = particle.Volume; % 颗粒体积（m3）
Fg = buoyancy(rho_l,rho_c,g,V);

%% 摩擦力（颗粒与膜面相互作用）
% 根据颗粒与膜面的相对运动状态判定颗粒
relV_SS = particle.Velocity-membrane.Velocity;
if Fn < 0 
    if any(relV_SS) % 颗粒相对膜面运动
        Ffmag = membrane.KM*abs(Fn); % 计算动摩擦力的大小
        Ff = -Ffmag*relV_SS./sqrt(relV_SS*relV_SS'); % 摩擦力方向为速度的反方向
    else % 颗粒相对膜面静止
        Ffmax = membrane.KS*abs(Fn); % 最大静摩擦力的大小
        Fmag = sqrt((Fd+Fg)*(Fd+Fg)'); % 曳力和重力的合力大小
        if Fmag > Ffmax % 颗粒受力大于最大静摩擦力
            Ff = -Ffmax*((Fd+Fg)/Fmag); % 摩擦力大小为最大静摩擦，方向为受力方向的反方向
%           FC = (Fmag-Ffmax)*((Fd+Fg)/Fmag);
        else
            Ff = -(Fd+Fg); % 摩擦力为曳力和重力合力的反作用力
        end
    end
else % 颗粒将从膜面甩离
    Ff = [0 0 0]; % 摩擦力为零
end
FC = Fd+Fg+Ff;

%% 输出参数
% 结果参数集
% argout.log = prompt;
% argout.K = K;
argout.F = table(F1,F2,Fc,Fn,Fd,Ff,Fg); % 范德华力、流体静压、离心力、颗粒法方向合力、流体曳力、摩擦力、浮力

end

%% 计算范德华力
function [outputArgs] = vanderWaals(A,r,rc,Z0)   
    % 输入参数分别为Hanmaker系数（J）、膜面粗糙度（m）、当量（与颗粒相同体积球体的）半径（m）、晶体与膜面的距离（m）
    % 计算膜面对颗粒的分子作用力
    F = A/6*(r*rc/(Z0^2*(r+rc))+rc/(Z0+rc)^2);
    % 输出
    outputArgs = F;
end

%% 计算静压力
function [outputArgs] = staticPressure(rho,g,H,A)
    % 输入参数分别为流体密度、重力加速度、流体深度、颗粒在膜面法向投影面积
    % 计算静压力
    F = rho*g*H*A;
    % 输出
    outputArgs = F;
end

%% 计算流体流动对颗粒的作用力向量
function [outputArgs] = hydraulicForce(rc,h,v,mu)
    % 计算曳力
    vrc = 3*rc/h.*v;
    F = 1.701*6*pi*mu*rc.*vrc;
    % 输出
    outputArgs = F;
end

%% 计算浮力向量
function outputArgs = buoyancy(rho_l,rho_c,g,V)
    % 计算重力和浮力的合力
    Fz = (rho_c-rho_l)*g*V;
    % 输出
    outputArgs = [Fz,0,0]; % z正方向为向下
end

%% 计算离心力（维持颗粒能伴随膜面旋转所需的力）
function outputArgs = centrifugalForce(omega,r,m)
    % 输入参数分别为角速度（rad/s或1/s）、旋转半径、颗粒质量
    % 计算离（向）心力
    a = omega^2*r; % 向心加速度
    F = a*m;
    % 输出
    outputArgs = F;
end

% 转速单位变换
function omega = rpm2omega(rpm)
    omega = rpm*2*pi/60;
end

% 边界层厚度
function [Vcorr,Y] = velocityBC(l,d,Vf,fluid)
    Vmag = 0;
    for i = 1:length(Vf)
        Vmag = Vf(i)*Vf(i)+Vmag;
    end
    Vmag = sqrt(Vmag);
    Re = d*fluid.Density*Vmag/fluid.Viscosity; % 流体雷诺数
    Y = 5.84*d/sqrt(Re); % 附壁边界层厚度
    if l <= Y
        Vcorr = l/Y*Vf; % 边界层内修正速度
    else
        Vcorr = Vf;
    end
end