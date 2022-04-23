// This is a sub-orbital touring vessel
RUNONCEPATH("LIB/BASE_LIB.KS").
CLEARSCREEN.

SET RUNMODE TO 1.
SET TVAL TO GET_THROTTLE(25).
SET SVAL TO UP.
LOCK THROTTLE TO TVAL.
LOCK STEERING TO SVAL.

// LAUNCH!
STAGE.
UNTIL RUNMODE=0 {

    IF RUNMODE=1 {
        SET SVAL TO UP.
        SET TVAL TO GET_THROTTLE(25).
        IF SHIP:ALTITUDE > 1000 {
            SET RUNMODE TO 2.
        }
    }

    ELSE IF RUNMODE=2 {
        SET SVAL TO HEADING(90,65).
        SET TVAL TO 1.
        IF SHIP:APOAPSIS > 75000 {
            SET TVAL TO 0.
            SET RUNMODE TO 3.
        }
    }

    ELSE IF RUNMODE=3 {
        UNLOCK STEERING.
        SET WARP TO 3.
        IF SHIP:ALTITUDE > 70000 {
            SET WARP TO 0.
            WAIT 1.
            STAGE.
            WAIT 1.
            SET RUNMODE TO 4.
        }
    }

    ELSE IF RUNMODE=4 {
        SET WARP TO 2.
        IF SHIP:ALTITUDE < 70000 {
            SET RUNMODE TO 0.
        }
    }

    ELSE {
        SET RUNMODE TO 0.
    }

    SET RUNSTR TO "RUNMODE: " + RUNMODE.
    PRINT_PARAMS(RUNSTR).
    WAIT 0.
}

CLEARSCREEN.
PRINT "EXECUTING DESCENT".
PARACHUTE_LANDING().
