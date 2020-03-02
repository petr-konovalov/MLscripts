function U = getTrapetzoidControl(T, coef, maxV, maxA, aimX, curX, epsV)
    dXr = getTrapetzoidMotionVelocity(T, maxV, maxA, aimX);
    Xr = getTrapetzoidMotionPoint(T, maxV, maxA, aimX);
    U = (dXr+sign(Xr-curX)*epsV)/coef;
end