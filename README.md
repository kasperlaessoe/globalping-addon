# Home Assistant Add-on: Globalping Probe

Run a [Globalping][globalping] network probe on Home Assistant.

## About

This Home Assistant add-on packages the [Globalping probe][probe] —
a community-run network measurement node operated by JSDelivr — as a
supervisor add-on. Once installed and started, your Home Assistant host
joins the Globalping network and can be used to run `ping`, `traceroute`,
`mtr`, `dns`, and `http` tests from your location.

The probe:

- Runs entirely outbound. It does not open ports or accept incoming
  connections.
- Self-updates on every container start by downloading the latest probe
  bundle from jsDelivr/GitHub, just like the upstream image.
- Optionally registers under your Globalping account when you provide an
  adoption token, which gives you additional credits and higher rate
  limits.

## Installation

1. Open Home Assistant → **Settings → Add-ons → Add-on Store**.
1. Click the menu in the top-right corner and select **Repositories**.
1. Add this repository's URL: `https://github.com/kasperlaessoe/globalping-addon`
1. Refresh, find **Globalping Probe** in the store, and click **Install**.
1. (Optional) Open the **Configuration** tab and paste your adoption
   token. You can get one from the
   [Globalping dashboard][probe-adopt].
1. Start the add-on and check the log to see the probe register with
   the Globalping network.

For full configuration documentation see [`globalping/DOCS.md`](globalping/DOCS.md).

## Architectures supported

- `aarch64`
- `amd64`
- `armv7`

## Repository layout

- `globalping/` — the add-on itself (Dockerfile, config, rootfs).
- `.github/` — CI workflows reused from the Home Assistant Community
  Add-ons project.

## Credits

- The Globalping platform and probe are built by [JSDelivr][jsdelivr].
- This add-on's structure is based on the
  [Home Assistant Community Add-ons example][app-example] by Franck Nijhof.

## License

MIT License. See [`LICENSE.md`](LICENSE.md).

[app-example]: https://github.com/hassio-addons/app-example
[globalping]: https://github.com/jsdelivr/globalping
[jsdelivr]: https://www.jsdelivr.com/
[probe-adopt]: https://dash.globalping.io/probes?view=start-a-probe
[probe]: https://github.com/jsdelivr/globalping-probe
