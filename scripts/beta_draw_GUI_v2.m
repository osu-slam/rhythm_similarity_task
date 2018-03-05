%% draw_GUI
% beta_draw_GUI(mode, varargin):
% Draws GUI used in beta_rhythm_behav.  
%
% If mode is set to 'first', draws the GUI used by subjects and needs two 
% more inputs, wPtr and rect. if mode is set to 'update', updates screen in
% response to subject input and needs wPtr, rect, resp, and dur. If
% updating in response to likert response, set duration to 0?

% CHANGELOG (DD/MM/YY)
% 19/10/17  -- Initialized file

function beta_draw_GUI_v2(mode, varargin)

if strcmp(mode, 'first')
    wPtr = varargin{1};
    rect = varargin{2};
elseif strcmp(mode, 'update')
    wPtr = varargin{1};
    rect = varargin{2};
    resp = varargin{3};
    dur  = varargin{4};
end

%% Shape coordinates
rr = 75; % radius of oval
ee = 80; % half of distance from likert scale square to square

one6thX = rect(3)/6;
one3rdX = rect(3)/3;

one3rdY = rect(4)/3;

edge = (one6thX - 2*ee)/2; % Top and bottom edge of likert squares

playOval = round([ ...
    one3rdX - rr, 2*one3rdX - rr; ...
    one3rdY - rr, one3rdY - rr; ...
    one3rdX + rr, 2*one3rdX + rr; ...
    one3rdY + rr, one3rdY + rr; ...
    ]);

playTri = round([ ...
    (2/3)*rr, -(1/3)*rr, -(1/3)*rr, -(1/3)*rr, -(1/3)*rr, (2/3)*rr; ...
    0, rr*tand(30), rr*tand(30), -rr*tand(30), -rr*tand(30), 0; ...
    ]);

likeRect = round([ ...
    one6thX*[1:4] + ee; ...
    (2*one3rdY - edge)*ones(1, 4); ...
    one6thX*[2:5] - ee; ...
    (2*one3rdY + edge)*ones(1, 4); ...
    ]);

labelRect = round([ ...
    one6thX*[0,5] + ee; ...
    (2*one3rdY - edge)*ones(1, 2); ...
    one6thX*[1,6] - ee; ...
    (2*one3rdY + edge)*ones(1, 2); ...
    ]);
labelRect([1, 3], 1) = labelRect([1, 3], 1) + 2*ee;
labelRect([1, 3], 2) = labelRect([1, 3], 2) - 2*ee;

%% First drawing
if strcmp(mode, 'first')
    HideCursor(); 
    Screen('TextSize', wPtr , 42);

    % Draw shapes
    Screen('FillOval', wPtr, [220, 35, 35], playOval);
    Screen('DrawLines', wPtr, playTri, 4, [], [one3rdX one3rdY]);
    Screen('DrawLines', wPtr, playTri, 4, [], [2*one3rdX one3rdY]);
    DrawFormattedText(wPtr, 'Z', 'center', 'center', [255 255 255], [], [], [], [], [], playOval(:, 1)');
    DrawFormattedText(wPtr, 'M', 'center', 'center', [255 255 255], [], [], [], [], [], playOval(:, 2)');

    Screen('FillRect', wPtr, [], likeRect);
    for ii = 1:4
        DrawFormattedText(wPtr, num2str(ii), 'center', 'center', [0 0 0], [], [], [], [], [], likeRect(:, ii)');
    end
    DrawFormattedText(wPtr, 'most\ndifferent', 'center', 'center', [0 0 0], [], [], [], [], [], labelRect(:, 1)');
    DrawFormattedText(wPtr, 'most\nsimilar', 'center', 'center', [0 0 0], [], [], [], [], [], labelRect(:, 2)');

    Screen('Flip', wPtr, [], 1); % Don't clear, allows updating?
    
elseif strcmp(mode, 'update')
    if strcmp(resp, 'esc') % Pause
    elseif strcmp(resp, 'z') % Play stim 1
        Screen('FillOval', wPtr, [256 256 256], playOval(:, 1));
        Screen('DrawLines', wPtr, playTri, 4, [], [one3rdX one3rdY]);
        DrawFormattedText(wPtr, 'Z', 'center', 'center', [255 255 255], [], [], [], [], [], playOval(:, 1)');
        Screen('Flip', wPtr, [], 1);
        
        WaitSecs(dur);
        
        Screen('FillOval', wPtr, [35, 220, 35], playOval(:, 1));
        Screen('DrawLines', wPtr, playTri, 4, [], [one3rdX one3rdY]);
        DrawFormattedText(wPtr, 'Z', 'center', 'center', [255 255 255], [], [], [], [], [], playOval(:, 1)');
        Screen('Flip', wPtr, [], 1);
        
    elseif strcmp(resp, 'm') % Play stim 2
        Screen('FillOval', wPtr, [256, 256, 256], playOval(:, 2));
        Screen('DrawLines', wPtr, playTri, 4, [], [2*one3rdX one3rdY]);
        DrawFormattedText(wPtr, 'M', 'center', 'center', [255 255 255], [], [], [], [], [], playOval(:, 2)');
        Screen('Flip', wPtr, [], 1);
        
        WaitSecs(dur);
        
        Screen('FillOval', wPtr, [35, 220, 35], playOval(:, 2));
        Screen('DrawLines', wPtr, playTri, 4, [], [2*one3rdX one3rdY]);
        DrawFormattedText(wPtr, 'M', 'center', 'center', [255 255 255], [], [], [], [], [], playOval(:, 2)');
        Screen('Flip', wPtr, [], 1);
        
    elseif ~isnan(str2double(resp)) % Likert response
        num = str2double(resp);
        Screen('FillRect', wPtr, [35, 220, 35], likeRect(:, num));
        DrawFormattedText(wPtr, resp, 'center', 'center', [0 0 0], [], [], [], [], [], likeRect(:, num)');
        Screen('Flip', wPtr, [], 1);
        
        WaitSecs(0.125);
        
        Screen('FillRect', wPtr, [], likeRect(:, num));
        DrawFormattedText(wPtr, resp, 'center', 'center', [0 0 0], [], [], [], [], [], likeRect(:, num)');
        Screen('Flip', wPtr, [], 1);
        
    end
end



end