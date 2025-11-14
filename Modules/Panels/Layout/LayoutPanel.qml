import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Services.Compositor
import qs.Widgets
import qs.Modules.MainScreen

SmartPanel {
  id: root

  preferredWidth: Math.round(380 * Style.uiScaleRatio)
  preferredHeight: Math.round(520 * Style.uiScaleRatio)

  onOpened: {
    Logger.i("LayoutPanel", "Layout panel opened")
  }

  onClosed: {
    Logger.i("LayoutPanel", "Layout panel closed")
  }

  panelContent: Rectangle {
    color: Color.transparent

    property real contentPreferredHeight: Math.min(preferredHeight, Math.max(280 * Style.uiScaleRatio, mainColumn.implicitHeight + Style.marginL * 2))

    ColumnLayout {
      id: mainColumn
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM

      // Header
      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: headerRow.implicitHeight + Style.marginM * 2

        RowLayout {
          id: headerRow
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          NIcon {
            icon: "window"
            pointSize: Style.fontSizeXXL
            color: Color.mPrimary
          }

          NText {
            text: I18n.tr("layout.panel.title")
            pointSize: Style.fontSizeL
            font.weight: Style.fontWeightBold
            color: Color.mOnSurface
            Layout.fillWidth: true
          }

          NIconButton {
            icon: "close"
            tooltipText: I18n.tr("tooltips.close")
            baseSize: Style.baseWidgetSize * 0.8
            onClicked: {
              root.close()
            }
          }
        }
      }

      // Current Layout Display
      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: currentLayoutLayout.implicitHeight + Style.marginM * 2

        ColumnLayout {
          id: currentLayoutLayout
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          NText {
            text: I18n.tr("layout.panel.current")
            pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
            font.weight: Style.fontWeightMedium
            Layout.fillWidth: true
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            Rectangle {
              Layout.preferredWidth: 56
              Layout.preferredHeight: 56
              radius: Style.radiusS
              color: Qt.alpha(Color.mPrimary, 0.12)
              border.color: Color.mPrimary
              border.width: 2

              NText {
                anchors.centerIn: parent
                text: CompositorService.backend ? CompositorService.backend.currentLayoutSymbol || "?" : "?"
                pointSize: Style.fontSizeXL
                color: Color.mPrimary
                font.weight: Style.fontWeightBold
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: Style.marginXS

              NText {
                text: {
                  if (!CompositorService.backend) return I18n.tr("layout.panel.no-compositor")
                  const symbol = CompositorService.backend.currentLayoutSymbol
                  const layouts = CompositorService.backend.availableLayouts || []
                  const layout = layouts.find(l => l.symbol === symbol)
                  return layout ? layout.displayName : I18n.tr("layout.panel.unknown")
                }
                pointSize: Style.fontSizeM
                color: Color.mOnSurface
                font.weight: Style.fontWeightSemiBold
                Layout.fillWidth: true
              }

              NText {
                text: {
                  if (!CompositorService.backend) return ""
                  const symbol = CompositorService.backend.currentLayoutSymbol
                  const layouts = CompositorService.backend.availableLayouts || []
                  const layout = layouts.find(l => l.symbol === symbol)
                  return layout ? `${layout.displayName} layout` : I18n.tr("layout.panel.unknown")
                }
                pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
                Layout.fillWidth: true
              }
            }
          }
        }
      }

      // Layout Grid
      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: layoutGrid.implicitHeight + Style.marginM * 2

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginS

          NText {
            text: I18n.tr("layout.panel.available")
            pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
            font.weight: Style.fontWeightMedium
            Layout.fillWidth: true
          }

          GridLayout {
            id: layoutGrid
            Layout.fillWidth: true
            columns: 3
            columnSpacing: Style.marginS
            rowSpacing: Style.marginS

            Repeater {
              model: CompositorService.backend ? CompositorService.backend.availableLayouts : []
              delegate: LayoutButton {
                required property var modelData
                
                Layout.preferredWidth: (layoutGrid.width - (layoutGrid.columns - 1) * layoutGrid.columnSpacing) / layoutGrid.columns
                Layout.preferredHeight: 88
                Layout.fillWidth: true
                
                layoutData: modelData
                isCurrent: CompositorService.backend && CompositorService.backend.currentLayoutSymbol === modelData.symbol
                
                onClicked: {
                  try {
                    Logger.i("LayoutPanel", `Switching to layout: ${modelData.name}`)
                    CompositorService.backend.setLayout(modelData.name)
                    root.close()
                  } catch (e) {
                    Logger.e("LayoutPanel", "Failed to switch layout:", e)
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // Layout Button Component
  component LayoutButton: Rectangle {
    id: buttonRoot

    property var layoutData: ({})
    property bool isCurrent: false
    signal clicked()

    height: Style.baseWidgetSize * 1.3 * Style.uiScaleRatio
    radius: Style.radiusS
    color: {
      if (isCurrent) {
        return Qt.alpha(Color.mPrimary, 0.15)
      }
      if (mouseArea.containsMouse) {
        return Color.mSurfaceVariant
      }
      return Color.mSurface
    }
    border.color: {
      if (isCurrent) {
        return Color.mPrimary
      }
      if (mouseArea.containsMouse) {
        return Color.mOutline
      }
      return Qt.alpha(Color.mOutline, 0.6)
    }
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
      onClicked: buttonRoot.clicked()
    }
  }
}