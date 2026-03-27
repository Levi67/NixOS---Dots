import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../theme"

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            // Correct Quickshell Wayland properties
            WlrLayershell.namespace: "quickshell"
            //Wl.exclusiveZone: height 

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: layout.implicitHeight
            color: Theme.debugColor 

            RowLayout {
                id: layout
                anchors.fill: parent
                anchors.leftMargin: Theme.sideMargin
                anchors.rightMargin: Theme.sideMargin
                spacing: Theme.bubbleSpacing

                // SECTION 1: Left Side (Workspaces)
                Bubble {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.topMargin: Theme.verticalMargin
                    Layout.bottomMargin: Theme.verticalMargin
                    
                    Workspaces { }
                }

                // SECTION 2: Expanding Spacer 1
                Item {
                    Layout.fillWidth: true
                }

                // SECTION 3: Center (Clock)
                Bubble {
                    Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
                    Layout.topMargin: Theme.verticalMargin
                    Layout.bottomMargin: Theme.verticalMargin

                    Clock {
                        textColor: Theme.text
                        textSize: Theme.textSize
                    }
                }

                // SECTION 4: Expanding Spacer 2
                Item {
                    Layout.fillWidth: true
                }

                // SECTION 5: Symmetrical Balance 
                // Matches the width of Section 1 so the Clock is perfectly dead-center
                Item {
                    implicitWidth: 100 
                }
            }
        }
    }
}