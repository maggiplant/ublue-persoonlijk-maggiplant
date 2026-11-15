# ublue-persoonlijk-maggiplant

Mijn persoonlijke [bootc](https://github.com/bootc-dev/bootc)-image voor Universal Blue.

Deze repository is gebaseerd op [ublue-os/image-template](https://github.com/ublue-os/image-template)

## Inhoud

In principe gewoon `ghcr.io/ublue-os/bazzite-nvidia-open:stable` met emacs-pgtk geïnstalleerd via dnf5 [build_files/build.sh](./build_files/build.sh)

# In werking stellen

Vanaf een bestaand bootc-systeem (bijv. Bazzite):

```bash
sudo bootc switch ghcr.io/maggiplant/ublue-persoonlijk-maggiplant:latest
```

Daarna herstarten, en vervolgens schakelt `sudo bootc upgrade` (of de standaard auto-update van Bazzite) automatisch mee met de nieuwste build.

# CI-workflows

- [build.yml](./.github/workflows/build.yml) bouwt de image via het [Justfile](./Justfile), rechunkt die met rpm-ostree (kleinere deltas bij `bootc update`) en publiceert die naar GHCR (`ghcr.io/maggiplant/ublue-persoonlijk-maggiplant`) met de tags `latest`, `latest-YYYYMMDD`, `YYYYMMDD` en — bij een schone werkmap — SHA-varianten. Elke build wordt ondertekend met cosign; de publieke sleutel staat in [cosign.pub](./cosign.pub).
- [build-disk.yml](./.github/workflows/build-disk.yml) maakt met [bootc-image-builder](https://osbuild.org/docs/bootc/) schrijfbare images (`qcow2`) en een installatie-ISO (`anaconda-iso`). De ISO-kickstarts in [disk_config/iso-kde.toml](./disk_config/iso-kde.toml) en [disk_config/iso-gnome.toml](./disk_config/iso-gnome.toml) wijzen al naar deze image. Upload naar S3 is optioneel (workflow_dispatch met `upload-to-s3`).

# Justfile

Voor het lokaal bouwen en testen is [just](https://just.systems/man/en/introduction.html) nodig (staat standaard op Universal Blue-images), samen met `podman` en `jq`. Alle parameters (imagenavam, organisatie, omschrijving, BIB-image) staan in [ublue-persoonlijk-maggiplant.env](./ublue-persoonlijk-maggiplant.env).

## Image bouwen

```bash
just build
```

Bouwt `localhost/ublue-persoonlijk-maggiplant:latest` met podman.

## Schijfimages en VM's

```bash
just build-qcow2    # qcow2-image in output/qcow2/disk.qcow2
just build-raw      # raw-image
just build-iso      # installatie-ISO (iso-kde.toml)
```

`rebuild-qcow2`/`rebuild-raw`/`rebuild-iso` doen de container-build er eerst weer bij. `run-vm-qcow2`, `run-vm-raw` en `run-vm-iso` starten de image als VM (via `docker.io/qemux/qemu`), en `spawn-vm` gebruikt systemd-vmspawn:

```bash
just spawn-vm            # start wat er al ligt
just spawn-vm 1 qcow2 6G # eerst opnieuw bouwen (of: just spawn-vm rebuild=1)
```

## Onderhoud

```bash
just check   # just-syntax controleren
just fix     # just-syntax herstellen
just lint    # shellcheck over alle .sh-bestanden
just format  # shfmt over alle .sh-bestanden
just clean   # build-artefacten opruimen
```
