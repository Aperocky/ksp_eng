PARAMETER ACTION, ARG_1 IS "NONE", ARG_2 IS "NONE", ARG_3 IS "NONE".
RUNONCEPATH("LIB/BASE_LIB.KS").
RUNONCEPATH("LIB/SPACE_LIB.KS").
RUNONCEPATH("LIB/NODE_LIB.KS").

CLEARSCREEN.
IF ACTION="CIRC" {
    LOCAL IS_AP TO TRUE.
    IF ARG_1="PE" { SET IS_AP TO FALSE. }
    CIRCULARIZE_NODE(IS_AP).
    IF ARG_2="RUN" {
        NODE_EXEC().
    }
} ELSE IF ACTION="CIRC_RAW" {
    CIRCULARIZE().
} ELSE IF ACTION="DISPLAY" {
    DISPLAY_STATS().
} ELSE IF ACTION="DEORBIT" {
    DEORBIT_KSC_NODE().
    NODE_EXEC().
    SET WARP TO 4.
    WAIT UNTIL SHIP:ALTITUDE < 70000.
    WAIT 1.
    ACT_ON_PARTS("SEPARATOR", "DECOUPLE").
    ACT_ON_PARTS("DECOUPLER", "DECOUPLE").
    WAIT 1.
    LOCAL SERVICE_BAY TO CHOOSE TRUE IF ARG_1="NONE" ELSE ARG_1.
    LOCAL PARACHUTE TO CHOOSE TRUE IF ARG_2="NONE" ELSE ARG_2.
    PARACHUTE_LANDING(SERVICE_BAY, PARACHUTE).
} ELSE IF ACTION="DEORBIT_OLD" {
    DEORBIT_KERBIN().
    SET WARP TO 4.
    WAIT UNTIL SHIP:ALTITUDE < 70000.
    WAIT 1.
    ACT_ON_PARTS("SEPARATOR", "DECOUPLE").
    ACT_ON_PARTS("DECOUPLER", "DECOUPLE").
    WAIT 1.
    LOCAL SERVICE_BAY TO CHOOSE TRUE IF ARG_1="NONE" ELSE ARG_1.
    LOCAL PARACHUTE TO CHOOSE TRUE IF ARG_2="NONE" ELSE ARG_2.
    PARACHUTE_LANDING(SERVICE_BAY, PARACHUTE).
} ELSE IF ACTION="SKIP_ATM" {
    ATMOSPHERIC_SKIP().
} ELSE IF ACTION="SET_PERIAPSIS" {
    ADJUST_PERIAPSIS(ARG_1).
    IF ARG_2="RUN" {
        NODE_EXEC().
    }
} ELSE IF ACTION="SET_APOAPSIS" {
    ADJUST_APOAPSIS(ARG_1).
    IF ARG_2="RUN" {
        NODE_EXEC().
    }
} ELSE IF ACTION="PARACHUTE" {
    LOCAL USE_SERVICE_BAY TO CHOOSE TRUE IF ARG_1="NONE" ELSE ARG_1.
    LOCAL PARACHUTE TO CHOOSE TRUE IF ARG_2="NONE" ELSE ARG_2.
    PARACHUTE_LANDING(USE_SERVICE_BAY, PARACHUTE).
} ELSE IF ACTION="SUICIDE_BURN" {
    SUICIDE_BURN_AND_LAND().
} ELSE IF ACTION="SUBORBIT" {
    RUNPATH("ORBITS/SUBORBITAL.KS").
} ELSE IF ACTION="LKO" {
    LOCAL BRK_PARAM TO CHOOSE "NONE" IF ARG_1="NONE" ELSE ARG_1.
    LOCAL ALT_PARAM TO CHOOSE 85000 IF ARG_2="NONE" ELSE ARG_2.
    LOCAL STAGE_WHEN_ORBIT TO CHOOSE FALSE IF ARG_3="NONE" ELSE ARG_3.
    RUNPATH("ORBITS/LKO.KS", BRK_PARAM, ALT_PARAM, STAGE_WHEN_ORBIT).
} ELSE IF ACTION="LAUNCH_NOATM" {
    LAUNCH_NO_ATMOSPHERE().
} ELSE IF ACTION="HOHMANN" {
    HOHMANN_TRANSFER(ARG_1, ARG_2).
    NODE_EXEC().
    IF SHIP:ALTITUDE > ARG_1 {
        CIRCULARIZE_NODE(FALSE).
    } ELSE {
        CIRCULARIZE_NODE().
    }
    NODE_EXEC().
} ELSE IF ACTION="HOHMANN_TARGET" {
    LOCAL ANGDIFF TO 0.
    IF ARG_1<>"NONE" {
        SET ANGDIFF TO ARG_1.
    }
    HOHMANN_TRANSFER_TARGET(ANGDIFF).
    IF ARG_2="RUN" {
        NODE_EXEC().
        IF SHIP:ALTITUDE > TARGET:ALTITUDE {
            CIRCULARIZE_NODE(FALSE).
        } ELSE {
            CIRCULARIZE_NODE().
        }
        NODE_EXEC().
        SYNC_ORBIT_PERIOD().
    }
} ELSE IF ACTION="SYNC" {
    SYNC_ORBIT_PERIOD().
} ELSE IF ACTION="NODE" {
    LOCAL ALLOW_STAGE TO CHOOSE TRUE IF ARG_1="NONE" ELSE ARG_1.
    NODE_EXEC(ALLOW_STAGE).
} ELSE IF ACTION="NEXT_ORBIT" {
    NEXT_ORBIT().
} ELSE IF ACTION="GET_INC" {
    GET_INCLINATION().
} ELSE IF ACTION="MATCH_INC" {
    MATCH_INCLINATION().
    IF ARG_1="RUN" {
        NODE_EXEC().
    }
} ELSE IF ACTION="PARTS" {
    PRINT GET_PARTS(ARG_1).
} ELSE IF ACTION="PARTS_ACT" {
    ACT_ON_PARTS(ARG_1, ARG_2).
} ELSE IF ACTION="SCIENCE" {
    COLLECT_SCIENCE().
} ELSE IF ACTION="PHASE" {
    LOCAL TARGET_PHASE_ANGLE TO GET_PHASE_ANGLE().
    PRINT "PHASE ANGLE OF TARGET: " + ROUND(TARGET_PHASE_ANGLE, 1) + " DEG".
} ELSE IF ACTION="APPROACH" {
    APPROACH().
} ELSE IF ACTION="LOW_KERBIN_RESCUE" {
    MATCH_INCLINATION().
    NODE_EXEC().
    ADJUST_APOAPSIS(200000).
    NODE_EXEC().
    CIRCULARIZE_NODE().
    NODE_EXEC().
    HOHMANN_TRANSFER_TARGET().
    NODE_EXEC().
    APPROACH().
} ELSE IF ACTION="MUN_ORBIT_TRANSFER" {
    SET TARGET TO MUN.
    IF ARG_1="NONE" {
        PRINT "NEED PHASE ARGUMENT".
    } ELSE {
        LOCAL ANGDIFF TO ARG_1.
        HOHMANN_TRANSFER_TARGET(ANGDIFF).
        NODE_EXEC().
        NEXT_ORBIT().
        WAIT 2.
        CIRCULARIZE_NODE(FALSE).
        NODE_EXEC().
    }
} ELSE IF ACTION="MINMUS_ORBIT_TRANSFER" {
    // BEWARE OF MUN! IT MIGHT SIT IN MIDDLE AND DISRUPT YOUR PLANS.
    // THIS COMMAND DOES NOT EXECUTE A FULL TRANSFER AS IT TAKES TOO LONG
    // IT MERELY PUTS THE VESSEL ON THE TRANSFER.
    SET TARGET TO MINMUS.
    MATCH_INCLINATION().
    NODE_EXEC().
    CIRCULARIZE_NODE().
    NODE_EXEC().
    HOHMANN_TRANSFER_TARGET(4).
    NODE_EXEC().
} ELSE IF ACTION="GET_HEIGHT" {
    GET_VESSEL_HEIGHT().
} ELSE IF ACTION="TEST" {
    LOCAL PARTS TO GET_PARTS(ARG_1).
    PRINT PARTS[0]:ALLMODULES.
} ELSE {
    PRINT "ACTION NOT RECOGNIZED".
}
