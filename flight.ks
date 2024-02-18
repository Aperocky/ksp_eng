PARAMETER ACTION, ARG_1 IS 0, ARG_2 IS "COCKPIT", ARG_3 IS "NONE".
IF PATH()="1:/" {
    RUNONCEPATH("BASE_LIB.KS").
    RUNONCEPATH("FLIGHT_LIB.KS").
} ELSE {
    RUNONCEPATH("LIB/BASE_LIB.KS").
    RUNONCEPATH("LIB/FLIGHT_LIB.KS").
}

LOCAL SCALAR TO 15000.
IF ARG_1:ISTYPE("SCALAR") {
    SET SCALAR TO ARG_1.
}
IF ACTION="WAYPOINT" {
    AUTOPILOT_TO_WAYPOINT(SCALAR).
} ELSE IF ACTION="TAKEOFF" {
    TAKEOFF(SCALAR).
} ELSE IF ACTION="LANDING" {
    LANDING().
} ELSE IF ACTION="GLIDE" {
    GLIDE_DOWN(SCALAR).
} ELSE IF ACTION="ACT" {
    LOCAL PART TO ARG_1.
    LOCAL ACT TO ARG_2.
    ACT_ON_PARTS(PART, ACT).
} ELSE IF ACTION="AUTO" {
    ACT_ON_PARTS("TURBO", "AFTERBURNER").
    TAKEOFF(5000).
    LOCAL CURR_WAYPOINT TO GET_SELECTED_WAYPOINT().
    UNTIL CURR_WAYPOINT="NONE" {
        AUTOPILOT_TO_WAYPOINT(SCALAR).
        ACT_ON_PARTS(ARG_2, "COLLECT_SCIENCE").
        WAIT 1.
        SET CURR_WAYPOINT TO GET_SELECTED_WAYPOINT().
    }
    LANDING(30).
} ELSE {
    PRINT "COMMAND NOT FOUND".
}
