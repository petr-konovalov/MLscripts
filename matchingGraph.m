%matching problem solver
classdef matchingGraph < handle
    
    methods
        function obj = matchingGraph(szl, szr)
            import java.util.ArrayList;
            obj.matchingSize = -1;
            obj.match = -ones(1, szr);
            obj.taked = zeros(1, szl);
            obj.g = cell(szl, 1);
            for k = 1: szl
                obj.g(k) = ArrayList;
            end
        end
        
        function calcMaxMatching(g)
            run = true;
            g.usedTimer = 0;
            g.matchingSize = 0;
            g.used = zeros(1, g.leftLobeSize);
            g.taked = zeros(1, g.leftLobeSize);
            for k = 1: g.rightLobeSize
                g.match(k) = -1;
            end
            while run
                run = false;
                g.usedTimer = g.usedTimer + 1;
                for k = 1: size(g.g, 1)
                    if ~g.taked(k) && dfs(g, k)
                        run = true;
                        g.matchingSize = g.matchingSize + 1;
                    end
                end
            end
        end
        
        function res = leftLobeSize(obj)
            res = size(obj.g, 1);
        end
        
        function res = rightLobeSize(obj)
            res = size(obj.match, 2);
        end
        
        function res = getMatchingSize(obj)
            res = obj.matchingSize;
        end
        
        function res = getMatching(obj)
            res = obj.match;
        end
    end
    
    properties
        g; %array of adjaction lists
    end
    
    properties (Access = 'private')
        match; %array of adjacent nodes for the right lobe
        taked; 
        usedTimer;
        used; 
        matchingSize;
    end
    
    methods (Access = 'private')
        function res = dfs(g, v)
            res = false;
            if g.used(v) ~= g.usedTimer
                g.used(v) = g.usedTimer;
                for toId = 0: g.g{v}.size() - 1
                    to = g.g{v}.get(toId);
                    if g.match(to) == -1
                        g.match(to) = v;
                        g.taked(v) = 1;
                        res = true;
                        return;
                    end
                end
                for toId = 0: g.g{v}.size() - 1
                    to = g.g{v}.get(toId);
                    if dfs(g, g.match(to))
                        g.match(to) = v;
                        g.taked(v) = 1;
                        res = true;
                        return;
                    end
                end
            end
        end
    end
    
end

