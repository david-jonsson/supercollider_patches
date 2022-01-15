s.boot()

TempoClock.default.tempo = 132/60;

"sc_drums.scd".loadRelative;
"sc_base.scd".loadRelative;
"sc_effects.scd".loadRelative;

/*
 * Drums
 */
(
Pdef(
    \pdef_kick,
    Pbind(
        \instrument, \Kick,
        // \out, ~fx_bus,
        \amp, 0.7,
        \rel_time, 0.400,
        \pitch_start, 280,
        \pitch_end, 50,
        \pitch_slope, -8,
        \filter_moddepth, 3.5,
        \filter_rq, 1,
        \dur, Pseq([1, 1, 1, 1, 1, 1, 1, 0.75, 0.25], inf),
    )
).play.quant_(8);
)


(
Pdef(
    \pdef_snare,
    Pbind(
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
        // \dur, Pseq([1, 1, 1, 1, 1, 1, 1, 0.75, 0.25], inf),

        // \dur, Pseq([1], inf),
    )
).play.quant_([8,7.75])
)

Pdef(\pdef_snare).stop;

(
var rel = 0.45;
Pdef(
    \pdef_toms,
    Pbind(
        \instrument, \TomsFM,
        \amp, 0.6,

        \att_times,    [[0.00, 0.00, 0.00, 0.00, 0.00]],
        \rel_times,    [[0.05, rel, rel, rel, rel]],
        \amp_slopes,   [[\lin, \lin, \lin, \lin]],
        \pitch_starts, [[100, 250, 600, 5000, 500]],
        \pitch_ends,   [[100, 100, 300, 100, 50]],
        \pitch_slopes, [[\lin, -8, -8, -8, -8]],
        \fm_moddepths, [5000, 100],
        \filter_moddepth, 0.8,
        \filter_rq, 1,
        \snap, 2,

/*        \att_times,    [[0.00, 0.00, 0.00, 0.00, 0.00]],
        \rel_times,    [[0.05, rel, rel, rel, rel]],
        \amp_slopes,   [[\lin, \lin, \lin, \lin]],
        \pitch_starts, [[100, 400, 200, 1000, 400]],
        \pitch_ends,   [[100, 200, 100, 400, 150]],
        \pitch_slopes, [[\lin, -4, -4, -4, -10]],
        \fm_moddepths, [3000, 1000],
        \filter_moddepth, 0.6,
        \filter_rq, 0.1,
        \snap, 2,*/

        // \midinote, Pseq([0, 15, 10, 0, 5], inf),
        // \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.25], inf),

        \midinote, Pseq([5, 10, 5, 10, 5], inf),
        \dur, Pseq([0.75, 0.75, 0.75, 0.25], inf),
    )
).play.quant_(8);
)

(
var rel = 0.200;
var bend = 6;
var lo = 40;
var mi = lo + 12;
var hi = lo + (12 * 2.77 / 1);
Pdef(
    \pdef_toms,
    Pbind(
        \instrument, \Toms909,
        \amp, 0.3,
        \release, 0.5,
        \amps,         [[0.5, 0.5, 0.2]],
        \att_times,    [[0.01, 0.01, 0.1, 0.00, 0.00]],
        \rel_times,    [[0.5, 0.5, 0.5, rel, rel]],
        \amp_slopes,   [[\lin, \lin, \lin, \lin]],
        \pitch_starts, [[lo       , mi       ,hi       , 0, lo]],
        \pitch_ends,   [[lo - bend, mi - bend,hi - bend, 0, lo - bend]],
        \pitch_slopes, [[-1, -1, -1, -8, -1]],
        \filter_moddepth, 4,
        \filter_rq, 0.5,
        \snap, 0.2,
        \midinote, Pseq([0, 3, 0, 3, 0], inf),
        \dur, Pseq([0.75, 0.75, 0.75, 0.25], inf),
        // \dur, Pseq([3], inf),
    )
).play.quant_(0);
)

Pdef(\pdef_toms).stop;

(
~pad.stop();
~pad = Pbind(
    \instrument, \Paddd,
    \fx_bus, ~fx_bus,
    \midinote, Pseq([44], inf),
    \dur, Pseq([8], inf),
).play(quant: 1);
)


~fx_bus = Bus.audio(s, 1);

(
~delay.stop();
~delay = Synth(
    \PPDelay,
    [
        \fx_bus, ~fx_bus,
    ]
);
)

(
~reverb.stop();
~reverb = Synth(
    \Reverb,
    [
        \fx_bus, ~fx_bus,
    ]
);
)

(
~reverb.set(
    \mix, 0.5,
    \room, 1,
    \damp, 0.1,
);
)



(
~delay.set(
    \feedback, 0.5,
    \dtime,    0.0014,
);
)

(
var offset = 0, pitch  = 52;
~pad.stream = Pbind(
    \instrument, \Paddd,
    \amp, 0.1,
    \fx_bus, ~fx_bus,
    \filter_cutoff, Prand([2000, 3000, 2500, 0, 1000], inf),
    \filter_slope,  -30,
    \midinote, Pseq([pitch,  pitch + offset , pitch], inf),
    \dur, Pseq([0.25, 0.25, 3.50], inf),
).asStream;
)

/*
 * Base
 */
(
var offset = 0;
~base.stop();
~base = Pbind(
    \instrument, \Base,
    // \out, ~fx_bus,
    \amp, 1,
    \att_time, 0.004,
    \rel_time, 0.9,
    \harm_amps, [[0.1, 0.7, 0.9, 0.3, 0.1]],
    // \harm_amps, [[0.8, 0., 0.0, 0.0, 0.0]],

    \triangle_amp_slope, \lin,
    \filter_pitch_start, 100,
    \filter_pitch_end, 50,
    \filter_pitch_slope, -1,
    \filter_moddepth, 10,
    \filter_rq, 1,
    \midinote, Pseq([25, 30, 34, 27], inf),
    // \dur, Pseq([1.0, 1, 1, 1, 1], inf),
    // \midinote, Pseq([40], inf),
    \dur, Pseq([2], inf),
).play(quant: 8);
)


/*(
~fdsa.set(
    \filter_cutoff, 0,
    \filter_slope,  -1,
);
)*/