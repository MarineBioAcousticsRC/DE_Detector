function [metaDir] = dBuild_dirs(baseDir)
% build output directories

metaDir = ([baseDir,'metadata']);

if ~isdir(metaDir)
    mkdir(metaDir)
end
