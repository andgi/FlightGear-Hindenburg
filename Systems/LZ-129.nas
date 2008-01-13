###############################################################################
## $Id: LZ-129.nas,v 1.11 2008-01-13 22:57:24 anders Exp $
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
    assistant.announce("Weigh-off in progress.");
    var after =
      getprop(ballastCenter) + 0.90 * getprop(weight_on_gear) * lbtoslug;
    interpolate(ballastCenter,
                (after >= 0) ? after : 0,
                10);
}

var drop_ballast = func (ballast, x) {
    # NOTE: The announcement should probably be at the callers discretion. 
    assistant.announce("Dropping ballast " ~
                       ((ballast == ballastAft)    ? "aft" :
                       (ballast == ballastFore)   ? "fore" :
                       (ballast == ballastCenter) ? "center" :
                       "BAD BALLAST SELECTOR") ~
                       "! " ~
                       int(slugtolb * getprop(ballast)) ~
                       " pounds remaining.");
    interpolate(ballast, (1.0 - x) * getprop(ballast), 0.5);
}

var switch_engine_direction = func (eng) {
    var engineJSB = "/fdm/jsbsim/propulsion/engine" ~ "[" ~ eng ~ "]";
    var engineFG  = "/engines/engine" ~ "[" ~ eng ~ "]";
    var dir       = engineJSB ~ "/yaw-angle-rad";

    if ((eng < 0) or (eng > 4)) return;

    if (!getprop(engineFG ~ "/running")) {
        setprop(dir, (getprop(dir) == 0) ? 3.14159265 : 0.0);
        # NOTE: The popup tip should probably be at the callers discretion. 
        assistant.announce("Changing engine " ~ eng ~
                           " direction to " ~
                           ((getprop(dir) == 0) ? "forward." : "reverse."));
    } else {
        # NOTE: The popup tip should probably be at the callers discretion. 
        assistant.announce("Cannot change direction for " ~
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

#    assistant.announce("Weight " ~ int(W) ~ " pound. Lift " ~ int(L) ~ " pound.");

    assistant.announce("We are " ~ int(abs(L - W)) ~ " pounds " ~
                       ((L - W) > 0 ? "light." : "heavy."));
}

## Helpful crew announcements by autonomous singleton class.
var assistant = {
    init : func {
        me.UPDATE_INTERVAL = 1.73;
        me.loopid = 0;
        me.prall = 1;
        me.prall_prop = "/fdm/jsbsim/fcs/instrumentation/gas-cells/any-prall";
        me.moored = 0;
        me.reset();
        print("LZ 129 Crew ... All present and accounted for.");
     },
    update : func {
        var p = getprop(me.prall_prop);

        if ((me.prall == 0) and (p > 0)) {
            me.prall = 1;
            me.announce("We are above pressure height.");
        } elsif (p < 1) {
            me.prall = 0;
        }

        var m = getprop("/fdm/jsbsim/mooring/moored");
        if ((me.moored == 0) and (m > 0)) {
            me.moored = 1;
            me.announce("Docked to the mooring mast.");
        } elsif (m < 1) {
            me.moored = 0;
        }
    },
    announce : func(msg) {
        setprop("/sim/messages/copilot", msg);
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

## Experimental mooring mast and ground crew
var ground_crew = {
    init : func {
        me.mooring = props.globals.getNode("/fdm/jsbsim/mooring");
        var ais =
            props.globals.getNode("/ai/models").getChildren("aircraft");
        var found = 0;
        foreach (ai; ais) {
            if (ai.getNode("callsign").getValue() == "Mooring mast KNUQ") {
                me.mooring.getNode("latitude-deg").setValue
                    (ai.getNode("position/latitude-deg").getValue());
                me.mooring.getNode("longitude-deg").setValue
                    (ai.getNode("position/longitude-deg").getValue());
                me.mooring.getNode("altitude-ft").setValue
                    (ai.getNode("position/altitude-ft").getValue() + 650.0);
                found = 1;
            }
        }
        if (!found) print("LZ 129 Ground crew ... No mooring mast available.");
        print("LZ 129 Ground crew ... Standing by.");
    },
    attach_mooring_wire : func {
        if ((me.mooring.getNode("total-distance-ft").getValue() < 1500.0) and
            (getprop("/position/altitude-agl-ft") < 1000.0)) {
            interpolate("/fdm/jsbsim/mooring/on-the-wire", 1.0, 10);
            assistant.announce("Ground reports: Mooring cable attached.");
        } else {
            assistant.announce("We are too far from the mooring mast.");
        }
    },
    release_mooring : func {
        if (me.mooring.getNode("moored").getValue() >= 1.0) {
            me.mooring.getNode("on-the-wire").setValue(0.0);
            assistant.announce("Mooring connection released.");
        } elsif (me.mooring.getNode("on-the-wire").getValue() >= 1.0) {
            me.mooring.getNode("on-the-wire").setValue(0.0);
            assistant.announce("Released mooring wire.");
        }
    }
};

var init = func {
    assistant.init();
    ground_crew.init();
}

_setlistener("/sim/signals/fdm-initialized", func {
    init();
});
