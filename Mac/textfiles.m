



for i = 1:length(run_info.onsets);
        fprintf('%d\t%d\t%.2f\t%.2f\t%.3f\t%s\n',i,run_info.trial_order(i),run_info.onsets(i),run_info.durations(i),run_info.rt(i),run_info.responses{i});    
    end;
    
    fid = fopen([run_info.output_filename 'new.txt'],'w');
    fprintf(fid,'\n\nEXPERIMENT INFO for %s, %s\n\n',run_info.script_name,run_info.output_filename);
    fprintf(fid,'Subject Code = %s\n',run_info.subject_code);
    fprintf(fid,'Input File = %s\n',run_info.stimulus_input_file);
    fprintf(fid,'Experiment notes: %s\n\n',run_info.experiment_notes);
    fprintf(fid,'Trial\tOrder\tOnset\tDur\tRT\tResponse\n\n');
    
    for i = 1:length(run_info.onsets);
            fprintf(fid,'%d\t%d\t%.2f\t%.2f\t%.3f\t%s\n',i,run_info.trial_order(i),run_info.onsets(i),run_info.durations(i),run_info.rt(i),run_info.responses{i});      
        end;