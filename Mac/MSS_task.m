function MSS_scale(tdfile,resource_path)

%%MSS(tdfile,resource_path)
%This is a program which presents text, sound and video stimuli using a
%text delimited "script" that is compatible with Mac Stim, with certain
%added features.
%
%tdfile should be a tab delimited file with fields:
%[type,num,pre,maxTime,totTime,rep,stpEvt,bg,st,bgFile,stFile,hshift,vshift,tag]= textread( tab_delimited_text_file, '%c %d %f %f %f %d %s %c %c %s %s %d %d %s','delimiter', '\t', 'whitespace', '', 'commentstyle', 'matlab' );
%
%If you are not running your script from the directory that holds your
%tdfile, you should specify the entire path, e.g.
%/top_dir/mid_dir/location_of_td_file/tdfile.txt
%
%resource_path is an optional field containing the location of your resources, with default as same dir
%as tdfile

%% Set up variables for subject info and script info

experiment_name='Social Working Memory: Orange is the New Black Task';
experiment_code='SWM';  % this should be a short (2-3 letter) code for the experiment
% it will be put as part of the data file name
experiment_notes='SWM, subjects complete social and non-social working memory trials with characters from Orange is the New Black';

DATA_PATH = '~/Desktop/OINB_study/Data/swm/'; %Folder where you want to store your data
DEBUG = 1;
PRINT_OUTPUT = 1; %Results will always print to screen, PRINT_OUTPUT determines whether gets saved to txt file as well

%Will you start scans manually, or use the trigger?
%manual=0;

%For scanning, this variable 'manual' should equal 0

%Button box info
portName = '/dev/tty.KeySerial1'; % set this to the name of the port connected to your button box
baudRate = 115200; % set this to your scanner's baudrate

%END USER INPUT%

script_revision_date='08/21/17';
%Originally created 12/14/07 by Emily Falk
%Revisions

% print out the experiment information
fprintf('%s (revised %s)\n',experiment_name, script_revision_date);

% read in subject code
subject_code=input('Enter subject code: ','s'); % the 's' tells input to take in a text string rather than a number

% read in input device
button_box = input('Do you want to use the button box? [Enter 1 if yes, 0 if no]: ');

if DEBUG
    button_box
end;

%% Basic Input Testing

%make sure that the input script (tdfile) is actually a file
if ~exist(tdfile,'file')
    fprintf('Your input script %s does not exist.  Make sure you have the right path and filename.\n',tdfile);
else

    slash = findstr('/',tdfile); %find the slashes in the path specified for tdfile

    if isempty(slash) %if there are no slashes, we assume that no directory was provided and thus assume that tdfile is in the same dir with the MSS script
        tdfile_path = [pwd '/'];
    else
        tdfile_path = tdfile(1:slash(end)); %if there are slashes, we assume that everything preceeding the last slash is the directory and everything following is the file name for your script
    end;

    if DEBUG
        fprintf('tdfile_path = %s\n',tdfile_path)
    end;

    %%%%read in tab delimited file set up like MacStim (textread will read in as col vectors)
    [type,num,pre,maxTime,totTime,rep,stpEvt,bg,st,bgFile,stFile,hshift,vshift,tag,tag2,tag3,tag4,tag5,tag6,tag7,tag8]= textread(tdfile, '%c %d %f %f %f %d %s %c %c %s %s %d %d %d %d %d %d %d %d %d %d','delimiter', '\t', 'whitespace', '', 'commentstyle', 'matlab' );
end;

%Note: defaults for totTime, stpEvt, bgFile and stFile established elsewhere
if ~exist('resource_path') %if no resource path is specified, we assume that the resources are in the same dir as your tdfile script
    resource_path = tdfile_path;
elseif isempty(resource_path)
    resource_path = tdfile_path;
end;

if ~exist(resource_path,'dir')
    fprintf('WARNING: %s IS NOT A VALID PATH.\n',resource_path);
    return
end;

if resource_path(1) ~= '/' %if resource_path does not start with a slash we assume that the resource dir is relative to the tdfile dir
    resource_path = [tdfile_path resource_path];
end;

if resource_path(end) ~= '/' %make sure resource_path ends in a slash so that it can be concatenated with stimulus file names later
    resource_path = [resource_path '/'];
end;

if DEBUG
    fprintf('resource_path = %s\n', resource_path);
end;

if length(hshift) ~= length(stFile)
    fprintf('Warning: the vector hshift is shorter than the number of trials you have.  Filling with zeros\n');
    hshift = [hshift zeros(1,length(stFile)-length(hshift))];
end;

if length(vshift) ~= length(stFile)
    fprintf('Warning: the vector vshift is shorter than the number of trials you have.  Filling with zeros\n');
    vshift = [vshift zeros(1,length(stFile)-length(vshift))];
end;

if length(type) ~= length(stFile)
    fprintf('Warning: Your type vector and your stFile vector do not match in length\n');
end;

if length(pre) ~= length(stFile)
    fprintf('Warning: Your pre vector and your stFile vector do not match in length\n');
end;

if length(maxTime) ~= length(stFile)
    fprintf('Warning: Your maxTime vector and your stFile vector do not match in length\n');
end;

if length(totTime) ~= length(stFile)
    fprintf('Warning: Your totTime vector and your stFile vector do not match in length\n');
end;

if length(stpEvt) ~= length(stFile)
    fprintf('Warning: Your stpEvt vector and your stFile vector do not match in length\n');
end;

if length(bg) ~= length(stFile)
    fprintf('Warning: Your bg vector and your stFile vector do not match in length\n');
end;

if length(st) ~= length(stFile)
    fprintf('Warning: Your st vector and your stFile vector do not match in length\n');
end;

if length(bgFile) ~= length(stFile)
    fprintf('Warning: Your bgFile vector and your stFile vector do not match in length\n');
end;


for c = 1:length(stFile)

    if isempty(type(c))
        fprintf('In the future, you should specify a type for trial %d.  Reverting to default (s)\n',c);
        type(c) = 's';
    end;

    if isempty(num(c))
        fprintf('Reverting to default (1) for num(%d)\n',c)
        num(c) = '1';
    end;

    if isempty(pre(c))
        fprintf('Reverting to default (0) for pre(%d)\n',c)
        pre(c) = 0;
    end;

    if isempty(bg(c))
        fprintf('Reverting to default (t) for bg(%d)\n',c)
        bg(c) = 't';
    end;

    if isempty(st(c))
        fprintf('Reverting to default (t) for st(%d)\n',c)
        st(c) = 't';
    end;

    if isempty(rep(c))
        fprintf('Reverting to default rep for rep(%d)\n',c)
        rep(c) = 1;
    end;
end;

if length(tag) ~= length(stFile)
    for i = length(tag) +1:length(stFile)
        tag{i} = '';
    end;
end;


if DEBUG
    fprintf('stFile{1} = %s\n',stFile{1});
    fprintf('hshift = %d\n',hshift);
    fprintf('vshift = %d\n',vshift);
end;

if ~exist('tdfile'),
    fprintf('File does not exist\n');
    return;
end;

%% Define Defaults and storage variables

for i=1:length(stFile)

    if DEBUG
        fprintf('stFile{i} pre = %s\n',stFile{i});
        fprintf('resource_path = %s\n',resource_path);
    end;

    %text does not need a relative directory structure, but for all other
    %resources, makes sure that directory is appended to the front of the
    %filename

    stFileName{i} = stFile{i}; %we will append path to all files names in next loop, but later we want to output stFile without path info when specifying output
    bgFileName{i} = bgFile{i}; %same as above

    if st(i) ~= 't' && ~isempty(stFile{i})
        stFile{i} = [resource_path stFile{i}];
    end;

    if bg(i) ~= 't' && ~isempty(bgFile{i})
        bgFile{i} = [resource_path bgFile{i}];
    end;

    if length(tag) ~= length(stFile)
        for i = length(tag) +1:length(stFile)
            tag(i) = '';
        end;
    end;

    if DEBUG
        fprintf('stFile{i} post = %s\n',stFile{i});
    end;
end;

% set up variables controlling trials and defaults
number_of_trials=length(stFile);
default_stimulus_duration=2; % time for stimulus, in seconds
interstimulus_interval= 0; % default time between trials, in seconds
trial_order = calculate_trial_order(type,num); %default stimulus order is consecutive
default_wrap = 600; %in pixels
%default_display = sprintf('DrawFormattedText_new(w,''+'',''center'', ''center'',black, default_wrap,0,0);');
default_display = sprintf('DrawFormattedText_new(w,''+'',''center'', ''center'',white, default_wrap,0,0);');
nrchannels = 1; %default number of channels for sound playback is 1 = mono (if you have stereo sound, use nrchannels = 2)

% set up variables to store data
rt =zeros(1,number_of_trials); %vector to hold reaction times
rt2 =zeros(1,number_of_trials);
resp = cell(1,number_of_trials); %vector to hold responses made
onset = zeros(1,number_of_trials); %vector to record the actual onset of each trial
duration = zeros(1,number_of_trials); %vector to record the duration of each trial
key_presses = struct('key',{{}},'time',[],'stimulus',{{}}); %matrix to hold key pressed, time of key press, and current stimulus (will increment up)


%% set up input devices

%Open port for button box & scanner port
if button_box
    baudRate_string = strcat('BaudRate=', int2str(baudRate));
    [scannerPort, openerror] = IOPort('OpenSerialPort', portName, baudRate_string);
end

%Specify commands to check for buttons depending on which device is used
if button_box
    check_for_button_press = 'BbCheck(scannerPort)';
    wait_for_button_press = 'BbWait(scannerPort)';
    get_button_name = 'BbName(keyCode)';
    is_stop_event = 'Bb_is_stop_event(keyCode,stpEvt{i})';
else
    check_for_button_press = 'KbCheck(inputDevice)';
    wait_for_button_press = 'KbWait(inputDevice)';
    get_button_name = 'KbName(keyCode)';
    is_stop_event = 'Kb_is_stop_event(keyCode,stpEvt{i})';
end

DEBUG=1;
numDevices=PsychHID('NumDevices');
devices=PsychHID('Devices');

devices.product;

%makes start device the control computer (see note below re: customizing to your computer)
for khome = 1:numDevices,
    if DEBUG
        fprintf('I got into the khome = 1:numDevices loop\n');
    end
    if (strcmp(devices(khome).transport,'USB') && strcmp(devices(khome).usageName,'Keyboard')), 
        homeDevice=khome;
        if DEBUG
            fprintf('Home Device is #%d (%s)\n',homeDevice,devices(homeDevice).product);
        end;
        break,
    elseif (strcmp(devices(khome).transport,'SPI') && strcmp(devices(khome).usageName,'Keyboard')), 
        homeDevice=khome;
        if DEBUG
            fprintf('Home Device is #%d (%s)\n',homeDevice,devices(homeDevice).product);
        end;
        break,
    elseif (strcmp(devices(khome).transport,'USB') && strcmp(devices(khome).usageName,'Keyboard')) && ~strcmp(devices(khome).product,'932'),
        homeDevice=khome;
        fprintf('Defaulting: Home Device is #%d (%s)\n',homeDevice,devices(homeDevice).product);
        break,
    end;
end;

%if button box was not requested at start of experiment use the keyboard
if ~button_box
    for n=1:numDevices,
        if (strcmp(devices(n).transport,'USB') && strcmp(devices(n).usageName,'Keyboard') && ~strcmp(devices(n).product,'932')),
            inputDevice=n;
            break,
        elseif (strcmp(devices(n).transport,'Bluetooth') && strcmp(devices(n).usageName,'Keyboard')),
            inputDevice=n;
            break,
        elseif strcmp(devices(n).transport,'ADB') && strcmp(devices(n).usageName,'Keyboard'),
            inputDevice=n;
        elseif strcmp(devices(n).transport,'SPI') && strcmp(devices(n).usageName,'Keyboard'),
            inputDevice=n;
        end;
    end;
    fprintf('Using Device #%d (%s)\n',inputDevice,devices(n).product);
end;


%% Create place to save the data collected to a file

d=clock; % read the clock information
% this spits out an array of numbers from year to second

output_filename=sprintf('%s/%s_%s_%s_%s_%02.0f-%02.0f.mat',DATA_PATH,subject_code,experiment_code,tdfile,date,d(4),d(5));

% create a data structure with info about the run
run_info.subject_code=subject_code;
run_info.output_filename=output_filename;
run_info.experiment_notes=experiment_notes;
run_info.stimulus_input_file=tdfile;
run_info.script_revision_date=script_revision_date;
run_info.script_name=mfilename; % saves the name of the script
run_info.onsets=onset;
run_info.durations=duration;
run_info.responses=resp;
run_info.rt=rt;
run_info.rt2=zeros(1,length(run_info.rt));
run_info.trial_order=trial_order;
run_info.tag=tag;
run_info.tag2=tag2;
run_info.tag3=tag3;
run_info.tag4=tag4;
run_info.tag5=tag5;
run_info.tag6=tag6;
run_info.tag7=tag7;
run_info.tag8=tag8;

% save the data to the desired file
save(output_filename,'run_info','key_presses');

%% Setup initial screen & display settings

HideCursor;
Screen('Preference','SkipSyncTests', 1) % Necessary for MacOS High Sierra & higher, which fail the automatic sync tests Psychtoolbos does to ensure timing is exact to the millisecond-level (we don't need to be that exact here)

% Set up the onscreen window, and fill with white (255)
Screen('Preference', 'Verbosity', 1);
screens=Screen('Screens');
screenNumber=max(screens);
[w, rect]=Screen('OpenWindow', screenNumber,0,[],32,2);
[wWidth, wHeight]=Screen('WindowSize', w);
%grayLevel=255;
grayLevel=0;
Screen('FillRect', w, grayLevel);  % NB: only need to do this once!
Screen('Flip', w);


% set up screen positions for stimuli
xcenter=wWidth/2;
ycenter=wHeight/2;

% setup basic colors
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.

% use Arial font
theFont='Geneva';
Screen('TextFont',w,theFont);

% use 20 point font in black
Screen('TextSize',w, 40);
%Screen('TextColor',w,black);
Screen('TextColor',w,white);

%% Pre-Load Sound, Picture and Video Resources, and calculate timings

stMovieList = zeros(1,length(st)); %initialize list of movie media files
stSoundList = cell(length(st),2); %initialize list of sound media files
imagetex = zeros(1,length(st)); %initialize imagetex for pics
pRect = cell(1,length(st));
stimulus_duration = zeros(1,length(st));

for i = 1:length(st),
    if DEBUG
        fprintf('Preloading: i = %d\n',i);
        fprintf('Preloading: file = %s\n',stFile{i});
    end;

    %Update user on how preloading is coming
    block_string = sprintf('Loading trial %d of %d',i,length(st));
    DrawFormattedText_new(w, block_string, 'center','center',[0 255 0], 600, 0, 0);
    Screen('Flip',w);


    %preload movies
    if st(i) == 'm'
        [movie movieduration fps imgw imgh] = Screen('OpenMovie', w, stFile{i});
        stMovieList(i) = movie;


        %preload sounds
    elseif st(i) == 's'
        [x,fs] = wavread(stFile{i}); %read in wav file info
        stSoundList{i,1} = x;
        stSoundList{i,2} = fs;

        if DEBUG
            fprintf('Trying to read sound from line %d\n',i)
        end;

        %preload pics
    elseif st(i) == 'p'
        if exist(stFile{i},'file') ~= 2 %if file doesn't exist, skip trial
            fprintf('Warning: your file %s does not exist on trial %d.\n',stFile{i},i);
            continue;
        end;
        a = strcmp(stFile,stFile{i});
        b = strcmp(st,st(i));
        h = zeros(length(st),1);
        h(find(hshift==hshift(i))) = 1;
        v = zeros(length(st),1);
        v(find(vshift==vshift(i))) = 1;
        c = a.*b.*h.*v;
        f = find(c,1);
        if f < i
            imagetex(i)=imagetex(f);
        else
            img = imread(stFile{i});
            itex = Screen('MakeTexture', w, img);
            imagetex(i) = itex;
            %offsets image by amount specified in hshift and vshift
            pr = CenterRect(Screen('Rect', imagetex(i)),Screen('Rect',w));
            pr=OffsetRect(pr, hshift(i), vshift(i));
            pRect{i}=pr;
            clear img;
        end
    end;

    if bg(i) == 'p'
        if exist(bgFile{i},'file') ~= 2 %if file doesn't exist, skip trial
            fprintf('Warning: your file %s does not exist on trial %d.\n',bgFile{i},i);
            continue;
        end;

        a = strcmp(stFile,stFile{i});
        b = strcmp(st,st(i));
        h = zeros(length(st),1);
        h(find(hshift==hshift(i))) = 1;
        v = zeros(length(st),1);
        v(find(vshift==vshift(i))) = 1;
        c = a.*b.*h.*v;
        f = find(c,1);
        if f < i
            bg_imagetex(i)=bg_imagetex(f);
        else
            img = imread(bgFile{i});
            itex = Screen('MakeTexture', w, img);
            bg_imagetex(i) = itex;
            %offsets image by amount specified in hshift and vshift
            pr = CenterRect(Screen('Rect', bg_imagetex(i)),Screen('Rect',w));
            pr=OffsetRect(pr, hshift(i), vshift(i));
            bRect{i}=pr;
            clear img;
        end
    end;

    %set stimulus duration
    if ~isempty(maxTime(i)) && st(i) ~= 's'
        stimulus_duration(i) = maxTime(i);
        if maxTime(i) == 0 %this happens if left blank in worksheet (textread function reads blanks as zeros)
            stimulus_duration(i) = default_stimulus_duration;
            fprintf('WARNING: reverted to default stimulus duration for cycle %d, st = %s, maxTime(i) = %f\n',i,stFile{i},maxTime(i))
        end;
    elseif st(i) == 's'
        %Pre calculate sound lengths
        %Note: stSoundList{i,1} = x = actual audio, stSoundList{i,2} = fs =frames/sec
        if maxTime(i) == 0 || isempty(maxTime(i)); %if no time is specified
            stimulus_duration(i) = (size(stSoundList{i,1},1)/stSoundList{i,2});
        elseif maxTime(i) < 0
            stimulus_duration(i) = (size(stSoundList{i,1},1)/stSoundList{i,2}) - maxTime(i);
        elseif size(stSoundList{i,1},1)/stSoundList{i,2} >= maxTime(i) %if length of sound file is greater than the time specified, play only for time specified
            stSoundList{i,1}=stSoundList{i,1}(1:round(stSoundList{i,2}*maxTime(i)));
            stimulus_duration(i) = maxTime(i);
        elseif size(stSoundList{i,1},1)/stSoundList{i,2} < maxTime(i) %if length of sound file is less than total time specified, make stimulus duration (which starts after sound is played) the difference between file length and desired time
            stimulus_duration(i) = maxTime(i);
            if DEBUG
                fprintf('Made it into this loop. Sound stimulus duration = %f\n',stimulus_duration(i));
            end;
        end;
    else
        stimulus_duration(i) = default_stimulus_duration;
        if DEBUG
            fprintf('Reverting to default stimulus duration on cycle %d\n',i);
        end;
    end;

    if isempty(stFile{i}) && st(i) == 't'
        fprintf('Warning: stFile{%d} = []\n',i);
        stFile{i} = '+'; %default to fixation cross
    end;

end;

if ~isempty(find(st == 's',1))
    % Perform basic initialization of the sound driver:
    InitializePsychSound;
    PsychPortAudio('Verbosity',1);
end;

%% Start experiment and Cycle through trials

%start experiment with key press

%Draw instructions
if button_box
    DrawFormattedText_new(w,'The scan is about to begin.  For feelings trials, you will be deciding how the target character would feel, given how their friends and enemies feel. For alphabetizing questions, you will alphabetize the character names with the anchoring method. Please answer as quickly and accurately as you can. Please also stay still during your scan. Thanks!','center','center',white, default_wrap, 0, 0);
else
    DrawFormattedText_new(w,'The experiment is about to begin.  For feelings trials, you will be deciding how the target character would feel, given how their friends and enemies feel. For alphabetizing questions, you will alphabetize the character names with the anchoring method. Please answer as quickly and accurately as you can. Thanks!','center','center',white, default_wrap, 0, 0);
end
Screen('Flip',w);

%KbWait(homeDevice);  % wait for keypress

%---------Wait for trigger, then start task------------%
%set trigger and manual start/continue to 0
%cpressed=0;
%trigger_key='5%';

if button_box
    experiment_start_time=triggerWait(scannerPort); %first check for trigger...
else
    RestrictKeysForKbCheck(KbName('5%'));
    KbWait(inputDevice);
    RestrictKeysForKbCheck([]);
end;
%% Set up stims

%if manual==1,
%experiment_start_time = GetSecs;
%end;

if ~button_box,
    experiment_start_time = GetSecs;
end;

for j = 1:number_of_trials,
    i = trial_order(j); %run the stimuli in the order specified by the trial_order array

    if tag(i) == 1,

        pre_start_time = GetSecs; %anchor as start of trial

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %SETUP BACKGROUND STIMULUS IF ONE IS GIVEN
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if ~isempty(bgFile{i}) %if a background file has been specified
            if bg(i) == 't'&& st(i) ~= 'n' %background is text, stimulus is not scale
                %bg_display = sprintf('DrawFormattedText_new(w,bgFile{i},''center'', ''center'',black, default_wrap,hshift(i),vshift(i));');
                bg_display = sprintf('DrawFormattedText_new(w,bgFile{i},''center'', ''center'',white, default_wrap,hshift(i),vshift(i));');
            elseif bg(i) == 'p' %background is a picture
                %sets image up for the screen
                bg_display = sprintf('Screen(''DrawTexture'',w,bg_imagetex(i),[],bRect{i});');
                %elseif bg(i) == 'n'
                %   bg_display = sprintf('scale_MSS(bgFile(i),w);');
                %end;
            else %if no background is specified, default background is fixation cross
                bg_display = default_display;
                if DEBUG
                    fprintf('reverting to default background on cycle %d\n',i);
                end;
            end;


            %Display background stimulus for time specified in pre
            if pre(i) > 0
                eval(bg_display);
                Screen('Flip',w);
                while GetSecs < pre_start_time+pre(i)
                    [keyIsDown,secs,keyCode]=eval(check_for_button_press);
                    if keyIsDown, %key is pressed
                        key_presses.key{length(key_presses.key)+1} = eval(get_button_name);
                        key_presses.time(length(key_presses.time)+1) = GetSecs - experiment_start_time;
                        if isempty(bgFileName{i})
                            key_presses.stimulus{length(key_presses.stimulus)+1} = ['pre stimulus displayed,  bg was ' bgFileName{i}];
                        else
                            key_presses.stimulus{length(key_presses.stimulus)+1} = [bgFileName{i} 'displayed, during pre stimulus interval '];
                        end
                    end;
                    while keyIsDown && GetSecs < pre_start_time+pre(i)
                        [keyIsDown,secs,keyCode]=eval(check_for_button_press);
                        WaitSecs(0.001);
                    end
                end;
            end;

            %%%%%%%%%%%%%%%%%%%%%%%
            %SETUP PRIMARY STIMULUS
            %%%%%%%%%%%%%%%%%%%%%%%

            if st(i) == 'm' %primary stimulus is a movie
                start_time = GetSecs;
                onset(i) = start_time - experiment_start_time;
                [resp{i} keys movie_start] = DisplayMovie(stMovieList(i),w,stpEvt{i},maxTime(i),inputDevice); %this function plays a movie and sound simultaneously

                if ~isempty(keys)
                    key_presses.key = [key_presses.key keys.key]; %append keys pressed during movie to key_presses
                    key_presses.time = [key_presses.time keys.time + movie_start - experiment_start_time];
                    key_presses.stimulus = [key_presses.stimulus arrayfun( @(x) stFileName{i},zeros(1,length(keys.key)),'UniformOutput',false)];
                end;

                %update key info to save
                run_info.onsets=onset;
                run_info.durations=duration;
                run_info.responses=resp;
                run_info.rt=rt;

                % save the data to the desired file
                save(output_filename,'run_info','key_presses');

            else
                if st(i) == 't' %primary stimulus is text
                    if stFile{i} ~= '+'
                        current_target = stFile{i};
                    end;

                    if DEBUG
                        fprintf('stFile(%d) = %s\n',i,stFile{i});
                        fprintf('size(stFile(%d)=%d\n',i,size(stFile{i},2));
                    end;

                    % setup text to be displayed (as written, will center text and
                    % wrap at default_wrap pixels)
                    %displaycommand = sprintf('DrawFormattedText_new(w,stFile{i},''center'', ''center'',black, default_wrap,hshift(i),vshift(i));');
                    displaycommand = sprintf('DrawFormattedText_new(w,stFile{i},''center'', ''center'',white, default_wrap,hshift(i),vshift(i));');

                    %elseif st(i) == 'n' %primary stimulus is scale

                    if DEBUG
                        fprintf('stFile(%d) = %s\n',i,stFile{i});
                    end;

                    %displaycommand = sprintf('[rt(i) resp{i}] = scale_MSS(bgFile(i),w);');

                elseif st(i) == 's' %primary stimulus is sound
                    eval(bg_display); %present the background file while sound is playing
                    Screen('Flip',w);

                    t1 = GetSecs;

                    % Open the default audio device [], with default mode [] (==Only playback),
                    % and a required latencyclass of zero 0 == no low-latency mode, as well as
                    % a frequency of stSoundList{i,2} = fs, and nrchannels sound channels.
                    % This returns a handle to the audio device:
                    pahandle = PsychPortAudio('Open', [], [], 1, stSoundList{i,2},nrchannels);

                    % Fill the audio playback buffer with the audio data 'stSoundList{i,1} = x from above':
                    PsychPortAudio('FillBuffer', pahandle, stSoundList{i,1}');
                    t2 = GetSecs;

                    if DEBUG
                        fprintf( 'It took %f seconds to open PsychPortAudio and fill the buffer in iteration %d\n',t2-t1,i);
                    end

                    % Start audio playback for 'repetitions' repetitions of the sound data,
                    % start it immediately (0) and wait for the playback to start, return onset
                    % timestamp.
                    t1 = PsychPortAudio('Start', pahandle, rep(i), 0, 1);
                    onset(i) = t1 - experiment_start_time; %sound onset
                    sound_closed = 0;

                    displaycommand = bg_display; %For sound, foreground and background images are same

                elseif st(i) == 'p' %primary stimulus is a picture
                    displaycommand = sprintf('Screen(''DrawTexture'',w,imagetex(i),[],pRect{i});');
                end; % if st(i)

                if DEBUG
                    fprintf('\ni= %d,\nst(i) = %c\n',i, st(i));
                    fprintf('displaycommand = %s\n\n',displaycommand);
                end;


                %%%%%%%%%%%%%%%%%%%%%%%
                %Put stimuli on screen
                %%%%%%%%%%%%%%%%%%%%%%%

                t1 = GetSecs;


                if ((st(i) == 'n') | (st(i) == 'y') | (st(i) == 'z'))
                    scale_text=bgFile(i);%Uses bgFile as scale text
                    text_size = 20; %sets text size
                   % if st(i) == 'n'
                    %    target = current_target; %current politician is target
                    %elseif st(i) == 'y'
                     %   target = 'Case';
                    %end
                    middle = 0;

                    % Set keys.
                    leftKey = '1!';
                    rightKey = '2@';
                    escapeKey = '3#';

                    Screen('TextSize', w, text_size); %formats text size

                    for ii=1:length(scale_text(:,1)),

                        %Gets input for Screen presentation
                        tstring=scale_text{ii,1};

                        spotRadius = 20; % The radius of the spot.
                        key_resp(ii)=0; %sets key_resp to 0 if no response is made

                        % Use the parameters.
                        spotDiameter = spotRadius * 2;
                        spotRect = [0 0 spotDiameter spotDiameter];
                        centeredspotRect = CenterRect(spotRect, rect); % Center the spot.
                        xOffset = 0;
                        yOffset = 5;
                       
                        if st(i) == 'n'| (st(i) == 'z')
                            xincrement = 65;
                            xbound = 350;
                            maxval = 10;
                            minval = 0;
                        elseif st(i) == 'y'
                            xincrement = 130;
                            xbound = 130;
                            maxval = 1;
                            minval = -1;
                        end

                        % Sets up percentage scale
                        if st(i) == 'n'
                            scale='0-------1-------2-------3-------4-------5-------6-------7-------8-------9-------10';
                   sctext= 'not at all                                                                           extremely';          
                         scquestion='WARM';
                         
                        elseif st(i) == 'z'
                            scale='0-------1-------2-------3-------4-------5-------6-------7-------8-------9-------10';
                   sctext= 'not at all                                                                           extremely';          
                         scquestion='COMPETENT';
                            
                        elseif st(i) == 'y'
                            scale='1         +         2';
                        end



                        % Removes the blue screen flash and minimize extraneous warnings.
                        Screen('Preference', 'VisualDebugLevel', 3);
                        Screen('Preference', 'SuppressAllWarnings', 1);

                        resptime(ii)=0;
                        respfinal(ii)=0;
                        key_resp(ii)=0;
                        rt2(i)=0;
                        start_time = GetSecs;
                        first = 1;

                        %Waits for participant to make a decision regarding the attitude
                        %statement
                        while (GetSecs-start_time)<maxTime(i)
                            Screen('TextSize', w, text_size); %formats text size
                            %Draws formatted text from input file to the screen
%                           [nx, ny, textbounds]=DrawFormattedText(w, tstring, 'center', 325, black, 60);
                            %[nx, ny, textbounds]=DrawFormattedText(w, scale, 'center','center', black, 60);
                            %[nx, ny, textbounds]=DrawFormattedText(w, scale, 'center','center', black, 60);
                            [nx, ny, textbounds]=DrawFormattedText(w, scale, 'center','center', white, 60);
                             %all coordinates from top left so 800 is all
                             %the way right, so 400 is half
                             
                            [nx, ny, textbounds]=DrawFormattedText(w, sctext, 'center',350, white, 95);
                            Screen('TextSize', w, text_size);
                            %[nx, ny, textbounds]=DrawFormattedText(w, sctextb, 'center',425, black, 190);
                            %[nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, black, 60);
                            %[nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, black, 60);
                            
                            if st(i) == 'n'
                            [nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, [243 5 219], 60);
                          
                             elseif st(i) == 'z'
                            [nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, [37 243 5], 60);
                            end
                            offsetCenteredspotRect = OffsetRect(centeredspotRect, xOffset, yOffset);
                            %Screen('FrameOval', w, [0 0 127], offsetCenteredspotRect);
                            Screen('FrameOval', w, white, offsetCenteredspotRect);
                            [vbltime]=Screen('Flip', w);
                            t2 = GetSecs;

                            if DEBUG && first == 1
                                fprintf('We needed %f seconds to Draw texture %d.\n',t2-t1,i)
                            end;

                            first = 0;

                            resp_yet = 0;
                            [keyIsDown, t, keyCode]=eval(check_for_button_press);
                            key = eval(get_button_name);
                            resptime(ii)= t - start_time;
                            if strcmp(key,escapeKey) | strcmp(key,leftKey) | strcmp(key,rightKey)
                                if (st(i) == 'n'| st(i) =='z')
                                    key_resp(ii)=5;
                                elseif st(i) == 'y'
                                    key_resp(ii)=0;
                                end
                                if strcmp(key,leftKey)
                                    xOffset = xOffset + (-xincrement);
                                    key_resp(ii)=key_resp(ii) + (-1);
                                    resp_yet = 1;
                                elseif strcmp(key,rightKey)
                                    xOffset = xOffset + (xincrement);
                                    key_resp(ii)=key_resp(ii) + 1;
                                    resp_yet = 1;
                                elseif strcmp(key,escapeKey)
                                    middle = 1;
                                    key_resp(ii)=5;
                                    respfinal(ii)=GetSecs - start_time;
                                    resp_yet = 1;
                                end;
                                break;
                            end;
                        end;

                        WaitSecs(0.1);

                        % Loop until participant confirms response, unless
                        % previous button-press was the escape key
                        % (indicating that the middle value on the scale is
                        % the intended response)

                        while middle == 0 & (GetSecs-start_time)<maxTime(i) & resp_yet == 1,
                            Screen('TextSize', w, text_size); %formats text size
                            %Draws percentage scale to screen
%                             [nx, ny, textbounds]=DrawFormattedText(w, tstring, 'center', 325, black, 60);
                            %[nx, ny, textbounds]=DrawFormattedText(w, scale, 'center','center', black, 60);
                           %[nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, black, 60);
                           
                           [nx, ny, textbounds]=DrawFormattedText(w, scale, 'center','center', white, 60);
                           %[nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, [243 5 219], 60);
                            
                           if st(i) == 'n'
                            [nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, [243 5 219], 60);
                          
                             elseif st(i) == 'z'
                            [nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, [37 243 5], 60);
                            end
                           
                           Screen('TextSize', w, 20); %formats text size
                            %[nx, ny, textbounds]=DrawFormattedText(w, sctext, 'center',350, black, 95);
                            [nx, ny, textbounds]=DrawFormattedText(w, sctext, 'center',350, white, 95);
                            %[nx, ny, textbounds]=DrawFormattedText(w, sctextb, 'center',525, black, 225);
                            Screen('TextSize', w, text_size); %I lacking this line (and at 963) is what was screwing up the font

                            offsetCenteredspotRect = OffsetRect(centeredspotRect, xOffset, yOffset);
                            Screen('FrameOval', w, white, offsetCenteredspotRect);
                            Screen('Flip', w);
                            WaitSecs(0.1);

                            if xOffset > xbound
                                xOffset = xbound;
                                key_resp(ii) = maxval;
                            elseif xOffset < -(xbound)
                                xOffset = -(xbound);
                                key_resp(ii) = minval;
                            end;

                            [ keyIsDown, seconds, keyCode ] = eval(check_for_button_press);
                            key = eval(get_button_name);

                            if keyIsDown
                                if strcmp(key,leftKey)
                                    xOffset = xOffset + (-xincrement);
                                    key_resp(ii)=key_resp(ii) + (-1);
                                elseif strcmp(key,rightKey)
                                    xOffset = xOffset + (xincrement);
                                    key_resp(ii)=key_resp(ii) + 1;
                                elseif strcmp(key,escapeKey)
                                    resp_yet = 2;
                                    respfinal(ii)=GetSecs - start_time;
                                    break;
                                end;
                                if xOffset > xbound
                                    xOffset = xbound;
                                    key_resp(ii) = maxval;
                                elseif xOffset < -(xbound)
                                    xOffset = -(xbound);
                                    key_resp(ii) = minval;
                                end;
                            end;
                        end;

                    %for remaining trial duration, put up scale (without
                    %cursor) and target
                    while (GetSecs - start_time) < maxTime(i)
                        Screen('TextSize', w, text_size); %formats text size
%                         [nx, ny, textbounds]=DrawFormattedText(w, scale, 'center','center', black, 60);
%                         [nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, black, 60);
%                         Screen('TextSize', w, 20); %formats text size
%                         [nx, ny, textbounds]=DrawFormattedText(w, sctext, 'center',350, black, 95);
                        
                        [nx, ny, textbounds]=DrawFormattedText(w, scale, 'center','center', white, 60);
                        %[nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, [243 5 219], 60);
                         if st(i) == 'n'
                            [nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, [243 5 219], 60);
                          
                             elseif st(i) == 'z'
                            [nx, ny, textbounds]=DrawFormattedText(w, scquestion, 'center',  225, [37 243 5], 60);
                            end
                        Screen('TextSize', w, 20); %formats text size
                        [nx, ny, textbounds]=DrawFormattedText(w, sctext, 'center',350, white, 95);
                       % [nx, ny, textbounds]=DrawFormattedText(w, sctextb, 'center',525, black, 200);
                        Screen('TextSize', w, text_size); %this one was needed too
                        Screen('Flip', w);
                    end;

                    if (resp_yet == 2) | (middle == 1)
                        rt(i)=resptime(ii);
                        resp{i}=key_resp(ii);
                        rt2(i)=respfinal(ii);
                    else
                        rt(i)=0;
                        resp{i}=0;
                        rt2(i)=0;
                    end;
                  end;

                elseif ((st(i) ~= 'n') & (st(i)~= 'z') & (st(i) ~= 'y'))
                    eval(displaycommand);
                    [vbltime,start_time]=Screen('Flip',w);
                    t2 = GetSecs;

                    if DEBUG
                        fprintf('We needed %f seconds to Draw texture %d.\n',t2-t1,i)
                    end;
                end;

                if st(i) ~= 's' %can't be a movie here
                    onset(i) = start_time - experiment_start_time; %get onset of the stimulus for text and picture stims (movies and sound recorded above)
                end;

                %update key info to save
                run_info.onsets=onset;
                run_info.durations=duration;
                run_info.responses=resp;
                run_info.rt=rt;
                run_info.rt2=rt2;

                % save the data to the desired file
                save(output_filename,'run_info','key_presses');

                %wait for a response, or for the trial to end (whichever comes first)
                no_response_yet=1;

                %p = pause trial
                while (type(i) == 'p' & no_response_yet == 1) | (type(i) ~= 'p' & no_response_yet == 1 & GetSecs < start_time + stimulus_duration(i)),
                    [keyIsDown,secs,keyCode]=eval(check_for_button_press);
                    if keyIsDown, %key is pressed
                        key_presses.key{length(key_presses.key)+1} = eval(get_button_name);
                        key_presses.time(length(key_presses.time)+1) = GetSecs - experiment_start_time;
                        key_presses.stimulus{length(key_presses.stimulus)+1} = stFileName{i};

                        if eval(is_stop_event) %checks if key is one specified as a stop event
                             no_response_yet=0;
                             rt(i)=secs-start_time; %record response
                             [output, stopKey] = eval(is_stop_event);
                             resp{i}=stopKey; %record key pressed

                            if st(i) == 's'
                                % Stop playback:
                                PsychPortAudio('Stop', pahandle);
                                % Close the audio device:
                                PsychPortAudio('Close', pahandle);
                                sound_closed = 1;
                            end;
                            break;
                        else
                            %Note: be aware that if you keep this part of the code,
                            %and specify certain stop events, if someone presses a
                            %key that is not a stop event and holds it down, no
                            %other keys will be recorded (including stop events)
                            %until the first key is released.

%                             while keyIsDown %wait until key is released to start outer loop again
%                                 [keyIsDown,secs,keyCode]=eval(check_for_button_press);
%                                 WaitSecs(0.001);
%                             end
                        end;
                    end;
                end;
            end;

            if st(i) == 's' & ~sound_closed;

                % Stop playback:
                PsychPortAudio('Stop', pahandle);

                % Close the audio device:
                PsychPortAudio('Close', pahandle);

            end;

            duration(i) = GetSecs - onset(i) - experiment_start_time; %record actual stimulus duration time

            %For any remaining time, put up background
            if GetSecs < pre_start_time+totTime(i) & type(i) ~= 'p'
                eval(bg_display);
                Screen('Flip',w);
                while GetSecs < pre_start_time+totTime(i) & type(i) ~= 'p'

                    [keyIsDown,secs,keyCode]=eval(check_for_button_press);
                    if keyIsDown, %key is pressed
                        key_presses.key{length(key_presses.key)+1} = eval(get_button_name);
                        key_presses.time(length(key_presses.time) +1) = GetSecs - experiment_start_time;
                        if isempty(bgFileName{i})
                            key_presses.stimulus{length(key_presses.stimulus)+1} = ['default bg, st was ' stFileName{i}];
                        else
                            key_presses.stimulus{length(key_presses.stimulus) +1} = [bgFileName{i} ', st was ' stFileName{i}];
                        end
                    end;

                    while keyIsDown & GetSecs < pre_start_time+totTime(i)
                        [keyIsDown,secs,keyCode]=eval(check_for_button_press);
                        WaitSecs(0.001);
                    end
                end;

            end;

            % Wait for interstimulus interval
            if interstimulus_interval ~= 0
                eval(default_display); %puts up default display for isi
                Screen('Flip',w);
                start_time = GetSecs;
                while GetSecs < start_time + interstimulus_interval,
                    [keyIsDown,secs,keyCode]=eval(check_for_button_press);
                    if keyIsDown, %key is pressed
                        key_presses.key{length(key_presses.key)+1} = eval(get_button_name);
                        key_presses.time(length(key_presses.time)+1) = GetSecs - experiment_start_time;
                        key_presses.stimulus{length(key_presses.stimulus)+1} = 'ISI';
                    end

                    while keyIsDown & GetSecs < start_time + interstimulus_interval
                        [keyIsDown,secs,keyCode]=eval(check_for_button_press);
                        WaitSecs(0.001);
                    end
                    %WaitSecs(0.001);  % prevents overload and decrement of priority
                end;
            end;
            if DEBUG
                fprintf('It took %f seconds between pre_start_time and onset.\n',onset(i)-pre_start_time +experiment_start_time)
            end;
        end;%for j
    end;
end;


Screen('Close');
fprintf('The experiment lasted %f seconds\n',GetSecs-experiment_start_time)

%% Post Processing of Data

%clean up numeric responses (e.g. 3# --> 3)
run_info.responses = clean_output(run_info.responses);
key_presses.key = clean_output(key_presses.key);

% save the final, cleaned data to the desired file
save(output_filename,'run_info','key_presses');

% after everything is done, clear the screen
Screen('CloseAll'); % Close all screens, return to windows.
ShowCursor;

%print a report
experiment_output(output_filename,PRINT_OUTPUT); %Results will always print to screen, PRINT_OUTPUT determines whether gets saved to txt file as well

%Close scanner port
if button_box
    IOPort('Close', scannerPort);
end


