function res = inRect(pnt, SCenter, SDir, SWidth, SDepth)
	res = abs(vectMult(pnt - SCenter, SDir)) < SWidth &&  between(scalMult(pnt - SCenter, SDir), 0, SDepth);
end
