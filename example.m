clear;

slider = Slider(0, [2, 3, 4, 5]);
slider.setSpeed(12);

fprintf('Forwards 12 steps\n');
fprintf('---\n');
slider.setDestination(12);
while slider.getStepsRemaining() ~= 0
    slider.run();
end

fprintf('Backwards 10 steps\n');
fprintf('---\n');
slider.setDestination(-10);
while slider.getStepsRemaining() ~= 0
    slider.run();
end

fprintf('Go to initial position - forwards 2 steps \n');
fprintf('---\n');
slider.resetPos();
while slider.getStepsRemaining() ~= 0
    slider.run();
end
