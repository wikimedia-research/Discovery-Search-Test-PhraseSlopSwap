# PhraseSlopSwap
Analysis of second A/B test (A/B/C in this case) wherein we changed the [phrase slop](https://www.elastic.co/guide/en/elasticsearch/guide/current/slop.html) from 0 (A) to 1 (B) or 2 (C).

## Hypotheses

1. Changing phrase slop from 0 to 1 or 2 will yield less zero results.
2. Phrase slop 1 is better than slop 2.
3. Phrase slop 2 is better than slop 1.
