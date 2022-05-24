PARAMETER ACTION, ARG_1 IS "NONE", ARG_2 IS "NONE", ARG_3 IS "NONE".
RUNONCEPATH("LIB/BASE_LIB.KS").
RUNONCEPATH("LIB/SPACE_LIB.KS").
RUNONCEPATH("LIB/NODE_LIB.KS").

CLEARSCREEN.
IF ACTION="CIRC" {
    LOCAL IS_AP TO TRUE.
    IF ARG_1="PE" { SET IS_AP TO FALSE. }
    CIRCULARIZE_NODE(IS_AP).
    NODE_EXEC().
} ELSE IF ACTION="DEORBIT" {
    LOCAL DROGUE TO ARG_1="DROGUE".
    DEORBIT_KERBIN().
    SET WARP TO 4.
    WAIT UNTIL SHIP:ALTITUDE < 70000.
    PARACHUTE_LANDING(DROGUE).
} ELSE IF ACTION="PARACHUTE" {
    LOCAL DROGUE TO ARG_1="DROGUE".
    PARACHUTE_LANDING(DROGUE).
} ELSE IF ACTION="SUICIDE_BURN" {
    LOCAL SAFE_HEIGHT TO 5.
    IF ARG_1<>"NONE" {
        SET SAFE_HEIGHT TO ARG_1.
    }
    SUICIDE_BURN_AND_LAND(SAFE_HEIGHT).
} ELSE IF ACTION="LKO" {
    LOCAL BRK TO CHOOSE "NONE" IF ARG_1="NONE" ELSE ARG_1.
    LOCAL ALT TO CHOOSE 85000 IF ARG_2="NONE" ELSE ARG_2.
    RUN LKO_TOUR(BRK, ALT).
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
    LOCAL ALLOW_STAGE TO ARG_1="NONE".
    NODE_EXEC(ALLOW_STAGE).
} ELSE IF ACTION="NEXT_ORBIT" {
    NEXT_ORBIT().
} ELSE IF ACTION="INC" {
    GET_INCLINATION().
} ELSE IF ACTION="MATCH_INC" {
    MATCH_INCLINATION().
} ELSE IF ACTION="PARTS" {
    PRINT GET_PARTS(ARG_1).
} ELSE IF ACTION="PHASE" {
    LOCAL TARGET_PHASE_ANGLE TO GET_PHASE_ANGLE().
    PRINT "PHASE ANGLE OF TARGET: " + ROUND(TARGET_PHASE_ANGLE, 1) + " DEG".
} ELSE IF ACTION="APPROACH" {
    APPROACH().
} ELSE IF ACTION="MUN_ORBIT_TRANSFER" {
    SET TARGET TO MUN.
    IF ARG_1="NONE" {
        PRINT "NEED PHASE ARGUMENT".
    } ELSE {
        LOCAL ANGDIFF TO ARG_1.
        HOHMANN_TRANSFER_TARGET(ANGDIFF).
        NODE_EXEC(FALSE).
        NEXT_ORBIT().
        WAIT 2.
        CIRCULARIZE_NODE(FALSE).
        NODE_EXEC(FALSE).
    }
} ELSE IF ACTION="TEST" {
    LOCAL PARTS TO GET_PARTS(ARG_1).
    PRINT PARTS[0]:MODE.
} ELSE {
    PRINT "ACTION NOT RECOGNIZED".
}