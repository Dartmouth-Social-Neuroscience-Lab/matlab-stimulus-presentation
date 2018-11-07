function [keyPressed,secs,keyCode] = BbCheck(port)

%This function checks for button box input from a specified port, and returns whether a button press has been
%detected and if so, the time and key code of the button press. Mimicks the function KbCheck for keyboards; main 
%difference is BbCheck registers a button only once no matter how long you hold it down for, while KbCheck will
%register a key repeatedly until it's released. Hence the output "keyPressed", instead of "keyIsDown". 
%This difference mainly matters when using BbCheck vs. KbCheck in a while loop.

%Clear values queued in port
IOPort('Flush', port); %TRY COMMENTING THIS OUT on next testing session - since it reads the LAST button press the clears the queue, we may not need this. In fact it may be slowing us down.

%Default output variable values
keyPressed = 0;
secs       = [];
keyCode    = zeros(1,53); %A vector of zeros at the length of the button mapping array used in BbName

%Check for button box input and update output variables if button press is detected
[portData,portTime,~] = IOPort('read',port);
if ~isempty(portData)
    
    %Record that button has been pressed and record time of press
    keyPressed = 1;
    secs       = portTime;
    
    %For each button, update the keyCode vector index corresponding with the button's ASCII code to equal 1 instead of 0
    for button = 1:length(keyCode)
        if any(portData == button)
            keyCode(button) = 1;
        end
    end
    
end

end