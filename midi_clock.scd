/*
 * Start a internal clock responging to midiclock ticks,
 * before start sending midiclock signals
 */
(
var ppqn = 48;
var i = 0;
~clock_pulse = 0;
~midi_clock = MIDIdef.midiClock(\midi_tick,
    {
        ~clock_pulse = (~clock_pulse + 1) % ppqn;
    }
)
)
