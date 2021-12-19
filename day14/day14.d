import std;

void main() {
    string[] lines = readText("day14/input.txt").splitLines();
    string origialPoly = lines[0];

    char[string] templates;
    foreach (string line; lines[2 .. $]) {
        string[] parts = line.split("->");
        templates[parts[0].strip()] = parts[1].strip()[0];
    }

    {
        string poly = origialPoly;
        foreach (iter; 0 .. 10) {
            Appender!string tmp;

            foreach (i; 0 .. cast(long)poly.length - 1) {
                tmp ~= poly[i];
                tmp ~= templates[poly[i .. i + 2]];
            }

            tmp ~= poly[$ - 1];

            poly = tmp[];
        }

        Element[char] elem_counts;
        foreach (char elem; poly) {
            if (Element* ptr = elem in elem_counts) {
                ptr.count += 1;
            } else {
                elem_counts[elem] = Element(elem, 1);
            }
        }

        Element[] elements = elem_counts.values;
        Element max = elements.maxElement!(a => a.count);
        Element min = elements.minElement!(a => a.count);

        writefln("After 10 iterations the difference between the maximum and minimum element is %s", max.count - min.count);
    }

    {
        long[string] pairs;
        long[string] tmpPairs;
        foreach (key; templates.keys) {
            pairs[key] = 0;
        }

        foreach (i; 0 .. cast(long)origialPoly.length - 1) {
            pairs[origialPoly[i .. i + 2]] += 1;
        }

        // Each pair can be expanded independently of its neighbours. We simply need to
        // assume that each pair has a connecting pair on the left and right, but the
        // actual pairing does not matter.
        foreach (iter; 0 .. 40) {
            foreach (key; pairs.keys) {
                tmpPairs[key] = 0;
            }

            foreach (pair, count; pairs) {
                char c = templates[pair];
                tmpPairs[pair[0 .. 1] ~ c] += count;
                tmpPairs[c ~ pair[1 .. 2]] += count;
            }

            swap(pairs, tmpPairs);
        }

        // Count the number of elements in each pair
        Element[char] elem_counts;
        foreach (pair, count; pairs) {
            if (Element* ptr = pair[0] in elem_counts) {
                ptr.count += count;
            } else {
                elem_counts[pair[0]] = Element(pair[0], count);
            }

            if (Element* ptr = pair[1] in elem_counts) {
                ptr.count += count;
            } else {
                elem_counts[pair[1]] = Element(pair[1], count);
            }
        }

        // Because each pair shares both elements with another pair, the total count
        // for each element is twice as high as it should be. Care needs to be taken
        // for the first and last element, as those are not repeated in another pair
        // and need to be counted twice before division.
        elem_counts[origialPoly[0]].count += 1;
        elem_counts[origialPoly[$-1]].count += 1;
        foreach (key; elem_counts.keys) {
            elem_counts[key].count /= 2;
        }

        Element[] elements = elem_counts.values;
        Element max = elements.maxElement!(a => a.count);
        Element min = elements.minElement!(a => a.count);

        writefln("After 40 iterations the difference between the maximum and minimum element is %s", max.count - min.count);
    }
}

struct Element {
    char code;
    long count;
}
