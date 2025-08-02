This repo has a GitHub Action configured to automatically export the Godot project, and optionally link the build in a Discord server. Pushes to **develop** will trigger a debug build, and pushes to **main** will trigger a release build. Individual build platforms can be enabled/disabled in the [workflow file](.github/workflows/build.yml).

**In order to enable Discord integration,  the following repository variables need to be configured:**

## Repository Secrets
See [Creating Secrets for a Repository](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets#creating-secrets-for-a-repository).
| **Variable Name**     | **Description** |
| --------------------- |:-------------:|
| DEBUG_WEBHOOK_URL     | [Discord webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) URL for channel to post debug builds |
| RELEASE_WEBHOOK_URL   | [Discord webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) URL for channel to post release builds |
| GH_API_TOKEN          | [GitHub access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token). Requires "Read" perms for "Actions"     |

## Repository Variables
See [Creating Configuration Variables for a Repository](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-variables#creating-configuration-variables-for-a-repository).
| **Variable Name**  | **Description** |
| ------------------ |:-------------:|
| BUILD_NAME         | Name of the exported .exe and .zip file. Build platform and debug status are appended.     |