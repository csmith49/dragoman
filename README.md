# Dragoman
/draɡəmən/

(n) An interpreter or guide, especially in countries speaking Arabic, Turkish, or Persian.

## Installation

Make sure you have `opam` installed. If you're using [Homebrew](https://brew.sh), running the following command should be sufficient:

```(bash)
brew install opam
```

Then, from this directory, simply run `./install.sh` to download and install the dependencies and build the executable `./interpret`.

## Input

The interpreter takes as input a JSON file storing the scene and the [Horn clause](https://en.wikipedia.org/wiki/Horn_clause) to be evaluated. Several example input files are given in the `./examples` folder. For example:

```json
{
    "scene" : {
        "objects" : [
            {
                "size" : "large",
                ...
            },
            ...
        ],
        "relationships" : {
            "left" : [...],
            ...
        }
    },
    "clause" : [
        ...
    ]
}
```

The interpreter expects the scene to follow the [CLEVR](https://cs.stanford.edu/people/jcjohns/clevr/) scene schema, although some attributes are ignored.

### Clauses

Clauses are represented by lists of conjuncts, which take one of two forms.

The first form encodes the binary relations `left`, `right`, `front`, and `behind`. The following encodes the conjunct `front(x, y)`:

```json
{
    "kind" : "relate",
    "relation" : "front",
    "left" : "x",
    "right" : "y"
}
```

The second form encodes attribute comparisons. The following encodes `shape(z, cylinder)`:

```json
{
    "kind" : "select",
    "attribute" : "shape",
    "value" : "cylinder",
    "variable" : "z"
}
```

To construct the Horn clause

`H(x, y) :- shape(x, cube), left(x, y), color(y, red)`

which looks for a red object to the left of a cube, we can use the following clause:

```json
[
    {
        "kind" : "select",
        "attribute" : "shape",
        "value" : "cube",
        "variable" : "x"
    },
    {
        "kind" : "relate",
        "relation" : "left",
        "left" : "x",
        "right" : "y"
    },
    {
        "kind" : "select",
        "attribute" : "color",
        "value": "red",
        "variable" : "y"
    }
]
```

## Output

Output is given as a [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) representation, with commas as delimiters. The first row indicates the variables, and each subsequent row indicates a possible satisfying assignment to the variables.

## Usage

The `-i` flag specifies the location of the input problem file. Output is either written to the terminal, or to a file specified by the `-o` flag. For example, the following interprets the `problem1.json` file in the examples folder and prints the output to `stdout`:

```bash
./interpret -i ./examples/problem1.json
```

Other commands can be seen by running `./interpret --help`.
