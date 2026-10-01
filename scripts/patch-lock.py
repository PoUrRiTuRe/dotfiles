#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  patch-lock.py — empreinte digitale sur l'écran de verrouillage
#  de Serpantinum (SUPER + L)
#
#  - le lecteur d'empreinte écoute EN MÊME TEMPS que le champ mot de passe
#  - animation : anneau cyan qui pulse → coche magenta (succès)
#                                      → tremblement rouge (doigt refusé)
#
#  Prérequis : le fichier PAM /etc/pam.d/serpantinum-fprint (voir README)
#
#  Usage :  python3 patch-lock.py            (applique)
#           python3 patch-lock.py --restore  (remet l'original)
# ─────────────────────────────────────────────────────────────
import sys, shutil, pathlib

path = pathlib.Path.home() / ".local/share/serpantinum/src/quickshell/lock/Lock.qml"
backup = path.with_name("Lock.qml.orig")

if "--restore" in sys.argv:
    if not backup.exists():
        sys.exit("!! Pas de sauvegarde Lock.qml.orig : rien à restaurer.")
    shutil.copy2(backup, path)
    print("==> Lock.qml d'origine restauré. Recharge Serpantinum (SUPER + R).")
    sys.exit(0)

if not pathlib.Path("/etc/pam.d/serpantinum-fprint").exists():
    sys.exit("!! /etc/pam.d/serpantinum-fprint n'existe pas : crée-le d'abord (voir les instructions).")

src = path.read_text(encoding="utf-8")
if "fprintPam" in src:
    sys.exit("==> Déjà patché. (--restore pour revenir à l'original)")

FPRINT_BLOCK = '''    // [rotten] Empreinte digitale, en parallèle du mot de passe
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
                    // [rotten] Indicateur d'empreinte : anneau → coche
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
    # 1. État de l'empreinte
    (
        '        property string statusText: I18n.t("lock.status.locked")\n    }',
        '        property string statusText: I18n.t("lock.status.locked")\n'
        '        property string fpState: "idle"   // [rotten] idle / scanning / success / fail\n    }',
    ),
    # 2. Au verrouillage : démarrer l'écoute du lecteur
    (
        "        pamActionTimer.start();\n        kbPollerRestartTimer.restart();\n    }",
        "        pamActionTimer.start();\n        kbPollerRestartTimer.restart();\n"
        "        fprintStartTimer.restart();   // [rotten] empreinte\n    }",
    ),
    # 3. Au déverrouillage : libérer le lecteur
    (
        "        if (!rootLock.locked) return;\n        rootLock.locked = false;",
        "        if (!rootLock.locked) return;\n"
        "        if (fprintPam.active) fprintPam.abort();   // [rotten] libère le lecteur\n"
        "        lockUI.fpState = \"idle\";\n"
        "        rootLock.locked = false;",
    ),
    # 4. La session PAM d'empreinte
    (
        "    Process {\n        id: suspendProcess",
        FPRINT_BLOCK + "    Process {\n        id: suspendProcess",
    ),
    # 5. L'animation, par-dessus l'écran de verrouillage
    (
        "                    id: screenRoot\n                    anchors.fill: parent\n                    focus: true\n",
        "                    id: screenRoot\n                    anchors.fill: parent\n                    focus: true\n" + OVERLAY,
    ),
]

for old, new in edits:
    n = src.count(old)
    if n != 1:
        sys.exit(f"!! Passage attendu trouvé {n} fois (au lieu d'une) : Serpantinum a peut-être changé.\n"
                 f"   {old.strip().splitlines()[0]}\n   Rien n'a été modifié.")
    src = src.replace(old, new)

if not backup.exists():
    shutil.copy2(path, backup)
    print(f"==> Original sauvegardé : {backup.name}")
path.write_text(src, encoding="utf-8")
print("==> Lock.qml patché. Recharge Serpantinum (SUPER + R), puis teste avec SUPER + L.")
