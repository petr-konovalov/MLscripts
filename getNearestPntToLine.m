%pnt - точка для которой будет найдена ближайшая на прямой
%A, B - точки через которые проходит прямая

function res = getNearestPntToLine(pnt, A, B)
    vec = B - A;
    vec = vec / norm(vec);
    t = scalMult(vec, pnt - A);
    res = A + vec * t;
end