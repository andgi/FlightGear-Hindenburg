###############################################################################
## $Id: LZ-129.nas,v 1.5 2007-07-10 22:24:30 anders Exp $
##
## LZ-129 Hindenburg
##
##  Copyright (C) 2007  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license.
##
###############################################################################

var ballastFore    = "/fdm/jsbsim/inertia/ballast-tank[0]/contents-slug";
var ballastAft     = "/fdm/jsbsim/inertia/ballast-tank[1]/contents-slug";
var ballastCenter  = "/fdm/jsbsim/inertia/ballast-tank[2]/contents-slug";
var gascell        = "/fdm/jsbsim/inertia/gas-cell";
var weight_on_gear = "/fdm/jsbsim/forces/fbz-gear-lbs";
var slugtolb  = 32.174049;
var lbtoslug  = 1.0/slugtolb;


setForwardGasValves = func (v) {
    setprop(gascell ~ "[15]/valve_open", v);
    setprop(gascell ~ "[14]/valve_open", v);
    setprop(gascell ~ "[13]/valve_open", v);
    setprop(gascell ~ "[12]/valve_open", v);
    setprop(gascell ~ "[11]/valve_open", v);
    setprop(gascell ~ "[10]/valve_open", v);
    setprop(gascell ~ "[9]/valve_open", v);
    setprop(gascell ~ "[8]/valve_open", v);
}

setAftGasValves = func (v) {
    setprop(gascell ~ "[7]/valve_open", v);
    setprop(gascell ~ "[6]/valve_open", v);
    setprop(gascell ~ "[5]/valve_open", v);
    setprop(gascell ~ "[4]/valve_open", v);
    setprop(gascell ~ "[3]/valve_open", v);
    setprop(gascell ~ "[2]/valve_open", v);
    setprop(gascell ~ "[1]/valve_open", v);
    setprop(gascell ~ "[0]/valve_open", v);
}

print_wow = func {
    gui.popupTip("Current weight on gear " ~
                 getprop(weight_on_gear) ~ " lbs.");
}

weighoff = func {
    gui.popupTip("Weigh-off to 10% in progress. " ~
                   "Current weight " ~ getprop(weight_on_gear) ~ " lbs.");
    var after =
      getprop(ballastCenter) + 0.90 * getprop(weight_on_gear) * lbtoslug;
    interpolate(ballastCenter,
                (after >= 0) ? after : 0,
                10);
}

drop_ballast = func (ballast, x) {
    # NOTE: The popup tip should probably be at the callers discretion. 
    gui.popupTip("Dropping ballast " ~
                 ((ballast == ballastAft)    ? "aft" :
                  (ballast == ballastFore)   ? "fore" :
                  (ballast == ballastCenter) ? "center" :
                  "BAD BALLAST SELECTOR") ~
                 "! " ~
                 "Ballast left: " ~ getprop(ballast) ~ " slug");
    interpolate(ballast, (1.0 - x) * getprop(ballast), 0.5);
}

switch_engine_direction = func (eng) {
    var engineJSB = "/fdm/jsbsim/propulsion/engine" ~ "[" ~ eng ~ "]";
    var engineFG  = "/engines/engine" ~ "[" ~ eng ~ "]";
    var dir       = engineJSB ~ "/yaw-angle-rad";

    if (!getprop(engineFG ~ "/running")) {
        setprop(dir, (getprop(dir) == 0) ? 3.14159265 : 0.0);
        # NOTE: The popup tip should probably be at the callers discretion. 
        gui.popupTip("Changing direction for engine " ~ eng ~
                     " to " ~
                     ((getprop(dir) == 0) ? "forward." : "reverse."));
    } else {
        # NOTE: The popup tip should probably be at the callers discretion. 
        gui.popupTip("Cannot change direction for " ~
                     ((getprop(dir) == 0) ? "forward" : "reverse") ~
                     " running engine " ~ eng ~ ".");
    }
}

init = func {
    # Nothing to do here yet.
}

_setlistener("/sim/signals/fdm-initialized", func {
    init();
});
