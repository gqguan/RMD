classdef fluid < handle
    %fluid 流体
    
    properties
        Id = 'f101';
        Viscosity = 1e-3;
        Density = 1e3;
        Velocity = [0,0,0]; % 流体初始为静止
    end
    
    methods
        function obj = fluid(inputArg)
            %fluid 构造此类的实例
            % 构造颗粒对象，需指明该颗粒的识别号
            if exist('inputArg','var')
                if isa(inputArg,'fluid')
                    obj = inputArg;
                elseif ischar(inputArg)
                    obj.Id = inputArg;
                else
                    error('命名流体有误！'); 
                end                         
            else
                warning('未命名流体');
                obj.Id = 'N/A';
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

