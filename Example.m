clear;

slider = Slider();

% % If you know the serial port of the Arduino, you can provide it to the
% % constructor. If not, you can just use the selection box
% slider = Slider('COM4');

% ---

% Green LED on pin 6 of Arduino
greenLed = 6;

% Red LED on pin 9 of Arduino
redLed = 9;

initLed(slider, greenLed);
initLed(slider, redLed);

ledBrightness(slider, greenLed, 1.0);
ledBrightness(slider, redLed, 0.0);

% ---

targetPos = 300;
speed = 120;
slider.moveTo(targetPos, speed);

% Wait until the the slider has arrived at `targetPos`
while ~slider.hasArrived()
end

% ---

targetPos = -600;
speed = 200;
slider.moveTo(targetPos, speed);

% Change brightness of LEDs based on slider position
while ~slider.hasArrived()
    distanceToGo = slider.distanceToGo();
    fprintf('Distance to go: %i\n', distanceToGo);

    fractionToGo = abs(distanceToGo) / abs(targetPos);

    ledBrightness(slider, greenLed, fractionToGo);
    ledBrightness(slider, redLed, 1.0 - fractionToGo);
end

% ---

% Move back to initial position
targetPos = 0;
speed = 300;
slider.moveTo(targetPos, speed);

while ~slider.hasArrived()
end

% ---

% Close the connection to the Arduino
slider.delete();
clear slider;

% ---

function initLed(slider, led)
    % initLed(slider, led)
    slider.pinMode(led, Slider.pmOutput);
end

function ledBrightness(slider, led, brightness)
    % ledBrightness(slider, led, brightness)

    % ---
    % Parameters
    %     `led`: pin on Arduino to LED
    %     `brightness`: range from 0.0 to 1.0

    slider.analogWrite(led, round(brightness * 255));
end
