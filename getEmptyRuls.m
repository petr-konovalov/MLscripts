function ruls = getEmptyRuls(comSize)
    ruls(comSize, 1) = Crul(0, 0, 0, 0, 0);
    for k = 1: comSize
        ruls(k) = Crul(0, 0, 0, 0, 0);
    end
end