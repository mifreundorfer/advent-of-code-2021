import std;

void main() {
    string[] lines = readText("day10/input.txt").splitLines();

    int error_score_total = 0;
    char[] stack = [];
    int numErrorLines = 0;
    for (int i = 0; i < lines.length; i++) {
        string line = lines[i];
        stack.length = 0;

        bool has_error = false;
        foreach (char c; line) {
            if (isOpenBrace(c)) {
                stack ~= c;
            } else {
                assert(stack.length > 0);
                char open = stack[$-1];
                stack.length -= 1;
                if (c != matchingClosingBrace(open)) {
                    error_score_total += getErrorScore(c);
                    numErrorLines += 1;
                    has_error = true;
                    break;
                }
            }
        }

        if (has_error) {
            foreach (j; i .. cast(int)lines.length - 1) {
                lines[j] = lines[j + 1];
            }
            lines.length -= 1;
            i--;
        }
    }

    writefln("The total error score is %s", error_score_total);

    long[] completion_scores = [];
    foreach (string line; lines) {
        stack.length = 0;

        foreach (char c; line) {
            if (isOpenBrace(c)) {
                stack ~= c;
            } else {
                assert(stack.length > 0);
                char open = stack[$ - 1];
                stack.length -= 1;
                assert(c == matchingClosingBrace(open));
            }
        }

        long completion_score = 0;
        while (stack.length > 0) {
            completion_score *= 5;
            completion_score += getCompletionScore(matchingClosingBrace(stack[$ - 1]));
            stack.length -= 1;
        }

        if (completion_score > 0) {
            completion_scores ~= completion_score;
        }
    }

    completion_scores = completion_scores.sort().array;
    writefln("The middle completion score is %s", completion_scores[completion_scores.length / 2]);
}

bool isOpenBrace(char c) {
    return c == '(' || c == '[' || c == '{' || c == '<';
}

char matchingClosingBrace(char c) {
    final switch (c) {
        case '(': return ')';
        case '[': return ']';
        case '{': return '}';
        case '<': return '>';
    }
}

int getErrorScore(char illegalBrace) {
    final switch (illegalBrace) {
        case ')': return 3;
        case ']': return 57;
        case '}': return 1197;
        case '>': return 25137;
    }
}

int getCompletionScore(char closingBrace) {
    final switch (closingBrace) {
        case ')': return 1;
        case ']': return 2;
        case '}': return 3;
        case '>': return 4;
    }
}