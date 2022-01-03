s.boot()

TempoClock.default.tempo = 132/60;

/*
 *  Kick
 */
(
SynthDef(\Kick,
    {
        arg
        out = 0,
        att_time = 0.01,
        rel_time = 0.200,
        pitch_start = 200,
        pitch_end = 100,
        pitch_slope = -4,
        filter_moddepth = 1;
        // filter_rq = 1;

        var
        amp_env,
        pitch_env,
        signal;

        amp_env = EnvGen.kr(Env.perc(att_time, rel_time));
        pitch_env = EnvGen.kr
        (
            Env([pitch_start, pitch_end], [rel_time], pitch_slope),
            doneAction: Done.freeSelf
        );

        signal = LFTri.ar
        (
            freq: pitch_env,
            iphase: 0,
            mul: amp_env
        );
        signal = LPF.ar
        (
            in: signal,
            freq: pitch_env * filter_moddepth,
            // rq: filter_rq
        );
        Out.ar(out, signal ! 2);
    }
).add();
)

/*
 *  Snare
 */
(
SynthDef(\Snare,
    {
        arg
        out = 0,
        att_time = 0.01,
        rel_time = 0.200,
        triangle_pitch_start = 300,
        triangle_pitch_end = 160,
        triangle_pitch_slope = \linear,
        filter_pitch_start = 300,
        filter_pitch_end = 160,
        filter_pitch_slope = \linear,
        filter_moddepth = 1,
        filter_rq = 1,
        noise_pitch_start = 300,
        noise_pitch_end = 160,
        noise_pitch_slope = -6,
        snap = 0.5;

        var
        filter_pitch_env,
        triangle_amp_env,
        triangle_pitch_env,
        noise_amp_env,
        noise_pitch_env,
        signal,
        noise,
        triangle;

        /*
         * Noise
         */
        noise_amp_env   = EnvGen.kr(Env
            (
                [1, 0, 0.5, 0],
                [0.01, 0.05, 0.15],
                [\lin, -3, \lin],
            )
        );
        noise = BrownNoise.ar() * noise_amp_env * snap;
/*        noise_pitch_env = EnvGen.kr
        (
            Env
            (
                [0, 0, 1, 0,],
                [0.04, 0.07, 0.2],
                [\lin, -3, \lin],
            )
            doneAction: Done.freeSelf
        );
        noise = BLowPass.ar
        (
            in: BrownNoise.ar(),
            freq: noise_pitch_env * noise_filter_moddepth,
            rq: noise_filter_rq,
            mul: noise_amp_env * snap
        );*/

        /*
         * Triangle
         */
        triangle_amp_env   = EnvGen.kr(Env.perc(att_time, rel_time));
        triangle_pitch_env = EnvGen.kr
        (
            Env
            (
                [triangle_pitch_start, triangle_pitch_end,triangle_pitch_end],
                [rel_time / 2 , rel_time],
                triangle_pitch_slope
            ),
            doneAction: Done.freeSelf
        );
        triangle = LFTri.ar
        (
            freq: triangle_pitch_env,
            iphase: 0,
            mul: triangle_amp_env * 1
        );
        signal = triangle + noise;

        /*
         * Filter
         */
        filter_pitch_env = EnvGen.kr
        (
            Env
            (
                [filter_pitch_start, filter_pitch_end, filter_pitch_end],
                [rel_time / 2 , rel_time],
                filter_pitch_slope
            ),
            doneAction: Done.freeSelf
        );
        signal = BLowPass.ar
        (
            in: signal,
            freq: filter_pitch_env * filter_moddepth,
            rq: filter_rq
        );
        Out.ar(out, signal ! 2);
    }
).add();
)

/*
 *  Toms
 */
(
SynthDef(\Toms,
    {
        arg
        out = 0,
        midinote = 0,
        att_time = 0.01,
        rel_time = 0.200,
        triangle_pitch_start = 35,
        triangle_pitch_end = 30,
        triangle_pitch_slope = \linear,
        triangle_filter_moddepth = 1,
        triangle_filter_rq = 1,
        noise_pitch_start = 50,
        noise_pitch_end = 20,
        noise_pitch_slope = \linear,
        noise_filter_moddepth = 1,
        noise_filter_rq = 1;

        var
        noise_amp_env,
        noise_pitch_env,
        triangle_amp_env,
        triangle_pitch_env_hi,
        triangle_pitch_env_lo,
        triangle_hi,
        triangle_low,
        signal,
        triangle,
        noise;

        /*
         * Noise
         */
        noise_amp_env   = EnvGen.kr(Env.perc(att_time, rel_time));
        noise_pitch_env = EnvGen.kr
        (
            Env
            (
                [
                    (midinote + noise_pitch_start).midicps,
                    (noise_pitch_end).midicps
                ],
                [rel_time], noise_pitch_slope
            ),
            doneAction: Done.freeSelf
        );
        noise = BLowPass.ar
        (
            in: BrownNoise.ar(),
            freq: noise_pitch_env * noise_filter_moddepth,
            rq: triangle_filter_rq,
            mul: noise_amp_env * 0.4
        );

        /*
         * Triangle
         */
        triangle_amp_env = EnvGen.kr(Env.perc(att_time, rel_time));
        triangle_pitch_env_lo = EnvGen.kr
        (
            Env
            (
                [
                    (midinote + triangle_pitch_start).midicps,
                    (triangle_pitch_end).midicps
                ],
                [rel_time], triangle_pitch_slope
            ),
            doneAction: Done.freeSelf
        );
        triangle_pitch_env_hi = EnvGen.kr
        (
            Env
            (
                [
                    (midinote + triangle_pitch_start + 12).midicps,
                    (triangle_pitch_end + 12).midicps
                ],
                [rel_time], triangle_pitch_slope
            ),
            doneAction: Done.freeSelf
        );

        triangle_low = LFTri.ar
        (
            freq: triangle_pitch_env_lo,
            iphase: 0,
            mul: triangle_amp_env * 0.5
        );
        triangle_hi = LFTri.ar
        (
            freq: triangle_pitch_env_hi,
            iphase: 0,
            mul: triangle_amp_env * 0.5
        );
        triangle = triangle_hi + triangle_low;
        signal = triangle + noise;

        /*
         * Filter
         */
        signal = BLowPass.ar
        (
            in: signal,
            freq: triangle_pitch_env_hi * triangle_filter_moddepth,
            rq: triangle_filter_rq
        );
        Out.ar(out, signal ! 2);
    }
).add();
)

/*
 *  Claves
 */
(
SynthDef(\Claves,
    {
        arg
        out = 0,
        midinote,
        att_times =    #[0.01, 0.01, 0.01, 0.01, 0.01],
        rel_times =    #[0.20, 0.20, 0.20, 0.20, 0.20],
        amp_slopes =   #[\lin, \lin, \lin, \lin],
        pitch_starts = #[100, 100, 100, 100, 100],
        pitch_ends =   #[100, 100, 100, 100, 100],
        pitch_slopes = #[\lin, \lin, \lin, \lin, \lin],
        fm_moddepths = #[200, 100],
        filter_moddepth = 1,
        filter_rq = 1,
        snap = 0.5;

        var
        amp_envs = Array.newClear(indexedSize: 5),
        pitch_envs = Array.newClear(indexedSize: 5),
        signal,
        noise,
        carrier,
        mod1,
        mod2;

        /*
         *  d
         *  c
         * ab <- carriers
         *
         *  a : noisemaxSize
         *  b : sawtooth -3db
         *  c : sawtooth -6db
         *  d : sawtooth  8db
         */
        /*
         * Noise
         */
        amp_envs[0] = EnvGen.kr(Env.perc(att_times[0], rel_times[0]));
        noise = WhiteNoise.ar() * amp_envs[0] * snap;


        /*
         * Mod 2
         */
        amp_envs[3] = EnvGen.kr(Env.perc(att_times[3], rel_times[3]));
        pitch_envs[3] = EnvGen.kr
        (
            Env
            (
                [pitch_starts[3], pitch_ends[3]],
                [rel_times[3]],
                pitch_slopes[3]
            ),
            doneAction: Done.freeSelf
        );
        mod2 = SawDPW.ar
        (
            freq: pitch_envs[3],
            mul: amp_envs[3] * fm_moddepths[1]
        );

        /*
         * Mod 1
         */
        amp_envs[2] = EnvGen.kr(Env.perc(att_times[2], rel_times[2]));
        pitch_envs[2] = EnvGen.kr
        (
            Env
            (
                [pitch_starts[2], pitch_ends[2]],
                [rel_times[2]],
                pitch_slopes[2]
            ),
            doneAction: Done.freeSelf
        );
        mod1 = SawDPW.ar
        (
            freq: pitch_envs[2] + (mod2 * fm_moddepths[1]),
            mul: amp_envs[2] * fm_moddepths[0]
        );

        /*
         * Carrier
         */
        amp_envs[1] = EnvGen.kr(Env.perc(att_times[1], rel_times[1]));
        pitch_envs[1] = EnvGen.kr
        (
            Env
            (
                [pitch_starts[1], pitch_ends[1]],
                [rel_times[1]],
                pitch_slopes[1]
            ),
            doneAction: Done.freeSelf
        );
        carrier = SawDPW.ar
        (
            freq: pitch_envs[1] + mod1 - 50 + (10 * midinote),
            mul: amp_envs[1]
        );
        signal = carrier + noise;

        pitch_envs[4] = EnvGen.kr
        (
            Env
            (
                [pitch_starts[4], pitch_ends[4]],
                [rel_times[4]],
                pitch_slopes[4]
            ),
            doneAction: Done.freeSelf
        );
        signal = BLowPass.ar
        (
            in: signal,
            freq: pitch_envs[4] * filter_moddepth,
            rq: filter_rq
        );
        Out.ar(out, signal ! 2);
    }
).add();
)

(
~kick.stop();
~kick = Pbind(
    \instrument, \Kick,
    \rel_time, 0.400,
    \pitch_start, 300,
    \pitch_end, 40,
    \pitch_slope, -10,
    \filter_moddepth, 4,
    \dur, Pseq([1, 1, 1, 0.75, 0.25], inf),
).play(quant: 1);
)


(
~snare.stop();
~snare = Pbind(
    \instrument, \Snare,
    \rel_time, 0.250,
    \triangle_pitch_start, 160,
    \triangle_pitch_end, 100,
    \triangle_pitch_slope, -1,
    \filter_moddepth, 100,
    \filter_rq, 1,
    \filter_pitch_start, 160,
    \filter_pitch_end, 160,
    \filter_pitch_slope, \linear,
    \snap, 0.20,
    \dur, Pseq([15.50, 0.50], inf),
).play(quant: [1,0.75]);
)

(
~toms.stop();
~toms = Pbind(
    \instrument, \Toms,
    \rel_time, 0.300,
    \triangle_pitch_start, 35,
    \triangle_pitch_end, 30,
    \triangle_pitch_slope, \linear,
    \triangle_filter_moddepth, 3,
    \triangle_filter_rq, 0.6,
    \noise_pitch_start, 50,
    \noise_pitch_end, 20,
    \noise_pitch_slope, -30,
    \noise_filter_moddepth, 5.5,
    \noise_filter_rq, 0.1,
    \midinote, Pseq([0, 10, 5, 0, 5], inf),
    \dur, Pseq([0.5, 0.75, 0.25, 0.5, 0.25], inf),
).play(quant: 1);
)

(
var rel = 0.30;
~claves.stop();
~claves = Pbind(
    \instrument, \Claves,
    \att_times,    [[0.00, 0.00, 0.00, 0.00, 0.00]],
    \rel_times,    [[0.05, rel, rel, rel, rel]],
    \amp_slopes,   [[\lin, \lin, \lin, \lin]],
    \pitch_starts, [[100, 400, 200, 800, 400]],
    \pitch_ends,   [[100, 200, 100, 400, 100]],
    \pitch_slopes, [[\lin, -4, -4, -4, -4]],
    \fm_moddepths, [3000, 1000],
    \filter_moddepth, 0.6,
    \filter_rq, 0.1,
    \snap, 1,
    \midinote, Pseq([0, 10, 5, 0, 5], inf),
    \dur, Pseq([0.5, 0.75, 0.25, 0.5, 0.25], inf),
).play(quant: 1);
)









