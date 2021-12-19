import std;

void main() {
    int[][] grid;
    foreach (string line; readText("day15/input.txt").splitLines()) {
        grid ~= line.map!(x => cast(int)(x - '0')).array;
    }

    int countX = cast(int)grid[0].length;
    int countY = cast(int)grid.length;

    int[][] cost;
    foreach (i; 0 .. countY) {
        cost ~= repeat!int(int.max, countX).array;
    }

    cost[0][0] = 0;
    auto todo = heapify!("a > b")([Index(0, 0, 0)]);
    foreach (index; todo) {
        int currentCost = cost[index.y][index.x];

        if (index.x > 0) {
            int newCost = currentCost + grid[index.y][index.x - 1];
            if (newCost < cost[index.y][index.x - 1]) {
                cost[index.y][index.x - 1] = newCost;
                todo.insert(Index(newCost, index.x - 1, index.y));
            }
        }

        if (index.y > 0) {
            int newCost = currentCost + grid[index.y - 1][index.x];
            if (newCost < cost[index.y - 1][index.x]) {
                cost[index.y - 1][index.x] = newCost;
                todo.insert(Index(newCost, index.x, index.y - 1));
            }
        }

        if (index.x < countX - 1) {
            int newCost = currentCost + grid[index.y][index.x + 1];
            if (newCost < cost[index.y][index.x + 1]) {
                cost[index.y][index.x + 1] = newCost;
                todo.insert(Index(newCost, index.x + 1, index.y));
            }
        }

        if (index.y < countY - 1) {
            int newCost = currentCost + grid[index.y + 1][index.x];
            if (newCost < cost[index.y + 1][index.x]) {
                cost[index.y + 1][index.x] = newCost;
                todo.insert(Index(newCost, index.x, index.y + 1));
            }
        }
    }

    writefln("The lowest total risk is %s", cost[countY - 1][countX - 1]);

    int[][] largeGrid;
    foreach (row; grid) {
        int[] largeRow;
        foreach (i; 0 .. 5) {
            largeRow ~= row.map!(a => (a + i - 1) % 9 + 1).array;
        }

        largeGrid ~= largeRow;
    }

    foreach (i; 1 .. 5) {
        foreach (row; 0 .. countY) {
            largeGrid ~= largeGrid[row].map!(a => (a + i - 1) % 9 + 1).array;
        }
    }

    assert(largeGrid.length == countY * 5);
    assert(largeGrid[0].length == countX * 5);

    grid = largeGrid;

    countX = cast(int)grid[0].length;
    countY = cast(int)grid.length;

    cost = [];
    foreach (i; 0 .. countY) {
        cost ~= repeat!int(int.max, countX).array;
    }

    cost[0][0] = 0;
    todo = heapify!("a > b")([Index(0, 0, 0)]);
    foreach (index; todo) {
        int currentCost = cost[index.y][index.x];

        if (index.x > 0) {
            int newCost = currentCost + grid[index.y][index.x - 1];
            if (newCost < cost[index.y][index.x - 1]) {
                cost[index.y][index.x - 1] = newCost;
                todo.insert(Index(newCost, index.x - 1, index.y));
            }
        }

        if (index.y > 0) {
            int newCost = currentCost + grid[index.y - 1][index.x];
            if (newCost < cost[index.y - 1][index.x]) {
                cost[index.y - 1][index.x] = newCost;
                todo.insert(Index(newCost, index.x, index.y - 1));
            }
        }

        if (index.x < countX - 1) {
            int newCost = currentCost + grid[index.y][index.x + 1];
            if (newCost < cost[index.y][index.x + 1]) {
                cost[index.y][index.x + 1] = newCost;
                todo.insert(Index(newCost, index.x + 1, index.y));
            }
        }

        if (index.y < countY - 1) {
            int newCost = currentCost + grid[index.y + 1][index.x];
            if (newCost < cost[index.y + 1][index.x]) {
                cost[index.y + 1][index.x] = newCost;
                todo.insert(Index(newCost, index.x, index.y + 1));
            }
        }
    }

    writefln("The lowest total risk for the larger map is %s", cost[countY - 1][countX - 1]);
}

struct Index {
    int cost;
    int x;
    int y;

    int opCmp(Index other) const {
        if (cost < other.cost) {
            return -1;
        } else if (cost > other.cost) {
            return 1;
        }

        return 0;
    }
}