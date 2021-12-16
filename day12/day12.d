import std;

void main() {
    Cave[string] caves;
    foreach(string line; readText("day12/input.txt").splitLines()) {
        string[] parts = line.split('-');
        string name1 = parts[0];
        string name2 = parts[1];

        Cave cave1;
        Cave cave2;
        if (name1 in caves) {
            cave1 = caves[name1];
        } else {
            cave1 = new Cave(name1);
            caves[name1] = cave1;
        }

        if (name2 in caves) {
            cave2 = caves[name2];
        } else {
            cave2 = new Cave(name2);
            caves[name2] = cave2;
        }

        cave1.connected ~= cave2;
        cave2.connected ~= cave1;
    }

    Cave start_cave = caves["start"];
    Cave end_cave = caves["end"];

    Cave[][] paths = [];

    PathNode[] working_path = [PathNode(start_cave, 0)];
    while (working_path.length > 0) {
        PathNode* node = &working_path[$-1];
        if (node.cave == end_cave) {
            Cave[] path = working_path.map!(x => x.cave).array;
            paths ~= path;
            working_path.length -= 1;
            continue;
        }

        if (node.current_connection >= node.cave.connected.length) {
            working_path.length -= 1;
            continue;
        }

        Cave connected = node.cave.connected[node.current_connection];
        node.current_connection += 1;
        if (!connected.can_visit_multiple_times && working_path.count!(a => connected is a.cave) != 0) {
            continue;
        }

        working_path ~= PathNode(connected, 0);
    }

    writefln("There are %s distinct paths through the cave system", paths.length);

    paths = [];
    working_path = [PathNode(start_cave, 0)];
    Cave visited_twice = null;
    while (working_path.length > 0) {
        PathNode* node = &working_path[$ - 1];
        if (node.cave == end_cave) {
            Cave[] path = working_path.map!(x => x.cave).array;
            paths ~= path;
            working_path.length -= 1;
            continue;
        }

        if (node.current_connection >= node.cave.connected.length) {
            working_path.length -= 1;
            if (visited_twice is node.cave) {
                visited_twice = null;
            }
            continue;
        }

        Cave connected = node.cave.connected[node.current_connection];
        node.current_connection += 1;
        if (connected.can_visit_multiple_times) {
            working_path ~= PathNode(connected, 0);
        } else {
            ulong visited_count = working_path.count!(a => connected is a.cave);
            if (visited_count == 0) {
                working_path ~= PathNode(connected, 0);
            } else if (visited_count == 1 && connected != start_cave && visited_twice is null) {
                working_path ~= PathNode(connected, 0);
                visited_twice = connected;
            }
        }
    }

    writefln("When visiting a single small cave twice there are %s distinct paths through the cave system", paths.length);
}

class Cave {
    string name;
    bool can_visit_multiple_times;
    Cave[] connected;

    this(string name) {
        this.name = name;
        can_visit_multiple_times = name.map!(a => std.ascii.isUpper(a)).all;
    }
}

struct PathNode {
    Cave cave;
    int current_connection;
}