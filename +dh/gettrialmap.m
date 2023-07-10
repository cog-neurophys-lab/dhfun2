%  [TRIALNO,STIMNO,OUTCOME,STARTTIME,ENDTIME] = dhfun(DH.GETTRIALMAP,FID)
%
%  Read the entire contents of the TRIALMAP dataset
%
%  arguments:
%  FID - file identifier returned by open function
%  TRIALNO - TrialNo member of TRIALMAP_ITEM struct
%            usually corresponds to the TrialNo member of
%            TD01 item associated with a particular trial
%  STIMNO - StimNo member of TRIALMAP_ITEM struct
%            usually corresponds to the StimNo member of
%            TD01 item associated with a particular trial
%  OUTCOME - Outcome member of TRIALMAP_ITEM struct
%            contains trial outcome code
%  STARTTIME - StartTime member of TRIALMAP_ITEM struct
%            contains start time of trial in nanoseconds
%  ENDTIME  - EndTime member of TRIALMAP_ITEM struct
%            contains end time of trial in nanoseconds
%
%  Remarks:
%
%  Each output argument is returned as array with elements
%  corresponding to individual trials
function [trialno,stimno,outcome,starttime,endtime] = gettrialmap(fid)

filename = get_filename(fid);

fileInfo = h5info(filename).Datasets;
trialMapInfo = filter_by_name(fileInfo, "TRIALMAP");
trialMapData = h5read(filename, '/TRIALMAP');

trialno = trialMapData.TrialNo;
stimno = trialMapData.StimNo;
outcome = trialMapData.Outcome;
starttime = trialMapData.StartTime;
endtime = trialMapData.EndTime;

