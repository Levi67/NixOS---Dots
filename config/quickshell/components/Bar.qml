// components/Bar.qml
import Quickshell
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
      
      anchors {
        top: true
        left: true
        right: true
      }
      
      implicitHeight: 30

      RowLayout {
        anchors.fill: parent

        // FIXED: Remove the "UI." prefix. 
        // QML finds "Clock.qml" automatically because it's in the same folder.
        Clock {
          Layout.alignment: Qt.AlignRight

          textColor: Theme.base
          textSize: Theme.textSize
          // Note: Ensure Clock.qml has a property named textColor
          // or this will throw another error.
        }
      }
    }
  }

  // Your date process logic (Consider moving this into Clock.qml later!)
  Process {
    id: dateProc
    command: ["date"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.time = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}