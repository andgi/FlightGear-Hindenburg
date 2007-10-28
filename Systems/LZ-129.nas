###############################################################################
## $Id: LZ-129.nas,v 1.9 2007-10-28 15:00:15 anders Exp $
##
## LZ-129 Hindenburg
##
##  Copyright (C) 2007  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license.
##
###############################################################################

var ballastFore    = "/fdm/jsbsim/inertia/ballast[0]/contents-slug";
var ballastAft     = "/fdm/jsbsim/inertia/ballast[1]/contents-slug";
var ballastCenter  = "/fdm/jsbsim/inertia/ballast[2]/contents-slug";
var gascell        = "/fdm/jsbsim/inertia/gas-cell";
var weight_on_gear = "/fdm/jsbsim/forces/fbz-gear-lbs";
var weight         = "/fdm/jsbsim/inertia/weight-lbs";
var slugtolb  = 32.174049;
var lbtoslug  = 1.0/slugtolb;


var setForwardGasValves = func (v) {
    setprop(gascell ~ "[15]/valve_open", v);
    setprop(gascell ~ "[14]/valve_open", v);
    setprop(gascell ~ "[13]/valve_open", v);
    setprop(gascell ~ "[12]/valve_open", v);
    setprop(gascell ~ "[11]/valve_open", v);
    setprop(gascell ~ "[10]/valve_open", v);
    setprop(gascell ~ "[9]/valve_open", v);
    setprop(gascell ~ "[8]/valve_open", v);
}

var setAftGasValves = func (v) {
    setprop(gascell ~ "[7]/valve_open", v);
    setprop(gascell ~ "[6]/valve_open", v);
    setprop(gascell ~ "[5]/valve_open", v);
    setprop(gascell ~ "[4]/valve_open", v);
    setprop(gascell ~ "[3]/valve_open", v);
    setprop(gascell ~ "[2]/valve_open", v);
    setprop(gascell ~ "[1]/valve_open", v);
    setprop(gascell ~ "[0]/valve_open", v);
}

var print_wow = func {
    gui.popupTip("Current weight on gear " ~
                 getprop(weight_on_gear) ~ " lbs.");
}

var weighoff = func {
    gui.popupTip("Weigh-off to 10% in progress. " ~
                   "Current weight " ~ getprop(weight_on_gear) ~ " lbs.");
    var after =
      getprop(ballastCenter) + 0.90 * getprop(weight_on_gear) * lbtoslug;
    interpolate(ballastCenter,
                (after >= 0) ? after : 0,
                10);
}

var drop_ballast = func (ballast, x) {
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

var switch_engine_direction = func (eng) {
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

var weightoff_report = func {
    var cells =
      props.globals.getNode("/fdm/jsbsim/inertia").getChildren("gas-cell");
    var L = 0;
    var W = getprop(weight);

    foreach (c; cells) {
        L += c.getChild("buoyancy-lbs").getValue();
    }

#    setprop("/sim/messages/copilot",
#            "Weight " ~ int(W) ~ " pound. Lift " ~ int(L) ~ " pound.");

    setprop("/sim/messages/copilot",
            "We are " ~ int(abs(L - W)) ~ " pounds " ~
            ((L - W) > 0 ? "light." : "heavy."));
}

## Helpful crew annoncements by autonomous singleton class.
var assistant = {
    init : func {
        me.UPDATE_INTERVAL = 1.73;
        me.loopid = 0;
        me.prall = 1;
        me.prall_prop = "/fdm/jsbsim/fcs/instrumentation/gas-cells/any-prall";
        me.reset();
        print("LZ 129 Crew ... All present and accounted for.");
     },
    update : func {
        var p = getprop(me.prall_prop);

        if ((me.prall == 0) and (p > 0)) {
            me.prall = 1;
            setprop("/sim/messages/copilot",
                    "We are above pressure height.");
        } elsif (p < 1) {
            me.prall = 0;
        }
    },
    reset : func {
        me.loopid += 1;
        me._loop_(me.loopid);
    },
    _loop_ : func(id) {
        id == me.loopid or return;
        me.update();
        settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }
};

var init = func {
    assistant.init(); 
}

_setlistener("/sim/signals/fdm-initialized", func {
    init();
});
