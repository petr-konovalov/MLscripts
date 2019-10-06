%AB - considered segment

function res = checkSeg(A, B, obstacles)
    res = true;
    for j = 1: size(obstacles, 1)
        obst = obstacles(j, :);
        if numel(SegmentCircleIntersect(A(1), A(2), B(1), B(2), obst(1), obst(2), obst(3))) > 0
            res = false;
            break;
        end
    end
end