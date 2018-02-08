# Topo

## Usage

At first, run `bundle`. Then, specify the initial position in `main.rb` and run `ruby main.rb`.
The intermittent positions are cached in table `elevations`.
The found peak is stored in table `peaks`.

## Roadmap

* 0.1 (Elevation) Hill-climbing for finding a local extreme.
* 0.2 (Prominence) BFS from a peak to find higher peak reachable with smallest possible descent.
