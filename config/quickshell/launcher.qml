import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "./theme"

ShellRoot {
    PanelWindow {
        id: launcher
        width: 600
        height: 700
        color: "transparent" 

        WlrLayershell.namespace: "launcher"
        WlrLayershell.layer: WlrLayer.Overlay 
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        Rectangle {
            anchors.fill: parent
            color: Theme.barBackground 
            radius: 20
            // Window border: 40% darker than accent
            border.color: Qt.darker(Theme.accent, 1.6) 
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.padding * 2.5 
                spacing: Theme.gapSize * 2

                // --- SEARCH INPUT ---
                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    focus: true
                    
                    leftPadding: Theme.padding * 2  
                    rightPadding: Theme.padding * 2 
                    topPadding: Theme.padding
                    bottomPadding: Theme.padding

                    placeholderText: "Search apps..."
                    placeholderTextColor: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.4)
                    color: Theme.text
                    font.pixelSize: Theme.textSize
                    verticalAlignment: TextInput.AlignVCenter 

                    background: Rectangle {
                        implicitHeight: Theme.bubbleHeight + 16 
                        color: Theme.barBackground
                        radius: 12
                        // Input border: 50% darker when focused
                        border.color: parent.activeFocus ? Qt.darker(Theme.accent, 1.5) : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.1)
                        border.width: 1
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            let results = DesktopEntries.applications.values.filter(app => 
                                app.name.toLowerCase().includes(searchInput.text.toLowerCase())
                            );
                            if (results.length > 0) {
                                results[0].execute();
                                Qt.quit();
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            Qt.quit();
                        }
                    }
                }

                // --- THE APP LIST ---
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Theme.gapSize
                    
                    model: DesktopEntries.applications.values.filter(app => 
                        app.name.toLowerCase().includes(searchInput.text.toLowerCase())
                    )

                    delegate: ItemDelegate {
                        id: delegateItem
                        width: list.width
                        height: Theme.bubbleHeight + Theme.padding 
                        
                        background: Rectangle {
                            color: hovered ? Theme.inactiveWorkspace : "transparent"
                            radius: 8
                            // Hover border: 60% darker for high contrast
                            border.width: hovered ? 1 : 0
                            border.color: Qt.darker(Theme.accent, 1.6)
                        }
                        
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.padding
                            anchors.rightMargin: Theme.padding
                            spacing: Theme.bubbleSpacing

                            IconImage {
                                source: Quickshell.iconPath(modelData.icon, true)
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignVCenter 
                            }
                            
                            Text {
                                text: modelData.name
                                color: Theme.text
                                font.pixelSize: Theme.fontSize
                                Layout.alignment: Qt.AlignVCenter 
                                verticalAlignment: Text.AlignVCenter
                                Layout.fillWidth: true
                            }
                        }

                        onClicked: {
                            modelData.execute();
                            Qt.quit();
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        acceptedButtons: Qt.NoButton 
                        onWheel: (wheel) => {
                            let scrollStep = (Theme.bubbleHeight + Theme.padding + list.spacing) * 3;
                            if (wheel.angleDelta.y > 0) {
                                list.contentY = Math.max(list.originY, list.contentY - scrollStep);
                            } else {
                                list.contentY = Math.min(list.contentHeight - list.height, list.contentY + scrollStep);
                            }
                        }
                    }
                }
            }
        }
    }
}