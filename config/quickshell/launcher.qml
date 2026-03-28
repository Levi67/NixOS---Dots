import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland // <-- 1. Required for Layer Shell
import Quickshell.Widgets

ShellRoot {
// 2. Swapped FloatingWindow for PanelWindow
PanelWindow {
id: launcher
width: 400
height: 500
color: "#1e1e2e" // Catppuccin Mocha Background

    // 3. Put it in the Overlay layer so it floats above your normal windows
    WlrLayershell.layer: WlrLayer.Overlay 
    
    // 4. Request keyboard focus so you can actually type in your search input!
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        // 1. SEARCH INPUT
        TextField {
            id: searchInput
            Layout.fillWidth: true
            placeholderText: "Search apps..."
            focus: true
            onTextChanged: list.currentIndex = 0 
            
            // Close on Escape
            Keys.onEscapePressed: Qt.quit()
        }

        // 2. THE APP LIST
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            // MAGIC PART: Grabs .desktop files automatically
            model: DesktopEntries.applications.values.filter(app => 
                app.name.toLowerCase().includes(searchInput.text.toLowerCase())
            )

            delegate: ItemDelegate {
                width: list.width
                height: 40
                
                contentItem: RowLayout {
                    spacing: 10
                    IconImage {
                        source: Quickshell.iconPath(modelData.icon, true)
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                    }
                    Text {
                        text: modelData.name
                        color: "white"
                    }
                }

                // 3. EXECUTION
                onClicked: {
                    modelData.execute(); 
                    Qt.quit();           
                }
            }
        }
    }
}

}