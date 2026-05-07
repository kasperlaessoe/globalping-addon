# Home Assistant Add-on: Globalping Probe

Run a [Globalping][globalping] network probe on your Home Assistant
instance and contribute to the global community-run network testing
platform from JSDelivr.

## About

The Globalping probe is a small service that joins the JSDelivr-operated
Globalping network. Once running, your Home Assistant host will be
available as a measurement point that anyone (including you) can use to
run `ping`, `traceroute`, `mtr`, `dns`, and `http` tests from your
location.

The probe is fully outbound: it opens no ports and accepts no incoming
connections. It only talks to the Globalping API over a secure
connection. See the upstream [security notes][probe-security] for
details.

## Installation

1. Add this repository to Home Assistant. From the Home Assistant UI go
   to **Settings → Add-ons → Add-on Store**, click the menu in the top
   right and select **Repositories**, then paste the URL of this repo.
1. Find the "Globalping Probe" add-on in the store and click **Install**.
1. (Optional) Open the **Configuration** tab and paste your adoption
   token to register the probe under your Globalping account.
1. Start the add-on.
1. Check the **Log** tab — you should see the probe download the latest
   bundle and connect to the Globalping API.

## Configuration

```yaml
log_level: info
adoption_token: ""
```

### Option: `log_level`

Controls the verbosity of the add-on log output. Possible values:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Show detailed debug information.
- `info`: Normal events (default).
- `notice`, `warning`, `error`, `fatal`: Progressively quieter levels.

This controls add-on log output. The probe itself logs at its own level.

### Option: `adoption_token`

Optional Globalping adoption token. When set, the probe is registered
under your Globalping account, which gives you additional daily credits
and higher rate limits.

Get your token from the [Globalping dashboard][probe-adopt].

Leave this empty to run the probe unadopted (it still contributes to the
network).

> **Note:** Anyone who knows your adoption token can register probes
> under your account. Treat it like a password.

## Networking and capabilities

The probe runs with `host_network: true` and the `NET_RAW` and
`NET_ADMIN` capabilities. These are required for raw ICMP sockets used
by `ping`, `traceroute`, and `mtr`.

Only one probe is allowed per public IP address. If you already run a
Globalping probe elsewhere on the same network you should disable this
one (or vice versa).

## Updating

The probe code self-updates on every container start by downloading the
latest bundle from jsDelivr/GitHub. The container itself is updated when
you upgrade the add-on through Home Assistant.

## Support

For Globalping platform questions, visit the
[Globalping repository][globalping].

For add-on bugs, open an issue on this repository.

## License

MIT License. See `LICENSE.md`.

[globalping]: https://github.com/jsdelivr/globalping
[probe-adopt]: https://dash.globalping.io/probes?view=start-a-probe
[probe-security]: https://github.com/jsdelivr/globalping-probe#security
