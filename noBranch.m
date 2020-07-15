function [BinIM_nobranch] = noBranch(BinIM)
% Find branchpoints (hopefully only ever 1 or none) and remove
BinIM = bwskel(BinIM);
branchPoints = bwmorph(BinIM, 'branchpoints');
if branchPoints == logical(zeros(551,551))
    BinIM_nobranch = bwskel(BinIM);
else
    [check, ~] = size(find(branchPoints.' == 1));
    if check>1
        BinIM_nobranch = logical(zeros(551,551));
        return
    else
    branchSub = BinIM - bwmorph(branchPoints, 'thicken');
    [r, c] = find(branchPoints.' == 1);
    position = [r, c];

    % Find 3 nearest neighbours to branch point:
    [a,b] = find(branchSub.' == 1);
    nonzero = [a,b];
    [m,~] = size(nonzero);
    distances = [];
    for i = 1:m
        distances = [distances, sqrt((nonzero(i,1) - position(:,1))^2 + (nonzero(i,2) - position(:,2))^2)];
    end
    n = 3;
    val = zeros(n,1);
    idx = zeros(n,1);
    %find 3 points that are minimums of distances
    for i=1:n
      [val(i),idx(i)] = min(distances);
      distances(idx(i)) = NaN;
    end
    % Determine which point is on the main branch
        %Find line with largest area, determine which point (of three) is on
        %that line
    mainline = bwareafilt(~(branchSub<1),1);
    
    % Define the Points
    if mainline(nonzero(idx(1),2), nonzero(idx(1),1)) == 1
        %then point one on mainline
        mainlinept = [nonzero(idx(1),2), nonzero(idx(1),1)];
        branchpt1 = [nonzero(idx(2),2), nonzero(idx(2),1)];
        branchpt2 = [nonzero(idx(3),2), nonzero(idx(3),1)];

    elseif mainline(nonzero(idx(2),1), nonzero(idx(2),2)) ==1
        %then second point on mainline
        mainlinept = [nonzero(idx(2),2), nonzero(idx(2),1)];
        branchpt1 = [nonzero(idx(1),2), nonzero(idx(1),1)];
        branchpt2 = [nonzero(idx(3),2), nonzero(idx(3),1)];
    else
        %then third point on mainline
        mainlinept = [nonzero(idx(3),2), nonzero(idx(3),1)];
        branchpt1 = [nonzero(idx(2),2), nonzero(idx(2),1)];
        branchpt2 = [nonzero(idx(1),2), nonzero(idx(1),1)];
    end

   % Find angle between main branch point, branchpoint, and either branch
    x0 = position(1,1);
    y0 = position(1,2);
    x1 = mainlinept(1,2);
    y1 = mainlinept(1,1);
    x2 = branchpt1(1,2);
    y2 = branchpt1(1,1);
    x3 = branchpt2(1,2);
    y3 = branchpt2(1,1);

    angle2 = acos((((x0 - x1)^2 + (y0 - y1)^2) + ((x0 - x2)^2 + (y0 - y2)^2) - ((x1 - x2)^2 + (y1 - y2)^2)) / (2 * sqrt((x0 - x1)^2 + (y0 - y1)^2) * sqrt((x0 - x2)^2 + (y0 - y2)^2)))*180/pi;
    angle3 = acos((((x0 - x1)^2 + (y0 - y1)^2) + ((x0 - x3)^2 + (y0 - y3)^2) - ((x1 - x3)^2 + (y1 - y3)^2)) / (2 * sqrt((x0 - x1)^2 + (y0 - y1)^2) * sqrt((x0 - x3)^2 + (y0 - y3)^2)))*180/pi;

    % Get rid of branch with smaller angle
    if (180-angle2)>(180-angle3)
        %then want to get rid of branch associated with angle2
        branchSub(branchpt1(1,1), branchpt1(1,2)) = 0;
        [a,b] = find(branchSub.' == 1);
        nonzero = [a,b];
        [m,n] = size(nonzero);
        distances2 = [];
        for i = 1:m
            distances2 = [distances2, sqrt((nonzero(i,1) - branchpt1(1,2))^2 + (nonzero(i,2) - branchpt1(1,1))^2)];
        end
        [val,idx] = min(distances2);
        BinIM_nobranch = BinIM;
        BinIM_nobranch(branchpt1(1,1), branchpt1(1,2)) = 0;
        BinIM_nobranch(nonzero(idx(1),2), nonzero(idx(1),1)) = 0;

        BinIM_nobranch = bwareafilt(BinIM_nobranch, 1);
        BinIM_nobranch = bwmorph(BinIM_nobranch, 'spur', 2);
    else
        %then want to get rid of branch associated with angle3
        branchSub(branchpt2(1,1), branchpt2(1,2)) = 0;
        [a,b] = find(branchSub.' == 1);
        nonzero = [a,b];
        [m,n] = size(nonzero);
        distances2 = [];
        for i = 1:m
            distances2 = [distances2, sqrt((nonzero(i,1) - branchpt2(1,2))^2 + (nonzero(i,2) - branchpt2(1,1))^2)];
        end
        [val,idx] = min(distances2);
        BinIM_nobranch = BinIM;
        BinIM_nobranch(branchpt2(1,1), branchpt2(1,2)) = 0;
        BinIM_nobranch(nonzero(idx(1),2), nonzero(idx(1),1)) = 0;

        BinIM_nobranch = bwareafilt(BinIM_nobranch, 1);
        BinIM_nobranch = bwmorph(BinIM_nobranch, 'spur', 2);
    end
    end
end
end