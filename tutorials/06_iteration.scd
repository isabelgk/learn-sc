// https://www.youtube.com/watch?v=bMGXYEg1gJo

// Iteration can be done over collections
// Check out the Collection help file, specifically the Iteration section.


// --- Iteration --
// `do` evaluates a function for each item in a collection
[6, 4, 0.5, 10, 7].do{"hello".postln};
// As a side effect, the collection is also posted to the post window.
// This happens because `do` returns the receiver

// If you want to use the collection's items in the function, you need
// to declare an input argument.
(
[6, 4, 0.5, 10, 7].do{
	arg item, count;
	[count, item.squared].postln;
}
)

// If you want to modify the collection itself...
(
x = Array.newClear(5);

[6, 4, 0.5, 10, 7].do{
	arg item, count;
	x[count] = item.squared;
}
)
x;

// It's better to use `collect` than the above method:
(
z = [6, 4, 0.5, 10, 7].collect{
	arg item;
	item.squared;
}
)

// Even faster:
z = [6, 4, 0.5, 10, 7].collect(_.squared);

// Ranges:
[0, 1, 2, 3, 4].do{arg item; item.postln};
5.do{arg item; item.postln};



// --- Iterative Synthesis ---

// A basic dual-saw:
x = {VarSaw.ar(40!2, 0, 0.05)}.play;
x.free;


// We can improve with iteration:
(
SynthDef.new(\iter, {
	arg freq=40;
	var temp, sum, env;
	sum = 0;  // Must be initialized, otherwise it'll be `nil`

	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);

	// We'll create 10 different `VarSaw`s
	10.do{
		temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,    // Phase -- randomized to avoid
			                       // a pop at the beginning
			{Rand(0.005, 0.05)}!2  // Duty-cycle, randomized for fun
		);

		// Accumulate the saws
		sum = sum + temp;
	};

	// Scale it down
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter, [\freq, 400]);
x = Synth.new(\iter, [\freq, 300]);
x = Synth.new(\iter, [\freq, 66.midicps]);  // MIDI note conversion!

// We can use iteration to make multiple synths at once.
// This isn't a great idea generally since they're not sample-accurately
// synced, but it's a useful example anyway.
(
[53, 59, 63, 68].do{
	arg midinote;
	Synth.new(\iter, [\freq, midinote.midicps]);
}
)

// Let's try another example:
(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum = 0;
	10.do{
		// Items and iteration count are the same, so no need for item, count
		arg count;
		// Add an overtone:
		temp = SinOsc.ar(freq * (count + 1)); // add one to avoid 0 Hz osc
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)
x = Synth.new(\iter2);
x.free;

// This is actually already a UGen (with less flexibility)
x = {Blip.ar(200, 10, 0.5)}.play;
x.free;

// With iteration, we can do interesting things to each overtone
(
SynthDef.new(\iter2, {
	arg freq=200, dev=1.02;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;

		// Fluctuate frequency
		temp = SinOsc.ar(
			freq *
			(count + 1) *
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(dev.reciprocal, dev)
		);

		// Fluctuate amplitude
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).exprange(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)
x = Synth.new(\iter2);
x.set(\freq, 50);
x.set(\dev, 1.3);
x.free;

// One problem, though, is that we can't make the number of iterations
// an argument. There's not really a solution here.