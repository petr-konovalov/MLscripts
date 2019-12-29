function res = inHalfPlane(pnt, origin, vec)
    res = scalMult(pnt - origin, vec) > 0;
end