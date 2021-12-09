import std;

struct Point
{
    int x1;
    int y1;
    int x2;
    int y2;

    static Point parse(string line)
    {
        string[] parts = line.split("->").array;
        int[] p1 = parts[0].strip.split(',').map!(to!int).array;
        int[] p2 = parts[1].strip.split(',').map!(to!int).array;
        return Point(p1[0], p1[1], p2[0], p2[1]);
    }
}

void main()
{
    Point[] points = readText("day5/input.txt").splitLines.map!(Point.parse).array;

    int gridSizeX = points.map!((p) => max(p.x1, p.x2)).maxElement + 1;
    int gridSizeY = points.map!((p) => max(p.y1, p.y2)).maxElement + 1;

    auto grid = new int[gridSizeX * gridSizeY];
    grid[] = 0;

    foreach (point; points)
    {
        if (point.x1 == point.x2)
        {
            int start = min(point.y1, point.y2);
            int end = max(point.y1, point.y2);
            for (int i = start; i <= end; i++)
            {
                grid[point.x1 + i * gridSizeX] += 1;
            }
        }
        else if (point.y1 == point.y2)
        {
            int start = min(point.x1, point.x2);
            int end = max(point.x1, point.x2);
            for (int i = start; i <= end; i++)
            {
                grid[i + point.y1 * gridSizeX] += 1;
            }
        }
    }

    writefln("Number of areas to avoid: %d", grid.count!("a > 1"));

    grid[] = 0;
    foreach (point; points)
    {
        int startX = point.x1;
        int startY = point.y1;

        int stepX = point.x1 == point.x2 ? 0 : (point.x1 > point.x2 ? -1 : 1);
        int stepY = point.y1 == point.y2 ? 0 : (point.y1 > point.y2 ? -1 : 1);

        int countX = abs(point.x1 - point.x2);
        int countY = abs(point.y1 - point.y2);
        assert(countX == countY || countX == 0 || countY == 0);

        for (int i = 0, count = max(countX, countY); i <= count; i++)
        {
            int x = startX + stepX * i;
            int y = startY + stepY * i;
            grid[x + y * gridSizeX] += 1;
        }
    }

    writefln("Corrected number of areas to avoid: %d", grid.count!("a > 1"));
}