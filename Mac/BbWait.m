function [secs, keyCode] = BbWait(port, whichButton)

%This function waits for button box input from a specified port, and returns the time and key code of the button press. 
%Mimicks the function KbWait for keyboards, with the additional functionality that you can use the whichButton argument 
%to specify which button you want to wait for. 
%
%Possible whichButton values:
% - [] for any button
% - 1  for button 1
% - 2  for button 2
% - 3  for button 3
% - 4  for button 4

%Clear values queued in port
IOPort('Flush', port);

%Loop until specified button is pressed
buttonPressed = 0;
while buttonPressed == 0 
    [portData,portTime,~] = IOPort('read',port);
    if isa(whichButton, 'char') & any(portData==BbName(whichButton)) %buttons 1-4
        buttonPressed=portData; 
    elseif isempty(whichButton) & ~isempty(portData) %any button
        buttonPressed=portData;
    end
    WaitSecs(.005); %poll every 5 ms
end

%Save time and key code of button pressed to output variables
secs = portTime;
keyCode = portData;

end

