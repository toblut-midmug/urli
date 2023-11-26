# %urli

A simple, slightly opinionated URL shortener for Urbit.

URLs are shortened to random, three-digit base 58 short IDs. A short URL
then reads e.g. `sampel-palnet.arvo.network/urli/1bC`.
Shortening the same URL twice will give the same short ID.
The minimalistic frontend is mostly plain HTML with a sprinkle of JavaScript for the
copy to clipboard button.

## Installation

```
|install %urli ~dister-toblut-midmug
```


## Why?
Well, I mainly wrote this app to learn [Sail](https://docs.urbit.org/language/hoon/guides/sail) and how to do handle HTTP requests
in Urbit. 
