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
        // 1. Increased the size
        width: 600
        height: 700
        
        // 2. Swapped hardcoded color for your Theme background
        color: Theme.barBackground 

        WlrLayershell.namespace: "launcher"

        WlrLayershell.layer: WlrLayer.Overlay 
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        ColumnLayout {
            anchors.fill: parent
            // Using your theme's padding multiplied to give it breathing room
            anchors.margins: Theme.padding * 2 
            spacing: Theme.gapSize * 2

            // SEARCH INPUT
TextField {
    id: searchInput
    Layout.fillWidth: true
    focus: true
    
    // 1. PADDING (The fix for the "weird" look)
    leftPadding: Theme.padding * 2  // Pushes text away from the left edge
    rightPadding: Theme.padding * 2 // Keeps it symmetrical on the right
    topPadding: Theme.padding
    bottomPadding: Theme.padding

    placeholderText: "Search apps..."
    // Using your theme text with 50% opacity for the placeholder
    placeholderTextColor: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.5)

    color: Theme.text
    font.pixelSize: Theme.textSize
    
    // Ensures the cursor and text are centered vertically in the box
    verticalAlignment: TextInput.AlignVCenter 

    background: Rectangle {
        // Ensuring the background is tall enough to feel like a search bar
        implicitHeight: Theme.bubbleHeight + 16 
        color: Theme.barBackground
        radius: 8
        
        // Adds a nice accent border when you are typing
        border.color: parent.activeFocus ? Theme.accent : "transparent"
        border.width: 1
    }

    onTextChanged: list.currentIndex = 0 
    Keys.onEscapePressed: Qt.quit()
}

            // THE APP LIST
            ListView {
    id: list
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    spacing: Theme.gapSize
    
    // 1. IMPROVE SCROLL FEEL
    // This allows the list to "bounce" at the ends (very smooth)
    boundsBehavior: Flickable.StopAtBounds 
    // Makes scrolling feel more like a phone/modern app
    flickDeceleration: 3000 
    // Ensure the mouse wheel actually moves the list
    interactive: true

    // 2. KEYBOARD NAVIGATION
    // This ensures that when you arrow down, the list scrolls automatically
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
        // This ensures the row takes up the full height of the delegate
        anchors.fill: parent
        anchors.leftMargin: Theme.padding
        anchors.rightMargin: Theme.padding
        spacing: Theme.bubbleSpacing

        IconImage {
            source: Quickshell.iconPath(modelData.icon, true)
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            // 1. Center the icon vertically
            Layout.alignment: Qt.AlignVCenter 
        }
        
        Text {
            text: modelData.name
            color: Theme.text
            font.pixelSize: Theme.fontSize
            // 2. Center the text vertically
            Layout.alignment: Qt.AlignVCenter 
            
            // 3. Optional: verticalAlignment inside the text box itself
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
        acceptedButtons: Qt.NoButton // Allows clicks to pass to the items below
        
        onWheel: (wheel) => {
            // Adjust '5' to make it faster or slower
            // Each "notch" on the wheel moves the list by 5 items worth of height
            let scrollStep = (Theme.bubbleHeight + Theme.padding + list.spacing) * 0.18;
            
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