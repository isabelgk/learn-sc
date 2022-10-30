// https://www.youtube.com/watch?v=_GZmuvmgtUc


// --- Basics ---
// Buffers hold sampled audio like soundfiles and are client-side
// representations of data on a server
s.boot;
p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
~b0 = Buffer.read(s, p);
~b0.play;  // listen
~b0.zero;  // cleared, but not removed from the server

~b0.free;  // remove entirely from the server
~b0.play  // <== fails
// get it back
~b0 = Buffer.read(s, p);

~b1 = Buffer.read(s, Platform.resourceDir +/+ "sounds/SinedPink.aiff");
~b1.play;

~b0.numFrames;
~b0.numChannels;
// numSamples = numFrames * numChannels;

// What if you have a stereo audio file but only want one channel?
~b2 = Buffer.readChannel(s, p, channels:[0]);
~b2.numChannels;

~b2.duration;

// Buffers are given numbers when they are allocated and will be unique
~b0.bufnum;
~b1.bufnum;
~b2.bufnum;

// You can get sample rate
~b0.sampleRate;
s.sampleRate;

// You can get all the info about a buffer
~b0.query;



// --- Reading part of a sample ---
~b0_part0 = Buffer.read(s, p, 0, s.sampleRate / 2);
~b0_part0.play;
~b0_part1 = Buffer.read(s, p, 130000, ~b0.numFrames - 130000);
~b0_part1.play;



// --- Reading multiple files ---
~bells = Array.new;
~folder = PathName.new("/some/path/with/bells");
(
~folder.entries.do({
	arg path;
	~bells = ~bells.add(Buffer.read(s, path.fullPath));
});
)
~bells.at(0).play;
~bells.at(4).play;
~bells.at(7).play;
~bells[12].play;  // square brackets also work
// There's a limit of buffers you can store, and you can update it
s.options.numBuffers;
s.options.numBuffers = 2000;



// --- PlayBuf ---
(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf;
	var sig;
	sig = PlayBuf.ar(2, buf);  // <== cannot make channels dynamic
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test, [\buf, ~b1.bufnum]);
Synth.new(\playbuf_test, [\buf, ~b0.bufnum]);  // <== buffer channel mismatch

s.plotTree;
s.freeAll;  // <== PlayBufs will build up


(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, da=2;
	var sig;

	// Dealing with samplerate mismatch...
	// UGens > Buffer > Info > BufRateScale
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, doneAction:da);

	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)
Synth.new(\playbuf_test, [\buf, ~b1.bufnum, \rate, 0.01]);


// Adding a trigger and loop
(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, t_trig=1, loop=0, start=0, da=2;
	var sig;
	sig = PlayBuf.ar(
		2,
		buf,
		BufRateScale.kr(buf) * rate,
		t_trig,  // jump to startPos
		start,   // frame to start playback
		loop,
		doneAction:da
	);

	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)
x = Synth.new(\playbuf_test, [\buf, ~b1.bufnum, \rate, 0.01, \loop, 1]);
x.set(\t_trig, 1);
x.set(\loop, 0);
x.free;


// A brief interlude in ratio for rate scaling...
12.midiratio;
7.midiratio;
Synth.new(\playbuf_test, [\buf, ~b1.bufnum, \rate, -7.midiratio]);
Synth.new(\playbuf_test, [\buf, ~b1.bufnum, \rate, -12.midiratio]);


g = Group.new;
(
x = Synth.new(\playbuf_test, [\buf, ~b1.bufnum, \rate, 1.5, \loop, 1, \amp, 0.5], g);
y = Synth.new(\playbuf_test, [\buf, ~b1.bufnum, \rate, 1.2, \loop, 1, \amp, 0.5], g);
)
g.set(\rate, 0.5);
g.free;



// --- BufRd ---
(
SynthDef.new(\bufrd_test, {
	arg amp=1, out=0, buf, start, end;
	var sig, ptr;
	ptr = Line.ar(start, end, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\bufrd_test, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames]);


(
SynthDef.new(\bufrd_loop, {
	arg amp=1, out=0, buf, start, end, rate=1;
	var sig, ptr;
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)
x = Synth.new(\bufrd_loop, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames]);

