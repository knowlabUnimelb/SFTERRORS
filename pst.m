% Total response time for parallel self-terminating model
% see equation 3.23 - Haiyuan Yang thesis
function [accuracy, time, idx] = pst(x1, x2, y1, y2)

if x1 <= x2 && y1 <= y2
    accuracy = 1; 
    time = min([x1, y1]);
    idx = 1;
elseif x1 <= x2 && y1 > y2
    accuracy = 1;
    time = x1;
    idx = 2; 
elseif x1 > x2 && y1 <= y2
    accuracy = 1; 
    time = y1; 
    idx = 3;
elseif x1 > x2 && y1 > y2
    accuracy = 0; 
    time = max([x2, y2]);
    idx = 4;
else
    error('pst: undeclared option');
end
    
    