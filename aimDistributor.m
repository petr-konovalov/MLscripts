%aim distributor interface
classdef (Abstract) aimDistributor
    
    methods (Abstract)
        distribution = getDistribution(obj)
    end
    
    methods 
        function obj = setArrangement(obj, startPos, aimPos)
            if isempty(startPos)
                error('startPos must not be empty.');
            elseif isempty(aimPos)
                error('aimPos must not be empty.')
            elseif size(startPos, 1) ~= size(aimPos, 1)
                error('startPos size must be equal aimPos size.');
            end
            
            obj.startPos = startPos;
            obj.aimPos = aimPos;
        end
    end
    
    properties (Access = 'protected')
        startPos;
        aimPos;
    end
    
end

