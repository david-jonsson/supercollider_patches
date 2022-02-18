s.boot;

"midi_clock.scd".loadRelative;

MIDIClient.init;
~midi_in = MIDIIn.findPort ("SQ-64", "SQ-64 SQ-64 _ MIDI OUT 2");
MIDIIn.connect(0, ~midi_in.uid);

(
/*
 * Maybe change pressed to a circular buffer to do
 * some more fancy stuff like randomization
 */
var pressed = LinkedList.new();
var playing = Array.fill(128, { false; });
var channel = 1;
var note_length = 12;
var new_synth = nil;
var i = 0;

~arp_on.free;
~arp_on = MIDIdef.noteOn(\arp_on,
    {
        arg vel, nn;
        playing[nn] = true;
        pressed.add(nn);
    },
    chan: channel
);

~arp_off.free;
~arp_off = MIDIdef.noteOff(\arp_off,
    {
        arg vel, nn, triggs;
        playing[nn] = false;r
    },
    chan: channel
);

~arp_tick.free;
~arp_tick = MIDIdef.midiClock(\arp_tick,
    {
        arg ... args;
        var
        modd = ~clock_pulse % note_length,
        next_note;
        i = i + 1;
        if(modd == 0,
            {

                if(new_synth != nil, { new_synth.free; new_synth = nil; });
                next_note = pressed.popFirst;

                while(
                    {
                        if(next_note == nil,
                            { false },
                            { playing[next_note] == false }
                        );
                    },
                    {
                        next_note = pressed.popFirst;
                    }
                );
                if(next_note != nil,
                    {
                        new_synth = Synth.new("default", [\freq, next_note.midicps, \amp, 1]);
                        pressed.add(next_note);
                    };
                );
            };
        );
    },
);
)