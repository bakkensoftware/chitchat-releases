# Third-party notices

ChitChat's proprietary classification does not change the licenses of the
following components. Full notices are in [notices/](notices/).

## Windows application and overlay

| Component | License text |
| --- | --- |
| Go runtime and standard library | [Go BSD license](notices/go.txt) |
| Gorilla WebSocket v1.5.3 | [BSD-2-Clause](notices/gorilla-websocket.txt) |
| golang.org/x/sys v0.48.0 | [BSD-3-Clause](notices/golang-x-sys.txt) |
| golang.org/x/image v0.46.0 | [BSD-3-Clause](notices/golang-x-image.txt) |
| golang.org/x/text v0.42.0 | [BSD-3-Clause](notices/golang-x-text.txt) |
| go-text/typesetting v0.3.5 | [Unlicense or BSD-3-Clause](notices/go-text-typesetting.txt) |
| HarfBuzz port within typesetting | [MIT and copyright notices](notices/harfbuzz.txt) |
| Embedded Go Regular font | [Go font license](notices/font-go-regular.txt) |
| NSIS installer runtime and plugins | [NSIS COPYING](notices/nsis.txt) |

The installer uses NSIS with LZMA compression. NSIS's COPYING file includes
the compression module's license and linking exception. Windows system
libraries and system fonts are used from the operating system; they are
not redistributed as separate files in the installer.

## Embedded theme fonts

These fonts use the SIL Open Font License 1.1. Their licenses apply to the
fonts, including embedded copies, independently of the application license.
Embedded font copyright metadata is also reproduced in
[embedded-font-notices.txt](notices/embedded-font-notices.txt).

| Family | Copyright and license |
| --- | --- |
| Audiowide | [OFL](notices/font-audiowide.txt) |
| Big Shoulders Display | [OFL](notices/font-bigshouldersdisplay.txt) |
| Bricolage Grotesque | [OFL](notices/font-bricolagegrotesque.txt) |
| Cormorant Garamond | [OFL](notices/font-cormorantgaramond.txt) |
| Fraunces | [OFL](notices/font-fraunces.txt) |
| Hanken Grotesk | [OFL](notices/font-hankengrotesk.txt) |
| Instrument Serif | [OFL](notices/font-instrumentserif.txt) |
| JetBrains Mono | [OFL](notices/font-jetbrainsmono.txt) |
| Major Mono Display | [OFL](notices/font-majormonodisplay.txt) |
| Recursive | [OFL](notices/font-recursive.txt) |
| Share Tech Mono | [OFL](notices/font-sharetechmono.txt) |
| Shippori Mincho | [OFL](notices/font-shipporimincho.txt) |
| Silkscreen | [OFL](notices/font-silkscreen.txt) |
| Syne | [OFL](notices/font-syne.txt) |
| Tilt Neon | [OFL](notices/font-tiltneon.txt) |
| Unbounded | [OFL](notices/font-unbounded.txt) |
| VT323 | [OFL](notices/font-vt323.txt) |

The family license texts are reproduced from the corresponding directories
of the [Google Fonts collection](https://github.com/google/fonts/tree/main/ofl).

Audiowide and Share Tech Mono use unmodified upstream TTFs to retain their
Reserved Font Names. Source: Google Fonts commit
[`47d54ca1ebb14fd864695f1d39dc734f39017c33`](https://github.com/google/fonts/tree/47d54ca1ebb14fd864695f1d39dc734f39017c33/ofl),
`audiowide/Audiowide-Regular.ttf` and `sharetechmono/ShareTechMono-Regular.ttf`.

## Separately downloaded speech components

The Windows installer does not bundle uv, Python, Phonon, PyTorch, speech
model weights or their dependency environments. The `setup` command
downloads the speech environment and model separately; those components
retain their own licenses and notices. Setup currently requests
`fermion-research`, `torch`, `safetensors`, `soundfile`, `scipy` and
`zstandard` and their dependencies. Versions resolve at setup time.

See [Phonon](https://github.com/fermionresearch/phonon),
[uv](https://github.com/astral-sh/uv), and
[Python](https://www.python.org/psf/license/) for their projects and terms.
These notices describe the installer payload, not a redistribution of a
preinstalled speech environment. A distribution that bundles that environment
or model must also include its resolved components' notices and satisfy
their redistribution terms.
