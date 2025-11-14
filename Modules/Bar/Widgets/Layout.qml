import QtQuick
import Quickshell
import qs.Commons
import qs.Services.Compositor
import qs.Services.UI
import qs.Modules.Bar.Extras

Item {
  id: root

  property ShellScreen screen

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var widgetMetadata: BarWidgetRegistry.widgetMetadata[widgetId]
  property var widgetSettings: {
    if (section && sectionWidgetIndex >= 0) {
      var widgets = Settings.data.bar.widgets[section]
      if (widgets && sectionWidgetIndex < widgets.length) {
        return widgets[sectionWidgetIndex]
      }
    }
    return {}
  }

  readonly property bool isBarVertical: Settings.data.bar.position === "left" || Settings.data.bar.position === "right"
  readonly property string displayMode: widgetSettings.displayMode !== undefined ? widgetSettings.displayMode : widgetMetadata.displayMode

  // Helper functions with error handling
  function getCurrentLayoutSymbol() {
    try {
      if (!CompositorService.backend) {
        Logger.w("Layout", "CompositorService.backend is null")
        return "?"
      }
      const symbol = CompositorService.backend.currentLayoutSymbol
      return symbol || "?"
    } catch (error) {
      Logger.e("Layout", "Error getting layout symbol:", error)
      return "?"
    }
  }

  function getCurrentLayoutName() {
    try {
      if (!CompositorService.backend) {
        return I18n.tr("layout.panel.no-compositor")
      }
      const name = CompositorService.backend.currentLayoutName
      return name || I18n.tr("layout.panel.unknown")
    } catch (error) {
      Logger.e("Layout", "Error getting layout name:", error)
      return I18n.tr("layout.panel.unknown")
    }
  }

  function initializeCompositorService() {
    try {
      if (CompositorService.backend && !CompositorService.backend.initialized) {
        Logger.i("Layout", "Initializing CompositorService backend")
        CompositorService.backend.initialize()
      }
    } catch (error) {
      Logger.e("Layout", "Error initializing CompositorService:", error)
    }
  }

  implicitWidth: pill.width
  implicitHeight: pill.height

  BarPill {
    id: pill

    density: Settings.data.bar.density
    oppositeDirection: BarService.getPillDirection(root)
    icon: "window"
    text: getCurrentLayoutSymbol()
    autoHide: false
    forceOpen: !isBarVertical && root.displayMode === "alwaysShow"
    forceClose: isBarVertical || root.displayMode === "alwaysHide"
    
    tooltipText: {
      const layoutName = getCurrentLayoutName()
      const symbol = getCurrentLayoutSymbol()
      if (symbol === "?") {
        return I18n.tr("layout.tooltip-unavailable")
      }
      return I18n.tr("layout.tooltip", {
        "layout": layoutName,
        "symbol": symbol
      })
    }

    onClicked: {
      try {
        // Open layout switcher panel
        const layoutPanel = PanelService.getPanel("layoutPanel", screen)
        if (layoutPanel) {
          layoutPanel.toggle(this)
        } else {
          Logger.w("Layout", "Layout panel not found")
        }
      } catch (error) {
        Logger.e("Layout", "Error handling click:", error)
      }
    }


  }

  // Watch for layout changes to update display
  Connections {
    target: CompositorService.backend
    function onCurrentLayoutSymbolChanged() {
      // Force re-evaluation of the text property
      pill.text = Qt.binding(getCurrentLayoutSymbol)
      Logger.i("Layout", "Layout symbol changed to:", getCurrentLayoutSymbol())
    }
    function onLayoutChanged() {
      Logger.i("Layout", "Layout changed to:", getCurrentLayoutName())
    }
  }

  Component.onCompleted: {
    initializeCompositorService()
    Logger.i("Layout", "Layout widget initialized")
  }
}