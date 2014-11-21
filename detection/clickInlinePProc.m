function [delFlag] = clickInlinePProc(outFileName,clickTimes,p)

% Step through vector of click times, looking forward and back to throw out
% solo clicks, and pairs of clicks, if they are too far away from a cluster
% of clicks with >2 members.
% outputs a vector of pruned times, and a vector flagging which members
% should be removed from other variables.
% Writes pruned times to .pTg file.

% % % Get rid of lone clicks % % %

% Step through deleting clicks that are too far from their preceeding
% and following click
clickTimesPruned = [];

clickTimes = sortrows(clickTimes);
if size(clickTimes,1) > 2
    delFlag = ones(size(clickTimes(:,1)));
    for itr1 = 1:size(clickTimes,1)
        if itr1 == 1
            if clickTimes(itr1+2,1)-clickTimes(itr1,1)>p.maxNeighbor
                delFlag(itr1) = 0;
            end
        elseif itr1 >= size(clickTimes,1)-1
            [I,~] = find(delFlag(1:itr1-1)==1);
            prevClick = max(I);
            if isempty(prevClick)
                delFlag(itr1) = 0;
            elseif clickTimes(itr1,1) - clickTimes(prevClick,1)>p.maxNeighbor
                delFlag(itr1) = 0;
            end
        else
            [I,~] = find(delFlag(1:itr1-1)==1);
            prevClick = max(I);
            if isempty(prevClick)
                if clickTimes(itr1+2,1) - clickTimes(itr1,1)>p.maxNeighbor
                    delFlag(itr1) = 0;
                end
            elseif clickTimes(itr1,1)- clickTimes(prevClick,1)>p.maxNeighbor &&...
                    clickTimes(itr1+2,1)-clickTimes(itr1,1)>p.maxNeighbor
                delFlag(itr1) = 0;
            end
        end
    end
    clickTimesPruned = clickTimes(delFlag==1,:);
elseif ~isempty(clickTimes)
    delFlag = zeros(size(clickTimes(:,1)));
else 
    delFlag = [];
end
% TODO: Get rid of pulsed calls

% get rid of duplicate times:
if size(clickTimesPruned,1)>1
    dtimes = diff(clickTimesPruned(:,1));
    closeStarts = find(dtimes<.00002);
    delFlag(closeStarts+1,:) = 0;
end

fidOut = fopen(strcat(outFileName(1:end-1),p.ppExt),'w+');
if ~isempty(clickTimesPruned)
    for itr3 = 1:size(clickTimesPruned,1)
        % Write post-processed click annotations to .pTg file
        fprintf(fidOut, '%f %f\n', clickTimesPruned(itr3,1),clickTimesPruned(itr3,2));
    end
else
    fprintf(fidOut, 'No clicks detected.');
end

fclose(fidOut);
