import std;

struct Display
{
    string[] patterns;
    string[] output;

    static Display parse(string line)
    {
        auto parts = line.split('|').array;
        auto patterns = parts[0].strip.split(' ').array;
        auto output = parts[1].strip.split(' ').array;
        return Display(patterns, output);
    }

    string findDigitPatternOfLength(int length)
    {
        foreach (pattern; patterns) {
            if (pattern.length == length) {
                return pattern;
            }
        }

        // foreach (pattern; output){
        //     if (pattern.length == length) {
        //         return pattern;
        //     }
        // }

        return null;
    }

    string[] findAllDigitPatternsOfLength(int length)
    {
        string[] result = null;
        foreach (pattern; patterns)
        {
            if (pattern.length == length)
            {
                result ~= pattern;
            }
        }

        // foreach (pattern; output)
        // {
        //     if (pattern.length == length)
        //     {
        //         result ~= pattern;
        //     }
        // }

        return result;
    }
}

void main()
{
    // Display format
    // 0: 6 segments: abcefg
    // 1: 2 segments: cf
    // 2: 5 segments: acdeg
    // 3: 5 segments: acdfg
    // 4: 4 segments: bcdf
    // 5: 5 segments: abdfg
    // 6: 6 segments: abdefg
    // 7: 3 segments: acf
    // 8: 7 segments: abcdefg
    // 9: 6 segments: abcdfg

    immutable string[] validPatterns =
    [
        "abcefg", // 0
        "cf",     // 1
        "acdeg",  // 2
        "acdfg",  // 3
        "bcdf",   // 4
        "abdfg",  // 5
        "abdefg", // 6
        "acf",    // 7
        "abcdefg",// 8
        "abcdfg", // 9
    ];

    Display[] displays = readText("day8/input.txt").splitLines().map!(Display.parse).array;

    int numEasyNumbers = 0;
    foreach (display; displays)
    {
        numEasyNumbers += display.output.count!(x => x.length == 2 || x.length == 3 || x.length == 4 || x.length == 7);
    }

    writefln("1, 4, 7, 8 appears %s times in the output", numEasyNumbers);

    int sum = 0;
    foreach (display; displays)
    {
        char[char] map = null;
        string one = display.findDigitPatternOfLength(2);
        string four = display.findDigitPatternOfLength(4);
        string seven = display.findDigitPatternOfLength(3);
        string eight = display.findDigitPatternOfLength(7);
        string[] patternsOf6 = display.findAllDigitPatternsOfLength(6);

        assert(one !is null && four !is null && seven !is null && eight !is null);

        // 'a' is the difference between 1 and 7
        map[findSingleUnkown(seven, one, map)] = 'a';

        // now that we know what 'a' is, 9 has only one unknown digit that is not in 4
        string nine = identifyWithSingleUnkown(patternsOf6, four, map);

        // the character that is different from 9 and 4 is 'g'
        map[findSingleUnkown(nine, four, map)] = 'g';

        // then, difference between 9 and 8 is 'e'
        map[findSingleUnkown(eight, nine, map)] = 'e';

        // now 0 has only one different from 1
        string zero = identifyWithSingleUnkown(patternsOf6, one, map);

        // the character that is different from 0 and 1 is 'b'
        map[findSingleUnkown(zero, one, map)] = 'b';

        // the character that is different from eight and seven is 'd'
        map[findSingleUnkown(eight, seven, map)] = 'd';

        // six only has one unkown left
        string six = identifyWithSingleUnkown(patternsOf6, map);

        // that unkown is 'f'
        map[findSingleUnkown(six, map)] = 'f';

        // this leaves only 'c'
        map[findSingleUnkown(eight, map)] = 'c';

        int number = 0;
        foreach (pattern; display.output) {
            string correctedPattern = pattern.byCodeUnit.map!((x) => map[x]).to!string;
            int digit = -1;
            foreach (i, validPattern; validPatterns) {
                if (correctedPattern.length == validPattern.length) {
                    int matching = 0;
                    foreach (segment; correctedPattern) {
                        if (validPattern.count(segment)) {
                            matching += 1;
                        }
                    }

                    if (matching == validPattern.length) {
                        assert(digit == -1);
                        digit = cast(int)i;
                    }
                }
            }

            assert(digit != -1);
            number *= 10;
            number += digit;
        }

        sum += number;
    }

    writefln("The sum of all numbers is %s", sum);
}

char findSingleUnkown(string withExtraChar, string other, char[char] knownMap)
{
    char result = 0;

    foreach (segment; withExtraChar) {
        if (segment in knownMap) {
            continue;
        }

        if (!other.count(segment)) {
            assert(result == 0);
            result = segment;
        }
    }

    assert(result != 0);

    return result;
}

char findSingleUnkown(string withSingleUnkown, char[char] knownMap)
{
    char result = 0;

    foreach (segment; withSingleUnkown) {
        if (segment in knownMap) {
            continue;
        }

        assert(result == 0);
        result = segment;
    }

    assert(result != 0);

    return result;
}

string identifyWithSingleUnkown(string[] options, string other, char[char] knownMap)
{
    string result = null;
    foreach (pattern; options) {
        int numNotInOther = 0;
        foreach (segment; pattern) {
            if (segment in knownMap) {
                continue;
            }

            if (!other.count(segment)) {
                numNotInOther += 1;
            }
        }

        if (numNotInOther == 1) {
            assert(result is null);
            result = pattern;
        }
    }

    assert(result !is null);
    return result;
}

string identifyWithSingleUnkown(string[] options, char[char] knownMap)
{
    string result = null;

    foreach (pattern; options) {
        int numUnkown = 0;
        foreach (segment; pattern) {
            if (segment in knownMap) {
                continue;
            }

            numUnkown += 1;
        }

        if (numUnkown == 1) {
            assert(result is null);
            result = pattern;
        }
    }

    assert(result !is null);

    return result;
}