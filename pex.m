% Total response time for parallel exhaustive model
% see equation 3.11 - Haiyuan Yang thesis
function [accuracy, time, idx] = pex(x1, x2, y1, y2)

if x1 <= x2 && y1 <= y2
    accuracy = 1; 
    time = max([x1, y1]);
    idx = 1;
elseif x1 <= x2 && y1 > y2
    accuracy = 0;
    time = y2;
    idx = 2;
elseif x1 > x2 && y1 <= y2
    accuracy = 0; 
    time = x2; 
    idx = 3;
elseif x1 > x2 && y1 > y2
    accuracy = 0; 
    time = min([x2, y2]);
    idx = 4;
else
    error('pst: undeclared option');
end
    
    