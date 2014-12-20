kos-plen
========


Attempt at an autopilot script for planes running kOS in Kerbal Space Program
-----------------------------------------------------------------------------


### Goal:
  - Fully implement the most of the features of a modern passenger aircrafts autopilot.


### Features:
  - Maintain given heading, altitude and speed.
  - Fly to waypoint.
  - "ILS" auto land.


### !!! WARNING !!! 
The take-off procedure may not be compatible with your plane.

### Installation:
- Copy "plen.ks" to your "[KSP-Folder]\Ships\Scripts" folder. You can give the file a different name if you want.
- If you need a plane that is guaranteed to work with the plen copy "p-4.craft" to your "[KSP-Folder]\Ships\SPH" folder.

### Usage:
- Load a plane with a SCS-module (kOS computer) to the runway.
- Open the terminal from the SCS part menu.
- Start the autopilot by typing  
    run plen.  
- The autopilot will now "safely and reliably" launch your plane and bring it up to an altitude of about 500m ASL.
- The autopilot will now transition into closed loop guidance which allows you to enter your flight parameters using Action Groups:  
     AG 1 - 6: Set altitude, heading, speed, climb rate and max bank.  
     AG 7 - 9: Used to change what the autopilot thinks it should do.  
     AG 0:     Switch between changing alt, hdg, spd and climb rate and bank max.  
- To start the ILS auto land, toggle all of AG 7 - 9 once. It will now fly to the mountains west of the KSC and start to align itself with the runway from there. Set altitude as needed in order to avoid terrain until the plane has reached its first waypoint.


### FAQ:
Q: I tried to use the Action Groups to control the autopilot, but nothing happened.  
A: Make sure the kOS window is not focused (should be transparent). Also wait until the plane reaches 500m and the screen changes.

Q: I tried to the auto land function, but my plane crashed into the terrain.  
A: Until the plane reaches the first waypoint ("MOD" in the upper left corner is smaller than 2) you are responsible for setting altitude and speed. Try to use 2000 as altitude setpoint.

Q: The screen is flickering.  
A: Increase the IPU in the kOS menu ingame. This issue is caused by the script not being able to clear and redraw the entire screen within a single frame. This is because kOS artificially restricts the processing power of the scriptable control system (SCS), increasing the IPU to about 500 allows the redrawing to happen within a frame.

Q: File "plen" not found!  
A: kOS could not find the script. Make sure "plen.ks" is in your "[KSP-Folder]\Ships\Scripts" folder.  
kOS might be looking in the wrong place. Try typing "switch to archive.", without the quotes. If that worked, you can instruct kOS to start in the right directory by default by activating the "ARCH" button in the ingame kOS menu.
