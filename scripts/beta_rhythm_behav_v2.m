%% beta_rhythm_behav
% Create a script to "beta-test" rhythm_mvpa amongst SLAMERS. 
% Author -- Matt H

% CHANGELOG
% 17/10/17  -- Initialized file. 
% 18/10/17  -- Settled on a GUI. Needs to become interactive now.
% 19/10/17  -- Fully interactive. Need subject response. 
% 20/10/17  -- Subject response and saving data now added. 
% 12/01/18  -- New stimuli used!

function beta_rhythm_behav_v2
%% Initialization

sca; DisableKeysForKbCheck([]); KbQueueStop; 
Screen('Preference','VisualDebugLevel', 0); 

PsychPortAudio('Close'); 
InitializePsychSound

clearvars; clc; 

AudioDevice = PsychPortAudio('GetDevices', 3); 

%% Parameters
name = inputdlg({'Save as?'});
name = name{1};

%% Pathing
dir_scripts = pwd;
cd ..
dir_study = pwd;
dir_stim = fullfile(dir_study, 'stim', 'working');
dir_results = fullfile(dir_study, 'results');
instructions = fullfile(dir_scripts, 'instructions_v3.txt');

%% Load stimuli and prepare PsychPortAudio
cd(dir_stim)
stim_all = dir('*.wav');
stim_096bpm = dir('096_*.wav');
stim_144bpm = dir('144_*.wav');
numStim = length(stim_all);
% numSets = 3; % number of sets to test

% test to make sure you have correct number of stimuli
if numStim ~= 12
    error('You have a strange number of stimuli in your stimDir.')
elseif isempty(stim_096bpm)
    error('Stimuli did not load correctly, as stim_096bpm is empty.')
elseif length(stim_096bpm) ~= length(stim_144bpm)
    error('You have an unequal number of stimuli categories in your stimDir.')
end

%% Number of blocks and comparisons
blocks = 1;
numCom = sum(1:numStim); % Formula for number of comparisons (including self)
% comPerSet = numCom/numSets;
% stimPerSet = length(c_rest_stim);

%%
au = cell(1, numStim);
fs = cell(1, numStim);
for ii = 1:numStim
    audioname = fullfile(stim_all(ii).folder, stim_all(ii).name);
    [au{ii}, fs{ii}] = audioread(audioname, 'double');
    au{ii} = [au{ii}, au{ii}]';
    clear audioname
end

%%% How many PsychPortAudio channels will computer have, 2?
%%% If not, stimuli need to be transformed from size (2, fs)
%%% ALSO, be sure to check white noise channels too...

for ii = 1:numStim - 1
    if fs{ii} ~= fs{ii + 1}
        error('YOUR FS ARE NOT EQUAL. CHECK YOUR STIM.')
    end
end
fs = fs{1};

noisesamples = fs * 0.5;

dur = cell(1, numStim);
for ii = 1:numStim
    dur{ii} = length(au{ii})/fs;
end

pahandle = PsychPortAudio('Open', [], [], [], fs);

%% Prepare keys
% masterKey -- lists the order in which permutations are to occur
masterKey = cell(1, blocks);
for bb = 1:blocks
    col1 = [];
    for ii = 1:numStim
        col1 = vertcat(col1, ii*ones(numStim + 1 - ii, 1));
    end

    col2 = [];
    for ii = 1:numStim
        col2 = vertcat(col2, [ii:numStim]');
    end

    masterKey{bb} = Shuffle(horzcat(col1, col2), 2);
    for ii = 1:length(masterKey{bb})
        masterKey{bb}(ii, :) = Shuffle(masterKey{bb}(ii, :));
    end
%     % TEST
%     if length(unique(masterKey{bb}, 'rows')) ~= numCom
%         error('Something happened when making master')
%     end
end

resp = NaN(numCom, blocks);
time.trial_start = NaN(numCom, blocks);
time.trial_end = NaN(numCom, blocks);

%% Preallocation for PTB
% Play icons -- parameters
rr = 75; % radius of oval
ee = 20; % half of distance from likert scale square to square

%% Prepare PTB
try
    cd(dir_scripts)
    [wPtr, rect] = Screen('OpenWindow', 0, 185);
    centerX = rect(3)/2;
    centerY = rect(4)/2;
    
    beta_display_instructions(wPtr, instructions)
    Screen('TextStyle', wPtr, 0);
    Screen('TextFont', wPtr, 'Arial');
    time.exp_start = GetSecs;
    
    for blk = 1:blocks
        for com = 1:numCom
            time.trial_start(com, blk) = GetSecs;
            beta_draw_GUI_v2('first', wPtr, rect)
            s1 = false; % Flips to true once subject listens to stim 1
            s2 = false; % Flips to true once subject listens to stim 2
            while 1
                [~, keyCode] = KbWait([], 2);
                press = KbName(keyCode);

                if strcmp(press, 'esc')
                    error('ESC pressed. Quitting!')
                elseif strcmp(press, 'down')
                    noise = 0.3*rand(2, noisesamples);
                    PsychPortAudio('FillBuffer', pahandle, noise); % Fill buffer
                    PsychPortAudio('Start', pahandle, 1); % Play noise
                    break
                end

                press = press(1);
                if ~isreal(str2double(press)) % For inputs i and j, which are considered imaginary numbers (i.e. are not NaN)
                    clear press
                elseif strcmp(press, 'z') % Play stimuli 1
                    s1 = true;
                    PsychPortAudio('FillBuffer', pahandle, au{masterKey{blk}(com, 1)}); % Fill buffer
                    PsychPortAudio('Start', pahandle, 1); % Play audio
                    beta_draw_GUI_v2('update', wPtr, rect, press, dur{masterKey{blk}(com, 1)}) % Update GUI in meanwhile
                elseif strcmp(press, 'm') % Play stimuli 2
                    s2 = true;
                    PsychPortAudio('FillBuffer', pahandle, au{masterKey{blk}(com, 2)}); % Fill buffer
                    PsychPortAudio('Start', pahandle, 1); % Play audio
                    beta_draw_GUI_v2('update', wPtr, rect, press, dur{masterKey{blk}(com, 2)}) % Update GUI in meanwhile
                elseif ~isnan(str2double(press)) % numeric keys are 2 char (e.g. 1!, 2@...)    
                    if s1 && s2
                        if str2double(press) < 8
                            resp(com, blk) = str2double(press);
                            beta_draw_GUI_v2('update', wPtr, rect, press, 0)
                            noise = 0.3*rand(2, noisesamples);
                            PsychPortAudio('FillBuffer', pahandle, noise); % Fill buffer
                            PsychPortAudio('Start', pahandle, 1); % Play noise
                            break
                        end
                    else
                        clear press
                    end
                end
                clear press
            end
            time.trial_end(com, blk) = GetSecs;
        end
    end
    
	time.exp_end = GetSecs;
    Screen('Flip', wPtr);
    DrawFormattedText(wPtr, 'All done! Thanks for participating!', 'center', 'center')
    Screen('Flip', wPtr);
    WaitSecs(5);
    sca;
    
    %% Shutdown 
    disp('Saving data...')
    similarCell = cell(numStim + 1, numStim + 1);
    similarMat = NaN(numStim, numStim);
    for ii = 1:numStim
        similarCell{ii + 1, 1} = stim_all(ii).name;
        similarCell{1, ii + 1} = stim_all(ii).name;
    end

    for ii = 1:numCom
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
    
catch err
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