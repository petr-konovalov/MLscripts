function [fastMoving, ballStanding, saveDir, ballSpeed, BPosHX, BPosHY] = ballMovingManager(B)
    persistent oldFastMoving;
    persistent oldSaveDir;
    persistent oldBallSpeed;
    persistent oldBallStanding;
    persistent hX; %history of ball coordinate X
    persistent hY; %history of ball coordinate Y
    persistent T;
    ballStandingSpeed = 0.4;
    fastBallSpeed = 1;
    hStepBallSpeed = 1;
    hStepSaveDir = 1;
    hLen = 10; %historyLength
    
    if isempty(oldFastMoving) 
        oldFastMoving = false;
    end
    
    if isempty(oldSaveDir)
        oldSaveDir = true;
    end
    
    if isempty(oldBallSpeed)
        oldBallSpeed = [0, 0];
    end
    
    if isempty(oldBallStanding)
        oldBallStanding = true;
    end
    
    if (numel(hX) < hLen || numel(hY) < hLen || numel(T) < hLen)
        hX = zeros(1, hLen);
        hY = zeros(1, hLen);
        T = zeros(1, hLen);
        for i = 1: hLen
            hX(i) = B.x;
            hY(i) = B.y;
            T(i) = cputime();
        end
    end
    
    if (B.I ~= 0 && (B.x ~= hX(hLen) || B.y ~= hY(hLen))) %check for new data
        %fprintf('%.2f %.2f\n', B.x, B.y);
        for i = 1: hLen - 1
            hX(i) = hX(i + 1);
            hY(i) = hY(i + 1);
            T(i) = T(i + 1);
        end
        hX(hLen) = B.x;
        hY(hLen) = B.y;
        T(hLen) = cputime();
        
        %ballMovement = B.z - [hX(1), hY(1)];
        ballSpeed = [hX(hLen) - hX(hLen - hStepBallSpeed), hY(hLen) - hY(hLen - hStepBallSpeed)] / ((T(hLen) - T(hLen - hStepBallSpeed)) * 1000);
        %disp(ballSpeed);
        SpeedAbs = norm(ballSpeed);
        fastMoving = SpeedAbs > fastBallSpeed;
        ballStanding = SpeedAbs < ballStandingSpeed;
        if (fastMoving)
            %задаЄт допустимые значени€ косинуса угла между текущим и
            %предыдущим направлени€ми движени€ м€ча
            sensivity = 0.8;
            curDir = B.z - [hX(hLen - hStepSaveDir), hY(hLen - hStepSaveDir)];
            prevDir = [hX(hLen - hStepSaveDir) - hX(hLen - 2 * hStepSaveDir), hY(hLen - hStepSaveDir) - hY(hLen - 2 * hStepSaveDir)];
            saveDir = getCos(curDir, prevDir) >= sensivity;
        else
            saveDir = true;
        end
    else
        saveDir = oldSaveDir;
        fastMoving = oldFastMoving;
        ballSpeed = oldBallSpeed;
        ballStanding = oldBallStanding;
    end
    oldFastMoving = fastMoving;
    oldSaveDir = saveDir;
    oldBallSpeed = ballSpeed;
    oldBallStanding = ballStanding;
    %outBuffer(2) = fastMoving;
    BPosHX = hX;
    BPosHY = hY;
end


function res = getCos(U, V)
    res = scalMult(U, V) / (norm(U) * norm(V));
end
