// components/Bar.qml
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
            required property var modelData
            screen: modelData



            WlrLayershell.namespace: "quickshell"
            
            // Uncomment this to make windows respect your new bar size!
            // Wl.exclusiveZone: height 

            anchors {
                top: true
                left: true
                right: true
            }
    
            implicitHeight: layout.implicitHeight
            color: Theme.debugColor // Your debug color

            RowLayout {
                id: layout
                anchors.fill: parent
                
                // Use variable for side margins
                anchors.leftMargin: Theme.sideMargin
                anchors.rightMargin: Theme.sideMargin
                
                // Use variable for spacing between bubbles
                spacing: Theme.bubbleSpacing

                Bubble {
                    // Use variables for the vertical "push"
                    Layout.topMargin: Theme.verticalMargin
                    Layout.bottomMargin: Theme.verticalMargin
                    
                    Layout.alignment: Qt.AlignCenter

                    Clock {
                        textColor: Theme.text
                        textSize: Theme.textSize
                    }
                }
            }
        }
    }
}