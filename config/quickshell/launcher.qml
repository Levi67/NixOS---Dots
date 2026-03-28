import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

ShellRoot {
    FloatingWindow {
        id: launcher
        width: 400
        height: 500
        //anchors.centerIn: parent
        color: "#1e1e2e" // Catppuccin Mocha Background
        
        // This makes it act like a real launcher (closes when you click away)
        //flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

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
                
                // MAGIC PART: This grabs all your .desktop files automatically
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
                        modelData.execute(); // This starts the app!
                        Qt.quit();           // Closes the launcher
                    }
                }
            }
        }
    }
}