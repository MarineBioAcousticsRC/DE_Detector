function handle = openAnnot(pathStr, baseName, featureId, ext, viewPath)
% handle = openAnnot(pathstr, basename, FeatureId, Ext, Viewpath)
% Open an annotation file based upon the current path, the file
% basename, the FeatureId string (distinguishes multiple feature
% sets), and the annotation extension.

if ~ isempty(ext)
    annotFilename = ...
        fullfile(pathStr, sprintf('%s%s.%s', baseName, ...
        featureId, ext));
    handle = ioOpenViewpath(annotFilename, viewPath, 'w');
else
    handle = -1;   % treat as if error, writes will test
end
