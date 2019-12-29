function [ruls1, ruls2] = startGame(center, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)
    global gameStatus;
    
    %ruls1 = [Crul(0, 0, 0, 0, 0), Crul(0, 0, 0, 0, 0)];
    ruls1 = gameModel(1, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY, gameStatus); 
    ruls2 = gameModel(2, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY, 3 - gameStatus); 
    
    if (r_dist_points(ball.z, center) > 300)
        %change game status when ball leave the center circle
        gameStatus = 3;
    end
end