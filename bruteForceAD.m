%brute force aim distributor interface
%finds distribution which minimizes optFunc
classdef (Abstract) bruteForceAD < aimDistributor
    
    methods
        function distribution = getDistribution(obj)
            distSz = size(obj.startPos, 1);
            perm = perms(1: distSz);
            
            optVal = obj.optFunc(perm(1, :));
            distribution = perm(1, :);
            for k = 2: size(perm, 1)
                curVal = obj.optFunc(perm(k, :));
                if obj.comp(curVal, optVal) < 0
                    optVal = curVal;
                    distribution = perm(k, :);
                end
            end
        end
    end
    
    methods (Abstract, Access = 'protected')
        val = optFunc(obj, perm);
        res = comp(obj, firstVal, secondVal);
    end
    
end

