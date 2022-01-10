s.boot()

TempoClock.default.tempo = 132/60;

"sc_drums.scd".loadRelative;
"sc_base.scd".loadRelative;

"sc_effects.scd".loadRelative;

/*
 * Drums
 */
(
~kick.stop();
~kick = Pbind(
    \instrument, \Kick,
    \amp, 0.7,
    \rel_time, 0.400,
    \pitch_start, 300,
    \pitch_end, 40,
    \pitch_slope, -10,
    \filter_moddepth, 4,
    \dur, Pseq([1, 1, 1, 1, 1, 1, 1, 0.75, 0.25], inf),
).play(quant: 1);
)


(
~snare.stop();
~snare = Pbind(
    \instrument, \Snare,
    \amp, 0.5,
    // \out,  ~fx_bus,
    \rel_time, 0.250,
    \triangle_pitch_start, 160,
    \triangle_pitch_end, 100,
    \triangle_pitch_slope, -1,
    \filter_moddepth, 100,
    \filter_rq, 1,
    \filter_pitch_start, 160,
    \filter_pitch_end, 160,
    \filter_pitch_slope, \linear,
    \snap, 0.30,
    \dur, Pseq([16, 15.50, 0.50], inf),
    // \dur, Pseq([1], inf),
).play(quant: [1, 15.75]);
)

(
var rel = 0.30;
~toms.stop();
~toms = Pbind(
    \instrument, \Toms,
    \amp, 0.9,
    \att_times,    [[0.00, 0.00, 0.00, 0.00, 0.00]],
    \rel_times,    [[0.05, rel, rel, rel, rel]],
    \amp_slopes,   [[\lin, \lin, \lin, \lin]],
    \pitch_starts, [[100, 400, 200, 1000, 400]],
    \pitch_ends,   [[100, 200, 100, 400, 150]],
    \pitch_slopes, [[\lin, -4, -4, -4, -4]],
    \fm_moddepths, [3000, 1000],
    \filter_moddepth, 0.6,
    \filter_rq, 0.1,
    \snap, 1,
    \midinote, Pseq([0, 10, 5, 0, 5], inf),
    \dur, Pseq([0.5, 0.75, 0.25, 0.5, 0.25], inf),
).play(quant: 1);
)


/*
 * Base
 */
(
~tom_base.stop();
~tom_base = Pbind(
    \instrument, \Base,
    \amp, 1.2,
    \triangles_pitch_offsets, [[0, 7, 12, -12, -7]],
    \rel_time, 0.5,
    \noise_amp_slope, -1,
    \triangle_amp_slope, -4,
    \filter_pitch_start, 50,
    \filter_pitch_end, 30,
    \filter_pitch_slope, -20,
    \filter_moddepth, 7,
    \filter_rq, 1,
    \snap, 0,
    \midinote, Pseq([50, 45, 34, 40, 43], inf),
    \dur, Pseq([1.0, 0.5, 0.25, 1, 0.25], inf),
    // \midinote, Pseq([40], inf),
    // \dur, Pseq([4], inf),
).play(quant: 1);
)


(
~fx_bus = Bus.audio(s, 1);
~ppdelay.stop();
~ppdelay = Synth(
    \PPDelay,
    [
        \fx_bus, ~fx_bus,
    ]
);
)



(

~pad.stop();
~pad = Pbind(
    \instrument, \Paddd,
    \fx_bus, ~fx_bus,
    \midinote, Pseq([44], inf),
    \dur, Pseq([8], inf),
).play(quant: 1);
)


(
~ppdelay.set(
    \feedback, 0.8,
    \dtime,    0.175,
);
)

(
var offset = 5;
var pitch  = 44;
~pad.stream = Pbind(
    \instrument, \Paddd,
    \fx_bus, ~fx_bus,
    \filter_cutoff, Prand([2000, 3000, 2500, 0, 1000], inf),
    \filter_slope,  -30,
    \midinote, Pseq([pitch,  pitch + offset , pitch], inf),
    \dur, Pseq([0.25, 0.25, 7.50], inf),
).asStream;
)
/*(
~fdsa.set(
    \filter_cutoff, 0,
    \filter_slope,  -1,
);
)*/