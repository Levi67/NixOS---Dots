pragma Singleton
import QtQuick

QtObject {



    // Colors (Catppuccin Mocha example)
    readonly property color base: '#9393c3'
    readonly property color text: "#cdd6f4"
    readonly property color accent: '#162337'
    readonly property color red: "#f38ba8"

    readonly property color barBackground: Qt.rgba(accent.r, accent.g, accent.b, 0.7)
    
    // Spacing & Sizing
    //readonly property int barHeight: 40


    readonly property int bubbleHeight: 30


    readonly property int padding: 8
    readonly property int fontSize: 13

    // Text properties
    readonly property int textSize: 20

    // theme/Theme.qml
    readonly property int gapSize: 5
    readonly property int barPadding: 8

    // theme/Theme.qml
    // ... your colors ...

    // The actual height of the pill/bubble
    readonly property int barHeight: 26 

    // The transparent space above and below the bubble
    readonly property int verticalMargin: 8

    // The space from the screen edges (Left/Right)
    readonly property int sideMargin: 10 

    // The space between different bubbles
    readonly property int bubbleSpacing: 12

    //readonly property color debugColor: "#66bc4242"

    readonly property color debugColor: "transparent"
    
}