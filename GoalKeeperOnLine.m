function rul = GoalKeeperOnLine(agent, G, V, BPosHX, BPosHY, ballStanding, ballSpeed)
    v = 400; % окрестность ворот, их ширина, радиус окружности
    eps = 50;
    %minBallSpeed = 0.5;
    %historyLength = 8;
    hPoly = 3;
    hLen = size(BPosHX, 2);
    BPos = [BPosHX(hLen), BPosHY(hLen)];
    
%     persistent BPosHX; %history of ball coordinate X
%     persistent BPosHY; %history of ball coordinate Y
%     persistent hX; %history of ball coordinate X
%     persistent hY; %history of ball coordinate Y
%     persistent T;
%     hLen = 17; %historyLength
%     hStepBallSpeed = 7;
%     
%     if (isempty(BPosHX) || isempty(BPosHY) || numel(BPosHX) < historyLength || numel(BPosHY) < historyLength)
%         BPosHX = zeros(1, historyLength);
%         BPosHY = zeros(1, historyLength);
%         for i = 1: historyLength
%             BPosHX(i) = B.x;
%             BPosHY(i) = B.y;
%         end
%     else
%         for i = 1: historyLength - 1
%             BPosHX(i) = BPosHX(i + 1);
%             BPosHY(i) = BPosHY(i + 1);
%         end
%         BPosHX(historyLength) = B.x;
%         BPosHY(historyLength) = B.y;
%     end
%     
%     %ballMovement = [B.x, B.y] - [BPosHX(1), BPosHY(1)];
%     rul = Crul(0, 0, 0, 0, 0);
%     
%     if (isempty(hX) || isempty(hY) || isempty(T) || numel(hX) < hLen || numel(hY) < hLen || numel(T) < hLen)
%         hX = zeros(1, hLen);
%         hY = zeros(1, hLen);
%         T = zeros(1, hLen);
%         for i = 1: hLen
%             hX(i) = B.x;
%             hY(i) = B.y;
%             T(i) = cputime();
%         end
%     elseif (B.I ~= 0)
%         for i = 1: hLen - 1
%             hX(i) = hX(i + 1);
%             hY(i) = hY(i + 1);
%             T(i) = T(i + 1);
%         end
%         hX(hLen) = B.x;
%         hY(hLen) = B.y;
%         T(hLen) = cputime();
%     end     
%         %ballMovement = B.z - [hX(1), hY(1)];
%         ballSpeed = [hX(hLen) - hX(hLen - hStepBallSpeed), hY(hLen) - hY(hLen - hStepBallSpeed)] / ((T(hLen) - T(hLen - hStepBallSpeed)) * 1000);
%         %disp(ballSpeed);
%         SpeedAbs = norm(ballSpeed);
%         ballMovement = [hX(hLen) - hX(hLen - hStepBallSpeed), hY(hLen) - hY(hLen - hStepBallSpeed)];
%    
%     
%     
    
    %SpeedX = StabilizationXPID(agent, G(1), 10, 1/750, 0.000000, -0.8, 50);
    %if (sqrt((tmp(1) - B.x) ^ 2 + (tmp(2) - B.y) ^ 2) >= radius) && (V(1) * (B.x - G(1)) + V(2) * (B.y - G(2)) >= 0)
    if (~ballStanding && dot(V, BPos - G) >= 0 && dot(V, ballSpeed) < 0)
        p = polyfit(BPosHX(hLen - hPoly: hLen), BPosHY(hLen - hPoly: hLen), 1);
        [x, y] = getPointForGoalkeeper([0, p(2)], [1, p(1) + p(2)], G, V);
        if (r_dist_points([x, y], G) <= v + eps)
%           SpeedY = StabilizationYPID(agent, y, 60, 5/750, 0.000000, -2 , 100);
%           Speed = SpeedX + SpeedY;
%           rul = Crul(Speed(1), Speed(2), 0, 0, 0);
            %rulRot = RotateToLinear(agent, B.z, 5, 0, 0.1);
            rul = MoveToPD(agent, [x, y], 80, 10/750, 0, 60);
            %rul = MoveToPD(agent, [x, y], 50, 0, 0, 40);
            %rul = MoveToWithFBPPlusParam(agent, [x,y], 40, obstacles([1 : agent.id, agent.id : 8], :));
            %rul.SpeedR = rulRot.SpeedR;
            %disp('move');
        else
           %rul = Crul(SpeedX(1), SpeedX(2), 0, 0, 0);
           rul = RotateToLinear(agent, BPos, 2, 20, 0.05);
           %disp('rot');
        end
    else
        %rul = Crul(SpeedX(1), SpeedX(2), 0, 0, 0);
        %rul = RotateToLinear(agent, [B.x, B.y], 10, 15, 0.2);
        %rul = MoveToWithRotation(agent, G, B.z, 0, 20, 75, 2, 20, 0, 0, 0.05, false);
        rul = MoveToPD(agent, G, 15, 2/750, -1.5, 50);
        %rul = MoveToWithFBPPlusParam(agent, G, 50, obstacles([1 : agent.id, agent.id : 8], :));
        rotRul = RotateToLinear(agent, BPos, 2, 20, 0.05);
        rul.SpeedR = rotRul.SpeedR;
        %rul = Crul(0, 0, 0, 0, 0);
        %disp('rotate');
    end
end
