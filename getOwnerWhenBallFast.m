function [cmd, id] = getOwnerWhenBallFast(ballSaveDir, prevOwnerCmd, prevOwnerId)
    %���� ��� ��� ������� �������� ��������� �����������, �� ����������
    %������� ������ ������� ������ ����� ������, ����� ������ ��
    %��������
    if (ballSaveDir)
        cmd = prevOwnerCmd;
        id = prevOwnerId;
    else
        cmd = -1;
        id = -1;
    end
        %{
    elseif prevOwnerCmd == -1
        cmd = -1;
        id = -1;
    else
        %��������� ����������� ��� ����, ����� ��� ����� ����
        %������������ �����������
        ownerDist = 500;
        if prevOwnerCmd == 1 && r_dist_points(own(prevOwnerId).z, ball.z) < ownerDist || prevOwnerCmd == 2 && r_dist_points(opp(prevOwnerId).z, ball.z) < ownerDist
            cmd = prevOwnerCmd;
            id = prevOwnerId;
        else
            cmd = -1;
            id = -1;
        end
    end
        %}
end