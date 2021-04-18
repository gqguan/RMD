%% 测试变量型和句柄型（指针）对象循环20万次的速度
%
% by Dr. Guan Guoqiang @ SCUT on 2021/4/19

clear
N = 200000;
t = zeros(4,1);
prompt = string;

%% 变量型对象计算
% 多核并行
prompt(1) = "变量型对象循环20万次";
p1(1:N) = particle('Unknown');
tic
parfor i = 1:N
    p1(i) = particle(sprintf('VarObj%06dp',i));
    p1(i).Volume = rand/1e-5;
    p1(i).Velocity = [0.01 0 0];
end
t1(1) = toc;
% 单核
p2(1:N) = particle('Unknown');
tic
for i = 1:N
    p2(i).Id = sprintf('VarObj%06d',i);
    p2(i).Volume = rand/1e-5;
    p2(i).Velocity = [0.01 0 0];
end
t2(1) = toc;

%% 句柄型对象计算
% 多核并行
prompt(2) = "句柄型对象循环20万次";
p3(1:N) = particle1('Unknown');
tic
parfor i = 1:N
    p3(i).Id = sprintf('HdlObj%06dp',i);
    p3(i).Volume = rand/1e-5;
    p3(i).Velocity = [0.01 0 0];
end
t1(2) = toc;
% 单核
p4(1:N) = particle1('Unknown');
tic
for i = 1:N
    p4(i).Id = sprintf('HdlObj%06d',i);
    p4(i).Volume = rand/1e-5;
    p4(i).Velocity = [0.01 0 0];
end
t2(2) = toc;

%% 输出
disp('各变量在工作空间的存储量大小')
whos p1 p2 p3 p4
prompt = prompt';
disp(table(prompt,t))