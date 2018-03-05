%% beta_display_instructions
% Takes the participant through the instructions. 

function beta_display_instructions(wPtr, filename)

% Set properties of display
font = 'Cambria'; % The best font. 
size = 40;

% Read instructions into cell array
fid = fopen(filename, 'r'); 
ii = 1; 
instructions = fgetl(fid); % Creates a cell array with each line of 
fclose(fid);               % instructions as an element. 

Screen('TextFont', wPtr, font); 
Screen('TextSize', wPtr, size);
Screen('TextStyle', wPtr, 0);
DrawFormattedText(wPtr, instructions, 'center', 'center');
Screen('Flip',wPtr);
    
while 1
    [~, keyCode] = KbWait([], 2);
    resp = KbName(keyCode);

    if strcmp(resp, 'esc')
        error('ESC pressed. Quitting!')
    end

    if strcmp(resp, 'right')
        break
    end

end

end