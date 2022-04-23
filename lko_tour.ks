// This is an orbital touring vessel
RUNONCEPATH("LIB.KS").
CLEARSCREEN.

SET RUNMODE TO 1.
SET TVAL TO 0.
SET SVAL TO HEADING(90, 90, -90).
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.

STAGE.
UNTIL RUNMODE=0 {

    SET PITCH TO GET_PITCH_KERBIN().
    IF STAGE:LIQUIDFUEL < 1 AND RUNMODE > 1 {
        STAGE. WAIT 0.
    }

    IF RUNMODE=1 {
        SET SVAL TO HEADING(90, PITCH, -90).
        IF STAGE:SOLIDFUEL < 1 {
            STAGE. WAIT 0.
            SET RUNMODE TO 2.
        }
    }

    ELSE IF RUNMODE=2 {
        SET TVAL TO GET_THROTTLE(30).
        SET SVAL TO HEADING(90, PITCH).
        IF SHIP:APOAPSIS > 85000 {
            SET RUNMODE TO 3.
        }
    }

    ELSE IF RUNMODE=3 {
        SET TVAL TO 0.
        SET WARP TO 3.
        IF SHIP:ALTITUDE > 70000 {
            SET WARP TO 0.
            WAIT 1.
            SET RUNMODE TO 4.
        }
    }

    ELSE IF RUNMODE=4 {
        CIRCULARIZE().
        SET RUNMODE TO 5.
    }

    ELSE IF RUNMODE = 5 {
        DEORBIT_KERBIN().
        WAIT 3.
        SET WARP TO 3.
        IF SHIP:ALTITUDE < 70000 {
            STAGE. WAIT 1.
            SET RUNMODE TO 0.
        }
    }

    SET RUNSTR TO "RUNMODE: " + RUNMODE.
    PRINT_PARAMS(RUNSTR).
    WAIT 0.
}

CLEARSCREEN.
PARACHUTE_LANDING().
