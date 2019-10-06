function [cmd, id] = getOwnerWhenBallSlow(ball, own, opp, ownG, oppG)
    %������� ����� ������������ �� ���� ����������� ��� �����������
    %���������
    distMinDiff = 200;
    %������ ����������� ���� (���� ��������) ������� ��� ����������� � ���
    ballOwnerArea = 300;
    
    %�������� �� ���������� ����
    if checkGoalKeeperZone(ball, ownG)
        cmd = 1;
        id = 1;
    elseif checkGoalKeeperZone(ball, oppG)
        cmd = 2;
        id = 1;
    else
        [fDist, fOwner] = calcBallCmdDist(ball, own);
        [sDist, sOwner] = calcBallCmdDist(ball, opp);
        if fDist < ballOwnerArea && sDist < ballOwnerArea
            %���� � ���� �������� ���� ���� ������ �� ������ ������ ��
            %�������� �� ��������
            cmd = -1;
            id = -1;
        %����� ��������� ��� ������� �� �����������
        elseif fDist < ballOwnerArea
            cmd = 1;
            id = fOwner;
        elseif sDist < ballOwnerArea
            cmd = 2;
            id = sOwner;
        elseif abs(fDist - sDist) < distMinDiff
            %���� ���������� �� ���� ������ ���������� �� ����������� ��
            %�������� �� ��������
            cmd = -1;
            id = -1;
            %����� ��������� ����� ������� �����
        elseif fDist < sDist
            cmd = 1;
            id = fOwner;
        else
            cmd = 2;
            id = sOwner;
        end
    end
end

function res = checkGoalKeeperZone(ball, G)
    goalKeeperArea = 900;
    res = r_dist_points(ball.z, G) < goalKeeperArea;
end


