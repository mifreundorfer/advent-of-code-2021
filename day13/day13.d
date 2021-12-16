import std;

void main()
{
    Point[] points = [];
    string[] lines = readText("day13/input.txt").splitLines();
    size_t i = 0;
    for (; i < lines.length; i++) {
        string line = lines[i];
        if (line.length == 0) {
            break;
        }

        string[] parts = line.split(',');
        points ~= Point(parts[0].to!int, parts[1].to!int);
    }

    i++;
    Point[] folds = [];
    for (; i < lines.length; i++) {
        string line = lines[i];
        assert(line[0 .. 10] == "fold along");
        if (line[11] == 'x') {
            folds ~= Point(line[13 .. $].to!int, 0);
        } else if (line[11] == 'y') {
            folds ~= Point(0, line[13 .. $].to!int);
        } else {
            assert(false);
        }
    }

    foreach (j, Point fold; folds) {
        if (fold.x == 0) {
            foreach (ref Point point; points) {
                if (point.y > fold.y) {
                    point.y = fold.y - (point.y - fold.y);
                }
            }
        } else {
            foreach (ref Point point; points) {
                if (point.x > fold.x) {
                    point.x = fold.x - (point.x - fold.x);
                }
            }
        }

        removeDuplicates(points);
        if (j == 0) {
            writefln("After one fold there are %s points remaining", points.length);
        }
    }

    int sizeX = points.map!(a => a.x).maxElement + 1;
    int sizeY = points.map!(a => a.y).maxElement + 1;

    writeln("The code is:");
    foreach (y; 0 .. sizeY) {
        writeln(iota(0, sizeX).map!(a => points.count!(b => b == Point(a, y)) == 0 ? " " : "#").join);
    }
}

struct Point {
    int x;
    int y;
}

void removeDuplicates(ref Point[] points) {
    bool[Point] map;
    int i = 0;
    for (; i < points.length; i++) {
        if (points[i] in map) {
            points[i] = points[$-1];
            points.length -= 1;
            i--;
        } else {
            map[points[i]] = true;
        }
    }

    points.length = i;
}