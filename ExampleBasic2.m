% Turns the built-in LED on and off three times

clear;

slider = Slider();

led = 13;
slider.pinMode(led, Slider.pmOutput);

fprintf('High\n');
slider.digitalWrite(led, Slider.dwvHigh);
pause(1.0);
fprintf('Low\n');
slider.digitalWrite(led, Slider.dwvLow);
pause(1.0);

fprintf('High\n');
slider.digitalWrite(led, Slider.dwvHigh);
pause(1.0);
fprintf('Low\n');
slider.digitalWrite(led, Slider.dwvLow);
pause(1.0);

fprintf('High\n');
slider.digitalWrite(led, Slider.dwvHigh);
pause(1.0);
fprintf('Low\n');
slider.digitalWrite(led, Slider.dwvLow);

slider.delete();
clear slider;
