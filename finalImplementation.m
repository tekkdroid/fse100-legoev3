%% SETUP
global key;
brick.StopAllMotors();
InitKeyboard();
brick.SetColorMode(3, 2);
% Variables
driveSpeedManual = 25;
driveSpeedAutoA = 40.125;
driveSpeedAutoB = 40;
turnSpeed = 20;
liftSpeed = 15;
blackColor = 1;
redColor = 5;
targetColors = [2, 3, 4];
wallGoneDist   = 65; 
wallRearmDist  = 50; 
rightTurnArmed = true; 
rightTurnCount = 0;
%% MAIN LOOP
while 1
  pause(0.1);
  if brick.TouchPressed(1)
      break;
  end
  currentColor = brick.ColorCode(3);
  %% MANUAL MODE: BLUE, GREEN OR YELLOW
  if ismember(currentColor, targetColors)
      brick.StopMotor('ABC', 'Brake');
      % Beep when entering manual mode
      if currentColor == 2
          brick.beep();
          pause(0.5);
          brick.beep();
      elseif currentColor == 3
          brick.beep();
          pause(0.5);
          brick.beep();
          pause(0.5);
          brick.beep();
     elseif currentColor == 1
          brick.beep();
          pause(0.5);
          brick.beep();
          pause(0.5);
          brick.beep();
          pause(0.5);
          brick.beep();
      end
      while ismember(currentColor, targetColors)
          pause(0.1);
          if brick.TouchPressed(1)
              brick.StopAllMotors();
              CloseKeyboard();
              return;
          end
          switch key
              case 'uparrow'
                  brick.StopMotor('C', 'Brake');
                  brick.MoveMotor('AB', driveSpeedManual);      % FIXED
              case 'downarrow'
                  brick.StopMotor('C', 'Brake');
                  brick.MoveMotor('AB', -driveSpeedManual);     % FIXED
              case 'rightarrow'
                  brick.StopMotor('C', 'Brake');
                  brick.MoveMotor('B', turnSpeed);
                  brick.MoveMotor('A', -turnSpeed);
              case 'leftarrow'
                  brick.StopMotor('C', 'Brake');
                  brick.MoveMotor('B', -turnSpeed);
                  brick.MoveMotor('A', turnSpeed);
              case 't'
                  brick.StopMotor('AB', 'Brake');
                  brick.MoveMotor('C', liftSpeed);
              case 'r'
                  brick.StopMotor('AB', 'Brake');
                  brick.MoveMotor('C', -liftSpeed);
              otherwise
                  brick.StopMotor('ABC', 'Brake');
          end
          currentColor = brick.ColorCode(3);
      end
      % Stop motors before automatic mode
      brick.StopMotor('ABC', 'Brake');
      if brick.TouchPressed(1)
          break;
      end
  end
  %% AUTOMATIC MODE
  %% TOUCH SENSOR 4: REVERSE AND TURN LEFT
  if (currentColor == blackColor || currentColor == redColor) && brick.TouchPressed(4)
      brick.MoveMotor('AB', -50);
      pause(0.7);
      brick.StopAllMotors();
      disp('turn left');
      brick.MoveMotorAngleRel('A',turnSpeed,180,'Brake');
      brick.MoveMotorAngleRel('B',turnSpeed,-180,'Brake');
      brick.WaitForMotor('AB');

  %% RED COLOR DETECTION
  elseif currentColor == redColor
      brick.StopMotor('AB', 'Brake');
      pause(1);
      if brick.TouchPressed(1)
          break;
      end
       brick.MoveMotor('A', driveSpeedAutoA);
       brick.MoveMotor('B', driveSpeedAutoB);
  %% BLACK COLOR: RIGHT WALL NAVIGATION
  elseif currentColor == blackColor
      distance = brick.UltrasonicDist(2);
      display(distance);
      % ---- LOGIC COUNTER: re-arm when a wall is on the right again ----
      if distance <= wallRearmDist
          rightTurnArmed = true;     
      end
      % Drive forward while following right wall
      brick.MoveMotor('A', driveSpeedAutoA);
      brick.MoveMotor('B', driveSpeedAutoB);
      if distance > wallGoneDist && rightTurnArmed
          % Turn right ONCE per wall-end event
          rightTurnArmed = false;     % disarm until wall is seen again
          brick.StopAllMotors();
          pause(0.5);
          brick.MoveMotorAngleRel('A',turnSpeed,-180,'Brake');
          brick.MoveMotorAngleRel('B',turnSpeed,180,'Brake');
          brick.WaitForMotor('AB');
          brick.MoveMotor('A', driveSpeedAutoA);
          brick.MoveMotor('B', driveSpeedAutoB);
          pause(0.2);
      end
  else
      % Stop when floor color is not recognized
      brick.StopMotor('AB', 'Brake');
  end
  % Check touch sensor after automatic action
  if brick.TouchPressed(1)
      break;
  end
  currentColor = brick.ColorCode(3);
  if ismember(currentColor, targetColors)
      brick.StopMotor('AB', 'Brake');
  end
end
%% CLEANUP
brick.StopAllMotors();
CloseKeyboard();


