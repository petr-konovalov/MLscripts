function goalZone = getGoalZone(G, V, goalSizes)
	ortV = [V(2), -V(1)];
	goalZone = [G+goalSizes(1)*V-goalSizes(2)*ortV/2, G+goalSizes(2)*ortV/2];
end
