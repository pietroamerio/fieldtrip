function trl = artifact2trl(artifact)

% ARTIFACT2TRL converts between two representations of events or trials.
%
% FieldTrip uses a number of representations for events that are conceptually very similar
%   event    = structure with type, value, sample, duration and offset
%   trl      = Nx3 numerical array with begsample, endsample, offset
%   trl      = table with 3 columns for begsample, endsample, offset
%   artifact = Nx2 numerical array with begsample, endsample
%   artifact = table with 2 columns for begsample, endsample
%   boolvec  = 1xNsamples boolean vector with a thresholded TTL/trigger sequence
%   boolvec  = MxNsamples boolean matrix with a thresholded TTL/trigger sequence
%
% If trl or artifact are represented as a MATLAB table, they can have additional
% columns. These additional columns have to be named and are not restricted to
% numerical values.
%
% See also ARTIFACT2BOOLVEC, ARTIFACT2EVENT, ARTIFACT2TRL, BOOLVEC2ARTIFACT, BOOLVEC2EVENT, BOOLVEC2TRL, EVENT2ARTIFACT, EVENT2BOOLVEC, EVENT2TRL, TRL2ARTIFACT, TRL2BOOLVEC, TRL2EVENT

% Copyright (C) 2009, Ingrid Nieuwenhuis
% Copyright (C) 2020, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

% trl and artifact are similar, except for the offset column
if isnumeric(artifact)
  if size(artifact,2)==2
    % the first two columns are begin and endsample
    trl(:,1:2) = artifact;
    trl(:,3)   = 0;
  elseif size(artifact,2)>2
    % when present, the third column must be the offset
    trl = artifact;
  end
elseif istable(artifact)
  trl = table();
  if isempty(artifact)
    % an empty table does not contain any columns, the output is empty as well
  elseif ismember('offset', artifact.Properties.VariableNames)
    % the artifact matrix already contains an offset
    trl = artifact;
  else
    trl.begsample = artifact.begsample;
    trl.endsample = artifact.endsample;
    trl.offset = zeros(size(trl.begsample)); % set the offset to zero
    % keep any additional columns
    trl = cat(2, trl, artifact(:,3:end));
  end
elseif iscell(artifact)
  % there are multiple types of trials/artifacts, use recursion to loop over them
  trl = cell(size(artifact));
  for i=1:numel(artifact)
    trl{i} = artifact2trl(artifact{i});
  end
end