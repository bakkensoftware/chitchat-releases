# ChitChat for Windows

ChitChat is Bakken Software's desktop dictation app. Press **Ctrl+Space** to
start recording and see your words in an overlay. Press it again to type the
result into the focused text box. **Esc** cancels a recording.

The default speech provider, Phonon-2, runs locally. Optional OpenAI
transcription sends audio to the configured hosted service and requires your
own API key. Read the [privacy information](PRIVACY.md) before dictating:
ChitChat saves recordings and transcripts on your computer.

This repository hosts public Windows installers and product documentation.
The application source is private. ChitChat is [proprietary](LICENSE.md);
bundled components retain their [own licenses](THIRD-PARTY-NOTICES.md).

## Downloads

Public installer publication is being prepared. **No tested public installer
or winget catalog entry is available from this repository yet.**

When published, installers will appear on the [Releases page](https://github.com/bakkensoftware/chitchat-releases/releases).
The intended winget identifier is `BakkenSoftware.Chitchat`; this is not a
claim that it is already in the catalog.

## Installation and first use

The Windows x64 installer installs for the current user under
`%LOCALAPPDATA%\Programs\chitchat-sonnet` by default. It creates desktop and
Start menu shortcuts and configures startup at login. It does not add the
application directory to PATH or bundle the local speech engine.

After installing a published release, install uv for local engine setup:

```powershell
winget install --exact --id astral-sh.uv --source winget
```

Open a new PowerShell window so uv is available on PATH, then run:

```powershell
$chitchat = "$env:LOCALAPPDATA\Programs\chitchat-sonnet\chitchat.exe"
& $chitchat setup
& $chitchat start
```

If you chose a different install directory, use its `chitchat.exe` path.
Setup needs an internet connection to download Python, speech dependencies
and the model. After successful setup, the default local transcription
does not need a hosted transcription account. The installer alone does not
complete speech setup. Silent installation uses `/S` and does not launch
the app from the installer finish page.

Select a text box, press Ctrl+Space, speak, and press Ctrl+Space again.
The tray menu opens configuration, switches themes and layouts, and offers
**History & clipboard**. Automatic copying of each dictation to the clipboard
is off by default. ChitChat cannot type into an elevated application unless
it is also elevated.

For diagnostics:

```powershell
& $chitchat doctor
& $chitchat help
```

## Updates and removal

Installing a newer release replaces the installed application files.
Uninstall through Windows Settings > Apps. Updating and uninstalling retain
settings, logs, recordings, transcripts and the downloaded speech engine.
See [stored data and deletion](PRIVACY.md#stored-data-and-deletion).

## Help

Report product problems through [Issues](https://github.com/bakkensoftware/chitchat-releases/issues).
Issues are public: do not attach private recordings, transcripts, API keys,
configuration files or unreviewed logs.
