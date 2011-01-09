###############################################################################
## $Id: LZ-129.nas,v 1.27 2011-01-09 20:54:23 anders Exp $
##
## LZ-129 Hindenburg
##
##  Copyright (C) 2007 - 2011  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license v2 or later.
##
###############################################################################

var ballastFore    = "/fdm/jsbsim/inertia/ballast[0]/contents-slug";
var ballastAft     = "/fdm/jsbsim/inertia/ballast[1]/contents-slug";
var ballastCenter  = "/fdm/jsbsim/inertia/ballast[2]/contents-slug";
var ballast_p      = "/fdm/jsbsim/inertia/ballast[3]/contents-slug";
var gascell        = "/fdm/jsbsim/buoyant_forces/gas-cell";
var weight_on_gear = "/fdm/jsbsim/forces/fbz-gear-lbs";
var weight         = "/fdm/jsbsim/inertia/weight-lbs";
var slugtolb  = 32.174049;
var lbtoslug  = 1.0/slugtolb;
var slugtokg  = 14.593903;
var lbtokg    = 0.45359237;

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
    var after = getprop(ballastCenter) + 0.9 * static_condition() * lbtoslug;
    if ((0 <= after) and (after < getprop(ballastCenter))) {
        interpolate(ballastCenter, after, 10);
    }
}

var drop_ballast = func (ballast, x) {
    # NOTE: The announcement should probably be at the callers discretion. 
    assistant.announce("Dropping ballast " ~
                       ((ballast == ballastAft)    ? "aft" :
                       (ballast == ballastFore)   ? "fore" :
                       (ballast == ballastCenter) ? "center" :
                       "BAD BALLAST SELECTOR") ~
                       "! " ~
                       int(slugtokg * getprop(ballast)) ~
                       " kilo remaining.");
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
        assistant.announce("Engine " ~ eng ~
                           " set to " ~
                           ((getprop(dir) == 0) ? "forward." : "reverse."));
    } else {
        # NOTE: The popup tip should probably be at the callers discretion. 
        assistant.announce("Cannot change direction for " ~
                           ((getprop(dir) == 0) ? "forward" : "reverse") ~
                           " running engine " ~ eng ~ ".");
    }
}

var static_condition = func {
    var cells =
        props.globals.getNode("/fdm/jsbsim/buoyant_forces").
            getChildren("gas-cell");
    var L = 0;
    var W = getprop(weight);
    
    foreach (var c; cells) {
        L += c.getChild("buoyancy-lbs").getValue();
    }
    return L - W;
};

var weightoff_report = func {
    var s = lbtokg * static_condition();

    assistant.announce("We are " ~ int(abs(s)) ~ " kilos " ~
                       (s > 0 ? "light." : "heavy."));
}

###########################################################################
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
        var w = getprop("/fdm/jsbsim/mooring/wire-connected");
        if ((me.moored == 0) and (m > 0.5) and (w > 0.5)) {
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

###########################################################################
## Experimental mooring mast and ground crew
var ground_crew = {
  ##################################################
  init : func {
    me.UPDATE_INTERVAL = 0.42;
    me.loopid = 0;
    ## Hash containing all supported mooring locations.
    ## NOTE: the altitude offset is model dependent.
    me.moorings = {"KNUQ_mooring_mast_north" : { alt_offset : 85.0 },
                   "KNUQ_mooring_mast_south" : { alt_offset : 85.0 },
                   "KNEL_mooring_mast"       : { alt_offset : 85.0 },
                   "EDDI_mooring_mast"       : { alt_offset : 85.0 },
                   "EDNY_mooring_mast"       : { alt_offset : 85.0 },
                   "Nimitz"                  : { alt_offset : 260.0 },
                   "Generic_mooring_mast"    : { alt_offset : 80.0 }};
    me.mooring = props.globals.getNode("/fdm/jsbsim/mooring");
    me.mast_model = nil;
    var ais =
      props.globals.getNode("/ai/models").getChildren("aircraft");
    var found = 0;
    foreach (var ai; ais) {
      var name = ai.getNode("callsign").getValue();
      if (me.moorings[name] != nil) {
        me.selected = name;
        me.mooring.getNode("latitude-deg").setValue
          (ai.getNode("position/latitude-deg").getValue());
        me.mooring.getNode("longitude-deg").setValue
          (ai.getNode("position/longitude-deg").getValue());
        me.mooring.getNode("altitude-ft").setValue
          (ai.getNode("position/altitude-ft").getValue() +
           me.moorings[name].alt_offset);
        found = 1;
      }
    }
    if (found) {
      me.reset();
    } else {
      print("LZ 129 Ground crew ... No mooring mast available.");
    }
    print("LZ 129 Ground crew ... Standing by.");
  },
  ##################################################
  set_mooring_location : func (pos) {
    var geo_info = geodinfo(pos.lat(), pos.lon());
    pos.set_alt(geo_info[0]); # Crash if we don't know the terrain elevation.
    me.selected = "Generic_mooring_mast";
    me.mooring.getNode("latitude-deg").setValue(pos.lat());
    me.mooring.getNode("longitude-deg").setValue(pos.lon());
    me.mooring.getNode("altitude-ft").setValue
        (pos.alt()*M2FT + me.moorings[me.selected].alt_offset);
    # Put a mooring mast model here. Note the model specific offset.
    pos.set_alt(geo_info[0] - 5*FT2M);
    if (me.mast_model) me.mast_model.remove();
    me.mast_model =
      geo.put_model("Aircraft/LZ-129/Models/mooring_mast.xml", pos);
    print("LZ 129 Ground crew: Switched mooring to " ~
          pos.lat() ~ ", " ~ pos.lon() ~ ".");
  },
  ##################################################
  attach_mooring_wire : func {
    var dist = me.mooring.getNode("total-distance-ft").getValue();
    if ((dist < 1500.0) and
        (getprop("/position/altitude-agl-ft") < 1000.0)) {
      me.mooring.getNode("winch-speed-fps").setValue(0);
      me.mooring.getNode("initial-wire-length-ft").setValue(dist);
      me.mooring.getNode("wire-connected").setValue(1.0);
      assistant.announce("Ground reports: Mooring cable attached.");
    } else {
      assistant.announce("We are too far from the mooring mast.");
    }
  },
  ##################################################
  change_wire_length : func(d) {
    var len = me.mooring.getNode("initial-wire-length-ft").getValue();
    var sp  = me.mooring.getNode("max-winch-speed-fps").getValue();
    if ((len == 0) and (d < 0)) {
      var t = me.mooring.getNode("wire-connected").getValue();
      interpolate(me.mooring.getNode("wire-connected"), 2*t, 5.0);
    } else {
      interpolate(me.mooring.getNode("initial-wire-length-ft"),
                  (len + d) < 0 ? 0 : len + d, math.abs(d/sp));
    }
  },
  ##################################################
  set_winch_speed : func(sp) {
    if (me.mooring.getNode("wire-connected").getValue() == 0.0) {
      me.mooring.getNode("winch-speed-fps").setValue(0);
      return;
    }

    var max = me.mooring.getNode("max-winch-speed-fps").getValue();
    if (math.abs (sp) > max) {
      sp = sp/math.abs(sp) * max;
    }
    me.mooring.getNode("winch-speed-fps").setValue(sp);
    LZ129.assistant.announce("Winch " ~
                             math.abs(int(0.3048*sp)) ~ "." ~
                             math.mod(math.abs(int(3.048*sp)), 10) ~
                             " meters-per-second " ~
                             ((sp < 0) ? "in" : "out") ~ ".");
  },
  ##################################################
  release_mooring : func {
    if (me.mooring.getNode("moored").getValue() >= 1.0) {
        me.mooring.getNode("wire-connected").setValue(0.0);
      assistant.announce("Mooring connection released.");
    } elsif (me.mooring.getNode("wire-connected").getValue() >= 1.0) {
      me.mooring.getNode("wire-connected").setValue(0.0);
      assistant.announce("Released mooring wire.");
    }
    me.mooring.getNode("winch-speed-fps").setValue(0);
  },
  ##################################################
  update : func {
    if (me.mooring.getNode("wire-connected").getValue()) return;

    var ais =
      props.globals.getNode("/ai/models").getChildren("aircraft") ~
      props.globals.getNode("/ai/models").getChildren("carrier");
    var distance = FT2M * me.mooring.getNode("total-distance-ft").getValue();
    var ac_pos = geo.aircraft_position();
    var found = 0;
    foreach (var ai; ais) {
      var name = ai.getNode("callsign").getValue();
      if (name == "") { name = ai.getNode("name").getValue(); }
      if (me.moorings[name] != nil) {
        var pos =
          geo.Coord.set_latlon
            (ai.getNode("position/latitude-deg").getValue(),
             ai.getNode("position/longitude-deg").getValue(),
             FT2M * (ai.getNode("position/altitude-ft").getValue() +
                     me.moorings[name].alt_offset));
        if ((name == me.selected) or
            (pos.direct_distance_to(ac_pos) < distance)) {
          if (name != me.selected) {
            print("LZ 129 Ground crew: Switched mooring to " ~ name ~ ".");
            me.selected = name;
          }
          distance = pos.distance_to(ac_pos);
          me.mooring.getNode("latitude-deg").setValue(pos.lat());
          me.mooring.getNode("longitude-deg").setValue(pos.lon());
          me.mooring.getNode("altitude-ft").setValue(M2FT * pos.alt());
          found = 1;
        }
      }
    }
#    if ((found == 0)) {
#      # This is might be an error. Reset mooring location.
#      print("LZ 129 Ground crew: Mooring location corrupted!!");
#      me.reset();
#    }
  },
  ##################################################
  reset : func {
    me.loopid += 1;
    me._loop_(me.loopid);
  },
  ##################################################
  _loop_ : func(id) {
    id == me.loopid or return;
    me.update();
    settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
  }
};

var auto_weighoff = func {
    var v = getprop(ballast_p) * slugtolb +
        getprop("/fdm/jsbsim/static-condition/net-lift-lbs") - 2000;

    interpolate(ballast_p,
                (v > 0 ? v * lbtoslug : 0),
                0.5);
}

var initial_weighoff = func {
    # Set initial static condition.
    # Finding the right static condition at initialization time is tricky.
    auto_weighoff();
    settimer(auto_weighoff, 0.25);
    settimer(auto_weighoff, 1.0);
}

var init_all = func (reinit=0) {
    # Initialize crew and ground crew.
    if (!reinit) assistant.init();
    if (!reinit) ground_crew.init();
    # Set initial static condition.
    initial_weighoff();

    if (getprop("/sim/presets/onground")) {
        # Set up an initial mooring location.
        settimer(func {
            ground_crew.set_mooring_location(geo.aircraft_position());
        }, 0.1);
        # We need the FDM to run in between.
        settimer(func {
            ground_crew.attach_mooring_wire();
            ground_crew.set_winch_speed(-1.0);
        }, 1.0);
    }
}

setlistener("/sim/signals/fdm-initialized", func {
    init_all();
    setlistener("/sim/signals/reinit", func (reinit) {
        if (!reinit.getValue()) {
            init_all(reinit=1);
        }
    });
});

