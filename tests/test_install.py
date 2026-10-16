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

        for key in ("HAKU_CURSOR_THEME", "HAKU_CURSOR_PALETTE"):
            self.env.pop(key, None)

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
        target = self.home / ".icons/Haku-Dark"
        target.mkdir(parents=True)
        (target / "custom").write_text("keep")
        result = self.run_shell(f'source "{ROOT}/lib/install_cursor.sh"; install_cursor')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unmanaged cursor", result.stderr)
        self.assertEqual((target / "custom").read_text(), "keep")

    def cursor_source(self):
        upstream = Path(os.environ.get("HAKUSPACE_TEST_CURSOR_SOURCE", ROOT.parent / "haku-cursor"))
        if not (upstream / "scripts/install.sh").is_file():
            self.skipTest("set HAKUSPACE_TEST_CURSOR_SOURCE to test the real upstream installer")
        source = self.home / "cursor-source"
        (source / "scripts").mkdir(parents=True)
        shutil.copy2(upstream / "scripts/install.sh", source / "scripts/install.sh")
        # Build fixtures cheaply; installation uses the current upstream script unchanged.
        (source / "Makefile").write_text("""STYLE ?= both
ANIM ?= all
.PHONY: dark light blue verify install
dark light blue:
\tpython3 build_fixture.py $@ $(STYLE) $(ANIM)
verify:
\t@echo verify >> calls
install:
\t@echo install $(THEME) >> calls
\t./scripts/install.sh $(THEME)
""")
        (source / "build_fixture.py").write_text("""from pathlib import Path
import os, sys
target, style, animation = sys.argv[1:]
with Path('calls').open('a') as out:
    out.write(f'build {target} {style} {animation}\\n')
styles = [target] if target in ('dark', 'light') else (['dark', 'light'] if style == 'both' else [style])
for variant in styles:
    name = 'Haku-' + target.capitalize() + ('-Light' if target not in ('dark', 'light') and variant == 'light' else '')
    name = os.environ.get('CURSOR_FIXTURE_NAME', name)
    directory = Path('dist') / name
    (directory / 'cursors').mkdir(parents=True, exist_ok=True)
    (directory / 'index.theme').write_text('[Icon Theme]\\n')
    (directory / 'cursors/left_ptr').write_bytes(b'new cursor')
""")
        self.env["HAKU_CURSOR_SOURCE"] = str(source)
        return source

    def install_cursor(self):
        return self.run_shell(f'source "{ROOT}/lib/install_cursor.sh"; install_cursor')

    def assert_selected_cursor(self, theme, target, style):
        source = self.cursor_source()
        result = self.install_cursor()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        selected = self.home / ".icons" / theme
        self.assertTrue((selected / "index.theme").is_file())
        self.assertTrue((selected / ".hakuspace-cursor").is_file())
        self.assertEqual({p.name for p in (self.home / ".icons").iterdir()}, {theme})
        self.assertFalse((self.home / "data/icons").exists())
        self.assertEqual((source / "calls").read_text().splitlines(),
                         [f"build {target} {style} all", "verify", f"install {theme}"])
        return source

    def test_default_cursor_is_dark(self):
        self.assert_selected_cursor("Haku-Dark", "dark", "dark")

    def test_light_cursor_is_exact(self):
        self.env["HAKU_CURSOR_THEME"] = "Haku-Light"
        self.assert_selected_cursor("Haku-Light", "light", "light")

    def test_blue_cursor_is_dark_only(self):
        self.env["HAKU_CURSOR_THEME"] = "Haku-Blue"
        self.assert_selected_cursor("Haku-Blue", "blue", "dark")

    def test_legacy_palette_installs_only_dark_theme(self):
        self.env["HAKU_CURSOR_PALETTE"] = "blue"
        self.assert_selected_cursor("Haku-Blue", "blue", "dark")

    def test_blue_light_cursor_is_light_only(self):
        self.env["HAKU_CURSOR_THEME"] = "Haku-Blue-Light"
        self.assert_selected_cursor("Haku-Blue-Light", "blue", "light")

    def assert_sibling_preserved(self, selected, sibling):
        self.env["HAKU_CURSOR_THEME"] = selected
        source = self.cursor_source()
        # A prior build may leave the unselected variant in dist as well.
        built_sibling = source / "dist" / sibling
        (built_sibling / "cursors").mkdir(parents=True)
        (built_sibling / "index.theme").write_text("upstream sibling")
        (built_sibling / "cursors/left_ptr").write_bytes(b"must not install")
        managed = self.home / ".icons" / selected
        managed.mkdir(parents=True)
        (managed / ".hakuspace-cursor").write_text("HakuSpace managed cursor v1\n")
        other = self.home / ".icons" / sibling
        (other / "cursors").mkdir(parents=True)
        (other / "index.theme").write_text("custom theme")
        (other / "cursors/left_ptr").write_bytes(b"user cursor")
        (other / "cursors/default").symlink_to("left_ptr")
        before = {p.relative_to(other): p.read_bytes() for p in other.rglob("*") if p.is_file()}
        result = self.install_cursor()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual({p.relative_to(other): p.read_bytes() for p in other.rglob("*") if p.is_file()}, before)
        self.assertTrue((other / "cursors/default").is_symlink())
        self.assertFalse((other / ".hakuspace-cursor").exists())

    def test_dark_update_preserves_unmanaged_light_sibling(self):
        self.assert_sibling_preserved("Haku-Blue", "Haku-Blue-Light")

    def test_light_update_preserves_unmanaged_dark_sibling(self):
        self.assert_sibling_preserved("Haku-Blue-Light", "Haku-Blue")

    def test_managed_cursor_rerun(self):
        self.assert_selected_cursor("Haku-Dark", "dark", "dark")
        result = self.install_cursor()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual({p.name for p in (self.home / ".icons").iterdir()}, {"Haku-Dark"})

    def test_legacy_palettes_and_explicit_theme_precedence(self):
        for palette in ("blue", "cyan", "green", "purple", "pink", "red", "orange", "yellow"):
            with self.subTest(palette=palette):
                self.env["HAKU_CURSOR_PALETTE"] = palette
                result = self.run_shell('resolve_cursor_theme; printf "%s %s %s" "$HAKU_CURSOR_THEME" "$CURSOR_BUILD_TARGET" "$CURSOR_STYLE"')
                self.assertEqual(result.stdout, f"Haku-{palette.capitalize()} {palette} dark", result.stderr)
        self.env.update(HAKU_CURSOR_THEME="Haku-Blue-Light", HAKU_CURSOR_PALETTE="pink")
        result = self.run_shell('resolve_cursor_theme; printf "%s %s %s" "$HAKU_CURSOR_THEME" "$CURSOR_BUILD_TARGET" "$CURSOR_STYLE"')
        self.assertEqual(result.stdout, "Haku-Blue-Light blue light", result.stderr)

    def test_missing_exact_build_is_refused_before_install(self):
        source = self.cursor_source()
        self.env["CURSOR_FIXTURE_NAME"] = "Haku-Unrelated"
        result = self.install_cursor()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Selected cursor was not built", result.stderr)
        self.assertNotIn("install", (source / "calls").read_text())
        self.assertFalse((self.home / ".icons").exists())

    def test_cursor_manifest_and_verification_use_home_icons(self):
        self.assert_selected_cursor("Haku-Dark", "dark", "dark")
        for relative in (".themes/Hikaide", ".icons/Hikaide-Symbols"):
            directory = self.home / relative
            directory.mkdir(parents=True)
            (directory / "index.theme").touch()
        self.env.update(HAKU_GTK_THEME_SOURCE=str(ROOT), HAKU_ICON_THEME_SOURCE=str(ROOT))
        result = self.run_shell(f'source "{ROOT}/lib/verify_assets.sh"; verify_assets; write_manifest; source "$ASSET_STATE_DIR/installed.env"; printf "%s\\n%s\\n" "$HAKU_CURSOR_THEME" "$HAKU_CURSOR_PATH"')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ["Haku-Dark", str(self.home / ".icons/Haku-Dark")])

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
