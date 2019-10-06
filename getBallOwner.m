function [cmd, id] = getBallOwner(ballFastMoving, ballSaveDir, ball, own, opp, ownG, oppG)
    persistent prevOwnerCmd;
    persistent prevOwnerId;
    
    if (isempty(prevOwnerId) || isempty(prevOwnerCmd))
        %предыдущий владелец не определён
        prevOwnerCmd = -1;
        prevOwnerId = -1;
    end
    
    if ballFastMoving
        [cmd, id] = getOwnerWhenBallFast(ballSaveDir, prevOwnerCmd, prevOwnerId);
    else
        [cmd, id] = getOwnerWhenBallSlow(ball, own, opp, ownG, oppG);
    end
    
    prevOwnerCmd = cmd;
    prevOwnerId = id;
end