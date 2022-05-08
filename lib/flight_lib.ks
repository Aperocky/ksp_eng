// IN flight lib mostly pertaining to intra-atmospheric flights on Kerbin.
// lib_navball from KSLib is inspiration to most of this file.

FUNCTION TO_UNIT_VECTOR {
    PARAMETER THING.
    IF THING:ISTYPE("VECTOR") {
        RETURN THING:NORMALIZED.
    } ELSE IF THING:ISTYPE("DIRECTION") {
        RETURN THING:FOREVECTOR.
    } ELSE IF THING:ISTYPE("VESSEL") OR THING:ISTYPE("PART") {
        RETURN THING:FACING:FOREVECTOR.
    } ELSE IF THING:ISTYPE("GEOPOSITION") OR THING:ISTYPE("WAYPOINT") {
        RETURN THING:POSITION:NORMALIZED.
    } ELSE {
        PRINT "TYPE: " + THING:TYPENAME + " IS NOT RECOGNIZED".
    }
}

FUNCTION COMPASS_FOR {
    PARAMETER VES IS SHIP.
    PARAMETER VEC IS "NONE".
    LOCAL POINTING TO VES:FACING:FOREVECTOR.
    IF NOT (VEC="NONE") {
        SET POINTING TO TO_UNIT_VECTOR(VEC).
    }
    LOCAL EAST TO VCRS(VES:UP:VECTOR, VES:NORTH:VECTOR).
    LOCAL TRIG_X TO VDOT(VES:NORTH:VECTOR, POINTING).
    LOCAL TRIG_Y TO VDOT(EAST, POINTING).

    LOCAL RESULT TO ARCTAN2(TRIG_Y, TRIG_X).
    IF RESULT < 0 {
        RETURN 360 + RESULT.
    } ELSE {
        RETURN RESULT.
    }
}

 FUNCTION PITCH_FOR {
    PARAMETER VES IS SHIP.
    PARAMETER VEC IS "NONE".
    LOCAL POINTING TO VES:FACING:FOREVECTOR.
    IF NOT (VEC="NONE") {
        SET POINTING TO TO_UNIT_VECTOR(VEC).
    }
    RETURN 90 - VANG(VES:UP:VECTOR, POINTING).
}

 FUNCTION ROLL_FOR {
    PARAMETER VES IS SHIP.
    LOCAL POINTING TO VES:FACING.
    LOCAL TRIG_X TO VDOT(POINTING:TOPVECTOR,VES:UP:VECTOR).
    IF ABS(TRIG_X) < 0.0035 {
        RETURN 0.
    } ELSE {
        LOCAL VEC_Y TO VCRS(VES:UP:VECTOR,VES:FACING:FOREVECTOR).
        LOCAL TRIG_Y TO VDOT(POINTING:TOPVECTOR,VEC_Y).
        RETURN ARCTAN2(TRIG_Y,TRIG_X).
    }
}

 FUNCTION GET_SELECTED_WAYPOINT {
    FOR WAYPOINT IN ALLWAYPOINTS() {
        IF WAYPOINT:ISSELECTED() {
            RETURN WAYPOINT.
        }
    }
    PRINT "NO WAYPOINT SELECTED".
    RETURN "NONE".
}

FUNCTION AUTODRIVE_TO_WAYPOINT {
    PARAMETER MAX_SPEED.
    BRAKES OFF.
    SET WAYPOINT TO GET_SELECTED_WAYPOINT().
    IF WAYPOINT="NONE" {
        RETURN.
    }
    CLEARSCREEN.
    SET TVAL TO 0.
    SET BEARING TO COMPASS_FOR(SHIP, WAYPOINT).
    LOCK THROTTLE TO TVAL.
    LOCK STEERING TO HEADING(BEARING, 0).
    UNTIL WAYPOINT:POSITION:MAG < 300 {
        SET BEARING TO COMPASS_FOR(SHIP, WAYPOINT).
        SET TVAL TO MAX(0, (MAX_SPEED - SHIP:GROUNDSPEED)/MAX_SPEED).
        PRINT "BEARING: " + ROUND(BEARING) + " DEGREES    " AT (5, 3).
        PRINT "DISTANCE: " + ROUND(WAYPOINT:POSITION:MAG()) + " METERS    " AT (5, 4).
        PRINT "SPEED: " + ROUND(SHIP:GROUNDSPEED*3.6) + " KPH    " AT (5, 5).
    }
    BRAKES ON.
}

FUNCTION AUTOPILOT_TO_WAYPOINT {
    PARAMETER HEIGHT.
    PARAMETER FULL_AUTO IS FALSE.
    SET WAYPOINT TO GET_SELECTED_WAYPOINT().
    IF WAYPOINT="NONE" {
        RETURN.
    }
    CLEARSCREEN.
    SAS OFF.
    UNLOCK STEERING.
    LOCAL BEARING TO COMPASS_FOR(SHIP, WAYPOINT).
    LOCAL PITCHPID TO PIDLOOP(0.01, 0.0001, 0.005, -1, 1).
    LOCAL ROLLPID TO PIDLOOP(0.002, 0.0001, 0.004, -1, 1).
    LOCAL TVAL TO 1.
    LOCK THROTTLE TO TVAL.
    LOCK MAP_DIST TO VXCL(SHIP:UP:VECTOR, WAYPOINT:POSITION):MAG.

    UNTIL MAP_DIST < 6500 {
        // FULL AUTO BLOCK
        LOCAL TVAL_SCALAR TO MIN(1, 900/(SHIP:GROUNDSPEED+1)).
        IF FULL_AUTO {
            IF MAP_DIST > 50000 {
                SET HEIGHT TO 18000.
            } ELSE {
                SET HEIGHT TO WAYPOINT:ALTITUDE.
            }        
        }
        // END FULLAUTO BLOCK.
        LOCAL COMPASS TO COMPASS_FOR().
        LOCAL DIRECTION TO COMPASS_FOR(SHIP, WAYPOINT).
        LOCAL PITCH TO PITCH_FOR().
        LOCAL ROLL TO ROLL_FOR().
        LOCAL PITCH_AIM TO MAX(-10, MIN((HEIGHT - SHIP:ALTITUDE)/100, 15)).
        LOCAL ANGDIFF TO DIRECTION - COMPASS.
        IF ABS(DIRECTION - COMPASS) > 180 {
            IF DIRECTION > COMPASS {
                SET ANGDIFF TO ANGDIFF - 360.
            } ELSE {
                SET ANGDIFF TO ANGDIFF + 360.
            }
        }
        LOCAL ROLL_AIM TO MAX(-60, MIN(ANGDIFF*2, 60)).
        SET TVAL TO MAX(0, (1 - ABS(ROLL_AIM/2)*SHIP:GROUNDSPEED*0.00005) * TVAL_SCALAR).
        SET PITCHPID:SETPOINT TO PITCH_AIM.
        SET ROLLPID:SETPOINT TO ROLL_AIM.
        SET SHIP:CONTROL:PITCH TO PITCHPID:UPDATE(TIME:SECONDS, PITCH).
        SET SHIP:CONTROL:ROLL TO ROLLPID:UPDATE(TIME:SECONDS, ROLL).
        SET SHIP:CONTROL:YAW TO 0.
        PRINT "PITCH: " + ROUND(PITCH) + " DEGREES     " AT (5, 2).
        PRINT "ROLL: " + ROUND(ROLL) + " DEGREES     " AT (5, 3).
        PRINT "DISTANCE: " + ROUND(MAP_DIST/1000) + " KM    " AT (5, 4).
        PRINT "SPEED: " + ROUND(SHIP:GROUNDSPEED*3.6) + " KPH    " AT (5, 5).
        IF ABS(COMPASS - DIRECTION) < 10 {
            PRINT "ETA: " + ROUND(MAP_DIST/SHIP:GROUNDSPEED) + " SECONDS    " AT (5, 6).
        }
    }
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    UNLOCK THROTTLE.
    SAS ON.
}

FUNCTION TAKEOFF {
    PARAMETER TARGET_ALT IS 1000.
    SAS OFF.
    BRAKES OFF.
    GEAR ON.
    LOCAL CURR_PITCH TO PITCH_FOR().
    STAGE.
    LOCAL TVAL TO 1.
    LOCAL DIR TO HEADING(90, PITCH_FOR).
    LOCK THROTTLE TO TVAL.
    LOCK STEERING TO DIR.
    WAIT UNTIL SHIP:GROUNDSPEED > 35.
    SET DIR TO HEADING(90, CURR_PITCH + 10).
    WAIT UNTIL ALT:RADAR > 20.
    SET DIR TO HEADING(90, 30).
    GEAR OFF.
    WAIT UNTIL SHIP:ALTITUDE > TARGET_ALT.
    SET DIR TO HEADING(90, 10).
    WAIT 5.
    SAS ON.
}

FUNCTION LANDING {
    PARAMETER LANDING_SPEED IS 30.
    WAIT 1.
    UNLOCK STEERING.
    SAS OFF.
    CLEARSCREEN.
    LOCAL PALOOP TO PIDLOOP(0.5, 0, 0.2, -8, 30).
    LOCAL PLOOP TO PIDLOOP(0.05, 0.001, 0.02, -1, 1).
    LOCAL RLOOP TO PIDLOOP(0.002, 0.001, 0.01, -1, 1).
    SET THROTTLE TO 0.
    WHEN ALT:RADAR < 200 THEN {
        GEAR ON.
    }
    UNTIL ALT:RADAR < 2 {
        LOCAL TARGET_ALT_MIN TO (SHIP:GROUNDSPEED - LANDING_SPEED) * 4 - 10.
        IF TARGET_ALT_MIN < 10 {
            SET TARGET_ALT_MIN TO (SHIP:GROUNDSPEED - LANDING_SPEED) * 2.
        }
        LOCAL TARGET_ALT TO MIN(300, TARGET_ALT_MIN).
        SET PALOOP:SETPOINT TO TARGET_ALT.
        LOCAL TARGET_PITCH TO PALOOP:UPDATE(TIME:SECONDS, ALT:RADAR).
        SET PLOOP:SETPOINT TO TARGET_PITCH.
        LOCAL PITCH TO PITCH_FOR().
        LOCAL ROLL TO ROLL_FOR().
        SET SHIP:CONTROL:PITCH TO PLOOP:UPDATE(TIME:SECONDS, PITCH).
        SET SHIP:CONTROL:ROLL TO RLOOP:UPDATE(TIME:SECONDS, ROLL).
        SET SHIP:CONTROL:YAW TO 0.
        PRINT "ALT: " + ROUND(ALT:RADAR) + " METERS     " AT (5, 2).
        PRINT "SPEED: " + ROUND(SHIP:GROUNDSPEED*3.6) + " KPH    " AT (5, 3).
    }
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    WAIT 3.
    BRAKES ON.
}
