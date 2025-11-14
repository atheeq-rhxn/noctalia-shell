import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Rectangle {
  id: layoutButton

  property var layoutData: ({})
  property bool isCurrent: false
  signal clicked()

  radius: Style.radiusM
  color: isCurrent ? Qt.alpha(Color.mPrimary, 0.15) : (mouseArea.containsMouse ? Color.mSurfaceVariant : Color.mSurface)
  border.color: isCurrent ? Color.mPrimary : (mouseArea.containsMouse ? Color.mOutline : Qt.alpha(Color.mOutline, 0.6))
  border.width: isCurrent ? 2 : 1

  Behavior on color {
    ColorAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  Behavior on border.color {
    ColorAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  Scale {
    id: buttonScale
    target: layoutButton
    origin.x: width / 2
    origin.y: height / 2
    xScale: mouseArea.containsMouse ? 1.03 : 1.0
    yScale: mouseArea.containsMouse ? 1.03 : 1.0
  }

  Behavior on xScale {
    NumberAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  Behavior on yScale {
    NumberAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  ColumnLayout {
    anchors.centerIn: parent
    anchors.margins: Style.marginS
    spacing: Style.marginXS

    Rectangle {
      Layout.preferredWidth: 40
      Layout.preferredHeight: 40
      radius: Style.radiusS
      color: isCurrent ? Color.mPrimary : Color.mSurfaceVariant
      Layout.alignment: Qt.AlignHCenter

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
          easing.type: Easing.OutCubic
        }
      }

      NText {
        anchors.centerIn: parent
        text: layoutData.symbol || "?"
        pointSize: Style.fontSizeL
        color: isCurrent ? Color.mOnPrimary : Color.mOnSurfaceVariant
        font.weight: Style.fontWeightBold
      }
    }

    NText {
      text: layoutData.displayName || "Unknown"
      pointSize: Style.fontSizeXXS
      color: isCurrent ? Color.mPrimary : Color.mOnSurface
      font.weight: isCurrent ? Style.fontWeightSemiBold : Style.fontWeightMedium
      horizontalAlignment: Text.AlignHCenter
      Layout.fillWidth: true
      wrapMode: Text.WordWrap
      maximumLineCount: 2
      lineHeight: 1.3
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: layoutButton.clicked()
  }
}