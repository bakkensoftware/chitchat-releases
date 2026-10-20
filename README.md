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

[Download ChitChat 0.1.92 for Windows x64](https://github.com/bakkensoftware/chitchat-releases/releases/download/v0.1.92/chitchat-setup-0.1.92.exe).
Verify it against [SHA256SUMS.txt](https://github.com/bakkensoftware/chitchat-releases/releases/download/v0.1.92/SHA256SUMS.txt)
before running the installer. See [release details](https://github.com/bakkensoftware/chitchat-releases/releases/tag/v0.1.92)
or browse [all releases](https://github.com/bakkensoftware/chitchat-releases/releases).

The winget catalog entry is **pending**. The intended identifier is
`BakkenSoftware.Chitchat`; it is not yet advertised as available in the catalog.

## Install with Scoop

```powershell
scoop bucket add bakken https://github.com/bakkensoftware/chitchat-releases
scoop install bakken/chitchat
chitchat setup
chitchat start
```

The bucket is maintained by Bakken Software. Scoop installs uv automatically;
the one-time setup command downloads Python, the local speech engine and model.
Scoop extracts the same release used by the Windows installer, adds the
`chitchat` command to PATH and creates a **ChitChat** Start menu shortcut.
It does not enable startup at login.

To update or uninstall:

```powershell
scoop update chitchat
scoop uninstall chitchat
```

Updates and removal stop a Scoop-launched ChitChat instance first and retain
settings, recordings, transcripts and the downloaded speech engine. Use one
ChitChat installation at a time: Scoop and the Windows installer share user
settings and speech data.

## Installation with the Windows installer

The Windows x64 installer installs for the current user under
`%LOCALAPPDATA%\Programs\chitchat-sonnet` by default. It creates desktop and
Start menu shortcuts and configures startup at login. It does not add the
application directory to PATH or bundle the local speech engine.

Run the downloaded installer, then install uv for local engine setup:

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
