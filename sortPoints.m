function [sortedPointsX, sortedPointsY] = sortPoints(skelPoints, EP1, EP2)
%SortPoints
%This function takes in a spline skeleton, and the two endpoints. 
%It will run a shortest neighbor algorithm, setting each
%previous neighbor to a distance of 100000000.
EP1x = EP1(1,1);
EP1y = EP1(1,2);
if nargin == 2
    EP2x = 10000;
    EP2y = 10000;
else
    EP2x = EP2(1,1);
    EP2y = EP2(1,2);
end
[max, ~] = size(skelPoints);
sortedPointsX = [];
sortedPointsY = [];
%Start with EP1 and find nearest neighbour
sortedPointsX(1,1) = EP1x;
sortedPointsY(1,1) = EP1y;
pointx = EP1x;
pointy = EP1y;
%for each point along the spline as you move through it
i=2;
while ~((pointx == EP2x) && (pointy == EP2y))
    distances = [];
    %find distance between selected point and all points on spline
    for j=1:max
        distances = [distances, sqrt((skelPoints(j,1) - pointx)^2 + (skelPoints(j,2) - pointy)^2)];
    end
    %find min distance
    [val,idx] = min(distances);
    while val ==0
        %then this is the endpoint 
        skelPoints(idx,:) = 10000; %make it far away
        %calculate distances again
        distances = [];
        for j=1:max
            distances = [distances, sqrt((skelPoints(j,1) - pointx)^2 + (skelPoints(j,2) - pointy)^2)];
        end
        [val,idx] = min(distances);
    end
    if val>10000
    else
        sortedPointsX(i,1) = skelPoints(idx, 1);
        sortedPointsY(i,1) = skelPoints(idx, 2);
    end
        pointx = skelPoints(idx, 1);
        pointy = skelPoints(idx, 2);
        i = i+1;
end