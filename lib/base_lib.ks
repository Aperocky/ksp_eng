FUNCTION GET_PARTS {
    PARAMETER PART_NAME.
    RETURN SHIP:PARTSDUBBEDPATTERN(PART_NAME).
}

FUNCTION LIST_PARTS {
    LOCAL PART_NAMES TO UNIQUESET().
    FOR PART IN SHIP:PARTS {
        PART_NAMES:ADD(PART:NAME).
    }
    FOR PART_NAME IN PART_NAMES {
        PRINT PART_NAME.
    }
}

FUNCTION LIST_EVENT_FOR_PART {
    PARAMETER PART.
    LOCAL MODULES TO PART:ALLMODULES.
    FOR MODULE IN MODULES {
        LOCAL EVENTS IS PART:GETMODULE(MODULE):ALLEVENTNAMES.
        FOR EVENT IN EVENTS {
            PRINT EVENT.
        }
    }
}

FUNCTION ACT_ON_PART {
    PARAMETER PART.
    PARAMETER ACTION.
    IF ACTION="COLLECT_SCIENCE" {
        LOCAL EXPERIMENT TO PART:GETMODULE("ModuleScienceExperiment").
        IF EXPERIMENT:HASDATA {
            EXPERIMENT:RESET().
            WAIT UNTIL NOT EXPERIMENT:HASDATA.
        }
        EXPERIMENT:DEPLOY().
        WAIT UNTIL EXPERIMENT:HASDATA.
        RETURN.
    }
    IF ACTION="AFTERBURNER" {
        IF PART:MODE="DRY" {
            PART:TOGGLEMODE.
            WAIT UNTIL PART:MODE="WET".
        }
        RETURN.
    }
    IF ACTION="AFTERBURNER_OFF" {
        IF PART:MODE="WET" {
            PART:TOGGLEMODE.
            WAIT UNTIL PART:MODE="DRY".
        }
        RETURN.
    }
    IF ACTION="DEPLOY_CHUTE" {
        LOCAL PARACHUTE TO PART:GETMODULE("ModuleParachute").
        PARACHUTE:DOEVENT("deploy chute").
    }
    LOCAL MODULES TO PART:ALLMODULES.
    FOR MODULE IN MODULES {
        LOCAL EVENTS IS PART:GETMODULE(MODULE):ALLEVENTNAMES.
        FOR EVENT IN EVENTS {
            IF EVENT:CONTAINS(ACTION) {
                PART:GETMODULE(MODULE):DOEVENT(EVENT).
                RETURN.
            }
        }
    }
}

FUNCTION ACT_ON_PARTS {
    PARAMETER PART_NAME.
    PARAMETER ACTION_NAME.
    LOCAL PARTS TO GET_PARTS(PART_NAME).
    FOR PART IN PARTS {
        ACT_ON_PART(PART, ACTION_NAME).
    }
}

FUNCTION COLLECT_SCIENCE {
    ACT_ON_PARTS("GOO", "COLLECT_SCIENCE").
    ACT_ON_PARTS("BAROMETER", "COLLECT_SCIENCE").
    ACT_ON_PARTS("THERMOMETER", "COLLECT_SCIENCE").
    ACT_ON_PARTS("SCIENCE.MOD", "COLLECT_SCIENCE").
    WAIT 2.
    ACT_ON_PARTS("SCIENCEBOX", "COLLECT").
}

FUNCTION GET_VESSEL_HEIGHT {
    LOCAL LOWEST_HEIGHT TO 0.
    LOCAL ROOT_PART_HEIGHT TO VDOT(FACING:FOREVECTOR, SHIP:ROOTPART:POSITION).
    FOR PART IN SHIP:PARTS {
        SET CURRENT_HEIGHT TO VDOT(FACING:FOREVECTOR, PART:POSITION).
        IF CURRENT_HEIGHT < LOWEST_HEIGHT {
            SET LOWEST_HEIGHT TO CURRENT_HEIGHT.
        }
    }
    LOCAL FINAL_HEIGHT TO ROOT_PART_HEIGHT - LOWEST_HEIGHT.
    PRINT "HEIGHT FROM ROOT PART: " + ROUND(FINAL_HEIGHT) + " M".
    RETURN FINAL_HEIGHT.
}

FUNCTION WARP_TO_TIME {
    PARAMETER DTIME.
    PARAMETER RAILS IS TRUE.

    CLEARSCREEN.
    PRINT "WARPING " + DTIME + " SECONDS...".
    SET TW TO KUNIVERSE:TIMEWARP.
    IF RAILS {
        SET TW:MODE TO "RAILS".
    }
    TW:WARPTO(TIME:SECONDS + DTIME).
    WAIT DTIME.
    WAIT UNTIL TW:WARP = 0 AND TW:ISSETTLED.
    CLEARSCREEN.
}

