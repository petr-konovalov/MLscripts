function [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(B)
    persistent oldBState;
    persistent hX; %history of ball coordinate X
    persistent hY; %history of ball coordinate Y
    persistent T;
    curTime = cputime();
    ballStandingSpeed = 0.4;
    fastBallSpeed = 1;
    hStepBallSpeed = 1;
    hStepSaveDir = 1;
    hLen = 10; %historyLength

    if isempty(oldBState)
        oldBState = struct('BFast', false, 'BStand', true, 'saveDir', true, 'BSpeed', [0, 0]);
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
    
    if (B.I ~= 0)
        BPEstim = B.z;
        if (T(hLen) ~= curTime && (B.x ~= hX(hLen) || B.y ~= hY(hLen))) %check for new data
            for i = 1: hLen - 1
                hX(i) = hX(i + 1);
                hY(i) = hY(i + 1);
                T(i) = T(i + 1);
            end
            hX(hLen) = B.x;
            hY(hLen) = B.y;
            T(hLen) = cputime();

            BState = ballRecognizedCase(B, T, hX, hY, hLen, hStepBallSpeed, hStepSaveDir, fastBallSpeed, ballStandingSpeed);
            %Ball speed can't be too large
            if BState.BSpeed > 10
                %prediction model
                BState = oldBState;
                BPEstim = ballNotRecognizedCase(curTime - T(hLen), [hX(hLen), hY(hLen)], oldBState);
            end
        else
            BState = oldBState;
        end
    else
        %prediction model
        BPEstim = ballNotRecognizedCase(curTime - T(hLen), [hX(hLen), hY(hLen)], oldBState);
        BState = oldBState;
    end
    oldBState = BState;
    BPosHX = hX;
    BPosHY = hY;
end


function res = getCos(U, V)
    res = scalMult(U, V) / (norm(U) * norm(V));
end

function BState = ballRecognizedCase(B, T, hX, hY, hLen, hStepBallSpeed, hStepSaveDir, fastBallSpeed, ballStandingSpeed)
    BState = struct('BFast', false, 'BStand', true, 'saveDir', true, 'BSpeed', [0, 0]);
    BState.BSpeed = [hX(hLen) - hX(hLen - hStepBallSpeed), hY(hLen) - hY(hLen - hStepBallSpeed)] / ((T(hLen) - T(hLen - hStepBallSpeed)) * 1000);
    SpeedAbs = norm(BState.BSpeed);
    BState.BFast = SpeedAbs > fastBallSpeed;
    BState.BStand = SpeedAbs < ballStandingSpeed;
    if (BState.BFast)
        %задаЄт допустимые значени€ косинуса угла между текущим и
        %предыдущим направлени€ми движени€ м€ча
        sensivity = 0.8;
        curDir = B.z - [hX(hLen - hStepSaveDir), hY(hLen - hStepSaveDir)];
        prevDir = [hX(hLen - hStepSaveDir) - hX(hLen - 2 * hStepSaveDir), hY(hLen - hStepSaveDir) - hY(hLen - 2 * hStepSaveDir)];
        BState.saveDir = getCos(curDir, prevDir) >= sensivity;
    else
        BState.saveDir = true;
    end
end

function BPEstim = ballNotRecognizedCase(dT, lastRecognizedBP, oldBState)
    if oldBState.BStand
        BPEstim = lastRecognizedBP; 
    else
        BPEstim = lastRecognizedBP + oldBState.BSpeed * dT; 
    end
end