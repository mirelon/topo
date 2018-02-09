# Topo

## Usage


At first, run `bundle`.

* Run `ruby main.rb`. Specify initial coordinates as an argument, e.g. `ruby main.rb 48.1234,17.1234`. The intermittent positions are cached in table `elevations`. The found peak is stored in table `peaks`. A new tab in google-chrome is opened with map of all peaks. 
* Run `ruby visualize.rb`. A file `elevations.png` is created and opened in new tab in google-chrome.
* Run `ruby prominence.rb`. Optionally specify id of the peak to count prominence of, e.g. `ruby prominence.rb 6`. Broad-first search is performed until a saddle point is found. The intermittent positions are cached in table `elevations`.

## Dependencies

[Dependency diagram](https://drive.google.com/file/d/1w_ES1l23431xla3ORWKU3THVlxcRg4AG/view?usp=sharing)

## Roadmap

* 0.1 (Elevation) Hill-climbing for finding a local extreme.
* 0.2 (Prominence) BFS from a peak to find higher peak reachable with smallest possible descent.

## Current status of cached elevations

![Cached elevations image](https://github.com/mirelon/topo/raw/master/elevations.png)
