FUNCTION GET_THROTTLE {
    PARAMETER DESIRED_ACC IS 20.
    LOCAL MAX_ACC TO SHIP:MAXTHRUST/SHIP:MASS+0.01.
    RETURN MIN(1, DESIRED_ACC/MAX_ACC).
}

FUNCTION PRINT_PARAMS {
    PARAMETER OPTIONAL_ONE IS "".
    PRINT "ALTITUDE:   " + ROUND(SHIP:ALTITUDE) + "  METERS    " AT (5,2).
    PRINT "APOAPSIS:   " + ROUND(SHIP:APOAPSIS) + "  METERS    " AT (5,3).
    PRINT "PERIAPSIS:  " + ROUND(SHIP:PERIAPSIS) + "  METERS    " AT (5,4).
    PRINT "CLIMB RATE: " + ROUND(SHIP:VERTICALSPEED) + "  M/S" AT (5,5).
    PRINT "GRND SPEED: " + ROUND(SHIP:GROUNDSPEED*3.6) + "  KPH" AT (5,6).
    PRINT OPTIONAL_ONE AT (5, 7).
}

FUNCTION DEORBIT_KERBIN {
    LOCK STEERING TO RETROGRADE.
    WAIT UNTIL VANG(RETROGRADE:VECTOR, SHIP:FACING:VECTOR) < 0.25.
    SET THROTTLE TO 1.
    WAIT UNTIL SHIP:PERIAPSIS < 0.
    SET THROTTLE TO 0.
    UNLOCK STEERING.
}

FUNCTION PARACHUTE_LANDING {
    PARAMETER DROGUE IS TRUE.

    SAS OFF.
    LOCK STEERING TO RETROGRADE.
    WAIT 1.
    LOCAL RUNMODE TO 10.
    SET WARP TO 3.
    CLEARSCREEN.

    UNTIL RUNMODE=0 {

        IF RUNMODE=10 {
            IF SHIP:ALTITUDE < 35000 {
                SET WARP TO 0.
                ACT_ON_PARTS("SERVICE.BAY", "OPEN").
                SET RUNMODE TO 11.
            }
        }

        ELSE IF RUNMODE=11 {
            IF ALT:RADAR < 5000 AND DROGUE {
                STAGE.
                SET RUNMODE TO 12.
            }
            IF ALT:RADAR < 2000 {
                STAGE.
                SET RUNMODE TO 13.
            }
        }

        ELSE IF RUNMODE=12 {
            IF ALT:RADAR < 2000 {
                STAGE.
                SET RUNMODE TO 13.
            }
        }

        ELSE IF RUNMODE=13 {
            IF ABS(SHIP:VERTICALSPEED) < 10 {
                SET WARP TO 3.
                SET RUNMODE TO 14.
            }
        }

        ELSE IF RUNMODE=14 {
            IF ALT:RADAR < 20 {
                SET WARP TO 0.
                SET RUNMODE TO 0.
            }
        }

        PRINT "ALTITUDE:   " + ROUND(ALT:RADAR) + " METERS    " AT (5,2).
        PRINT "SINK RATE:   " + ROUND(-SHIP:VERTICALSPEED) + " M/S    " AT (5,3).
        PRINT "GRND SPEED:  " + ROUND(SHIP:GROUNDSPEED*3.6) + " KMH    " AT (5,4).
        PRINT "RUNMODE:  " + RUNMODE AT (5,6).
        WAIT 0.
    }
    WAIT 5.
    CLEARSCREEN.
}

// GRAVITY TURN PITCH
FUNCTION GET_PITCH_KERBIN {
    PARAMETER AGGRO IS 15.
    PARAMETER END_INCLINATION IS 15.
    LOCAL END_ALT TO ((90 + AGGRO - END_INCLINATION)/AGGRO) ^ 2 * 1000.
    IF SHIP:ALTITUDE < 1000 {
        RETURN 90.
    }
    IF SHIP:ALTITUDE < END_ALT {
        RETURN 90 + AGGRO - SQRT(SHIP:ALTITUDE/1000) * AGGRO.
    }
    RETURN END_INCLINATION.
}

FUNCTION CIRCULARIZE {
    // USE RAW CIRCULARIZATION TECHNIQUE BY KEEPING APOAPSIS CLOSE
    // ONLY USE ON ASCENT!
    // SKID TO APOAPSIS
    PARAMETER ERR_ECC IS 100.
    WARP_TO_TIME(ETA:APOAPSIS - 10).

    LOCAL PITCH TO 0.
    LOCAL VVDIFF TO 0.
    LOCAL ST TO PROGRADE.
    LOCAL TV TO 0.
    LOCK STEERING TO ST.
    LOCK THROTTLE TO TV.

    WAIT ETA:APOAPSIS.

    UNTIL (SHIP:ALTITUDE - SHIP:PERIAPSIS) < ERR_ECC {
        IF STAGE:LIQUIDFUEL < 1 {
            STAGE. WAIT 0.
        }
        SET PITCH TO MIN(30, MAX(0, ORBIT:PERIOD - ETA:APOAPSIS)).
        SET ST TO PROGRADE + R(0, PITCH, 0).
        SET TV TO MIN((SHIP:APOAPSIS - SHIP:PERIAPSIS)/SHIP:APOAPSIS + 0.01, 1).
        PRINT_PARAMS().
        WAIT 0.
    }
    UNLOCK STEERING.
    UNLOCK THROTTLE.
}

FUNCTION APPROACH {
    // APPROACH TARGET AND PARK NEXT TO IT.
    IF NOT HASTARGET {
        PRINT("NO TARGET").
        RETURN.
    }

    SAS OFF.
    CLEARSCREEN.
    LOCAL TVAL TO 0.
    LOCAL SVAL TO SHIP:FACING:FOREVECTOR.
    LOCAL TARGET_DIRECTION TO TARGET:POSITION:NORMALIZED.
    LOCAL TARGET_RUNMODE TO 20.
    LOCAL TARGET_REL_SPEED TO 0.
    LOCAL RUNMODE TO 20.
    LOCK THROTTLE TO TVAL.
    LOCK STEERING TO SVAL.
    UNTIL RUNMODE=0 {

        LOCAL VEL TO SHIP:VELOCITY:ORBIT - TARGET:VELOCITY:ORBIT.
        LOCAL VEL_P TO VXCL(TARGET:POSITION:NORMALIZED, VEL).
        LOCAL VEL_ANG TO VANG(TARGET:POSITION, VEL).
        LOCAL REL_T TO TARGET:POSITION:MAG / VEL:MAG.
        LOCAL DIST TO TARGET:POSITION:MAG.
        LOCAL PARK_DIST TO DIST * SIN(VEL_ANG).
        LOCAL MAX_ACC TO SHIP:MAXTHRUST/SHIP:MASS.

        IF RUNMODE=20 {
            // MOVE TO APPROPRIATE RUNMODES.
            IF DIST > 10000 {
                SET RUNMODE TO 20.
            } ELSE IF DIST > 1000 { // COAST PHASE.
                SET RUNMODE TO 21.
            } ELSE { // PARK PHASE
                SET RUNMODE TO 22.
            }
        }

        ELSE IF RUNMODE=21 {
            IF VEL_ANG > 5 {
                SET TARGET_DIRECTION TO -VEL_P.
                SET TARGET_RUNMODE TO 26.
                SET RUNMODE TO 25.
            } ELSE IF VEL:MAG > DIST/25 {
                SET TARGET_DIRECTION TO -VEL.
                SET TARGET_REL_SPEED TO MAX(30, DIST/100).
                SET TARGET_RUNMODE TO 27.
                SET RUNMODE TO 25.
            } ELSE IF VEL:MAG < 20 {
                SET TARGET_DIRECTION TO TARGET:POSITION:NORMALIZED.
                SET TARGET_REL_SPEED TO MIN(30, DIST/100).
                SET TARGET_RUNMODE TO 27.
                SET RUNMODE TO 25.
            } ELSE IF VEL:MAG < DIST/200 {
                SET TARGET_DIRECTION TO TARGET:POSITION:NORMALIZED.
                SET TARGET_REL_SPEED TO MIN(DIST/100, 80).
                SET TARGET_RUNMODE TO 27.
                SET RUNMODE TO 25.
            } ELSE IF DIST < 1000 {
                SET RUNMODE TO 22.
            }
        }

        ELSE IF RUNMODE=22 {
            SET SVAL TO -VEL.
            LOCAL REST_DIST TO DIST * COS(VEL_ANG).
            LOCAL SKID_DIST TO 0.5 * MAX_ACC * (VEL:MAG/MAX_ACC)^2.
            IF VEL:MAG < 1 {
                SET RUNMODE TO 0.
            }
            IF REST_DIST < SKID_DIST+VEL:MAG {
                SET RUNMODE TO 28.
            }
        }

        ELSE IF RUNMODE=25 {
            // ALIGN TO DIRECTION
            SET SVAL TO TARGET_DIRECTION.
            IF VANG(SHIP:FACING:FOREVECTOR, TARGET_DIRECTION) < 3 {
                SET RUNMODE TO TARGET_RUNMODE.
            }
        }

        ELSE IF RUNMODE=26 {
            // REMOVE SIDE VELOCITY.
            SET SVAL TO -VEL_P.
            SET TVAL TO MIN(VEL_P:MAG/MAX_ACC, 1).
            IF VANG(SHIP:FACING:FOREVECTOR, -VEL_P) > 20 OR VEL_P:MAG < 0.5 {
                SET TVAL TO 0.
                SET RUNMODE TO 20.
            }
        }

        ELSE IF RUNMODE=27 {
            // RELATIVE SPEED TWEAKING
            SET SVAL TO TARGET_DIRECTION.
            LOCAL DIFFV TO ABS(TARGET_REL_SPEED - VEL:MAG).
            SET TVAL TO MIN(DIFFV/MAX_ACC, 1).
            IF VEL_ANG > 20 OR DIFFV < 0.2 {
                SET TVAL TO 0.
                SET RUNMODE TO 20.
            }
        }

        ELSE IF RUNMODE=28 {
            // KILL SPEED
            SET SVAL TO -VEL.
            SET TVAL TO MIN(VEL:MAG/MAX_ACC, 1).
            IF VANG(SHIP:FACING:FOREVECTOR, -VEL) > 10 {
                SET TVAL TO 0.
            }
            IF VEL:MAG < 0.2 {
                SET RUNMODE TO 0.
            }
        }

        PRINT "TARGET DISTANCE:   " + ROUND(DIST) + " METERS    " AT (5,2).
        PRINT "RELATIVE VELOCITY:   " + ROUND(VEL:MAG) + " M/S    " AT (5,3).
        PRINT "VELOCITY ANGLE:   " + ROUND(VEL_ANG, 1) + " DEGREES    " AT (5,4).
        PRINT "ENCOUNTER DISTANCE:   " + ROUND(PARK_DIST) + " METERS    " AT (5,5).
        PRINT "RAW ETA:  " + ROUND(REL_T) + " SECONDS    " AT (5,6).
        PRINT "RUNMODE:  " + RUNMODE AT (5,7).
        WAIT 0.
    }
    UNLOCK STEERING.
    UNLOCK THROTTLE.
    SAS ON.
}

FUNCTION SUICIDE_BURN_AND_LAND {
    PARAMETER SAFE_HEIGHT IS 5.
    SAS OFF.
    LOCAL RUNMODE TO 30.
    LOCAL SVAL TO -SHIP:VELOCITY:SURFACE.
    LOCAL TVAL TO 0.
    LOCK STEERING TO SVAL.
    LOCK THROTTLE TO TVAL.

    LOCAL G_FORCE TO SHIP:BODY:MU/(SHIP:BODY:RADIUS)^2.
    LOCAL PID_LAND TO PIDLOOP(0.01, 0, 0.01, -0.2, 0.2).
    LOCAL LAND_TIMER TO 0.
    CLEARSCREEN.
    UNTIL RUNMODE=0 {

        LOCAL V_VECTOR TO SHIP:VELOCITY:SURFACE.
        LOCAL U_VECTOR TO SHIP:UP:VECTOR.
        LOCAL H_VECTOR TO VXCL(U_VECTOR, V_VECTOR).
        LOCAL MAX_ACC TO SHIP:MAXTHRUST/SHIP:MASS.
        LOCAL HEADING_ANOMALY TO VANG(SHIP:FACING:FOREVECTOR, SVAL).

        IF RUNMODE=30 {
            // DO NOTHING YET
            IF SHIP:VERTICALSPEED < 0 AND (-ALT:RADAR/SHIP:VERTICALSPEED < 100 OR ALT:RADAR < 5000) {
                SET RUNMODE TO 31.
            }
        }

        IF RUNMODE=31 {
            // WAIT UNTIL SUICIDE BURN.
            SET SVAL TO -SHIP:VELOCITY:SURFACE.
            LOCAL SPEED TO SHIP:VELOCITY:SURFACE:MAG.
            LOCAL EBT TO SPEED/(MAX_ACC - G_FORCE).
            LOCAL BURN_ALT TO 0.5 * (MAX_ACC - G_FORCE) * EBT^2.
            IF ALT:RADAR - BURN_ALT < 10 {
                SET RUNMODE TO 32.
            }
        }

        IF RUNMODE=32 {
            // DYNAMIC SUICIDE BURN!
            SET SVAL TO -SHIP:VELOCITY:SURFACE.
            LOCAL EBT TO SHIP:VELOCITY:SURFACE:MAG/(MAX_ACC - G_FORCE).
            LOCAL BURN_ALT TO 0.5 * (MAX_ACC - G_FORCE) * EBT^2.
            LOCAL DYNAMIC_FACTOR TO (BURN_ALT + SAFE_HEIGHT*2)/ALT:RADAR.
            SET TVAL TO MIN(1, DYNAMIC_FACTOR).
            IF SHIP:VERTICALSPEED > -0.5 {
                SET RUNMODE TO 33.
            }
        }

        IF RUNMODE=33 {
            // HOVER TO KILL HORIZONTAL SPEED.
            GEAR ON.
            LOCAL H_ADJUST TO -H_VECTOR:NORMALIZED * MIN(0.1, 0.1 * H_VECTOR:MAG).
            SET SVAL TO SHIP:UP:VECTOR + H_ADJUST.
            SET PID_LAND:SETPOINT TO -2.
            LOCAL THRUST_ADJUST TO PID_LAND:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).
            LOCAL CURR_G TO SHIP:BODY:MU/(SHIP:ALTITUDE + SHIP:BODY:RADIUS)^2.
            SET TVAL TO MAX(0, MIN(1, GET_THROTTLE(CURR_G) + THRUST_ADJUST)).
            IF ALT:RADAR < SAFE_HEIGHT {
                SET LAND_TIMER TO TIME:SECONDS.
                SET TVAL TO GET_THROTTLE(CURR_G - 0.2).
                SET RUNMODE TO 34.
            }
        }

        IF RUNMODE=34 {
            SET SVAL TO SHIP:UP:VECTOR.
            IF TIME:SECONDS - LAND_TIMER > SAFE_HEIGHT/4 {
                SET TVAL TO 0.
                SET RUNMODE TO 0.
            }
        }

        PRINT "ALTITUDE: " + ROUND(ALT:RADAR) + " METERS    " AT (5,2).
        PRINT "SINK_RATE: " + ROUND(-SHIP:VERTICALSPEED, 2) + " M/S    " AT (5,3).
        PRINT "H_VEL: " + ROUND(H_VECTOR:MAG, 2) + " M/S    " AT (5,4).
        PRINT "THRUST:  " + ROUND(TVAL, 3) + " THROTTLE    " AT (5,5).
        PRINT "HEADING ANOMALY: " + ROUND(HEADING_ANOMALY, 1) + " DEGS    " AT (5,6).
        PRINT "RUNMODE:  " + RUNMODE AT (5,7).
    }
}

FUNCTION SYNC_ORBIT_PERIOD {
    SAS OFF.
    IF NOT(HASTARGET) {
        PRINT("NO TARGET").
        RETURN.
    }

    LOCAL LOCK SOP TO SHIP:ORBIT:PERIOD.
    LOCAL LOCK TOP TO TARGET:ORBIT:PERIOD.
    PRINT "CURRENT ORBIT PERIOD IS " + ROUND(SOP, 2) + " SECONDS".
    PRINT "SYNCING ORBIT PERIOD TO " + ROUND(TOP, 2) + " SECONDS".
    LOCAL SIGN TO TRUE.
    IF SOP > TOP {
        LOCK STEERING TO RETROGRADE.
        WAIT UNTIL VANG(SHIP:FACING:VECTOR, RETROGRADE:VECTOR) < 0.25.
    } ELSE {
        LOCK STEERING TO PROGRADE.
        SET SIGN TO FALSE.
        WAIT UNTIL VANG(SHIP:FACING:VECTOR, PROGRADE:VECTOR) < 0.25.
    }
    LOCAL TVAL TO 0.
    LOCK THROTTLE TO TVAL.

    IF SIGN {
        UNTIL SOP - TOP < 0.1 {
            SET TVAL TO ABS(SOP - TOP)/SOP * GET_THROTTLE(30).
        }
    } ELSE {
        UNTIL TOP - SOP < 0.1 {
            SET TVAL TO ABS(SOP - TOP)/TOP * GET_THROTTLE(30).
        }
    }
    SET TVAL TO 0.
    PRINT "ADJUSTED ORBIT PERIOD IS " + ROUND(SOP, 2) + " SECONDS".
    UNLOCK THROTTLE.
    UNLOCK STEERING.
    SAS ON.
}

FUNCTION NEXT_ORBIT {
    IF SHIP:ORBIT:HASNEXTPATCH {
        WARP_TO_TIME(SHIP:ORBIT:NEXTPATCHETA).
    }
}