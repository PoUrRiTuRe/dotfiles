#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  patch-greeter.py — animation d'empreinte sur le greeter SDDM « nebula »
#
#  Champ vide + Entrée → anneau cyan qui pulse (le lecteur attend ton doigt)
#  Doigt reconnu      → coche magenta, puis ouverture de la session
#  Doigt refusé       → tremblement rouge
#
#  Usage :  sudo python3 patch-greeter.py            (applique)
#           sudo python3 patch-greeter.py --restore  (remet l'original)
#  Test sans se déconnecter :
#     sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/nebula
# ─────────────────────────────────────────────────────────────
import os, sys, shutil, pathlib

path = pathlib.Path("/usr/share/sddm/themes/nebula/Main.qml")
if len(sys.argv) > 1 and sys.argv[-1].endswith(".qml"):   # chemin de test
    path = pathlib.Path(sys.argv[-1])
backup = path.with_name("Main.qml.orig")

if os.geteuid() != 0 and str(path).startswith("/usr/"):
    sys.exit("!! Lance-le avec sudo : sudo python3 patch-greeter.py")

if "--restore" in sys.argv:
    if not backup.exists():
        sys.exit("!! Pas de sauvegarde Main.qml.orig : rien à restaurer.")
    shutil.copy2(backup, path)
    print("==> Main.qml d'origine restauré.")
    sys.exit(0)

src = path.read_text(encoding="utf-8")
if "fpState" in src:
    sys.exit("==> Déjà patché. (--restore pour revenir à l'original)")

OVERLAY = '''    // [rotten] Indicateur d'empreinte : anneau → coche
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
    # 1. État de l'empreinte
    (
        '    property string errorMessage: ""\n',
        '    property string errorMessage: ""\n'
        '    property string fpState: "idle"   // [rotten] idle / scanning / success / fail\n',
    ),
    # 2. Champ vide + Entrée : le lecteur attend le doigt
    (
        "sddm.login(currentUser, pwd.text, root.sessionIndex);",
        'if (pwd.text === "") root.fpState = "scanning";   // [rotten] empreinte\n'
        "                                    sddm.login(currentUser, pwd.text, root.sessionIndex);",
    ),
    # 3. Échec / succès
    (
        "        function onLoginFailed() {\n",
        "        function onLoginSucceeded() {\n"
        '            if (root.fpState === "scanning") root.fpState = "success";   // [rotten]\n'
        "        }\n"
        "        function onLoginFailed() {\n"
        '            if (root.fpState === "scanning") {   // [rotten] doigt refusé\n'
        '                root.fpState = "fail";\n'
        "                fpShakeAnim.restart();\n"
        "                fpResetTimer.restart();\n"
        "            }\n",
    ),
    # 4. L'animation, en bas de l'écran
    (
        "    Row {\n        id: mainLayout\n",
        OVERLAY + "    Row {\n        id: mainLayout\n",
    ),
]

for old, new in edits:
    n = src.count(old)
    if n != 1:
        sys.exit(f"!! Passage attendu trouvé {n} fois (au lieu d'une) : le thème a peut-être changé.\n"
                 f"   {old.strip().splitlines()[0]}\n   Rien n'a été modifié.")
    src = src.replace(old, new)

if not backup.exists():
    shutil.copy2(path, backup)
    print(f"==> Original sauvegardé : {backup}")
path.write_text(src, encoding="utf-8")
print("==> Thème nebula patché. Teste-le avec :")
print("    sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/nebula")
