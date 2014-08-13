function [f, uppc] = dtf_map(tf_fname,f_desired)
% [f, uppc] = function tfmap(filename, channel, f_desired, verbose)
% transfer function map
% Given a filename and channel, determine which transfer function to use.
% Currently rather primitive (table lookup) and is only used
% in dtHighResClickBatch but transfer function handling should
% be done everywhere.
%
% If the optional argument f_desired is given, the transfer
% function is linearly interpolated to the specified frequency
% range.  Extrapolation is permitted, but should be used with
% caution.

% map to accomplish:  filename --> transfer fn file
% map contains regular expressions that are compared to
% the input filename sequentially.  When the first match
% occurs, the corresponding file is loaded and f, uppc
% are set to the appropriate frequencies and offsets.

fid = fopen(tf_fname,'r');
if fid ~=-1
    % read in transfer function file
    [A,count] = fscanf(fid,'%f %f',[2,inf]);
    f = A(1,:);
    uppc = A(2,:);    % [dB re uPa(rms)^2/counts^2]
    fclose(fid);
    
    % If user wants response for different frequencies than those
    % in the transfer function, use linear interpolation.
    if nargin > 1 && ...
            (length(f_desired) ~= length(f) || sum(f_desired ~= f))
        % interpolate for frequencies user wants
        uppc = interp1(f, uppc, f_desired, 'linear', 'extrap');
        f = f_desired;
    end
else
    msg = sprintf('Unable to open transfer function %s',tf_fname);
    error('TRANSFER_FN', msg);
end

