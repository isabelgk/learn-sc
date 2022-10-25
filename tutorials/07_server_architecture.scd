// https://www.youtube.com/watch?v=VGs_lMw2hQg

s.boot;
s.plotTree;
s.meter;

// --- Nodes ---
// A node is an abstract class which represents items on the server.
// There are two types of nodes that we deal with directly in SC.
// Node -> [Synth, Group]


// --- Busses ---
// Busses send signals between synths.


// --- Order of Execution ---
// This refers to the order of sending signals.


// Let's look at practical examples.
(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(out, sig);  // <== sending to another synth
	                   // via a named output channel
}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
	Out.ar(out, sig);
}).add;
)

s.options.numAudioBusChannels;
s.options.numOutputBusChannels;
s.options.numInputBusChannels;

// to change:
s.options.numInputBusChannels = 4;
s.options.numOutputBusChannels = 4;
s.reboot;
s.meter;

y = Synth.new(\reverb, [\in, 4]);
x = Synth.new(\blip, [\out, 4]);
x.set(\out, 25);  // Now there's no output being sent to the
                  // reverb, so we don't hear anything
y.set(\in, 25);  // Now it works again
x.free; // We can stop the source, but keep the effect
y.free;


// To avoid hardcoding the number of the bus, you can use Bus.audio
~reverbBus = Bus.audio(s, 1);
// SuperCollider always picks the lowest hardware bus that doesn't
// conflict
~reverbBus.index;

y = Synth.new(\reverb, [\in, ~reverbBus.index]);
x = Synth.new(\blip, [\out, ~reverbBus]);  // `.index` is implied



// Let's see how SC deals with bussing multi-channel signals
(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);

	sig = Pan2.ar(sig, LFNoise1.kr(10));  // <== multichannel UGens
	                                      // "hide" that they're
	                                      // multichannel a bit since
	                                      // there are no arrays
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);  // <== takes two inputs now
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);  // <== no more need to dup
	Out.ar(out, sig);
}).add;
)

~dualBus = Bus.audio(s, 2);

// If you look at the output, now two channels are separate
y = Synth.new(\reverb, [\in, ~dualBus]);
x = Synth.new(\blip, [\out, ~dualBus]);


// One channel of audio = one bus
// Multichannel audio allocates multiple busses
~dualBus.index;

// You can still use the "one-channel" bus with the dual-channel synth
// which might be problematic with overlap!



// --- Order of Execution ---
// What if we switch the order we create the synths?
s.plotTree;
x = Synth.new(\blip, [\out, ~dualBus]);   // source ("node") finishes first
y = Synth.new(\reverb, [\in, ~dualBus]);  // effect ("head") gets added before blip
// No sound! Why? See "Order of execution" help:
//   if you have a synth on the server (i.e. an "effect")
//   that depends on the output from another synth (the "source"),
//   the effect must appear later in the chain of nodes on the
//   server than the source



// --- Group ---
// A collection of nodes in a specific order. The nodes can be synths or groups or
// some combination. Adding a synth node shows up as a white rectangle on the
// plot tree. Adding a group is a gray rectangle.
x = Synth.new(\blip, [\out, ~dualBus]);
g = Group.new;
x.free;
g.free;  // Groups can also be freed


// Let's revisit the Synth help and `target` and `addAction` args.
// `s` = target server
x = Synth.new(\blip, [\out, ~dualBus], s);
y = Synth.new(\reverb, [\in, ~dualBus], s, \addToTail);
                                        // ^ as opposed to default \addToHead

// could also make the synth a target and place the reverb after the synth
// y = Synth.new(\reverb, [\in, ~dualBus], x, \addAfter);
x = Synth.before(y, \blip, [\out, ~dualBus]);


// There are convenience "add" methods you can find for add actions.

// It can sometimes be a good idea to create source groups and effect groups
// like this:
~sourceGrp = Group.new;
~fxGrp = Group.after(~sourceGrp);
x = Synth.new(\blip, [\out, ~dualBus], ~sourceGrp);
y = Synth.new(\reverb, [\in, ~dualBus], ~fxGrp);



// Here's one last example to showcase the usefulness of separate groups.
(
SynthDef.new(\blip, {
	arg out, fund=300, dens=2, decay=0.2;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(fund);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);  // <== takes two inputs now
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);  // <== no more need to dup
	Out.ar(out, sig);
}).add;
)

// Using iteration, we can create eight instances of the SynthDef
(
8.do{
	Synth.new(
		\blip,
		[
			\out, ~dualBus,
			\fund, exprand(60, 300).round(30)
		],
		~sourceGrp
	);
}
)
y = Synth.new(\reverb, [\in, ~dualBus], ~fxGrp);

// ... and with a group, we can relay messages to every node in it
~sourceGrp.set(\decay, 0.03);
~sourceGrp.set(\dens, 0.25);
~sourceGrp.freeAll;