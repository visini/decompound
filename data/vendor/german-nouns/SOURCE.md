# German noun data provenance

## Source

- Original source: [German Wiktionary](https://de.wiktionary.org/)
- Machine-readable extraction: [Kaikki.org German Wiktextract data](https://kaikki.org/dictionary/downloads/de/de-extract.jsonl.gz)
- Wiktextract repository: <https://github.com/tatuylonen/wiktextract>
- Wiktextract commit: [`e62056b1f7954ce7b17730606bfa7707b63af3cd`](https://github.com/tatuylonen/wiktextract/commit/e62056b1f7954ce7b17730606bfa7707b63af3cd)
- Download date: 2026-07-14
- Download size: 300,450,106 bytes
- Download SHA-256: `3d85e381c8270932c79181c09d009a259aca7534e9323783e7ccbd91c4384fc1`

Kaikki.org's download URL is a rolling URL rather than an immutable archive. The download script pins the expected content by SHA-256 and will fail instead of silently using a newer snapshot. Reproducing this exact snapshot after the upstream URL changes requires an archived copy with the recorded SHA-256.

## Extraction

Run from the repository root:

```sh
ruby script/download_german_nouns.rb
```

The script uses only the Ruby standard library. It caches the verified compressed source at `tmp/de-extract.jsonl.gz` and deterministically regenerates `nouns.csv` using these options:

- retain records whose `lang_code` is `de` and whose `pos` is `noun`;
- use `word` as the lemma and mark each output row as `Substantiv`;
- collect nominative, genitive, dative, and accusative forms for singular and plural from Wiktextract's form tags;
- merge records with an identical lemma and deduplicate their exact inflected forms;
- sort lemmas and forms using Ruby's default string ordering;
- encode each set of forms as a JSON array inside the CSV cell so alternate forms are retained without ambiguous delimiters;
- write UTF-8 CSV with LF line endings.

The columns are `Wortart`, `Lemma`, and the eight case/number combinations from `Nominativ Singular` through `Akkusativ Plural`.

## Attribution and licensing

The factual word forms originate from German Wiktionary contributors. Wiktionary textual content is available under CC BY-SA 4.0 and, where applicable, the GNU Free Documentation License. Wiktextract was created by Tatu Ylonen, and Kaikki.org provides the machine-readable extraction.

A copy of CC BY-SA 4.0 is included as [`LICENSE-CC-BY-SA-4.0.txt`](LICENSE-CC-BY-SA-4.0.txt). See the repository's [`NOTICE.md`](../../../NOTICE.md) for the distribution notice.
