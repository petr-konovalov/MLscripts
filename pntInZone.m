function res = pntInZone(pnt, zone)
	left = min(zone([1, 3]));
	right = max(zone([1, 3]));
	down = min(zone([2, 4]));
	up = max(zone([2, 4]));
	res = left <= pnt(1) && pnt(1) <= right && down <= pnt(2) && pnt(2) <= up;
end
