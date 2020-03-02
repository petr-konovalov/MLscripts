function V = getTrapetzoidMotionVelocity(T, maxV, maxA, aimX)
    t0 = maxV / maxA;
    t1 = aimX / maxV;
    tf = t1 + t0;
    
    if T <= t0 
        V = maxA * T;
    elseif T <= t1
        V = maxV;
    elseif T <= tf
        V = maxV - (T - t1) * maxA;
    else
        V = 0;
    end
end