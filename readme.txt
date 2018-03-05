%%% RHYTHM_MVPA %%%
CHANGELOG: 
10/04/17  Started code for experiment. -- MH
10/17/17  Stimuli finished, coding work begins in earnest. -- MH
02/05/17  Handed project off to Matt Moritz. -- MH

File structure:
\rhythm_similarity_task -- Main experiment folder
  \docs -- Any supporting documents I've created for the experiment, including stimuli notation and 
           various presentations. 
  \results -- Where results save from main experiment. 
  \scripts -- All scripts I've written for this experiment. 
    \old -- A script graveyard which contains old versions of the code
    \beta_display_instructions.m -- Helper function called within beta_rhythm_behav_v2.
    \beta_draw_GUI_v2.m  -- See above. Also called in beta_rhythm_behav_v3.
    \instructions_v3.txt -- Working copy of instructions. 
    \beta_rhythm_behav_v2.m -- Last working version of the code. Features self-paced experiment. 
    \beta_rhythm_behav_v3.m -- My working copy of the new code. This can function as a template for your work. 
  \stim -- Contains all of the stimuli I've made for this experiment
    \old_stim -- Outdated or replaced versions of stimuli. 
    \working  -- Current (as of v2) stimuli. You can move these files to \old and put the new stimuli here. 
    \RST_stimuli_v1.png -- A nice picture of the stimuli I used in old experiments. 
  \readme.txt -- This document. 

Below are old notes I kept about the code. They may or may not be useful. 
  
TO DO:
1.  Create stimuli %%% WORKING WITH V5
2.  Write code for behavioral experiment
2a. Beta-test with lab mates. Ran with Dr. Lee, now have some changes to make:
  i  ) Make new stimuli (DONE!)
  ii ) Update to be 1-4 scale DONE!
  
  iii) Add break points 1/4, 1/2, and 3/4 through
  iv ) Update how data is collected
  v  ) Update instructions on BOTH computers (done on computer 4)
3.  Write code for fMRI experiment. 

%%% DESCRIPTION %%%
Pseudopassive listening task where subjects respond with a button press when
they hear (or see?) an oddball stimuli. 

Experiment design is 2x2(x2?) factorial, with factors of duration, content, 
(and modality?). 

Scan will use hybrid protocol with full-brain coverage. 

Analysis will use contrasts built using FIR-based GLM, MVPA classifiers, and RSA. 

Behavioral task will require subjects to rate similarity of stimuli used in 
the experiment. 

%%% STIMULI DESIGN %%%
Silent window of scan can be up to 4 seconds long. 
Acquisition window needs to be at least 10 seconds long, if not longer
  (RE: time point analysis of subject 4's data). 
  
%%% TIMING %%%
Scan can last up to 1 hour, if not longer. 
Runs should not last longer than 6 minutes each (with rest time). 
Maximize the number of trials possible in each run?

%%% MAJOR QUESTIONS %%%
Are we including the modality factor?
  If so, should we have blocks of each modality or interspersed events?
  
%%% BEHAVIORAL TEST %%% (outdated)
Subjects listen to two stimuli pairs and respond on a likert (1-7) scale how similar the stimuli are.
No timing constraint, RT not a needed measure.
Subjects can listen to stimuli presentation as many times as they would like. 

New test will not collect RT, likert scale will be 1-5, and is no longer self paced. 
