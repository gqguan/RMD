function [FC,argout] = CalcForce1(membrane,particle,fluid)
%CalcForce1() ����Ĥ���������
% I/O����˵��
% �����������������FC(z,r,theta)�����������argout
% ���룺Ĥ��membrane����������particle�������壨fluid��

%% ����������
if exist('membrane','var')
    if ~isequal(class(membrane),'membrane')
        error('CalcForce1()��һ�������������ӦΪmembrane')
    end
end
if exist('particle','var')
    if ~isequal(class(particle),'particle1')
        error('CalcForce1()�ڶ��������������ӦΪparticle')
    end
end
if exist('fluid','var')
    if ~isequal(class(fluid),'fluid')
        error('CalcForce1()�����������������ӦΪfluid')
    end
end

%% Ĥ����ת���������ƽ�⣨�ⷨ�߷���Ϊ������
% ���»�����Ӧ��Ĥ���ⷨ���෴�� << ��Jiang(2019)AIChE J����ֵ
H = 1e-19; % Hanmakerϵ����J��
r = membrane.Roughness; % Ĥ��ֲڶȣ�m�� 
rc = particle.Size; % �������������ͬ�������ģ��뾶��m��
Z0 = 1e-10; % ������Ĥ��ľ��루m��
F1 = -vanderWaals(H,r,rc,Z0); % ������Ĥ������࣬����Ĥ���������������ⷨ�߷����෴
% ���徲ѹ����Ӧ��Ĥ���ⷨ���෴��
rho_l = fluid.Density; % �����ܶȣ�kg/m3��
g = 9.81; % �������ٶȣ�m/s2�� 
Z = particle.Position(1); % ������ȣ�m��
% Ap = pi*rc^2; % ������Ĥ�淨��ͶӰ�����m2�� << �������������
Ap = particle.Interface; % << �������������
F2 = -staticPressure(rho_l,g,Z,Ap); % ������Ĥ������࣬����Ĥ�澲ѹ���������ⷨ�߷�����
% ��������Ӧ��Ĥ���ⷨ����ͬ��
rho_c = particle.Density; % Ĥ������ܶȣ�kg/m3�� << ��NaCl�������
R = membrane.Radium; % ��ת�뾶��m��
omega = particle.Velocity(3)/(2*pi*membrane.Radium); % ���ٶȣ�rad/s��1/s��
m = particle.Mass; % ����������kg��
Fc = centrifugalForce(omega,R,m);
% �������Ĥ�������������֧����
Fn = Fc+F1+F2;

%% ����Կ�����ҷ���������������໥���ã�
% ���������������ٶ�
relV_FS = fluid.Velocity-particle.Velocity;
% �߽�������������ٶ�
relV_FS1 = velocityBC(rc,2*R,relV_FS,fluid);

if any(relV_FS1) % ������������˶�
    h = 2*rc; % ���������������ȣ�m�� << ����
    mu = fluid.Viscosity; % ������ << ��ˮ�ȼ�
    Fd = hydraulicForce(rc,h,relV_FS1,mu);
else
    Fd = [0 0 0];
end

%% �����븡���ĺ���
rho_l = fluid.Density; % �����ܶȣ�kg/m3��
rho_c = particle.Density; % �����ܶȣ�kg/m3��
V = particle.Volume; % ���������m3��
Fg = buoyancy(rho_l,rho_c,g,V);

%% Ħ������������Ĥ���໥���ã�
% ���ݿ�����Ĥ�������˶�״̬�ж�����
relV_SS = particle.Velocity-membrane.Velocity;
if Fn < 0 
    if any(relV_SS) % �������Ĥ���˶�      
        Ffmag = membrane.KM*abs(Fn); % ���㶯Ħ�����Ĵ�С
        Ff = -Ffmag*relV_SS./sqrt(relV_SS*relV_SS'); % Ħ��������Ϊ�ٶȵķ�����
        argout.FrictionStatus = 'kinetic';
        argout.FrictionForce = Ffmag;
    else % �������Ĥ�澲ֹ
        Ffmax = membrane.KS*abs(Fn); % ���Ħ�����Ĵ�С
        Fmag = sqrt((Fd+Fg)*(Fd+Fg)'); % ҷ���������ĺ�����С
        if Fmag > Ffmax % ���������������Ħ����
            Ff = -Ffmax*((Fd+Fg)/Fmag); % Ħ������СΪ���Ħ��������Ϊ��������ķ�����
%           FC = (Fmag-Ffmax)*((Fd+Fg)/Fmag);
        else
            Ff = -(Fd+Fg); % Ħ����Ϊҷ�������������ķ�������
        end
        argout.FrictionStatus = 'static';
        argout.FrictionForce = Ffmax;
    end
else % ��������Ĥ��˦��
    Ff = [0 0 0]; % Ħ����Ϊ��
end
FC = Fd+Fg+Ff;

%% �������
% ���������
% argout.log = prompt;
% argout.K = K;
argout.F = table(F1,F2,Fc,Fn,Fd,Ff,Fg); % ���»��������徲ѹ�����������������������������ҷ����Ħ��������������

end

%% ���㷶�»���
function [outputArgs] = vanderWaals(A,r,rc,Z0)   
    % ��������ֱ�ΪHanmakerϵ����J����Ĥ��ֲڶȣ�m�����������������ͬ�������ģ��뾶��m����������Ĥ��ľ��루m��
    % ����Ĥ��Կ����ķ���������
    F = A/6*(r*rc/(Z0^2*(r+rc))+rc/(Z0+rc)^2);
    % ���
    outputArgs = F;
end

%% ���㾲ѹ��
function [outputArgs] = staticPressure(rho,g,H,A)
    % ��������ֱ�Ϊ�����ܶȡ��������ٶȡ�������ȡ�������Ĥ�淨��ͶӰ���
    % ���㾲ѹ��
    F = rho*g*H*A;
    % ���
    outputArgs = F;
end

%% �������������Կ���������������
function [outputArgs] = hydraulicForce(rc,h,v,mu)
    % ����ҷ��
    vrc = 3*rc/h.*v;
    F = 1.701*6*pi*mu*rc.*vrc;
    % ���
    outputArgs = F;
end

%% ���㸡������
function outputArgs = buoyancy(rho_l,rho_c,g,V)
    % ���������͸����ĺ���
    Fz = (rho_c-rho_l)*g*V;
    % ���
    outputArgs = [Fz,0,0]; % z������Ϊ����
end

%% ������������ά�ֿ����ܰ���Ĥ����ת���������
function outputArgs = centrifugalForce(omega,r,m)
    % ��������ֱ�Ϊ���ٶȣ�rad/s��1/s������ת�뾶����������
    % �����루������
    a = omega^2*r; % ���ļ��ٶ�
    F = a*m;
    % ���
    outputArgs = F;
end

% ת�ٵ�λ�任
function omega = rpm2omega(rpm)
    omega = rpm*2*pi/60;
end

% �߽����
function [Vcorr,Y] = velocityBC(l,d,Vf,fluid)
    Vmag = 0;
    for i = 1:length(Vf)
        Vmag = Vf(i)*Vf(i)+Vmag;
    end
    Vmag = sqrt(Vmag);
    Re = d*fluid.Density*Vmag/fluid.Viscosity; % ������ŵ��
    Y = 5.84*d/sqrt(Re); % ���ڱ߽����
    if l <= Y
        Vcorr = l/Y*Vf; % �߽���������ٶ�
    else
        Vcorr = Vf;
    end
end