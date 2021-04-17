function [FC,argout] = CalcForce(operation,particle,fluid,membrane,opString)
%CalcForce() �����������������ά����Ծ�ֹ��ʵ���������������
% I/O����˵��
% �����������������FC(z,r,theta)�����������argout����������趨�ֶ�opString
% ���룺����������operation�����������ʣ�particle�����������ʣ�fluid����Ĥ���ʣ�membrane��

%% ����������
if ~exist('opString','var') % δָ��opStringʱ����ȱʡֵdynamic
    opString = 'dynamic';
end

%% Ĥ����ת���������ƽ��
% ���»�����Ӧ��Ĥ���ⷨ���෴�� << ��Jiang(2019)AIChE J����ֵ
H = 1e-19; % Hanmakerϵ����J��
r = membrane.Roughness; % Ĥ��ֲڶȣ�m�� 
rc = particle.EqvSize; % �������������ͬ�������ģ��뾶��m��
Z0 = 1e-10; % ������Ĥ��ľ��루m��
F1 = vanderWaals([H,r,rc,Z0]);
% ���徲ѹ����Ӧ��Ĥ���ⷨ���෴��
rho_l = fluid.Density; % �����ܶȣ�kg/m3��
g = 9.81; % �������ٶȣ�m/s2�� 
Z = operation.Z0+particle.Position(1); % ������ȣ�m��
% Ap = pi*rc^2; % ������Ĥ�淨��ͶӰ�����m2�� << �������������
Ap = particle.Interface; % << �������������
F2 = staticPressure([rho_l,g,Z,Ap]);
% ��������Ӧ��Ĥ���ⷨ����ͬ��
rho_c = particle.Density; % Ĥ������ܶȣ�kg/m3�� << ��NaCl�������
omega = rpm2omega(operation.Rotation.Speed); % ���ٶȣ�rad/s��1/s��
R = operation.Rotation.Radium; % ��ת�뾶��m��
m = particle.Mass; % ����������kg��
Fc = centrifugalForce([omega,R,m]);
% �������Ĥ�������������֧��������������ΪĤ���ⷨ���򣬵�FnΪ��ֵʱ�����ܷ������������ã�����Ϊ�˷����������ṩĦ������
Fn = Fc-F1-F2;

%% Ĥ����ת�ܷ������ƽ��
% ������Ĥ���������˶�����������������Ĥ����ת�����෴��
h = 2*rc; % ���������������ȣ�m�� << ����
vtheta = particle.Velocity(3)-fluid.Velocity(3); % ��ת�ܷ���ƽ�������ٶȣ������ٶȣ�m/s��
mu = fluid.Viscosity; % ������ << ��ˮ�ȼ�
F3 = hydraulicForce([rc,h,vtheta,mu]);
% Ĥ��������ܷ���ľ�Ħ������������Ĥ����ת������ͬ��
Ftheta = -F3;

%% Ĥ����ת�᷽�����ƽ��
% ������Ĥ���������˶�����������������������������������ͬ���ٶ�Ϊ����ϵz����
vz = particle.Velocity(1)-fluid.Velocity(1); % ��ת��ƽ�������ٶȣ������ٶȣ�m/s��
Fz1 = hydraulicForce([rc,h,vz,mu]);
% �����������ܶȴ�������ʱ������Ϊ������z�ĸ�����
rho_l = fluid.Density; % �����ܶȣ�kg/m3��
rho_c = particle.Density; % �����ܶȣ�kg/m3��
V = particle.Volume; % ���������m3��
F4 = buoyancy([rho_l,rho_c,g,V]);
% Ĥ�����������ľ�Ħ������������Ϊ������z����
Fz = -Fz1-F4;

%% ���ݳ�������趨�ֶηֱ����
% ������Ĥ���з����ܵĺ�����С������
Fmag = sqrt(Ftheta^2+Fz^2);
alpha = atan(Ftheta/Fz);
% ά�ֿ������Ĥ�澲ֹ����ľ�Ħ����ϵ��
K = Fmag/abs(Fn);
switch opString
    case('stationary')
        % ��Ĥ��Կ�����֧����Ϊ��ֵʱ�������ڷ����������������ö�����Ĥ��
        if Fn>0
            K = nan;
            % ������Ĥ�淨�����˶�
            FC(1) = Fz; % ����Ħ����Ϊ0
            FC(2) = Fn; % �������
            FC(3) = Ftheta; % ����Ħ����Ϊ0
            prompt = sprintf('����������������������Ĥ�棬���ܺ���ΪFC[%.4e %.4e %.4e]',FC);
        else        
            FC = [Fz,0,Ftheta];
            prompt = sprintf('����ά�����Ĥ�澲ֹʱ���ܵ�Ħ����ΪFC[%.4e %.4e %.4e]',FC);
        end
    case('dynamic') % ������Ĥ�����ܵ�ʵ��Ħ����
        % ���Ħ����
        Fmax = membrane.KS*abs(Fn);
        % ��Ĥ��Կ�����֧����Ϊ��ֵʱ�������ڷ����������������ö�����Ĥ��
        if Fn>0
            K = nan;
            % ������Ĥ�淨�����˶�
            FC(1) = Fz; % ����Ħ����Ϊ0
            FC(2) = Fn; % �������
            FC(3) = Ftheta; % ����Ħ����Ϊ0
            prompt = sprintf('����������������������Ĥ�棬���ܺ���ΪFC[%.4e %.4e %.4e]',FC);
        else
            % ��Ħ����С�����Ħ����ʱ��������תĤ�汣����Ծ�ֹ��Ĥ��������Ӵ���ľ�Ħ����ϵ��
            if Fmag<Fmax
                FC = [0,0,0];
                prompt = sprintf('������Ĥ�����ܵ�ʵ��Ħ����Ϊ%.4eNС�����Ħ����%.4eN��', Fmag, Fmax);
                prompt = sprintf('%s������Ĥ�����ܵ���ΪFC[%.4e %.4e %.4e]',prompt,FC);
            else
                % ���� = ��Ħ����
                FCmag = Fmag-membrane.KM*abs(Fn);
                FC(1) = FCmag*cos(alpha);
                FC(2) = 0;
                FC(3) = FCmag*sin(alpha);
                prompt = sprintf('������Ĥ�����ܵ�ʵ��Ħ����Ϊ%.4eN�������Ħ����%.4eN��', Fmag, Fmax);
                prompt = sprintf('%s������Ĥ�����ܵ���ΪFC[%.4e %.4e %.4e]',prompt,FC);
                prompt = sprintf('%s��������Ĥ���˶�����ǰ��Ĥ��λ��(%.4f,%.4f)��', prompt, particle.Position(3), particle.Position(1));
            end            
        end
end

% �������
argout.log = prompt;
argout.K = K;
argout.F = [F1,F2,F3,F4,Fc,Fz1]; % ���»��������徲ѹ����������ҷ��������������������������ҷ��

end

%% ���㷶�»���
function [outputArgs] = vanderWaals(inputArgs)   
    % �����������Ϊdoubleʱת��Ϊcell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % ������������Ŀ
    if length(inputArgs) ~= 4
        fprintf('�����󡿺���vanderWaals()���������ĿӦΪ4����\n')
        outputArgs = nan;
        quit
    end
    if all([inputArgs{2:end}] == zeros(1,3))
        fprintf('�����󡿺���vanderWaals()����������ڳ������\n')
        outputArgs = nan;
        quit
    end
    % ������ֵ��Hanmakerϵ����J����Ĥ��ֲڶȣ�m�����������������ͬ�������ģ��뾶��m����������Ĥ��ľ��루m��
    [A,r,rc,Z0] = inputArgs{:};
    % ����
    F = A/6*(r*rc/(Z0^2*(r+rc))+rc/(Z0+rc)^2);
    % ���
    outputArgs = F;
end

%% ���㾲ѹ��
function [outputArgs] = staticPressure(inputArgs)
    % �����������Ϊdoubleʱת��Ϊcell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % ������������Ŀ
    if length(inputArgs) ~= 4
        fprintf('�����󡿺���staticPressure()���������ĿӦΪ4����\n')
        outputArgs = nan;
        quit
    end
    % ������ֵ�������ܶȡ��������ٶȡ�������ȡ�������Ĥ�淨��ͶӰ���
    [rho,g,H,A] = inputArgs{:};
    % ����
    F = rho*g*H*A;
    % ���
    outputArgs = F;
end

%% �������������Կ�����������
function [outputArgs] = hydraulicForce(inputArgs)
    % �����������Ϊdoubleʱת��Ϊcell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % ������������Ŀ
    if length(inputArgs) ~= 4
        fprintf('�����󡿺���hydraulicForce()���������ĿӦΪ4����\n')
        outputArgs = nan;
        quit
    end
    if inputArgs{2} == 0
        fprintf('�����󡿺���hydraulicForce()����������ڳ������\n')
        outputArgs = nan;
        quit
    end
    % ������ֵ���������������ͬ�������ģ��뾶�����������������ȡ�ƽ�������ٶȡ�������
    [rc,h,v,mu] = inputArgs{:};
    % ����
    vrc = 3*rc/h*v;
    F = 1.701*6*pi*mu*rc*vrc;
    % ���
    outputArgs = F;
end

%% ���㸡��
function [outputArgs] = buoyancy(inputArgs)
    % �����������Ϊdoubleʱת��Ϊcell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % ������������Ŀ
    if length(inputArgs) ~= 4
        fprintf('�����󡿺���buoyancy()���������ĿӦΪ4����\n')
        outputArgs = nan;
        quit
    end
    % ������ֵ�������ܶȣ�kg/m3���������ܶȣ�kg/m3�����������ٶȣ�m/s2�������������m3��
    [rho_l,rho_c,g,V] = inputArgs{:};
    % ����
    F = (rho_l-rho_c)*g*V;
    % ���
    outputArgs = F;
end

%% ������������ά�ֿ����ܰ���Ĥ����ת���������
function [outputArgs] = centrifugalForce(inputArgs)
    % �����������Ϊdoubleʱת��Ϊcell
    if isa(inputArgs,'double')
        inputArgs = num2cell(inputArgs);
    end    
    % ������������Ŀ
    if length(inputArgs) ~= 3
        fprintf('�����󡿺���centrifugalForce()���������ĿӦΪ4����\n')
        outputArgs = nan;
        quit
    end
    % ������ֵ�����ٶȣ�rad/s��1/s������ת�뾶����������
    [omega,r,m] = inputArgs{:};
    % ����
    a = omega^2*r; % ���ļ��ٶ�
    F = a*m;
    % ���
    outputArgs = F;
end

% ת�ٵ�λ�任
function omega = rpm2omega(rpm)
    omega = rpm*2*pi/60;
end
