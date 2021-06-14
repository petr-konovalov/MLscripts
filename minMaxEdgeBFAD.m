%brute force aim distributor 
%finds distribution which minimizes maximum distantce between start
%position and aim position
classdef minMaxEdgeBFAD < bruteForceAD
    
    methods
        function obj = minMaxEdgeBFAD(startPos, aimPos)
            obj = obj.setArrangement(startPos, aimPos);
        end
    end
    
    methods (Access = 'protected')
        function val = optFunc(obj, perm)
            val = zeros(1, size(perm, 2));
            val(1) = norm(obj.startPos(1, :) - obj.aimPos(perm(1), :));
            for k = 2: size(perm, 2)
                val(k) = norm(obj.startPos(k, :) - obj.aimPos(perm(k), :)); 
            end
        end
        
        function res = comp(~, firstVal, secondVal)
            firstVal = sort(firstVal, 'descend');
            secondVal = sort(secondVal, 'descend');
            res = 0;
            for k = 1: size(firstVal, 2)
                if firstVal(k) < secondVal(k)
                    res = -1;
                    break;
                elseif firstVal(k) > secondVal(k)
                    res = 1;
                    break;
                end
            end
        end
    end
    
end

