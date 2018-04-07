var notes=["C", "CS", "D", "DS", "E", "F", "FS", "G", "GS", "A", "AS", "B"];
var octaves=[-3, -2, -1, 0, 1, 2, 3, 4, 5, 6];
var gen = function(octaves, notes)
{
    var result = "";
    var sounds = {};
    counter = 0;
    for (o in octaves) {
        sounds[String(octaves[o])] = {};
        result += "{* OCTAVE " + octaves[o] + " *}\n";
        for (n in notes) {
            result += notes[n] + "_";

            if (octaves[o] < 0) {
                result += "S";
            }

            result += Math.abs(octaves[o]);

            var offset = (12 * parseInt(octaves[o]) + parseInt(n) + 3);
            result += " = " + offset + "; ";
            sounds[String(octaves[o])][notes[n]] = offset;

            if (++counter % 6 == 0) {
                result += "\n";
            }

            if (counter % 12 == 0) {
                result += "\n";
            }
        }
    }

    return {pascal: result, sounds: sounds};
};

var generated = gen(octaves, notes).sounds;
var sequencor = function(melody, _target) {
    for (let i in melody) {
        let sound = melody[i];
        if (typeof(sound[0]) != "number") {
             _target.push(sound);
             continue;
        }

        for (let j = 0; j < parseInt(sound[0]); j++) {
            sequencor(sound[1], _target);
       }
    }
};
var parse = function (melody) {
    var scase = "\tcase tick of";
    var counter = 1;

    for (i in melody) {
        scase += "\n\t\t";
        var sound = melody[i];
        console.log(sound);

        if (sound[0] == null) {
            scase += String(counter) + ": nosound;";
            counter += sound[1];
            continue;
        }

        var note = sound[0];
        var octave = sound[1];
        var duration = sound[2];

        var noteId = (12 * parseInt(octave) + notes.indexOf(note) + 3)
        scase += String(counter) + ": sound(frequency(" + noteId + "));"

        counter += duration;
    }
    scase += "\n\t\t" + counter + ": tick := 0";

    scase += "\n\tend;";

    return scase
};
var melody = [
    ["D", 0, 4], ["B", 0, 4], ["B", 0, 4], ["A", 0, 4], ["B", 0, 4], ["G", 0, 4], ["D", 0, 4], ["D", 0, 4], [null, 1],
    ["D", 0, 4], ["B", 0, 4], ["B", 0, 4], ["C", 1, 4], ["E", 1, 4], ["D", 1, 4], [null, 8],
    ["D", 1, 4], ["E", 0, 4], ["E", 0, 4], ["C", 1, 4], ["C", 1, 4], ["B", 0, 4], ["A", 0, 4], ["G", 0, 4],
    ["D", 0, 4], ["B", 0, 4], ["B", 0, 4], ["A", 0, 4], ["B", 0, 4], ["G", 0, 4], [null, 16]
];

var _melody = [
    [4, [["F", 0, 8], [3, [["F", 0, 3]]], [null, 1], ["F", 0, 8],
    [2, [["A", 0, 4]]], ["F", 0, 4], ["G", 0, 8], [4, [["G", 0, 3]]], ["G", 0, 4], [2, [[null, 1], ["C", 1, 8]]], ["B", 0, 8]]], ["C", -2, 32], [null, 16]
]
var _melody = [
    ["G", -1, 4],[4, [[null, 1], ["G", 0, 4]]], ["G", 1, 4]
]

//var result = parse(sequencor(melody));
var newMelody = [];
sequencor(melody, newMelody);
var result = parse(newMelody);
console.log(result);
