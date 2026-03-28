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
        
        // 1. Invisible container to allow rounded corners
        color: "transparent" 

        WlrLayershell.namespace: "launcher"
        WlrLayershell.layer: WlrLayer.Overlay 
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        // 2. THE VISUAL SHELL (This is where the radius lives)
        Rectangle {
            anchors.fill: parent
            color: Theme.barBackground 
            radius: 20 // <--- WINDOW ROUNDNESS
            border.color: Theme.accent
            border.width: 1
            clip: true // Prevents children from drawing outside the rounded corners

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
                    placeholderTextColor: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.5)

                    color: Theme.text
                    font.pixelSize: Theme.textSize
                    verticalAlignment: TextInput.AlignVCenter 

                    background: Rectangle {
                        implicitHeight: Theme.bubbleHeight + 16 
                        color: Theme.barBackground
                        radius: 12 // Slightly rounder for the input box
                        border.color: parent.activeFocus ? Theme.accent : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.1)
                        border.width: 1
                    }

                    onTextChanged: list.currentIndex = 0 
                    Keys.onEscapePressed: Qt.quit()
                }

                // --- THE APP LIST ---
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Theme.gapSize
                    
                    boundsBehavior: Flickable.StopAtBounds 
                    flickDeceleration: 3000 
                    interactive: true
                    highlightFollowsCurrentItem: true
                    keyNavigationEnabled: true

                    model: DesktopEntries.applications.values.filter(app => 
                        app.name.toLowerCase().includes(searchInput.text.toLowerCase())
                    )

                    delegate: ItemDelegate {
                        id: delegateItem
                        width: list.width
                        height: Theme.bubbleHeight + Theme.padding 
                        
                        background: Rectangle {
                            color: parent.hovered ? Theme.inactiveWorkspace : "transparent"
                            radius: 8
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

                    // --- MOUSE WHEEL SPEED FIX ---
                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        acceptedButtons: Qt.NoButton 
                        
                        onWheel: (wheel) => {
                            // Calculates movement based on item height
                            let scrollStep = (Theme.bubbleHeight + Theme.padding + list.spacing) * 2;
                            
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