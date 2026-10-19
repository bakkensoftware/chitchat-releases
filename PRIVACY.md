# ChitChat for Windows: privacy information

This describes the Windows desktop application's data handling. It does
not cover other applications or an Android edition.

## Microphone and transcription

ChitChat records microphone audio while a dictation session is active and
holds that session's audio in memory during transcription. The overlay
displays recognized text. When you finish, the result is delivered to the
focused application; that application handles it under its own policies.

The default provider, **Phonon-2**, processes speech locally on your computer.
The application communicates with its local engine and overlay over
loopback connections. Installing the engine downloads Python packages and
model files from third-party distribution services. Those services receive
ordinary download request information, such as your IP address. Local
transcription is distinct from these setup downloads.

If you select **OpenAI**, microphone audio is sent to OpenAI for transcription,
either as a stream or an uploaded recording, according to the configured
model and transport. Configuration can include language and prompt hints
that are also sent. An overridden service URL sends requests to that
configured service instead. Hosted processing, retention and account
charges are governed by that service's terms and policies. Refer to
[OpenAI's API data controls](https://platform.openai.com/docs/guides/your-data)
for its current information. ChitChat cannot delete data already sent to a
hosted provider. Canceling stops the local session but does not recall audio
already transmitted.

The inspected application does not include a separate analytics or
advertising upload service. Choosing local speech does not prevent another
application, backup service or operating-system feature from syncing files
or text you choose to share.

## Stored data and deletion

ChitChat saves completed dictations locally, including those whose text
could not be typed into the target application. Each history entry contains
a WAV recording and a JSON transcript with completion time, audio duration,
provider/model and transcription elapsed time. Empty successful results and
successful retries also create entries. Cancellations, demonstrations and
failed transcriptions do not create completed-history entries.

History normally keeps the newest **20 completed entries**. This is a count
limit, not a time limit: an entry can remain until enough later dictations
replace it. A storage error can delay saving or cleanup. The application
has no setting to disable completed-dictation history.

| Data | Default location |
| --- | --- |
| Completed recordings and transcripts | `%LOCALAPPDATA%\chitchat-sonnet\history` |
| Most recent failed recording kept for retry | `%LOCALAPPDATA%\chitchat-sonnet\last-failed.wav` |
| Diagnostic logs | `%LOCALAPPDATA%\chitchat-sonnet\logs` |
| Settings | `%APPDATA%\chitchat-sonnet\config.json` |
| Local speech environment | `%LOCALAPPDATA%\chitchat-sonnet\phonon` |

The default `save_failed: true` setting keeps a failed recording for retry
when sufficient audio was captured. Setting it to `false` prevents future
failed-recording saves; it does not disable history or remove existing files.
Model and package downloads may also remain in their tools' cache directories.

Settings can contain an OpenAI API key if you enter one in `config.json`.
Using the `OPENAI_API_KEY` environment variable avoids storing it in that
file. Diagnostic logs can contain errors and operational information;
review them before sharing. The application does not add application-level
encryption to stored recordings, transcripts or configuration.

Uninstalling preserves these user-data directories and the speech engine.
To remove stored recordings, stop ChitChat, delete the `history` directory
and `last-failed.wav`, and empty any copies retained by your recycle bin,
backups or sync services as appropriate. To remove all ChitChat settings and
local application data, stop/uninstall the app and delete the two
`chitchat-sonnet` directories under APPDATA and LOCALAPPDATA. This also
removes its local speech environment; externally cached models may remain.
If you set `CHITCHAT_DATA_DIR` or `CHITCHAT_CONFIG_DIR`, use those locations
instead. File deletion is not a guarantee of secure erasure.

## Clipboard and sharing

Normal typing does not use the clipboard. The optional paste delivery mode
temporarily puts text on the clipboard, requests exclusion from clipboard
history/cloud sync, and restores the previous text afterward.

**Copy each dictation to the clipboard** is a separate, opt-in setting.
It and manual history-copy actions leave text on the clipboard and follow
your Windows clipboard history and synchronization settings. That can send
text to other signed-in devices. Other applications may read clipboard
contents. Copies and text already delivered to another application remain
outside ChitChat's history cleanup.

Questions or problems can be reported through the public
[issue tracker](https://github.com/bakkensoftware/chitchat-releases/issues).
Keep recordings, transcripts, credentials and other personal data out of
public reports.
