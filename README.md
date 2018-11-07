# matlab-stimulus-presentation

MSS is a program that reads in tab delimited .txt files (that you can make in excel and save as .txt format), and presents stimuli accordingly. This program was inspired by MacStim, and as such reflects a similar set of inputs. Improvements over MacStim include the ability to play .wav sound files, to automatically play for the duration of a sound or video file without timing it in advance, to specify an interstimulus interval that will display a default background between trials, and the fact that the output is automatically in MatLab format (and hence can be easily loaded for analysis purposes). This program will also resource files (sounds, videos, pictures) to be stored in the folder containing the tab delimited .txt file. You should add the folder where MSS is stored to your MatLab path (by clicking File --> Set Path in MatLab), and then you should call MSS from the folder that contains your .txt file, or specify the full path for the folder where your .txt file is stored.

## Getting Started

1. Make sure you have all the prerequisits below installed on your computer.
2. Set up a project folder on your local computer containing all the scripts in either the Mac or Windows folder, depending on your OS. The project folder and MSS_task script should both include the name of your task; e.g., 'if your task is social working memory,' your project folder would be called 'MSS_swm', and the MSS script would be called 'MSS_swm.m'
3. Add any task-specific stimuli, e.g. images or movies, to your folder.
4. Change the name of task_run1.txt to reflect your task, e.g. 'swm_run1.txt'. This file specifies the task stimuli, and how they should be presented. You should create a separate text file for each run. See Setting Up Input Files below for details on what this file's parameters mean.

### Prerequisites

*What you'll need on your local computer:*
* MATLAB
* [Psychtoolbox](http://psychtoolbox.org/download)
* [gstreamer](https://raw.githubusercontent.com/Psychtoolbox-3/Psychtoolbox-3/master/Psychtoolbox/PsychDocumentation/GStreamer.m) - only if you want to present videos as stimuli

### Setting Up Input Files

*Rows:* Each row corresponds with one trial of the experiment, e.g. stimulus, fixation cross, or response screen.

*Columns:*
1. “type” is the trial type as above, “s” means a single trial, ‘p’ means pause trial (script won’t continue until it gets input), r is randomized trial.
2. “num” indicates the number of random trials that should be kept in consecutive order (so, if 6 consecutive trials are all type = r, and num = 3 for the first, 2 for the 4th and 1 for the 5th, the first three trials would all be kept together in a block, the next two would be kept in order in a block and the last would be a third, and these three chunks would be randomly ordered.
3. “pre” is the initial delay in seconds before the stimulus is presented. If you want a background resource to be shown/sounded during this time (eg a background picture) then make this time greater than zero.
4. “max” is the amount of time that the main stimulus can be presented.  If a stop event occurs, then the actual time that the stimulus is displayed will be less than max, and the remaining time will be taken by showing the background resource. Note: if the stimulus file type is a sound or movie (st = s or m), and no duration is specified here, the program will automatically play the file for its duration.  If a shorter time than the sound or movie is specified, the sound/movie will be truncated.  If a longer time is specified, the background resource will be displayed for remaining time.
5. “tot” is the total seconds for this trial.  If tot is greater than pre+max, then the background will be displayed to make up the difference.  
6. “rep” %not implemented in the same way as MacStim.  For sound files, this should be 1 if you want the file to play once and stop.  Will not impact other types of trials.
7. “stpEvt” is the event required to trigger recording of the reaction time (n nothing ie ignore all event types).  If you want some keys only to stop an event, ie. exclusive keys to stop this event (all other keys are ignored) then you can put those keys you wish to use, eg “rl” to use the R and L keys only to stop key events.
8. “bg” is the background resource type (see (9))
9. “st” is the stimulus resource type from p picture, s sound, m movie, n none (ie present a fixation cross or no sound), and you can also present text (without needing to create PICT files specifically) by using t for text here.  Default is to display text in the center of the screen and to wrap text at wrap_text pixels across.  
10. “bg-file” and 
11. “st-file” are the file names of the background and stimulus files respectively.  These files must either be in the same folder with the main script file, or a resource path must be specified.
12. “hShift” and
13. “vShift” allow you to offset pictures, movies or text from the default central position (specified in pixels).
14. Additional columns with tags like "correct answer" can be added as needed

## Running the MSS Script

Open MATLAB and navigate to the study folder by typing the following command:

```
cd ~/'Dropbox (DSNL)'/'DSNL Team Folder'/task_folder/
```

The MSS_swm.m script reads in information about the stimuli for a given run by referring to that run’s text file. So, to start the first run, type the following command in the Matlab workspace and press enter:

```
MSS_task(task_run1.txt’)
```

You’ll next be prompted to enter the subject’s code. Enter their code and press enter.

Next, you’ll be asked if you’d like to use the button box. If you are running this at the scanner, press 1 (for yes). This will allow the scanner to trigger the beginning of the task. If you are not running the script at the scanner, press 0 (for no). Press enter and this will launch the task.

After the instruction screen loads, it is waiting for the number 5 to start the task. If you’re at the scanner, the scanner should send the number 5 to the script once you start the scan. If you are running this not connected to the scanner, you can press 5 on the keyboard to start the task.


### Data Recording
Data gets saved as a .mat file to an output folder specified in the MSS script. This file contains data fields for 1) key_presses and 2) run_info.

*Included in key_presses:*
* key - every key press recorded
* time - time of each key press
* stimulus - stimulus on screen at time of key press

*Included in run_info:*
* subject_code
* output_filename
* experiment_notes
* stimulus_input_file
* script_revision_date
* script_name
* onsets - onset time of each trial
* durations - duration of each trial
* responses - response recorded during each trial
* rt - reaction time
* trial_order - order number of each trial

*Note:* If you are using the scanner, you will need to set the button box to ASCII mode and the baudrate specified in the MSS script. Otherwise, data will not record.


### Function Notes
*Files Supplied to run MSS:*
* MSS_task.m - This is the main stimulus presentation script.  All other files and functions are called from here.
* calculate_trial_order.m - This function is used to determine the order of stimuli presented. 
* DrawFormattedText_new.m - This is similar to the built in function DrawFormattedText.m, except that it allows for text wrapping based on pixels instead of words and accommodates hshift and vshift to offset text.  See help file for more info.
* DisplayMovie.m - Displays video stimuli. Note: keyCaught is the key that caused the stop event, key_presses_movie contains all of the keys that were pressed while the movie was being played.
* experiment_output.m - Takes output of MSS and prints a short report to the screen and to a tab
%delimited file.
* Kb_is_stop_event.m - This function takes any key press that is sensed while text or picture stimuli are presented and decides whether that key constitutes a stop event (which would cause a switch to the background stimulus for the remainder of the trial). 
* Bb_is_stop_event.m - Same as Kb_is_stop_event, but for button box rather than keyboard inputs. The main script automatically calls this function instead (as well as the other Bb functions) if user specifies the button box is being used.
* Bb_check - This function behaves much like the built in function Kb_check, but for button box inputs.
* Bb_wait - This function behaves much like the built in function Kb_wait, but for button box inputs.
* Bb_name - This function behaves much like the built in function Kb_name, but for button box inputs. It translates ASCII codes to button numbers.
* wsstrtok.m - This function behaves much like the built in function strtok except that it preserves leading and trailing whitespace. This is necessary for the word wrapping function in the modified DrawFormattedText_new.m

*Other notes:* 
* Default Durations: If no duration is specified, sound and video files will be played for the duration necessary to hear/see in entirety and text/ picture files will be displayed for the default duration, which can be set at the top of MSS.m. In the case of a sound file, if a shorter duration is specified, the sound is truncated.  Videos always play for the full duration, unless a stop event is detected. 
* Stop Events: If a stop event occurs during the presentation of the main  stimulus file, the main stimulus will be removed from the screen and the background stimulus will be displayed for the remaining time in the trial (unless the trial is a video trial, in which case we move on to the next trial).


## Built With

* [MATLAB](https://www.mathworks.com/help/matlab/)
* [Psychtoolbox](http://psychtoolbox.org/) - MATLAB library for vision and neuroscience research

## Authors

* **Eleanor Collier** - *Initial work*

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/Dartmouth-Social-Neuroscience-Lab/matlab-stimulus-presentation/blob/master/LICENSE) file for details

## Acknowledgments

* Original code for MSS_script by Emily Falk
