%required norm(SDir) == 1
function res = inHalfStrip(pnt, SCenter, SDir, SWidth)
    res = abs(vectMult(pnt - SCenter, SDir)) < SWidth &&  scalMult(pnt - SCenter, SDir) > 0;
end