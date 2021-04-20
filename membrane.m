classdef membrane < handle
    %membrane 膜
    
    properties 
        Id = 'membr1';
        Roughness = 1e-8;
        KS = 0.2e-3; % 静摩擦力系数
        KM = 1e-5; % 动摩擦力系数
        Radium = 20e-3; 
        Theta = 2*pi;
        Height = 40e-3; % 膜面尺寸H，单位：m
        Width = 2*pi*20e-3; % 膜面尺寸W，单位：m
        Velocity = [0,0,0];
    end
    
    methods
        function obj = membrane(inputArg)
            %membrane构造此类的实例
            % 构造颗粒对象，需指明该膜的识别号
            if exist('inputArg','var')
                if isa(inputArg,'membrane')
                    obj = inputArg;
                elseif ischar(inputArg)
                    obj.Id = inputArg;
                else
                    error('命名膜有误！'); 
                end                         
            else
                warning('未命名膜');
                obj.Id = 'N/A';
            end
        end
        
        function set.Radium(obj,inputArg)
            if isnumeric(inputArg)
                obj.Radium = inputArg;
                getWidth(obj);
            else
                error('膜弧曲率半径指定有误！')
            end
        end
        
        function set.Theta(obj,inputArg)
            if inputArg >= 0 && inputArg <= 2*pi
                obj.Theta = inputArg;
                getWidth(obj);
            else
                error('膜宽计算的弧度输入有误！')
            end
        end
        
        function obj = getWidth(obj)
            % 当Radium属性不为inf时，设定膜宽度
            if isinf(obj.Radium)
                warning('指定膜弧曲率半径为inf，膜宽为原设定值！')                
            else
                obj.Width = obj.Theta*obj.Radium;
            end
        end
        
    end
end

