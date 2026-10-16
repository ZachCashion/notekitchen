# Note Kitchen

Search for piano chords and scales, see the notes light up on a keyboard, and hear them.

**Live:** https://zachcashion.github.io/notekitchen/

Type `Cm7b5`, `Fm6(b13)(#11)(+5)` or `Bb dorian`. Add `play` to loop an arpeggio, add `root` to show only the roots, and press ↑/↓ to transpose. The in-app **Help** page lists every command and the ~95 supported scales.

## About this fork

Note Kitchen was built by **Nebojsa Petrovic** ([nebs](https://github.com/nebs), [Once Upon a Synth](http://onceuponasynth.tv)) and ran at note.kitchen until the domain lapsed. This fork keeps the original code and history and gets it working again:

- **Sound works again.** Modern browsers keep audio suspended until a user gesture, which made `play` silent (upstream [#5](https://github.com/nebs/notekitchen/issues/5)).
- **Installable and offline.** A web app manifest, icons and a service worker let you install it on a phone or desktop and use it without a connection.
- **No build step and no trackers.** The 2018 gulp toolchain and committed `node_modules` are gone, along with Google Analytics, the Facebook SDK and the Twitter widgets. `app/` is plain HTML/CSS/JS served as-is.
- **Relative links.** Help-page links work from any path, not only from a domain root.

## Running locally

On Windows, with nothing to install (or `npm start` if you have Node):

```bash
powershell -ExecutionPolicy Bypass -File serve.ps1
```

Then open http://localhost:8080/app/. Any static server pointed at the repo root works too (for example `npx http-server -c-1 .`). A server is needed rather than opening the file directly, because service workers do not run on `file://`.

## Tests

With the server running, open http://localhost:8080/specs/specs.html to run the Jasmine specs.

## Deployment

Every push to `master` publishes `app/` to GitHub Pages (`.github/workflows/pages.yml`) and smoke-tests the live site. One-time setup: in the repo's **Settings > Pages**, set **Source** to **GitHub Actions**.

## Making changes

- After changing any file under `app/`, bump `CACHE` in `app/sw.js` (`nk-v1` → `nk-v2`). Otherwise installed copies keep serving the old files.
- To regenerate the icons, run `powershell -ExecutionPolicy Bypass -File tools/make-icons.ps1`.

## Built with

- [Tone.js](https://tonejs.github.io/) (r11, vendored) for sound
- [Jasmine](https://jasmine.github.io/) for tests

## License

MIT, see [LICENSE.md](LICENSE.md). Original work © 2018 Nebojsa Petrovic.
