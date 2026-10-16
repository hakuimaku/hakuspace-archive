"""Installer guards without network access or desktop writes."""
import os
from pathlib import Path
import subprocess
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallGuards(unittest.TestCase):
    def setUp(self):
        self.work = tempfile.TemporaryDirectory()
        self.addCleanup(self.work.cleanup)
        self.home = Path(self.work.name)
        self.env = dict(os.environ, HOME=str(self.home), XDG_CACHE_HOME=str(self.home / "cache"),
                        XDG_CONFIG_HOME=str(self.home / "config"),
                        XDG_DATA_HOME=str(self.home / "data"), GIT_CONFIG_GLOBAL="/dev/null",
                        GIT_AUTHOR_NAME="Test", GIT_AUTHOR_EMAIL="test@example.invalid",
                        GIT_COMMITTER_NAME="Test", GIT_COMMITTER_EMAIL="test@example.invalid")

    def run_shell(self, code):
        return subprocess.run(["bash", "-euc", f'source "{ROOT}/lib/common.sh"; {code}'],
                              env=self.env, text=True, capture_output=True)

    def git(self, *args):
        return subprocess.run(["git", *map(str, args)], env=self.env, check=True,
                              text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def test_update_and_dirty_checkout(self):
        remote = self.home / "remote"
        self.git("init", remote)
        (remote / "file").write_text("one")
        self.git("-C", remote, "add", ".")
        self.git("-C", remote, "commit", "-m", "initial")
        cache = self.home / "cache/hakuspace/assets-src/test"
        cache.parent.mkdir(parents=True)
        self.git("clone", remote, cache)
        (remote / "file").write_text("two")
        self.git("-C", remote, "commit", "-am", "update")
        command = f'source "{ROOT}/lib/source_repo.sh"; source_repo test ""'
        result = self.run_shell(command)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((cache / "file").read_text(), "two")
        (cache / "personal").write_text("keep")
        result = self.run_shell(command)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Dirty checkout", result.stderr)
        self.assertEqual((cache / "personal").read_text(), "keep")
        (cache / "personal").unlink()
        (cache / "file").write_text("local edit")
        self.git("-C", cache, "commit", "-am", "local")
        (remote / "file").write_text("remote edit")
        self.git("-C", remote, "commit", "-am", "remote")
        result = self.run_shell(command)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((cache / "file").read_text(), "local edit")

    def test_missing_source_uses_shallow_clone(self):
        remote = self.home / "remote"
        self.git("init", remote)
        (remote / "file").write_text("one")
        self.git("-C", remote, "add", ".")
        self.git("-C", remote, "commit", "-m", "initial")
        wrapper = self.home / "bin"
        wrapper.mkdir()
        git = wrapper / "git"
        git.write_text("""#!/usr/bin/env python3
import os, sys
args = sys.argv[1:]
if args[:3] == ['clone', '--depth', '1']:
    assert args[3] == 'https://github.com/hakuimaku/test.git'
    args[3] = os.environ['TEST_REMOTE_URL']
os.execv(os.environ['TEST_REAL_GIT'], ['git', *args])
""")
        git.chmod(0o755)
        self.env.update(TEST_REAL_GIT=shutil.which("git"), TEST_REMOTE_URL=remote.as_uri(),
                        PATH=f"{wrapper}:{self.env['PATH']}")
        result = self.run_shell(f'source "{ROOT}/lib/source_repo.sh"; source_repo test ""')
        self.assertEqual(result.returncode, 0, result.stderr)
        checkout = Path(result.stdout.strip())
        self.assertEqual((checkout / "file").read_text(), "one")
        self.assertEqual(self.git("-C", checkout, "rev-parse", "--is-shallow-repository").stdout.strip(), "true")

    def test_override_never_pulls_or_resets(self):
        result = self.run_shell(f'source "{ROOT}/lib/source_repo.sh"; source_repo test "$HOME"')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.home))

    def test_unmanaged_cursor_is_preserved(self):
        target = self.home / "data/icons/Haku-Blue"
        target.mkdir(parents=True)
        (target / "custom").write_text("keep")
        result = self.run_shell(f'source "{ROOT}/lib/install_cursor.sh"; install_cursor')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unmanaged cursor", result.stderr)
        self.assertEqual((target / "custom").read_text(), "keep")

    def legacy_files(self):
        target = self.home / ".local/bin"
        target.mkdir(parents=True)
        files = [target / "icon-accent", target / "icon_accent.py"]
        for file in files:
            file.write_text("legacy file")
        state = self.home / ".local/state/hakuspace/assets"
        state.mkdir(parents=True)
        receipt = state / "icon-accent.sha256"
        receipt.write_bytes(subprocess.check_output(["sha256sum", *map(str, files)]))
        return files, receipt

    def cleanup_legacy(self):
        return self.run_shell(f'source "{ROOT}/lib/cleanup_legacy_icon_accent.sh"; cleanup_legacy_icon_accent')

    def test_verified_legacy_cleanup_and_idempotence(self):
        files, receipt = self.legacy_files()
        result = self.cleanup_legacy()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any(file.exists() for file in [*files, receipt]))
        self.assertEqual(self.cleanup_legacy().returncode, 0)

    def test_modified_legacy_files_are_preserved(self):
        files, receipt = self.legacy_files()
        files[1].write_text("user edit")
        result = self.cleanup_legacy()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("warning", result.stderr)
        self.assertTrue(all(file.exists() for file in [*files, receipt]))
        self.assertEqual(files[1].read_text(), "user edit")

    def test_unmanaged_files_and_forged_receipts_are_preserved(self):
        files, receipt = self.legacy_files()
        receipt.unlink()
        self.cleanup_legacy()
        self.assertTrue(all(file.exists() for file in files))
        unrelated = self.home / "unrelated"
        unrelated.write_text("keep")
        receipt.write_bytes(subprocess.check_output(["sha256sum", str(unrelated)]))
        self.cleanup_legacy()
        self.assertTrue(all(file.exists() for file in [*files, receipt, unrelated]))

    def test_failed_checksum_read_preserves_both_files(self):
        files, receipt = self.legacy_files()
        receipt.write_bytes(subprocess.check_output(["sha256sum", str(files[0])]))
        wrapper = self.home / "bin"
        wrapper.mkdir()
        checksum = wrapper / "sha256sum"
        # Simulate a read error on the second file after emitting the first hash.
        checksum.write_text('#!/bin/sh\nhead -n1 "$TEST_RECEIPT"\nexit 1\n')
        checksum.chmod(0o755)
        self.env.update(PATH=f"{wrapper}:{self.env['PATH']}", TEST_RECEIPT=str(receipt))
        result = self.cleanup_legacy()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("cannot verify", result.stderr)
        self.assertTrue(all(file.exists() for file in [*files, receipt]))

    def test_symlinked_legacy_file_is_preserved(self):
        files, receipt = self.legacy_files()
        outside = self.home / "outside"
        outside.write_bytes(files[0].read_bytes())
        files[0].unlink()
        files[0].symlink_to(outside)
        self.cleanup_legacy()
        self.assertTrue(files[0].is_symlink())
        self.assertTrue(receipt.exists())
        self.assertEqual(outside.read_text(), "legacy file")


if __name__ == "__main__":
    unittest.main()
