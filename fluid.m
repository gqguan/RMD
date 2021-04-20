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

    end
end

