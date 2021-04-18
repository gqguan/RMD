classdef particle
    % 膜面颗粒
    %   此处显示详细说明
    
    properties 
        Id = 'p1001';
        GeomForm = '正方体';
        Density = 2.165e3;
        Volume = (10e-6)^3;
        Position = [0 0 0];
        Velocity = [0 0 0];
    end
    
    properties (SetAccess = private)
        Mass
        Size % 等体积球的半径，单位：m
        Interface % 颗粒与膜面的接触面积，单位：m2
        Status
    end
    
    methods
        function obj = particle(inputArg)
            % 构造颗粒对象，需指明该颗粒的识别号
            if exist('inputArg','var')
                if isa(inputArg,'particle')
                    obj = inputArg;
                elseif ischar(inputArg)
                    obj.Id = inputArg;
                else
                    error('命名颗粒有误！'); 
                end                         
            else
                warning('未命名颗粒');
                obj.Id = 'N/A';
            end
        end
        
        function obj = set.Id(obj,inputArg)
            % 设置颗粒识别号
            if ischar(inputArg)
                obj.Id = inputArg;
            else
                error('“%s”为无效“颗粒Id”名称设定！',inputArg);
            end
        end
        
        function obj = set.GeomForm(obj,inputArg)
            % 设置颗粒几何形状
            GFList = {'正方体','Hexahedron','球体','Sphere'};
            switch inputArg
                case GFList
                    obj.GeomForm = inputArg;
                otherwise
                    error('“%s”为无效“颗粒形状”指定！',inputArg)
            end
        end
        
        function obj = set.Density(obj,inputArg)
            % 设置颗粒密度
            if isnumeric(inputArg)
                obj.Density = inputArg;
            else
                error('无效“颗粒密度”指定！')
            end
        end
        
        function obj = set.Volume(obj,inputArg)
            % 设置颗粒体积
            if isnumeric(inputArg)
                obj.Volume = inputArg;
                obj = getOtherProps(obj);
            else
                error('无效“颗粒体积”指定！')
            end
        end
        
        function obj = set.Position(obj,inputArg)
            % 设置颗粒位置
            if isnumeric(inputArg) && isequal(size(inputArg),[1 3])
                obj.Position = inputArg;
            else
                error('无效“颗粒位置”指定！')
            end
        end
        
        function obj = set.Velocity(obj,inputArg)
            % 设置颗粒运动速度
            if isnumeric(inputArg) && isequal(size(inputArg),[1 3])
                obj.Velocity = inputArg;
                obj = getStatus(obj);
            else
                error('无效“颗粒速度”指定！')
            end
        end
        
        function obj = getStatus(obj)
            if any(obj.Velocity)
                obj.Status = 'Motional';
            else
                obj.Status = 'Static';
            end
        end
        
        function obj = getOtherProps(obj)
            obj.Mass = obj.Density*obj.Volume;
            obj.Size = (obj.Volume/pi/4*3)^(1/3);
            switch obj.GeomForm
                case({'正方体','Hexahedron'})                  
                    obj.Interface = obj.Volume^(2/3);
                case({'球体','Sphere'})
                    obj.Interface = pi*obj.Size^2;
            end
        end

    end
end

