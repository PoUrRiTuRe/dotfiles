#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  patch-lock.py — fingerprint on the Serpantinum lock screen
#  (SUPER + L)
#
#  - the fingerprint reader listens AT THE SAME TIME as the password field
#  - animation: pulsing cyan ring → magenta check mark (success)
#                                   → red shake (finger rejected)
#
#  Requires: the PAM file /etc/pam.d/serpantinum-fprint (see README)
#
#  Usage:  python3 patch-lock.py            (apply)
#          python3 patch-lock.py --restore  (restore the original)
# ─────────────────────────────────────────────────────────────
import sys, shutil, pathlib

path = pathlib.Path.home() / ".local/share/serpantinum/src/quickshell/lock/Lock.qml"
backup = path.with_name("Lock.qml.orig")

if "--restore" in sys.argv:
    if not backup.exists():
        sys.exit("!! No Lock.qml.orig backup: nothing to restore.")
    shutil.copy2(backup, path)
    print("==> Original Lock.qml restored. Reload Serpantinum (SUPER + R).")
    sys.exit(0)

if not pathlib.Path("/etc/pam.d/serpantinum-fprint").exists():
    sys.exit("!! /etc/pam.d/serpantinum-fprint doesn't exist: create it first (see README).")

src = path.read_text(encoding="utf-8")
if "fprintPam" in src:
    sys.exit("==> Already patched. (--restore to go back to the original)")

FPRINT_BLOCK = '''    // [nebula] Fingerprint, in parallel with the password
    Timer {
        id: fprintStartTimer
        interval: 900
        onTriggered: {
            if (rootLock.locked && !root.isUnlocking && !fprintPam.active) {
                lockUI.fpState = "scanning";
                fprintPam.start();
            }
        }
    }

    Timer {
        id: fprintSuccessTimer
        interval: 650
        onTriggered: root.finishUnlock()
    }

    PamContext {
        id: fprintPam
        config: "serpantinum-fprint"

        onCompleted: (result) => {
            if (!rootLock.locked || root.isUnlocking) return;
            if (result === PamResult.Success) {
                lockUI.fpState = "success";
                fprintSuccessTimer.start();
            } else {
                lockUI.fpState = "fail";
                fprintStartTimer.restart();
            }
        }
    }

'''

OVERLAY = '''
                    // [nebula] Fingerprint indicator: ring → check mark
                    Item {
                        id: fpIndicator
                        z: 1000
                        width: 76
                        height: 76
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 60
                        visible: lockUI.fpState !== "idle"
                        property color accent: lockUI.fpState === "fail" ? "#ff0055"
                                             : (lockUI.fpState === "success" ? "#e600ff" : "#00f0ff")
                        Behavior on accent { ColorAnimation { duration: 250 } }
                        transform: Translate { id: fpShake; x: 0 }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: lockUI.fpState === "success" ? Qt.alpha(fpIndicator.accent, 0.25) : "transparent"
                            border.width: 3
                            border.color: fpIndicator.accent
                            Behavior on color { ColorAnimation { duration: 300 } }

                            SequentialAnimation on scale {
                                running: lockUI.fpState === "scanning"
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.08; duration: 900; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: lockUI.fpState === "success" ? String.fromCodePoint(0xF012C) : String.fromCodePoint(0xF0237)
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 38
                            color: fpIndicator.accent
                            scale: lockUI.fpState === "success" ? 1.15 : 1.0
                            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                        }

                        SequentialAnimation {
                            id: fpShakeAnim
                            NumberAnimation { target: fpShake; property: "x"; to: 10; duration: 50 }
                            NumberAnimation { target: fpShake; property: "x"; to: -10; duration: 50 }
                            NumberAnimation { target: fpShake; property: "x"; to: 6; duration: 50 }
                            NumberAnimation { target: fpShake; property: "x"; to: 0; duration: 50 }
                        }

                        Connections {
                            target: lockUI
                            function onFpStateChanged() {
                                if (lockUI.fpState === "fail") fpShakeAnim.restart();
                            }
                        }
                    }
'''

edits = [
    # 1. Fingerprint state
    (
        '        property string statusText: I18n.t("lock.status.locked")\n    }',
        '        property string statusText: I18n.t("lock.status.locked")\n'
        '        property string fpState: "idle"   // [nebula] idle / scanning / success / fail\n    }',
    ),
    # 2. On lock: start listening to the reader
    (
        "        pamActionTimer.start();\n        kbPollerRestartTimer.restart();\n    }",
        "        pamActionTimer.start();\n        kbPollerRestartTimer.restart();\n"
        "        fprintStartTimer.restart();   // [nebula] fingerprint\n    }",
    ),
    # 3. On unlock: release the reader
    (
        "        if (!rootLock.locked) return;\n        rootLock.locked = false;",
        "        if (!rootLock.locked) return;\n"
        "        if (fprintPam.active) fprintPam.abort();   // [nebula] release the reader\n"
        "        lockUI.fpState = \"idle\";\n"
        "        rootLock.locked = false;",
    ),
    # 4. The fingerprint PAM session
    (
        "    Process {\n        id: suspendProcess",
        FPRINT_BLOCK + "    Process {\n        id: suspendProcess",
    ),
    # 5. The animation, on top of the lock screen
    (
        "                    id: screenRoot\n                    anchors.fill: parent\n                    focus: true\n",
        "                    id: screenRoot\n                    anchors.fill: parent\n                    focus: true\n" + OVERLAY,
    ),
]

for old, new in edits:
    n = src.count(old)
    if n != 1:
        sys.exit(f"!! Expected snippet found {n} times (instead of once): Serpantinum may have changed.\n"
                 f"   {old.strip().splitlines()[0]}\n   Nothing was modified.")
    src = src.replace(old, new)

if not backup.exists():
    shutil.copy2(path, backup)
    print(f"==> Original saved: {backup.name}")
path.write_text(src, encoding="utf-8")
print("==> Lock.qml patched. Reload Serpantinum (SUPER + R), then test with SUPER + L.")
