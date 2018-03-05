%% beta_rhythm_behav
% Create a script to "beta-test" rhythm_mvpa amongst SLAMERS. 
% Authors -- Matt H and Matt M
%
% CHANGELOG (MM/DD/YY)
% 10/17/17  -- Initialized file. -- MH
% 10/18/17  -- Settled on a GUI. Needs to become interactive now. -- MH
% 10/19/17  -- Fully interactive. Need subject response. -- MH
% 10/20/17  -- Subject response and saving data now added. -- MH
% 02/05/18  -- Started to update for new design, passed work onto Matt
%   Moritz. Added documentation to try and help. -- MH
%
% Experiment design --
% Subject begins after reading short instructions. Four seconds of silence
% follow, before the subject hears the first rhythm sequence. More silence
% follows, then the second rhythm plays. The likert prompt opens, with cues
% for 1 - 5. After the subject responds, a burst of white noise plays and
% the next trial begins after a short gap of silence. After hitting 1/4, 
% 1/2, and 3/4 complete, a short break begins for the subject. -- MH

function beta_rhythm_behav_v3 
% TIP - when debugging this script, you can comment out the line which
% defines this as a function (as well as the 'end' that it is paired to)
% and it will stop clearing the workspace when there is an error. -- MH
%% Initialization
% These are a few commands that should preceed every code. Type 'help ###'
% with an accompanying command for more information. It isn't super
% important to know how these work. -- MH
sca; DisableKeysForKbCheck([]); KbQueueStop; 
Screen('Preference','VisualDebugLevel', 0); 

PsychPortAudio('Close'); 
InitializePsychSound

clearvars; clc; 

AudioDevice = PsychPortAudio('GetDevices', 3); 

%% Parameters
% I use the term 'parameters' to refer to anything that changes with each
% subject you run. -- MH
name = inputdlg({'Save as?'});
name = name{1};

%% Pathing
% Here is where I define all the filepaths used in the code. Note how I use
% the command 'fullfile()'. I highly recommend reading up on this code, as
% it is very useful. -- MH
dir_scripts = pwd;
cd ..
dir_study = pwd;
dir_stim = fullfile(dir_study, 'stim', 'working');
dir_results = fullfile(dir_study, 'results');
instructions = fullfile(dir_scripts, 'instructions_v3.txt');

%% Load stimuli 
% This block of code is responsible for loading the stimuli. The process
% involves two steps:
% 1. Load the names of your stimuli into Matlab as variables
% 2. Load the audio data itself into Matlab. -- MH

% Select 
cd(dir_stim)
stim_all = dir('*.wav'); % Select all stimuli -- MH
stim_090bpm = dir('090_*.wav'); % Load subsets of stimuli based on tempo. 
stim_150bpm = dir('150_*.wav'); % You'll need to change these based on what 
numStim = length(stim_all);     % you name the stimuli. -- MH

% TEST -- Make sure you have correct number of stimuli
if numStim ~= 16 % Make sure this matches the final number of stimuli. 
    error('You have a strange number of stimuli in your stimDir.')
elseif isempty(stim_090bpm)
    error('Stimuli did not load correctly, as stim_090bpm is empty.')
elseif length(stim_090bpm) ~= length(stim_150bpm)
    error('You have an unequal number of stimuli categories in your stimDir.')
end

% Load actual audio data into cells
au = cell(1, numStim); % Holds actual audio data, as read by Matlab 
fs = cell(1, numStim); % Holds sampling rate (i.e. samples/second) -- MH
for ii = 1:numStim
    audioname = fullfile(stim_all(ii).folder, stim_all(ii).name);
    [au{ii}, fs{ii}] = audioread(audioname, 'double');
    au{ii} = [au{ii}, au{ii}]';
    clear audioname
end

% TEST - Make sure all audio have same sampling rate (fs)
for ii = 1:numStim - 1
    if fs{ii} ~= fs{ii + 1}
        error('YOUR FS ARE NOT EQUAL. CHECK YOUR STIM.')
    end
end
fs = fs{1}; % Why bother keeping each sampling rate if they're all identical? -- MH

dur = cell(1, numStim);
for ii = 1:numStim
    dur{ii} = length(au{ii})/fs;
end

%% Prepare PsychPortAudio
pahandle = PsychPortAudio('Open', [], [], [], fs);
% Ignore this warning. pahandle is used in a helper function I wrote for
% this code and is how PsychPortAudio, the audio controller, refers to the
% audio driver of the computer. -- MH

%% Number of blocks and comparisons
% Determines the number of blocks and comparisons to be made during one run
% of the code. -- MH
blocks = 4; 
numCom = sum(1:numStim); % Formula for number of comparisons (including self) -- MH
comPerBlock = numCom / blocks; % comparisons per block -- MH

% TEST -- is comPerBlock an interger?
if mod(comPerBlock, 1) ~= 0
    error('Comparisons per block is a non-interger number.')
end

%% Prepare keys
% In this experiment, it is CRITICAL that we randomize the stimuli across 
% each subject, and know what stimuli the subject is listening to for a 
% given trial. I use a masterKey which keeps track of which comparisons are
% being made. This code should be done, but I challenge you to try and
% figure out how I generate the master key for each block, I'm pretty proud
% of this code. -- MH

% masterKey -- lists the order in which permutations are to occur
masterKey = cell(1, blocks);
col1 = [];
for ii = 1:numStim
    col1 = vertcat(col1, ii*ones(numStim + 1 - ii, 1));
end

col2 = [];
for ii = 1:numStim
    col2 = vertcat(col2, [ii:numStim]');
end

keyTemp = Shuffle(horzcat(col1, col2), 2);
for bb = 1:blocks
    masterKey{bb} = keyTemp([(bb - 1)*comPerBlock + 1: bb*comPerBlock], :);
    for ii = 1:comPerBlock
         masterKey{bb}(ii, :) = Shuffle(masterKey{bb}(ii, :));
    end
    % TEST -- Does each entry in the masterKey have the proper number of
    % elements? 
    if length(masterKey{bb}) ~= comPerBlock
        error('Check length of each cell within masterKey')
    end
end

resp = NaN(numCom, blocks);
time.trial_start = NaN(numCom, blocks);
time.trial_end = NaN(numCom, blocks);

%% Ready for the real coding? Things get weird from here on...
try
    %% Prepare PsychToolbox (aka PTB) by opening a window
    cd(dir_scripts)
    [wPtr, rect] = Screen('OpenWindow', 0, 185);
    % Find the center of the new window -- MH
    centerX = rect(3)/2; 
    centerY = rect(4)/2;
    
    %% Display instructions
    % PTB text settings
    Screen('TextFont', wPtr, 'Cambria'); % The best font. -- MH
    Screen('TextSize', wPtr, 40);
    Screen('TextStyle', wPtr, 0);
    
    % Read instructions into cell array
    fid = fopen(instructions, 'r'); 
    instructions = fgetl(fid); % Creates a cell array with each line of 
    fclose(fid);               % instructions as an element. 
    DrawFormattedText(wPtr, instructions, 'center', 'center');
    Screen('Flip',wPtr);

    while 1 % Wait for subject response while instructions are on screen
        [~, keyCode] = KbWait([], 2);
        resp = KbName(keyCode);

        if strcmp(resp, 'esc')
            error('ESC pressed. Quitting!')
        end

        if strcmp(resp, 'right')
            break
        end

    end
    
    % Go back to normal text settings for experiment
    Screen('TextStyle', wPtr, 0);
    Screen('TextFont', wPtr, 'Arial');
    time.exp_start = GetSecs;
    
    %% And the REAL experiment goes here. 
    for blk = 1:blocks
        for com = 1:comPerBlock
            time.trial_start(com, blk) = GetSecs;
            
% I removed all of the code that came after this. This is where you'll need
% to fill in the rest. I highly recommend working on this incrementally,
% i.e. get small features to work before working on the whole enchilada. If
% I were taking on this mammoth of a project, I would approach it
% piece-wise as follows:
% GOAL 1 -- Get the audio to play in the right order for one block. 
% GOAL 2 -- Get the audio to play at the right time for one block. Add in
%   white noise between trials. 
% GOAL 3 -- Make the graphical user interface (GUI) for each trial. 
% GOAL 4 -- Make the GUI interactive (i.e. let the subject press buttons 
%   and collect his or her response). 
% GOAL 5 -- Add a break between blocks. 
% Good luck! Feel free to ask questions when you have them. -- MH

            time.trial_end(com, blk) = GetSecs;
        end
    end
    
    % End of experiment clean-up
	time.exp_end = GetSecs;
    Screen('Flip', wPtr);
    DrawFormattedText(wPtr, 'All done! Thanks for participating!', 'center', 'center')
    Screen('Flip', wPtr);
    WaitSecs(5);
    sca;
    
    %% Shutdown -- This is when the code saves all of the data. 
    % The data is saved as a matrix variable (similarMat) and an excell 
    % spreadsheet (similarCell). The former is easier to load into and use
    % in Matlab, while the latter is easier to visualize, as each row and 
    % column are assigned labels based on their names. -- MH
    disp('Saving data...')
    similarCell = cell(numStim + 1, numStim + 1);
    similarMat = NaN(numStim, numStim);
    for ii = 1:numStim
        similarCell{ii + 1, 1} = stim_all(ii).name;
        similarCell{1, ii + 1} = stim_all(ii).name;
    end

    for ii = 1:numCom % 'Poke' the correct value into the correct location. 
        similarCell{masterKey{blk}(ii, 1)+1, masterKey{blk}(ii, 2)+1} = resp(ii);
        similarCell{masterKey{blk}(ii, 2)+1, masterKey{blk}(ii, 1)+1} = resp(ii);
        similarMat(masterKey{blk}(ii, 1), masterKey{blk}(ii, 2)) = resp(ii);
        similarMat(masterKey{blk}(ii, 2), masterKey{blk}(ii, 1)) = resp(ii);
    end

    cd(dir_results)
    save([name '_results.mat'], 'resp', 'similarCell', 'similarMat', 'time')
    xlswrite([name '_results.xlsx'], similarCell)
    disp('Done!')
    cd(dir_scripts)
    
catch err % This is the code that runs if there is an error within the try-catch loop
    sca;
    time.trial_abort = GetSecs;
    try
        abort_trial = com;
    catch
    end
    cd(dir_results)
    disp('Dumping data...')
    save(['crash_' name '_variables.mat'])
    disp('Done!')
    cd(dir_scripts)
    rethrow(err)
end

end