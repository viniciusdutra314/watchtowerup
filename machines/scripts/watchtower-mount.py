#!/usr/bin/env -S python3 -I

from pathlib import Path
import subprocess
import sys
import time


def existing_mounts(target):
    result = subprocess.run(
        ["/usr/bin/findmnt", "-rnkC", "-M", str(target), "-o", "SOURCE,FSTYPE,FSROOT"],
        capture_output=True,
        text=True,
    )
    if result.stdout:
        print(result.stdout, end="", flush=True)
    if result.stderr:
        print(result.stderr, end="", file=sys.stderr, flush=True)

    # O findmnt retorna 1 quando o destino não tem montagem.
    if result.returncode == 1 and not result.stderr:
        return []
    result.check_returncode()
    return result.stdout.splitlines()


def existing_origin(mounts, device, remote):
    if len(mounts) != 1:
        return None

    source, current_type, root = mounts[0].split()
    if current_type == "nfs4" and source == remote:
        return "NFS"

    if root == "/":
        source_device = Path(source.partition("[")[0])
        if device.is_block_device() and source_device.is_block_device() and device.samefile(source_device):
            return "local"
    return None


def mount(source, target, options, *, filesystem="auto"):
    return subprocess.run(
        ["/usr/bin/mount", "--onlyonce", "-t", filesystem, "-o", options,
         "--", str(source), str(target)],
        stdin=subprocess.DEVNULL,
    )


def mount_disk(target, device, local_options):
    remote = f"wt-server:{target}"
    if existing_mounts(target):
        print(f"{target} já montado")
        return

    target.mkdir(exist_ok=True)
    if mount(device, target, local_options).returncode == 0:
        print(f"{target} montado (local).")
        return
    mount(remote, target, "nosuid,nodev,retry=0", filesystem="nfs4").check_returncode()
    print(f"{target} montado (NFS).")


def main():
    time.sleep(10)
    for name, uuid, local_options in [
        ("core", "f9ee577d-e5d6-47c8-bca7-1855b30169f6", "nosuid,nodev,subvolid=5"),
        ("library", "111c2127-50c6-4005-a541-e2441d7c2cba", "nosuid,nodev"),
        ("personal", "37d19077-e4da-4c03-b80b-f0c640448e68", "nosuid,nodev,subvolid=5"),
    ]:
        target = Path("/mnt") / f"wt-{name}"
        device = Path("/dev/disk/by-uuid") / uuid
        mount_disk(target, device, local_options)


if __name__ == "__main__":
    main()
