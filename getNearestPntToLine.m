%pnt - ����� ��� ������� ����� ������� ��������� �� ������
%A, B - ����� ����� ������� �������� ������

function res = getNearestPntToLine(pnt, A, B)
    vec = B - A;
    vec = vec / norm(vec);
    t = scalMult(vec, pnt - A);
    res = A + vec * t;
end