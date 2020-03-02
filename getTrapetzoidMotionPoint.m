function X = getTrapetzoidMotionPoint(T, maxV, maxA, aimX)
    t0 = maxV / maxA;
    t1 = aimX / maxV;
    tf = t1 + t0;
    
    if T <= t0 
        X = maxA * T * T / 2;
    elseif T <= t1
        X = maxV * maxV / (2 * maxA) + (T - t0) * maxV;
    elseif T <= tf
        X = maxV * maxV / (2 * maxA) + (T - t0) * maxV - maxA * (T - t1) * (T - t1) / 2;
    else
        X = aimX;
    end
end