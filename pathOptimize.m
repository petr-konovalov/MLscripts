function optPath = pathOptimize(path, obstacles)
    import java.util.LinkedList;

    aPath = pathToArr(path);
    pathLen = size(aPath, 1);
    optPath = LinkedList();
    
    curPnt = aPath(1, :);
    optPath.add(curPnt);
    
    k = 1;
    while k < pathLen
        j = k + 2;
        k = k + 1;
        while j <= pathLen
            if checkSeg(curPnt, aPath(j, :), obstacles)
                k = j;
            end
            j = j + 1;
        end
        curPnt = aPath(k, :);
        optPath.add(curPnt);
    end
end

function aPath = pathToArr(path)
    aPath = zeros(path.size(), 2);
    
    for k = 1: size(aPath, 1)
        tmp = path.pop();
        aPath(k, :) = [tmp(1), tmp(2)];
    end
end