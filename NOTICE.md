# Notices

## CharSplit

This project incorporates Ruby ports of the splitting and training algorithms from [CharSplit](https://github.com/dtuggener/CharSplit), created by Don Tuggener:

> Copyright 2016 Don Tuggener

CharSplit is distributed under the MIT License. A copy of its license is included in [`LICENSE-CharSplit.txt`](LICENSE-CharSplit.txt). The probability model bundled with this project was trained independently from the German Wiktionary corpus described below; it is not CharSplit's original model.

The method is described in Don Tuggener's 2016 University of Zurich thesis, *Incremental Coreference Resolution for German*.

## German Wiktionary data

This project uses factual linguistic data extracted from German Wiktionary.

Source: [German Wiktionary](https://de.wiktionary.org/)

German Wiktionary textual content is made available under the Creative Commons Attribution-ShareAlike 4.0 International license (CC BY-SA 4.0) and, where applicable, the GNU Free Documentation License.

The source data was converted to machine-readable JSON by [Wiktextract](https://github.com/tatuylonen/wiktextract) and distributed by [Kaikki.org](https://kaikki.org/). See [`data/vendor/german-nouns/SOURCE.md`](data/vendor/german-nouns/SOURCE.md) for provenance and reproducibility details.

The distributed generated table contains German word forms. It does not contain Wiktionary definitions, examples, etymologies, or other article prose.

The software and generated factual table in this repository are released under the MIT License. Any redistributed original Wiktionary or Wiktextract source data remains subject to its applicable source licenses.
