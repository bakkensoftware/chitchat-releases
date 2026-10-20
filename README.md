# ChitChat for Windows

**Speak instead of typing, even when you're offline.** ChitChat turns your
voice into text in the Windows app you're using. It runs
[Fermion Research's Phonon-2 speech model](https://huggingface.co/FermionResearch/Phonon-2)
on your own computer.

Press **Ctrl+Space**, speak, then press **Ctrl+Space** again to type your words
into the selected text box. An overlay shows the words as you speak.
Press **Esc** to cancel.

You need an internet connection for the first setup and model downloads.
After that, everyday dictation with the default local model works offline,
without a paid transcription account. Your audio stays on your computer.
ChitChat saves recordings and transcripts locally so you can find them later;
see [what is saved and how to delete it](PRIVACY.md#stored-data-and-deletion).

## Install

ChitChat is available for **64-bit Windows**. Choose Scoop if you already use
it, or download the Windows installer.

### With Scoop

Open PowerShell and run:

```powershell
scoop bucket add bakken https://github.com/bakkensoftware/chitchat-releases
scoop install bakken/chitchat
chitchat setup
chitchat start
```

The first two commands install ChitChat from Bakken Software's package
collection. `setup` downloads the local speech engine and Phonon-2 model;
let it finish before starting dictation. Scoop installs the setup tool
**uv** automatically.

ChitChat gets a Start menu shortcut and starts automatically when you sign
in to your Windows account. Run `chitchat start` to use it now without
signing out.

### With the Windows installer

1. [Download the latest ChitChat release](https://github.com/bakkensoftware/chitchat-releases/releases/latest)
   and run the `chitchat-setup-<version>.exe` installer from its **Assets** list.
2. Open PowerShell and install **uv**, the tool ChitChat uses to set up its
   local speech engine:

   ```powershell
   winget install --exact --id astral-sh.uv --source winget
   ```

3. Open a **new** PowerShell window, then download the speech engine and
   model and start ChitChat:

   ```powershell
   $chitchat = "$env:LOCALAPPDATA\Programs\chitchat-sonnet\chitchat.exe"
   & $chitchat setup
   & $chitchat start
   ```

The installer creates desktop and Start menu shortcuts and starts ChitChat
automatically when you sign in to your Windows account. The one-time
`setup` step still needs to finish before you can dictate.

If you selected a different installation folder, use its `chitchat.exe` path
in the command above. The installer does not add `chitchat` to PowerShell's
command search path.

The release page also includes `SHA256SUMS.txt` to verify the download.
[Browse all release notes and downloads](https://github.com/bakkensoftware/chitchat-releases/releases).

## Use ChitChat

1. Click the text box where you want to write.
2. Press **Ctrl+Space** and speak. Watch your words appear in the overlay.
3. Press **Ctrl+Space** again. ChitChat types the result into that text box.

Press **Esc** during a recording to cancel it. Right-click the ChitChat icon
in the Windows notification area to change settings, themes or layouts,
or open **History & clipboard** to find earlier dictations. Copying every
dictation to the clipboard is optional and is off by default.

ChitChat cannot type into an app running as administrator unless ChitChat
is also running as administrator.

## Update or remove

Use one installation method at a time. Scoop and the Windows installer
share the same settings, recordings and speech model.

### Scoop

Stop ChitChat before updating:

```powershell
chitchat stop
scoop update chitchat
chitchat start
```

If you installed ChitChat with Scoop before automatic startup was added,
run this once to enable it for your Windows account, even if Scoop says
you already have the latest version:

```powershell
scoop update
chitchat stop
scoop update chitchat --force
chitchat start
```

To uninstall:

```powershell
scoop uninstall chitchat
```

### Windows installer

Download and run the newer installer to update. To uninstall, open
**Windows Settings > Apps** and remove ChitChat.

Both installation methods keep your settings, recordings, transcripts and
downloaded speech engine when updating or uninstalling. To remove that
data too, follow the [data deletion instructions](PRIVACY.md#stored-data-and-deletion).

## Help and other speech options

If setup or dictation fails, run `chitchat doctor` in PowerShell to check
the installation. For the Windows installer, use `& $chitchat doctor` in
the PowerShell window where you set `$chitchat` above. `chitchat help`
lists the available commands.

Phonon-2 is the default. An optional **OpenAI** provider is also available
in configuration, using your own API key. That option needs internet access
and sends audio to the configured service. Read the
[privacy information](PRIVACY.md) before changing providers.

[Report a problem or request a feature](https://github.com/bakkensoftware/chitchat-releases/issues).
Reports are public, so leave out private recordings, transcripts, API keys,
configuration files and unreviewed logs.

ChitChat is published by Bakken Software. This repository contains its
Windows downloads and documentation; the application source is private.
See the [application license](LICENSE.md) and
[third-party notices](THIRD-PARTY-NOTICES.md).
