//TODO
//dampen error pick up.

//setup
clearscreen.
print "plen aplot".

print "Loading waypoints.".
set tgt to latlng(20.5829,-146.5116).
set rnwy to latlng(-0.0486,-74.60).
set ils1 to latlng(-0.0486,-75.5).
set ils2 to latlng(-0.0486,-78).




//max 50,35 (c,l)
print "Setting up User input.".

set landing to false.
set landing_step to 3.
set ap_mode to 0. //waypoint or landing.
set ap_refresh to false. //read heading.
set input_mode to 0. //setpoints or change rates
set command_mode to 1. //manual guidance, manual direction or automatic mode.

set ag1_last to ag1.
set ag2_last to ag2.
set ag3_last to ag3.
set ag4_last to ag4.
set ag5_last to ag5.
set ag6_last to ag6.
set ag7_last to ag7.
set ag8_last to ag8.
set ag9_last to ag9.
set ag10_last to ag10.

set ag1_changed to false.
set ag2_changed to false.
set ag3_changed to false.
set ag4_changed to false.
set ag5_changed to false.
set ag6_changed to false.
set ag7_changed to false.
set ag8_changed to false.
set ag9_changed to false.
set ag10_changed to false.

print "Setting up IMU".
SET t0 TO TIME:SECONDS.
set missionstart to t0.
lock met to (time:seconds - missionstart).


set v_spd to 0.
set v_hdg to 90.
set v_bank to 0.
set v_pitch to 15.

lock v_stb to ship:facing * r(0,90,0).

print "Initializing PID.".
//range: error range in which loop will use less than full deflection
//max: full deflection

//p(itch): alt-vsp(-ptc-)prt-aileron
set p_alt_setpoint to 1000.
set p_alt_range to 100.
set p_vsp_max to 10.
set p_vsp_range to 5.
set p_prt_max to 3.
set p_prt_range to 10.
set p_ail_max to 1.
set p_prt_I to 0.

set s_I to 0. //speed -> thrust
set b_I to 0. //bank -> roll
set c_I to 0. //climb -> pitch

set s_lasterror to 0.
set b_lasterror to 0.
set c_lasterror to 0.

//---------------------------------------------
print "Setting up PID.".

set heading_setpoint to 90.
set altitude_setpoint to 1000.
set b_max to 25.
set c_max to 25.

set s_setpoint to 180.
set b_setpoint to 0.
set c_setpoint to 15.
set heading_bearing to 0.

set s_ku to 0.2.
set s_tu to 20.
set s_kp to s_ku * 0.5.
set s_ki to (s_ku * 1.2 ) / s_tu.
set s_kd to 0.


set b_ku to 0.05.
set b_tu to 2.
set b_kp to b_ku * 0.5.
set b_ki to 0.//(b_ku * 1.2 ) / b_tu.
set b_kd to (b_kp * b_tu) / 8.

set c_ku to 0.04.
set c_tu to 3.2.
set c_kp to c_ku * 0.5.
set c_ki to (c_ku * 1.2 ) / c_tu.
set c_kd to (c_kp * c_tu) / 8.

set c_I_limit to 1.2.

print "Setting up triggers.".

when (altitude > 1000) then {set p_setpoint to 5.8.}.
//when (met > 50) then {set b_setpoint to 35.}.
//when (met > 70) then {set b_setpoint to 0.}.




wait 0.25.


if not (command_mode = 0) {
	stage.
	lock throttle to 1.
	lock steering to heading(90,3).
	//wait until airspeed > 125.
	//print "V2".
	wait until airspeed > 80.
	print "Rotate!".
	lock steering to heading(90,15).
	wait until altitude > 100.
	toggle gear.
	wait until altitude > 500.
	lock steering to heading(90,3).
	wait 3.
	unlock steering.
	set c_setpoint to verticalspeed.
}.


//################################################################
//loop


print "starting loop".

until false {
	//tracking actiongroups
	if not (ag1 = ag1_last) {set ag1_changed to true.}.
	if not (ag2 = ag2_last) {set ag2_changed to true.}.
	if not (ag3 = ag3_last) {set ag3_changed to true.}.
	if not (ag4 = ag4_last) {set ag4_changed to true.}.
	if not (ag5 = ag5_last) {set ag5_changed to true.}.
	if not (ag6 = ag6_last) {set ag6_changed to true.}.
	if not (ag7 = ag7_last) {set ag7_changed to true.}.
	if not (ag8 = ag8_last) {set ag8_changed to true.}.
	if not (ag9 = ag9_last) {set ag9_changed to true.}.
	if not (ag10 = ag10_last) {set ag10_changed to true.}.

	set ag1_last to ag1.
	set ag2_last to ag2.
	set ag3_last to ag3.
	set ag4_last to ag4.
	set ag5_last to ag5.
	set ag6_last to ag6.
	set ag7_last to ag7.
	set ag8_last to ag8.
	set ag9_last to ag9.
	set ag10_last to ag10.

	//keeping a track of reality
	set dt to TIME:SECONDS - t0.
	
	set v_acc to (airspeed - v_spd) / dt.
	set v_spd to airspeed.
	
	set v_aoa to vang(facing:vector,velocity:surface).
	set v_angv_p to ((90 - vang(up:vector,facing:vector)) - v_pitch) / dt.
	set v_pitch to (90 - vang(up:vector,facing:vector)).

	set v_angv_y to ((facing:pitch + 90) - v_hdg) / dt.
	set v_hdg to latlng(90,0):bearing.
	if v_hdg < 0 {set v_hdg to abs(v_hdg).} else {set v_hdg to 180 + (180 - v_hdg).}.


	set v_alt to altitude.
	set v_vspd to verticalspeed.

	set v_bank to vang(v_stb:vector, up:vector) - 90.
	


//User input.
	if ag7_changed {
		toggle ap_refresh. 
		toggle ag7_changed.
	}.
	
	if ag8_changed {
		set ap_mode to ap_mode + 1. 
		toggle ag8_changed.
	}.
	if ap_mode > 1 {set ap_mode to 0.}.
	
	if ag9_changed {
		set command_mode to command_mode + 1. 
		toggle ag9_changed.
		run tgt.
	}.
	if command_mode > 2 {set command_mode to 0.}.
	
	if ag10_changed {
		set input_mode to input_mode + 1. 
		toggle ag10_changed.
	}.
	if input_mode > 1 {set input_mode to 0.}.
	
	if input_mode = 0 {
		if ag1_changed {set s_setpoint to s_setpoint + 10. toggle ag1_changed.}.
		if ag2_changed {set s_setpoint to s_setpoint - 10. toggle ag2_changed.}.
		if ag3_changed {set p_alt_setpoint to p_alt_setpoint + 100. toggle ag3_changed.}.
		if ag4_changed {set p_alt_setpoint to p_alt_setpoint - 100. toggle ag4_changed.}.
		if ag5_changed {set heading_setpoint to heading_setpoint + 15. toggle ag5_changed.}.
		if ag6_changed {set heading_setpoint to heading_setpoint - 15. toggle ag6_changed.}.
		
		if heading_setpoint > 360 {set heading_setpoint to heading_setpoint - 360.}.
		if heading_setpoint < 0   {set heading_setpoint to heading_setpoint + 360.}.
	}.
	if input_mode = 1 {
		if ag1_changed {set p_vsp_max to p_vsp_max + 5. toggle ag1_changed.}.
		if ag2_changed {set p_vsp_max to p_vsp_max - 5. toggle ag2_changed.}.
		if ag3_changed {set b_max to b_max + 5. toggle ag3_changed.}.
		if ag4_changed {set b_max to b_max - 5. toggle ag4_changed.}.
	}.

	//drawing GUI
	clearscreen.

	print "SPD " + round(v_spd,2) at (30,0).
	print "HGT " + round(v_alt,2) at (30,2).
	print "HDG " + round(v_hdg,2) at (30,5).
	print "PIT " + round(v_pitch,2) at (30,6).
	print "BNK " + round(v_bank, 2) at (30,7).

	print "MET " + round(met, 2) at (0,0).
	print "DT " + round(dt, 5) at (15,0).
	
	print "MOD " + landing_step at (0,2).
	print "BEAR " + round(heading_bearing,2) at (15,2).
	
	print "apref 7 " + ap_refresh at (30,10).
	print "apcom 8 " + ap_mode at (30,11).
	print "commod 9 " + command_mode at (30,12).
	print "div " + (SHIP:GEOPOSITION:LAT + 0.0405) at (30,13).
	print "dist " + (rnwy:distance) at (30,13).
	
	

	if input_mode = 0 {
		print "[SPD]      [ALT]    [HDG]" at (4,29).
		print "[1]        [3]      [5]" at (5,31).
		print s_setpoint at (5,33).
		print p_alt_setpoint at (15,33).
		print heading_setpoint at (25,33).
		print "[2]        [4]      [6]" at (5,35).
	}.
	if input_mode = 1 {
		print "[VSP]      [BNK]" at (4,29).
		print "[1]        [3]" at (5,31).
		print p_vsp_max at (5,33).
		print b_max at (15,33).
		print "[2]        [4]" at (5,35).
	}.

	
	//landing
//	if 

//--------------------------------------------------
	//pid
	
	if (command_mode = 2) and ap_refresh {
		if ap_mode = 0 {
			set heading_setpoint to tgt:heading.
		} else {
			if landing_step = 3 {
				set heading_setpoint to ils2:heading.
//				set p_alt_setpoint to 2000.
				if ils2:distance < (1000 + ALT:RADAR) {
					
					set landing_step to landing_step - 1.
				}.
			}.
			if landing_step = 2 {
				set heading_setpoint to 90 + 150 * (SHIP:GEOPOSITION:LAT + 0.0486).
				if heading_setpoint < 20 {set heading_setpoint to 20.}.
				if heading_setpoint > 160 {set heading_setpoint to 160.}.
				set p_alt_setpoint to (rnwy:distance * 0.05).
				set p_vsp_max to 25.
				set b_max to 40.
				set s_setpoint to 180.
				if ils1:distance < (100 + ALT:RADAR) {
					set landing_step to landing_step - 1.
					set gear to true.
				}.
			}.
			if landing_step = 1 {
				set heading_setpoint to 90 + 500 * (SHIP:GEOPOSITION:LAT + 0.0486).
				set p_alt_setpoint to (rnwy:distance * 0.05).
				set s_setpoint to 115.
				set b_max to 100.
				if ALT:RADAR < (3) {
					set landing_step to landing_step - 1.
					set heading_setpoint to 90.
					set s_setpoint to 0.
				}.
			}.
		}.
	}.
	
	set heading_b1 to (heading_setpoint - v_hdg).
	set heading_b2 to (-360 +  heading_setpoint - v_hdg).
	set heading_b3 to (+360 -  v_hdg + heading_setpoint).
	if abs(heading_b1) < abs(heading_b2) {set heading_bearing to heading_b1.} else {set heading_bearing to heading_b2.}.
	if abs(heading_bearing) > abs(heading_b3) {set heading_bearing to heading_b3.}.
	
	set heading_error to heading_bearing.
	if heading_error > 15 {set heading_error to 15.}.
	if heading_error < -15 {set heading_error to -15.}.
	set b_setpoint to (heading_error / 15) * b_max. 
	
	set p_alt_error to p_alt_setpoint - v_alt.
	if p_alt_error > p_alt_range {set p_alt_error to p_alt_range.}.
	if p_alt_error < -p_alt_range {set p_alt_error to -p_alt_range.}.
	set p_vsp_setpoint to (p_alt_error / p_alt_range) * p_vsp_max. 
	if landing_step = 0 {set p_vsp_setpoint to -0.33.}.
	set p_vsp_error to p_vsp_setpoint - v_vspd.
	if p_vsp_error > p_vsp_range {set p_vsp_error to p_vsp_range.}.
	if p_vsp_error < -p_vsp_range {set p_vsp_error to -p_vsp_range.}.
	set p_prt_setpoint to (p_vsp_error / p_vsp_range) * p_prt_max. 
	
	set p_prt_error to p_prt_setpoint - v_angv_p.
	if p_prt_error > p_prt_range {set p_prt_error to p_prt_range.}.
	if p_prt_error < -p_prt_range {set p_prt_error to -p_prt_range.}.
	
	set p_prt_I to p_prt_I + p_prt_error * dt.
	if p_prt_I > p_prt_range {set p_prt_I to p_prt_range.}. //FINETUNE AND IMPLEMENT
	if p_prt_I < -p_prt_range {set p_prt_I to -p_prt_range.}.
	
	set c_command to (p_prt_error / (2 * p_prt_range)) + (p_prt_I / (20 * p_prt_range)) . 

//	if abs(altitude_command - c_setpoint) > 3 {
//		set c_setpoint to c_setpoint + (altitude_command - c_setpoint) / 15. //apply directly to error.
//	} else {
//		set c_setpoint to altitude_command.
//	}.
	
	
	
	
	set s_error to s_setpoint - v_spd.
	set b_error to b_setpoint - v_bank.
	
	set s_P to s_error.
	set b_P to b_error.
	
	
	set s_I to s_I + s_error * dt.
	set b_I to b_I + b_error * dt.
	
	set s_D to ((s_error) - (s_lasterror)) / dt.
	set b_D to ((b_error) - (b_lasterror)) / dt.
	
	set s_lasterror to s_error.
	set b_lasterror to b_error.
	
	if (s_I * s_ki) > 1 {set s_i to 1 / s_ki.}.  
	if (s_I * s_ki) < 0 {set s_i to 0 / s_ki.}.  
	if (b_I * b_ki) > 1 {set b_i to 1 / b_ki.}.  
	if (b_I * b_ki) < -1 {set b_i to -1 / b_ki.}.  
	
	set s_command TO s_kp * s_P + s_ki * s_I + s_kd * s_D.
	set b_command TO b_kp * b_P + b_ki * b_I + b_kd * b_D.
	
	

//output
	if not(command_mode = 0) {
		set ship:control:pitch to c_command.
		set ship:control:roll to b_command.
		lock throttle to s_command.
	}.


 //wrapping up   
    SET t0 TO TIME:SECONDS.
    WAIT 0.1.
}