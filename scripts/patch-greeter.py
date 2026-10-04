#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  patch-greeter.py — fingerprint animation on the "nebula" SDDM greeter
#
#  Empty field + Enter → pulsing cyan ring (the reader waits for a finger)
#  Finger accepted     → magenta check mark, then the session opens
#  Finger rejected     → red shake
#
#  Usage:  sudo python3 patch-greeter.py            (apply)
#          sudo python3 patch-greeter.py --restore  (restore the original)
#  Test without logging out:
#     sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/nebula
# ─────────────────────────────────────────────────────────────
import os, sys, shutil, pathlib

path = pathlib.Path("/usr/share/sddm/themes/nebula/Main.qml")
if len(sys.argv) > 1 and sys.argv[-1].endswith(".qml"):   # test path
    path = pathlib.Path(sys.argv[-1])
backup = path.with_name("Main.qml.orig")

if os.geteuid() != 0 and str(path).startswith("/usr/"):
    sys.exit("!! Run it with sudo: sudo python3 patch-greeter.py")

if "--restore" in sys.argv:
    if not backup.exists():
        sys.exit("!! No Main.qml.orig backup: nothing to restore.")
    shutil.copy2(backup, path)
    print("==> Original Main.qml restored.")
    sys.exit(0)

src = path.read_text(encoding="utf-8")
if "fpState" in src:
    sys.exit("==> Already patched. (--restore to go back to the original)")

OVERLAY = '''    // [nebula] Fingerprint indicator: ring → check mark
    Item {
        id: fpIndicator
        z: 1000
        width: 76 * s
        height: 76 * s
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60 * s
        visible: root.fpState !== "idle"
        property color accent: root.fpState === "fail" ? root.cError
                             : (root.fpState === "success" ? root.cMagenta : root.cCyan)
        Behavior on accent { ColorAnimation { duration: 250 } }
        transform: Translate { id: fpShake; x: 0 }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: root.fpState === "success" ? Qt.alpha(fpIndicator.accent, 0.25) : "transparent"
            border.width: 3 * s
            border.color: fpIndicator.accent
            Behavior on color { ColorAnimation { duration: 300 } }

            SequentialAnimation on scale {
                running: root.fpState === "scanning"
                loops: Animation.Infinite
                NumberAnimation { to: 1.08; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.fpState === "success" ? String.fromCodePoint(0xF012C) : String.fromCodePoint(0xF0237)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 38 * s
            color: fpIndicator.accent
            scale: root.fpState === "success" ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        }

        SequentialAnimation {
            id: fpShakeAnim
            NumberAnimation { target: fpShake; property: "x"; to: 10 * s; duration: 50 }
            NumberAnimation { target: fpShake; property: "x"; to: -10 * s; duration: 50 }
            NumberAnimation { target: fpShake; property: "x"; to: 6 * s; duration: 50 }
            NumberAnimation { target: fpShake; property: "x"; to: 0; duration: 50 }
        }
    }

    Timer {
        id: fpResetTimer
        interval: 1500
        onTriggered: root.fpState = "idle"
    }

'''

edits = [
    # 1. Fingerprint state
    (
        '    property string errorMessage: ""\n',
        '    property string errorMessage: ""\n'
        '    property string fpState: "idle"   // [nebula] idle / scanning / success / fail\n',
    ),
    # 2. Empty field + Enter: the reader waits for a finger
    (
        "sddm.login(currentUser, pwd.text, root.sessionIndex);",
        'if (pwd.text === "") root.fpState = "scanning";   // [nebula] fingerprint\n'
        "                                    sddm.login(currentUser, pwd.text, root.sessionIndex);",
    ),
    # 3. Failure / success
    (
        "        function onLoginFailed() {\n",
        "        function onLoginSucceeded() {\n"
        '            if (root.fpState === "scanning") root.fpState = "success";   // [nebula]\n'
        "        }\n"
        "        function onLoginFailed() {\n"
        '            if (root.fpState === "scanning") {   // [nebula] finger rejected\n'
        '                root.fpState = "fail";\n'
        "                fpShakeAnim.restart();\n"
        "                fpResetTimer.restart();\n"
        "            }\n",
    ),
    # 4. The animation, at the bottom of the screen
    (
        "    Row {\n        id: mainLayout\n",
        OVERLAY + "    Row {\n        id: mainLayout\n",
    ),
]

for old, new in edits:
    n = src.count(old)
    if n != 1:
        sys.exit(f"!! Expected snippet found {n} times (instead of once): the theme may have changed.\n"
                 f"   {old.strip().splitlines()[0]}\n   Rien n'a été modifié.")
    src = src.replace(old, new)

if not backup.exists():
    shutil.copy2(path, backup)
    print(f"==> Original saved: {backup}")
path.write_text(src, encoding="utf-8")
print("==> nebula theme patched. Test it with:")
print("    sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/nebula")
