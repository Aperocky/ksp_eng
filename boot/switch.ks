SET TERMINAL:CHARHEIGHT TO 16.
SWITCH TO 0.

// AUTO LAUNCH AUTO SHIPS
SET SHIP_NAME TO SHIP:NAME.
IF SHIP_NAME:CONTAINS("LKO AUTO TOUR") {
    RUN LKO_TOUR.
} ELSE IF SHIP_NAME:CONTAINS("SUBORBITAL TOUR") {
    RUN SUB_TOUR.
}
