###############################################################################
## $Id: LZ-129.nas,v 1.3 2007-06-17 23:50:40 anders Exp $
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

init = func {
    var crew = "/sim/model/crew/";
    setprop(crew ~ "rudder_coxswain/visible", 1);
    setprop(crew ~ "elevator_coxswain/visible", 1);
    setprop(crew ~ "captain/visible", 1);
}

_setlistener("/sim/signals/fdm-initialized", func {
    init();
});
