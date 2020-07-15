function [spline, endpoints] = extend(BinIM, skel)
% Takes thresholded binary image and extends the spline to the boundary
%of the worm if it is not there yet. Can input a skeleton if branching has
%been corrected already.

%boundary of the worm:
[boundaryx, boundaryy] = find(bwmorph(BinIM, 'endpoints').' == 1);

if ~exist('skel','var')
     % no input skeleton, so skeletonize the input BinIM
      skel = bwskel(BinIM);
end

[a,b] = find(skel.' == 1); %get array of points on skeleton
nonzero = [a,b];
[m,n] = size(nonzero);

%initial endpoints of skeleton
[xs, ys] = find(bwmorph(skel, 'endpoints').' ==1);

%for circular worms
if m<10
    spline = nonzero;
    endpoints = [xs, ys];
    return
end

endpoints = [];
%For both endpoints of skeleton:
for i2 = 1:2
    %is the endpoint already close to the boundary?
    [a,b] = find(bwmorph(BinIM, 'endpoints').' == 1);
    boundary = [a,b];
    [boundm,~] = size(boundary);
    endpoint = [xs(i2,1), ys(i2,1)];
    distances_endpt = [];
    for i = 1:boundm
        calcDist = sqrt((boundaryx(i,1) - endpoint(1,1))^2 + (boundaryy(i,1) - endpoint(1,2))^2);
        distances_endpt = [distances_endpt, calcDist];
    end
    [valbound,~] = min(distances_endpt);
    if valbound>1.5
    %then not close enough to boundary
        distances = [];
        for i = 1:m
            calcDist = sqrt((nonzero(i,1) - endpoint(1,1))^2 + (nonzero(i,2) - endpoint(1,2))^2);
            if calcDist>1.5
            distances = [distances, calcDist];
            else
            distances = [distances, NaN];
            end
        end
        [~,idx] = min(distances);
        secondPoint = [nonzero(idx(1),2), nonzero(idx(1),1)];
        slope = (secondPoint(1,2)-endpoint(1,1))/(secondPoint(1,1)-endpoint(1,2));
        step = 1;
        if slope == double(Inf)
            slope = 100;
            step = 0.02;
        elseif slope == double(-Inf)
            slope = -100;
            step = 0.02;
        elseif abs(slope)>1
            step = 0.5;
        end
    
        intc = endpoint(1,1)-slope*endpoint(1,2);

        %try point on line
        xnew = (endpoint(1,2)+step);
        newPt1 = [(xnew), (slope*xnew+intc)];
        %if new point going wrong direction, towards skeleton:
        distances_dir = [];
        for i = 1:m
        calcDist = sqrt((nonzero(i,1) - newPt1(1,2))^2 + (nonzero(i,2) - newPt1(1,1))^2);
        distances_dir = [distances_dir, calcDist];
        end
        [val,~] = min(distances_dir);

        if val<1
            %turn around and start plotting the other way
            xnew = (endpoint(1,2)-step);
            newPt = [(slope*xnew+intc), (xnew)];
            nonzero = [nonzero; newPt];
            is = 1;
            while is == 1
                xnew = (xnew-step);
                newPt = [(slope*xnew+intc),(xnew)];
                nonzero = [nonzero; newPt];
                %is close to boundary?
                for i = 1:boundm
                    calcDist = sqrt((boundaryx(i,1) - newPt(1,1))^2 + (boundaryy(i,1) - newPt(1,2))^2);
                    if calcDist<1.1
                        endpoints(i2, 1) = newPt(1,1);
                        endpoints(i2, 2) = newPt(1,2);
                        is = 0;
                    end
                end
            end
        else
            %keep plotting in that direction
            disp("right direction")
            nonzero = [nonzero; newPt1(1,2),newPt1(1,1)];
            is = 1;
            while is == 1
                xnew = (xnew+step);
                newPt = [(slope*xnew+intc), (xnew)];
                nonzero = [nonzero; newPt];
                %is close to boundary?
                for i = 1:boundm
                    calcDist = sqrt((boundaryx(i,1) - newPt(1,1))^2 + (boundaryy(i,1) - newPt(1,2))^2);
                    if calcDist<1.1
                        endpoints(i2, 1) = newPt(1,1);
                        endpoints(i2, 2) = newPt(1,2);
                        is=0;
                    end
                end
            end
        end
    else
        endpoints(i2,1) = xs(i2,1);
        endpoints(i2,2) = ys(i2,1);
    end
end
spline = nonzero;
end