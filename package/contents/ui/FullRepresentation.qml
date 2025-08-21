/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.quicklaunch 1.0

Item {
    property real mediumSpacing: 1.5 * units.smallSpacing
    property real itemHeight: Math.max(units.iconSizes.smallMedium, theme.defaultFont.pixelSize)

    Layout.minimumWidth: widgetWidth
    Layout.maximumWidth: widgetWidth

    Layout.minimumHeight: itemHeight
    Layout.preferredHeight: listView.count > 0 ? (itemHeight + 2 * mediumSpacing) * listView.count : itemHeight
    Layout.maximumHeight: (itemHeight + 2 * mediumSpacing) * 15

    Component.onCompleted: {
        // trigger adding all sources already available
        for (var i in appsSource.sources) {
            appsSource.sourceAdded(appsSource.sources[i]);
        }
    }
    
    PlasmaCore.DataSource {
        id: appsSource
        engine: 'apps'

        onSourceAdded: {
            connectSource(source)
        }

        onSourceRemoved: {
            disconnectSource(source);
        }
    }
    
    Logic {
        id: kRun
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        
        ListView {
            id: listView
            anchors.fill: parent

            model: apps

            highlight: PlasmaComponents.Highlight {}
            highlightMoveDuration: 0
            highlightResizeDuration: 0

            focus: true
            keyNavigationWraps: true
            highlightFollowsCurrentItem: true

            delegate: Item {
                width: parent.width
                height: itemHeight + 2*mediumSpacing

                property bool isHovered: false

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        listView.currentIndex = index
                        isHovered = true
                    }
                    onExited: {
                        isHovered = false
                    }
                    onClicked: run()

                    Row {
                        x: mediumSpacing
                        y: mediumSpacing
                        width: parent.width - 2*mediumSpacing
                        height: itemHeight
                        spacing: mediumSpacing

                        Item { // Hack - since setting the dimensions of PlasmaCore.IconItem won't work
                            height: units.iconSizes.smallMedium
                            width: height
                            anchors.verticalCenter: parent.verticalCenter

                            PlasmaCore.IconItem {
                                anchors.fill: parent
                                source: appsSource.data[modelData].iconName
                                active: isHovered
                            }
                        }

                        PlasmaComponents.Label {
                            text: appsSource.data[modelData].name
                            width: parent.width - units.iconSizes.smallMedium - mediumSpacing
                            height: parent.height
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Keys.onReturnPressed: run()
        }

    }

    Keys.forwardTo: [listView]

    function run() {
        plasmoid.expanded = false

        const entry = listView.model[listView.currentIndex];
        kRun.openUrl("file:" + appsSource.data[entry].entryPath)
    }
}
